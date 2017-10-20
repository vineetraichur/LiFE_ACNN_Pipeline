function prob_init(track_prob, dp, save_fe_prob1)

%% Build the file names for the diffusion data, the anatomical MRI.
dwiFile       = fullfile(lifeDemoDataPath('diffusion',dp),'life_demo_scan1_subject1_b2000_150dirs_stanford.nii.gz');
dwiFileRepeat = fullfile(lifeDemoDataPath('diffusion',dp),'life_demo_scan2_subject1_b2000_150dirs_stanford.nii.gz');
t1File        = fullfile(lifeDemoDataPath('anatomy',dp),  'life_demo_anatomy_t1w_stanford.nii.gz');

%% (1) Evaluate the Probabilistic CSD-based connectome.
% We will analyze first the CSD-based probabilistic tractography
% connectome.

fgFileName = track_prob;
% fgFileName    = fullfile(lifeDemoDataPath('tractography',dp), ...
%                 'life_demo_mrtrix_csd_lmax10_probabilistic.mat');

% The final connectome and data astructure will be saved with this name:
feFileName    = 'life_build_model_demo_CSD_PROB';

%% (1.1) Initialize the LiFE model structure, 'fe' in the code below. 
% This structure contains the forward model of diffusion based on the
% tractography solution. It also contains all the information necessary to
% compute model accuracry, and perform statistical tests. You can type
% help('feBuildModel') in the MatLab prompt for more information.
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,[],dwiFileRepeat,t1File);

fe_prob = fe;
save(save_fe_prob1, 'fe_prob', '-mat')

end