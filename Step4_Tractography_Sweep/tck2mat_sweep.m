function tck2mat_sweep(track_prob, track_det, track_tens)
disp('loading paths')
addpath(genpath('/ifs/loni/ccb/collabs/2017/ACNN/VineetRaichur_LiFE/LiFE_Libraries/life-vistasoft-master'))

in_fname  = {'output.SD_PROB.tck', 'output.SD_STREAM.tck', 'output.DT_STREAM.tck'};
out_fname = {track_prob, track_det, track_tens};

% parfor ii  = 1:length(in_fname)
% fg         = fgRead(in_fname{ii});
% fgFileName = out_fname{ii};
% fgWrite(fg,fgFileName);
% end

for ii  = 1:length(in_fname)
    fg = fgRead(in_fname{ii});
    fgFileName = out_fname{ii};
    fgWrite(fg,fgFileName);
end