function det_results(save_fe_det2, save_det, save_d, Figure_4, Figure_5, Figure_6)

load (save_fe_det2, '-mat')
fe = fe_det;

fe

det.tractography = 'Deterministic';

%% (2.3) Extract the RMSE of the model on the fitted data set. 
% We now use the LiFE structure and the fit to compute the error in each
% white-matter voxel spanned by the tractography model.
det.rmse   = feGet(fe,'vox rmse');

%% (2.4) Extract the RMSE of the model on the second data set. 
% Here we show how to compute the cross-valdiated RMSE of the tractography
% model in each white-matter voxel. We store this information for later use
% and to save computer memory.
det.rmsexv = feGetRep(fe,'vox rmse');

%% (2.5) Extract the Rrmse. 
% We show how to extract the ratio between the model prediction error
% (RMSE) and the test-retest reliability of the data.
det.rrmse  = feGetRep(fe,'vox rmse ratio');

%% (2.6) Extract the fitted weights for the fascicles. 
% The following line shows how to extract the weight assigned to each
% fascicle in the connectome.
det.w      = feGet(fe,'fiber weights');

save(save_det, 'det', '-mat')

%% (2.7) Plot a histogram of the RMSE. 
% We plot the histogram of  RMSE across white-mater voxels.
[fh(1), ~, ~] = plotHistRMSE(det,Figure_4);

%% (2.8) Plot a histogram of the RMSE ratio.
% As a reminder the Rrmse is the ratio between data test-retest reliability
% and model error (the quality of the model fit).
[fh(2), ~] = plotHistRrmse(det,Figure_5);

%% (2.9) Plot a histogram of the fitted fascicle weights. 
[fh(3), ~] = plotHistWeights(det,Figure_6);

%% Extract the coordinates of the white-matter voxels.
% We will use this later to compare probabilistic and deterministic models.
d.coords = feGet( fe, 'roi coords');
clear fe

save(save_d, 'd', '-mat')

end

% ---------- Local Plot Functions ----------- %
function [fh, rmse, rmsexv] = plotHistRMSE(info,Figure_4)
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

print(Figure_4,'-dpng')

end

function [fh, R] = plotHistRrmse(info,Figure_5)
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

print(Figure_5,'-dpng')

end

function [fh, w] = plotHistWeights(info,Figure_6)
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

print(Figure_6,'-dpng')

end