#!/bin/bash 

input_mri=$1
if [ -h "$input_mri" ]; then input_mri=$(readlink $1); fi

output_mri=$(readlink $2);

export FREESURFER_HOME=/usr/local/freesurfer-6

source $FREESURFER_HOME/SetUpFreeSurfer.sh

$FREESURFER_HOME/bin/mri_convert --out_orientation RAS $input_mri $output_mri 


# output_mri = $2;

# output_mri = $(readlink $2);

# output_mri = $2
# if [ -h "$output_mri" ]; then output_mri=$(readlink $2); fi