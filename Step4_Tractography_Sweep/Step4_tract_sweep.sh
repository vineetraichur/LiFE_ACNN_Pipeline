#!/bin/bash

#[ $PBS_O_WORKDIR ] && cd $PBS_O_WORKDIR
cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step4_Tractography_Sweep

export mrtrix_HOME=/usr/local/mrtrix-0.2.12/bin
export FREESURFER_HOME=/usr/local/freesurfer-6
export MATLABPATH=/usr/local/MATLAB/R2015b/bin

BGRAD="grad.b"

config_json=$1
readarray -t values < <(awk -F\" 'NF>=3 {print $4}' $config_json)

input_nii_gz=${values[10]}
BVECS=${values[9]}
BVALS=${values[8]}

echo $input_nii_gz
echo $BVECS
echo $BVECS

input_nii_gz=/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.nii.gz
BVECS=/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.bvecs
BVALS=/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.bvals

echo $input_nii_gz
echo $BVECS
echo $BVECS

wm_nii_gz=$2 #input from mri_convert module

tract_param=$3
# jq is a much better tool to process json files - need to update
readarray -t values < <(awk -F\" 'NF>=3 {print $4}' $tract_param)

LMAX=${values[5]}
NUMFIBERS=${values[6]}
MAXNUMFIBERSATTEMPTED=${values[7]}
DOPROB=${values[8]}
DOSTREAM=${values[9]}
DOTENSOR=${values[10]}

echo $LMAX

[ $DOPROB == "null" ] && DOPROB=true
[ $DOSTREAM == "null" ] && DOSTREAM=true
[ $DOTENSOR == "null" ] && DOTENSOR=true

track_prob_tck=$4 
track_det_tck=$5 
track_tens_tck=$6

#TODO - validate other fields?
#if [ $LMAX == "null" ]; then
#    echo "lmax is empty.. calculating max lmax to use #from .bvals"
#	LMAX=$(python $SERVICE_DIR/calculatelmax.py)
#fi
#echo "Using LMAX: $LMAX"

#echo "input_nii_gz:$input_nii_gz"
#echo "BGRAD:$BGRAD"

###################################################################################################
#
# convert .bvals .bvecs into a single .b
#
# sample .bvals
# 2000 2001 2002 2003 2004
# sample .bvecs
# 1 4 7 10 13
# 2 5 8 11 14
# 3 6 9 12 15
# sample output grad.b
# 1 2 3 2000
# 4 5 6 2001
# 7 8 9 2002
# 10 11 12 2003
# 13 14 15 2003

## transpose output w/ original at the top
cat $BVECS $BVALS | tr ',' ' ' | awk '
{ 
   for (i=1; i<=NF; i++)  {
       a[NR,i] = $i
   }
}
NF>p { p = NF }
END {    
   for(j=1; j<=p; j++) {
       str=a[1,j]
       for(i=2; i<=NR; i++){
           str=str" "a[i,j];
       }
       print str
   }
}' > $BGRAD
#
###################################################################################################

###################################################################################################
# This could be moved out of here and processed by a dedicated preprocessing (mrconvert) service 

echo "converting dwi input to mif (should take a few minutes)"
if [ -f dwi.mif ]; then
    echo "dwi.mif already exist... skipping"
else
    time $mrtrix_HOME/mrconvert --quiet $input_nii_gz dwi.mif
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################

echo "make brainmask from dwi data (about 18 minutes)"
if [ -f brainmask.mif ]; then
    echo "brainmask.mif already exist... skipping"
else
    time $mrtrix_HOME/average -quiet dwi.mif -axis 3 - | $mrtrix_HOME/threshold - - | $mrtrix_HOME/median3D -quiet - - | $mrtrix_HOME/median3D -quiet - brainmask.mif
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################

echo "dwi2tensor"
if [ -f dt.mif ]; then
    echo "dt.mif already exist... skipping"
else
    time $mrtrix_HOME/dwi2tensor -quiet dwi.mif -grad $BGRAD dt.mif 
fi

echo "tensor2FA"
if [ -f fa.mif ]; then
    echo "fa.mif already exist... skipping"
else
    time $mrtrix_HOME/tensor2FA -quiet dt.mif - | $mrtrix_HOME/mrmult -quiet - brainmask.mif fa.mif
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################

echo "erode"
if [ -f sf.mif ]; then
    echo "sf.mif already exist... skipping"
else
    time $mrtrix_HOME/erode -quiet brainmask.mif -npass 3 - | $mrtrix_HOME/mrmult -quiet fa.mif - - | $mrtrix_HOME/threshold -quiet - -abs 0.7 sf.mif
fi

echo "estimate response function"
if [ -f response.txt ]; then
    echo "response.txt already exist... skipping"
else
    time $mrtrix_HOME/estimate_response -quiet dwi.mif sf.mif -lmax 6 -grad $BGRAD response.txt
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################

# Generate white matter mask (wm.mii.gz) from t1(freesurfer output [mri/aseg.mgz]) used by tracking later 
#export MATLABPATH=$MATLABPATH:$SERVICE_DIR
#time matlab -nodisplay -nosplash -r main

echo "converting wm.nii.gz to wm.mif"
if [ -f wm.mif ]; then
    echo "wm.mif already exist... skipping"
else
    time $mrtrix_HOME/mrconvert --quiet $wm_nii_gz wm.mif
fi

###################################################################################################
# tensor tracking (DT_STREAM)

if [ $DOTENSOR == "true" ] ; then
    echo "generating DT_STREAM"
    #mrtrix doc says streamtrack/DT_STREAM doesn't need grad.. but without it, it fails
    #time $mrtrix_HOME/streamtrack -quiet DT_STREAM dwi.mif output.DT_STREAM.tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    time $mrtrix_HOME/streamtrack -quiet DT_STREAM dwi.mif $track_tens_tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################
# SD_PROB and SD_STREAM uses CSD lmax.N.mif (aka FOD?) (should take about 10 minutes to several hours - depending on lmax value) 

outfile=lmax.mif
if [ -f $outfile ]; then
    echo "$outfile already exist... skipping"
else
    echo "computing lmax"
    time $mrtrix_HOME/csdeconv dwi.mif -grad $BGRAD response.txt -lmax $LMAX -mask brainmask.mif $outfile
    ret=$?
    if [ ! $ret -eq 0 ]; then
        #curl -s -X POST -H "Content-Type: application/json" -d "{\"status\": \"failed\"}" ${SCA_PROGRESS_URL}.lmax > /dev/null
        echo $ret > finished
        exit $ret
    fi
fi

###################################################################################################
# streamtrack  (SD_STREAM)
if [ $DOSTREAM == "true" ] ; then
    echo "generating SD_STREAM"
    #time $mrtrix_HOME/streamtrack -quiet SD_STREAM lmax.mif output.SD_STREAM.tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    time $mrtrix_HOME/streamtrack -quiet SD_STREAM lmax.mif $track_det_tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo $ret > finished
        exit $ret
    fi
fi
curl -s -X POST -H "Content-Type: application/json" -d "{\"progress\": 1, \"status\": \"finished\"}" $progress_url > /dev/null

###################################################################################################
# streamtrack  (SD_PROB)
if [ $DOPROB == "true" ] ; then
    echo "generating SD_PROB"
    #time $mrtrix_HOME/streamtrack -quiet SD_PROB lmax.mif output.SD_PROB.tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    time $mrtrix_HOME/streamtrack -quiet SD_PROB lmax.mif $track_prob_tck -seed wm.mif -mask wm.mif -grad $BGRAD -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    ret=$?
    if [ ! $ret -eq 0 ]; then
        curl -s -X POST -H "Content-Type: application/json" -d "{\"status\": \"failed\"}" $progress_url > /dev/null
        echo $ret > finished
        exit $ret
    fi
fi
curl -s -X POST -H "Content-Type: application/json" -d "{\"progress\": 1, \"status\": \"finished\"}" $progress_url > /dev/null

###################################################################################################

#matlab -nodisplay -nosplash -nodesktop -r "tck2mat_pipe $track_prob $track_det $track_tens"
#if [ -f output.DT_STREAM.mat ] && [ -f output.SD_STREAM.mat ] && [ -f output.SD_PROB.mat ];
#then 
#   echo "all done"
#   echo 0 > finished
#else 
#   echo ".mat files missing"
#   echo 1 > finished
#   exit 1
#fi

echo "all done"
echo 0 > finished
