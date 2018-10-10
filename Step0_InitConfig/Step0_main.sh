#!/bin/bash 

pipe_config=$1

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step0_InitConfig

export MATLABPATH=/usr/local/MATLAB/R2018a/bin

matlab -nodisplay -nosplash -nodesktop -r "Step0_main $pipe_config"

exit
