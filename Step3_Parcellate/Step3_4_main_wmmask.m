function [] = Step3_4_main_wmmask(pipe_config_in, wmmask, wm_nifti, pipe_config_out)

addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/jsonlab-master'))
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master'))
% addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/spm8'))

cran_dir = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1'; % Project directory on Cranium
cd([cran_dir '/Step3_Parcellate'])

% load my own config.json
% config = loadjson('config.json');
% dt6config = loadjson(fullfile(config.dtiinit, '/dt6.json'));

dt6config = loadjson(pipe_config_in);
   
%% Create an MRTRIX .b file from the bvals/bvecs of the shell chosen to run
% mrtrix_bfileFromBvecs(fullfile(config.dtiinit,dt6config.files.alignedDwBvecs), fullfile(config.dtiinit,dt6config.files.alignedDwBvals), 'grad.b');
% mrtrix_bfileFromBvecs(dt6config.files.alignedDwBvecs, dt6config.files.alignedDwBvals, 'grad.b');
mrtrix_bfileFromBvecs(dt6config.trilin_bvecs, dt6config.trilin_bvals, 'grad.b'); % using paths stored in config.json

dt6config.gradb = [cran_dir '/Step3_Parcellate/grad.b'];
savejson('', dt6config, pipe_config_out); % Needed only if porting grad.b to Step 4

[out] = make_wm_mask(wmmask, wm_nifti);

%% Franco's code as is
% if isempty(getenv('SCA_SERVICE_DIR'))
%     disp('setting SCA_SERVICE_DIR to pwd')
%     setenv('SCA_SERVICE_DIR', pwd)
% end
% 
% disp('loading paths')
% %addpath(genpath('/N/u/hayashis/BigRed2/git/encode')) %not used?
% addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
% addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
% 
% % load my own config.json
% config = loadjson('config.json');
% dt6config = loadjson(fullfile(config.dtiinit, '/dt6.json'));
%     
% %% Create an MRTRIX .b file from the bvals/bvecs of the shell chosen to run
% mrtrix_bfileFromBvecs(fullfile(config.dtiinit,dt6config.files.alignedDwBvecs), fullfile(config.dtiinit,dt6config.files.alignedDwBvals), 'grad.b');
% 
% [ out ] = make_wm_mask(config);

