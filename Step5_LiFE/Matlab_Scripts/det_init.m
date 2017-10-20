function det_init(track_det, dp, save_fe_det1)

%% Build the file names for the diffusion data, the anatomical MRI.
dwiFile       = fullfile(lifeDemoDataPath('diffusion',dp),'life_demo_scan1_subject1_b2000_150dirs_stanford.nii.gz');
dwiFileRepeat = fullfile(lifeDemoDataPath('diffusion',dp),'life_demo_scan2_subject1_b2000_150dirs_stanford.nii.gz');
t1File        = fullfile(lifeDemoDataPath('anatomy',dp),  'life_demo_anatomy_t1w_stanford.nii.gz');

%% (2) Evaluate the Deterministic tensor-based connectome.
% We will now analyze the tensor-based Deterministic tractography
% connectome.

fgFileName = track_det;
% fgFileName    = fullfile(lifeDemoDataPath('tractography',dp), ...
%                 'life_demo_mrtrix_tensor_deterministic.mat');

% The final connectome and data astructure will be saved with this name:
feFileName    = 'life_build_model_demo_TENSOR_DET';

%% (2.1) Initialize the LiFE model structure, 'fe' in the code below. 
% This structure contains the forward model of diffusion based on the
% tractography solution. It also contains all the information necessary to
% compute model accuracry, and perform statistical tests. You can type
% help('feBuildModel') in the MatLab prompt for more information.
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,[],dwiFileRepeat,t1File);

fe

fe_det = fe;
save(save_fe_det1, 'fe_det', '-mat')

end