clear

cd('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_ACNN_Pipeline_Cranium/Step0_InitConfig')
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/jsonlab-master'))

% Step0_main
mcc -m -W main -T link:exe Step0_main.m