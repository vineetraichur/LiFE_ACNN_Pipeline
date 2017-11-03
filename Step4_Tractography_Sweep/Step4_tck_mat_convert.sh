#!/bin/bash

cd /ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_ACNN_Pipeline_Cranium/Step4_Tractography_Sweep

export MATLABPATH=/usr/local/MATLAB/R2015b/bin

track_prob_tck=$1
track_det_tck=$2 
track_tens_tck=$3

track_prob=$4
track_det=$5
track_tens=$6

matlab -nodisplay -nosplash -nodesktop -r "tck2mat_sweep $track_prob_tck $track_det_tck $track_tens_tck $track_prob $track_det $track_tens"

