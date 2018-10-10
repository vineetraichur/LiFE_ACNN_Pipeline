#!/bin/bash

pipe_config_in=$1
t1_1out=$2
pipe_config_out=$3

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step1_Autoalign

export MATLABPATH=/usr/local/MATLAB/R2018a/bin

matlab -nodisplay -nosplash -nodesktop -r "Step1_main $pipe_config_in $t1_1out $pipe_config_out"

exit
