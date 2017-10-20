
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life_demo_data'))

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-master'))

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master'))

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/mba-master'))

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LIFE_LONI_Cranium/Matlab_Scripts'))

cd('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LIFE_LONI_Cranium/Exectuables')

mcc -m -v det_init.m

% mcc -m -v det_fit.m

% mcc -m -v det_results.m

mcc -m -v prob_init.m

% mcc -m -v prob_fit.m

% mcc -m -v prob_results.m

% mcc -m -v life_compare.m