function prob_results(track_prob, dp, save_fe_prob2, Figure_1, Figure_2, Figure_3, save_prob, save_p)

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

%%
load (save_fe_prob2, '-mat')
fe = fe_prob;

fe

prob.tractography = 'Probabilistic';

%% (1.3) Extract the RMSE of the model on the fitted data set. 
% We now use the LiFE structure and the fit to compute the error in each
% white-matter voxel spanned by the tractography model.
prob.rmse   = feGet(fe,'vox rmse');

%% (1.4) Extract the RMSE of the model on the second data set. 
% Here we show how to compute the cross-valdiated RMSE of the tractography
% model in each white-matter voxel. We store this information for later use
% and to save computer memory.
prob.rmsexv = feGetRep(fe,'vox rmse');

%% (1.5) Extract the Rrmse. 
% We show how to extract the ratio between the model prediction error
% (RMSE) and the test-retest reliability of the data.
prob.rrmse  = feGetRep(fe,'vox rmse ratio');

%% (1.6) Extract the fitted weights for the fascicles. 
% The following line shows how to extract the weight assigned to each
% fascicle in the connectome.
prob.w      = feGet(fe,'fiber weights');

save(save_prob, 'prob', '-mat')

%% (1.7) Plot a histogram of the RMSE. 
% We plot the histogram of  RMSE across white-mater voxels.
[fh(1), ~, ~] = plotHistRMSE(prob, Figure_1);

%% (1.8) Plot a histogram of the RMSE ratio.
% As a reminder the Rrmse is the ratio between data test-retest reliability
% and model error (the quality of the model fit).
[fh(2), ~] = plotHistRrmse(prob, Figure_2);

%% (1.9) Plot a histogram of the fitted fascicle weights. 
[fh(3), ~] = plotHistWeights(prob, Figure_3);
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,[],dwiFileRepeat,t1File);

%% Extract the coordinates of the white-matter voxels
% We will use this later to compare probabilistic and deterministic models.
p.coords = feGet(fe,'roi coords');
clear fe

save(save_p, 'p', '-mat')

end

% ---------- Local Plot Functions ----------- %
function [fh, rmse, rmsexv] = plotHistRMSE(info, Figure_1)
% Make a plot of the RMSE:
rmse   = info.rmse;
rmsexv = info.rmsexv;

figName = sprintf('%s - RMSE',info.tractography);
fh = mrvNewGraphWin(figName);
[y,x] = hist(rmse,50);
plot(x,y,'k-');
hold on
[y,x] = hist(rmsexv,50);
plot(x,y,'r-');
set(gca,'tickdir','out','fontsize',14,'box','off');
title('Root-mean squared error distribution across voxels','fontsize',14);
ylabel('number of voxels','fontsize',14);
xlabel('rmse (scanner units)','fontsize',14);
legend({'RMSE fitted data set','RMSE cross-validated'},'fontsize',14);

print(Figure_1,'-dpng')

end

function [fh, R] = plotHistRrmse(info, Figure_2)
% Make a plot of the RMSE Ratio:

R       = info.rrmse;
figName = sprintf('%s - RMSE RATIO',info.tractography);
fh      = mrvNewGraphWin(figName);
[y,x]   = hist(R,linspace(.5,4,50));
plot(x,y,'k-','linewidth',2);
hold on
plot([median(R) median(R)],[0 1200],'r-','linewidth',2);
plot([1 1],[0 1200],'k-');
set(gca,'tickdir','out','fontsize',14,'box','off');
title('Root-mean squared error ratio','fontsize',14);
ylabel('number of voxels','fontsize',14);
xlabel('R_{rmse}','fontsize',14);
legend({sprintf('Distribution of R_{rmse}'),sprintf('Median R_{rmse}')});

print(Figure_2,'-dpng')

end

function [fh, w] = plotHistWeights(info, Figure_3)
% Make a plot of the weights:

w       = info.w;
figName = sprintf('%s - Distribution of fascicle weights',info.tractography);
fh      = mrvNewGraphWin(figName);
[y,x]   = hist(w( w > 0 ),logspace(-5,-.3,40));
semilogx(x,y,'k-','linewidth',2)
set(gca,'tickdir','out','fontsize',14,'box','off')
title( ...
    sprintf('Number of fascicles candidate connectome: %2.0f\nNumber of fascicles in optimized connetome: %2.0f' ...
    ,length(w),sum(w > 0)),'fontsize',14)
ylabel('Number of fascicles','fontsize',14)
xlabel('Fascicle weight','fontsize',14)

print(Figure_3,'-dpng')

end
