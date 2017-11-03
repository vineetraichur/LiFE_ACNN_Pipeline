function Step2_main(pipe_config_in, pipe_config_out)

cd('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_ACNN_Pipeline_Cranium/Step2_RemoveArtifacts')

% load my own config.json
% load (pipe_config_in, '-mat')
config = loadjson(pipe_config_in);

config 

% to find resolution
dwi = niftiRead(config.dwi);
res = dwi.pixdim(1:3);
clear dwi

% run dtiInit
% https://github.com/vistalab/vistasoft/blob/master/mrDiffusion/dtiInit/dtiInitParams.m
dwParams = dtiInitParams(...
    'clobber',1, ...
    'phaseEncodeDir',2, ...
    'bvecsFile',config.bvecs, ...
    'bvalsFile',config.bvals, ...
    'dt6BaseName','dti_trilin', ...
    'outDir', pwd, ...
    'dwOutMm', res ...
);

dtiInit(config.dwi, config.t1, dwParams)

%% Update and save config file with outputs from step 2
stp2_dir = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_ACNN_Pipeline_Cranium/Step2_RemoveArtifacts'; % or pwd
config.trilin_bvals = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_aligned_trilin.bvals');
config.trilin_bvecs = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_aligned_trilin.bvecs');
config.trilin_nii = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_aligned_trilin.nii.gz');
config.trilin_acpcXform = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_aligned_trilin_acpcXform.mat');
config.trilin_ecXform = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_aligned_trilin_ecXform.mat');
config.b0_nii = strcat(stp2_dir, '/life_demo_scan1_subject1_b2000_150dirs_stanford_b0.nii.gz');

% save(pipe_config_out, 'config', '-mat')
savejson('', config, pipe_config_out); % saves teh matlab struct file as a json file

return

