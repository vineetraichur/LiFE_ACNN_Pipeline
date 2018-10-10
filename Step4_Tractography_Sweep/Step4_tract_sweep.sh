#!/bin/bash

#[ $PBS_O_WORKDIR ] && cd $PBS_O_WORKDIR
cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step4_Tractography_Sweep

export mrtrix_HOME=/usr/local/mrtrix-0.2.12/bin
export FREESURFER_HOME=/usr/local/freesurfer-6
export MATLABPATH=/usr/local/MATLAB/R2018a/bin
#module load python

BGRAD="grad.b"

config_json=$1
input_nii_gz=`jq -r '.trilin_nii' $config_json`
BVECS=`jq -r '.trilin_bvecs' $config_json`
BVALS=`jq -r '.trilin_bvals' $config_json`

echo $input_nii_gz

wm_nii_gz=$2 #input from freesurfer

echo $wm_nii_gz

tract_param=$3
LMAX=`jq -r '.lmax' $tract_param`
NUMFIBERS=`jq -r '.fibers' $tract_param`
MAXNUMFIBERSATTEMPTED=`jq -r '.fibers_max' $tract_param`
DOPROB=`jq -r '.do_probabilistic' $tract_param`
DOSTREAM=`jq -r '.do_deterministic' $tract_param`
DOTENSOR=`jq -r '.do_tensor' $tract_param`

echo $LMAX

[ $DOPROB == "null" ] && DOPROB=true
[ $DOSTREAM == "null" ] && DOSTREAM=true
[ $DOTENSOR == "null" ] && DOTENSOR=true

track_prob_tck=$4 
track_det_tck=$5 
track_tens_tck=$6

#TODO - validate other fields?
#if [ $LMAX == "null" ]; then
#    echo "lmax is empty.. calculating max lmax to use from .bvals"
#	LMAX=$(python calculatelmax.py)
#fi
#
#echo "Using LMAX: $LMAX"

###################################################################################################
#generate grad.b from bvecs/bvals
#dtiinit=`jq -r '.dtiinit' config.json`
#export input_nii_gz=$dtiinit/`jq -r '.files.alignedDwRaw' $dtiinit/dt6.json`
#export BVECS=$dtiinit/`jq -r '.files.alignedDwBvecs' $dtiinit/dt6.json`
#export BVALS=$dtiinit/`jq -r '.files.alignedDwBvals' $dtiinit/dt6.json`

#load bvals/bvecs
bvals=$(cat $BVALS)
bvecs_x=$(cat $BVECS | head -1)
bvecs_y=$(cat $BVECS | head -2 | tail -1)
bvecs_z=$(cat $BVECS | tail -1)

#convert strings to array of numbers
bvecs_x=($bvecs_x)
bvecs_y=($bvecs_y)
bvecs_z=($bvecs_z)

#output grad.b
i=0
true > grad.b
for bval in $bvals; do
    echo ${bvecs_x[$i]} ${bvecs_y[$i]} ${bvecs_z[$i]} $bval >> grad.b
    i=$((i+1))
done

###################################################################################################
# Generate white matter mask (wm.mii.gz) from t1(freesurfer output [mri/aseg.mgz]) used by tracking later 

if [ ! -f wm.nii.gz ]; then
        echo "starting matlab to create wm.nii.gz"
        time matlab -nodisplay -nosplash -r "make_wm_mask $wm_nii_gz"
fi

echo "converting wm.nii.gz to wm.mif"
if [ -f wm.mif ]; then
    echo "wm.mif already exist... skipping"
else
    time $mrtrix_HOME/mrconvert --quiet wm.nii.gz wm.mif
    ret=$?
    if [ ! $ret -eq 0 ]; then
        echo "failed to mrconver wm.nii.gz to wm.mif"
        echo $ret > finished
        exit $ret
    fi
fi

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
# convert various mif files to .nii.gz to generate neuro/dwi/recon (Diffusion Signal Voxel Reconstruction Model) data product
#response.txt > same
echo "creating neuro/dwi/recon datatype"
$mrtrix_HOME/mrconvert lmax.mif csd.nii.gz
$mrtrix_HOME/mrconvert fa.mif fa.nii.gz
$mrtrix_HOME/mrconvert dt.mif dt.nii.gz
$mrtrix_HOME/mrconvert wm.mif whitematter.nii.gz
$mrtrix_HOME/mrconvert brainmask.mif brainmask.nii.gz

echo "all done"
echo 0 > finished
