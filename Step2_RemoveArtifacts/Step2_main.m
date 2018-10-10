function Step2_main(pipe_config_in, pipe_config_out)

% Loading all the supporting software tool libraries 
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/jsonlab-master'))
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master'))
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/spm8'))
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/encode-Batch_Karst'))
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/app-dtiinit-master'))

cran_dir = '/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Pipeline_Cranium_BLSubj1'; % Project directory on Cranium
cd([cran_dir '/Step2_RemoveArtifacts'])

% load my own config.json
% load (pipe_config_in, '-mat')
config = loadjson(pipe_config_in);

% to find resolution
if ~isfield(config,'resolution')
    disp('resolution not set.. setting it to default value')
    set(config, 'resolution', 'default')
end

disp('loading dwi resolution')
if strcmp(config.resolution,'default')
    dwi = niftiRead(config.dwi);
    res = dwi.pixdim(1:3);
else
    res = str2num(config.resolution);
end
clear dwi

dwParams = dtiInitParams;
dwParams.eddyCorrect       = -1;
dwParams.rotateBvecsWithRx = 0;
dwParams.rotateBvecsWithCanXform = 0;
dwParams.phaseEncodeDir    = str2num(config.phaseEncodeDir); 
dwParams.clobber           =  1;
dwParams.bvecsFile  = config.bvecs;
dwParams.bvalsFile  = config.bvals;
dwParams.dt6BaseName = 'dti';
dwParams.outDir = '.';
dwParams.dwOutMm    = res;

%apply config params
if isfield(config, 'eddyCorrect')
    dwParams.eddyCorrect = str2double(config.eddyCorrect); % new value is 1
    dwParams.rotateBvecsWithRx = config.rotateBvecsWithRx; % new value is 'false', code is expecting a number
    dwParams.rotateBvecsWithCanXform = config.rotateBvecsWithCanXform; % new value is 'false', code is expecting a number
end

% %dump paths to be used
dtiInitDir(config.dwi, dwParams)

[dt6FileName, outBaseDir] = dtiInit(config.dwi, config.t1, dwParams);

% disp('creating dt6.json')
% % savejson('', load(dt6FileName{1}), 'dt6.json');
% savejson('', load(dt6FileName{1}), dt6json_out);

%% Update and save config file with outputs from step 2
%config.trilin_bvals = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.bvals']; 
%config.trilin_bvecs = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.bvecs'];
%config.trilin_nii = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin_noMEC.nii.gz'];

config.trilin_bvals = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin.bvals']; 
config.trilin_bvecs = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin.bvecs'];
config.trilin_nii = [cran_dir '/Step2_RemoveArtifacts/dwi_aligned_trilin.nii.gz'];

% save(pipe_config_out, 'config', '-mat')
savejson('', config, pipe_config_out); % saves teh matlab struct file as a json file

return

