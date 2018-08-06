#!/bin/bash

config_json=$1
track_tck=$2
output_fe=$3
output_json=$4

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step5_LiFE_new

export MATLABPATH=/usr/local/MATLAB/R2015b/bin

matlab -nodisplay -nosplash -nodesktop -r "main $config_json $track_tck $output_fe $output_json"

exit
