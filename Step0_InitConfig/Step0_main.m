function Step0_main(pipe_config)

config = struct; % Initializing the matlab structure file that will contain locations of all files read/written in the pipeline

config.t1 = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life_demo_data/data/anatomy/life_demo_anatomy_t1w_stanford.nii.gz';
config.coords = [0,0,0; 0,-16,0; 0,-8,40];
config.dwi = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life_demo_data/data/diffusion/life_demo_scan1_subject1_b2000_150dirs_stanford.nii.gz';
config.bvecs = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life_demo_data/data/diffusion/life_demo_scan1_subject1_b2000_150dirs_stanford.bvecs';
config.bvals = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life_demo_data/data/diffusion/life_demo_scan1_subject1_b2000_150dirs_stanford.bvals';
config.MNI_template = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master/mrDiffusion/templates/MNI_T1.nii.gz';

% save(pipe_config, 'config', '-mat')
savejson('', config, pipe_config); % saves teh matlab struct file as a json file

end