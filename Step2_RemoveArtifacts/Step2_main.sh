#!/bin/bash

pipe_config_in=$1
pipe_config_out=$2

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step2_RemoveArtifacts

export MATLABPATH=/usr/local/MATLAB/R2018a/bin

matlab -nosplash -nodesktop -r "Step2_main $pipe_config_in $pipe_config_out"

exit
