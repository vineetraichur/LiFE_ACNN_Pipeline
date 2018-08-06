#!/bin/bash

pipe_config_in=$1
wmmask=$2
wm_nifti=$3
pipe_config_out=$4

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step3_Parcellate

export MATLABPATH=/usr/local/MATLAB/R2015b/bin

matlab -nodisplay -nosplash -nodesktop -r "Step3_4_main_wmmask $pipe_config_in $wmmask $wm_nifti $pipe_config_out"

exit
