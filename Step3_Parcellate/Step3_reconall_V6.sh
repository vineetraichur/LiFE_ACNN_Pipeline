#!/bin/bash 

input_vol=$1
subject_id=$2
subject_dir=$3
wm_ni_gz=$4

echo $3

#save_aseg=$4
#if [ -h "$save_aseg" ]; then save_aseg=$(readlink $4); fi

echo "The subject ID: $subject_id"

export SUBJECTS_DIR=$subject_dir
export FREESURFER_HOME=/usr/local/freesurfer-6
#export FREESURFER_HOME=/usr/local/freesurfer-5.3.0_64bit
source $FREESURFER_HOME/SetUpFreeSurfer.sh

$FREESURFER_HOME/bin/recon-all -all -3T -sd $subject_dir/ -subjid $subject_id  -i $input_vol -no-isrunning 

#cp ${subject_dir}/${subject_id}/mri/aseg.mgz ${save_aseg}

#Converting aseg.mgz 
$FREESURFER_HOME/bin/mri_convert --out_orientation RAS ${subject_dir}/${subject_id}/mri/aseg.mgz $wm_ni_gz

exit $?
