#!/bin/bash

config_json=$1
track_tck=$2
plotdata_json=$3
output_fe=$4
output_json=$5
out_product_json=$6

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1/Step5_LiFE_new

export MATLABPATH=/usr/local/MATLAB/R2018a/bin

matlab -nodisplay -nosplash -nodesktop -r "main $config_json $track_tck $plotdata_json $output_fe $output_json $out_product_json"

exit