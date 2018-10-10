function Step0_main(pipe_config)

cran_dir = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE'; % Project directory on Cranium
cd([cran_dir '/LiFE_Pipeline_Cranium_BLSubj1/Step0_InitConfig'])

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/jsonlab-master'))

config = struct; % Initializing the matlab structure file that will contain locations of all files read/written in the pipeline

config.t1 = [cran_dir '/BrainLife_Subj1_data/BLSubj1_Data/Anatomy/t1.nii.gz'];
config.coords = [0,0,0; 0,-16,0; 0,-8,40];
config.dwi = [cran_dir '/BrainLife_Subj1_data/BLSubj1_Data/Diffusion/dwi.nii.gz'];
config.bvecs = [cran_dir '/BrainLife_Subj1_data/BLSubj1_Data/Diffusion/dwi.bvecs'];
config.bvals = [cran_dir '/BrainLife_Subj1_data/BLSubj1_Data/Diffusion/dwi.bvals'];
config.MNI_template = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master/mrDiffusion/templates/MNI_T1.nii.gz';
config.eddyCorrect = '1';
config.rotateBvecsWithRx = 'false';
config.rotateBvecsWithCanXform = 'false';
config.resolution = 'default';
config.phaseEncodeDir = '2';

savejson('', config, pipe_config); % saves teh matlab struct file as a json file

end