clear 
clc

% Loading all the supporting software tool libraries 
addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\jsonlab-master'))
addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\life-vistasoft-master'))
addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\spm8'))
addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\encode-master'))

config = loadjson('config.json');

%% Step 1: app-autoalignacpc-master
% % Obtained from: https://github.com/brain-life/app-autoalignacpc/blob/master/main.m
% addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\Pre-process_DiffData\app-autoalignacpc-master'))
% 
% config.t1 = 'C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\life_demo_data\data\anatomy\life_demo_anatomy_t1w_stanford.nii.gz';
% % When json file is read, backslash (\) sign used in folder location specifications on windows machines gets dropped. 
% % So I am specifying these folder locations again in the matlab code (e.g., config.t1). 
% % This should not be an issue on linux machines becuase slash (/) used in folder locations specifications don't get dropped
% 
% main(config)

%% Step 2: app-dtiinit-master
addpath(genpath('C:\Users\vineetr\Google Drive\ACNN\Pre-process_DiffData\app-dtiinit-master'))
config.dwi = 'C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\life_demo_data\data\diffusion\life_demo_scan1_subject1_b2000_150dirs_stanford.nii.gz';
config.bvecs = 'C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\life_demo_data\data\diffusion\life_demo_scan1_subject1_b2000_150dirs_stanford.bvecs';
config.bvals = 'C:\Users\vineetr\Google Drive\ACNN\LiFE_Libraries\life_demo_data\data\diffusion\life_demo_scan1_subject1_b2000_150dirs_stanford.bvals';

main(config)

%% Step 3: app-freesurfer-master
% Obtained from: https://github.com/brain-life/app-freesurfer/blob/master/template.pbs

%% Step 4: app-tracking-master
% Obtained from: https://github.com/brain-life/app-tracking/blob/master/main.m

%% Step 5: app-life-master
% Obtained from: https://github.com/brain-life/app-life/blob/master/main.m