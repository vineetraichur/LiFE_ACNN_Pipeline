function life_compare(save_prob, save_det, save_p, save_d, Figure_7, Figure_8, Figure_9)

load (save_prob, '-mat')
load (save_det, '-mat')
load (save_p, '-mat')
load(save_d, '-mat')

%% (3) Compare the quality of fit of Probabilistic and Deterministic connectomes.
%% (3.1) Find the common coordinates between the two connectomes.
%
% The two tractography method might have passed through slightly different
% white-matter voxels. Here we find the voxels where both models passed. We
% will compare the error only in these common voxels. There are more
% coordinates in the Prob connectome, because the tracking fills up more
% White-matter.
%
% So, hereafter:
% - First we find the indices in the probabilistic connectome of the
% coordinate in the deterministic connectome. But there are some of the
% coordinates in the Deterministic conectome that are NOT in the
% Probabilistic connectome.
%
% - Second we find the indices in the Deterministic connectome of the
% subset of coordinates in the Probabilistic connectome found in the
% previous step.
%
% - Third we find the common voxels. These allow us to find the rmse for
% the same voxels.
fprintf('Finding common brain coordinates between P and D connectomes...\n')
prob.coordsIdx = ismember(p.coords,d.coords,'rows');
prob.coords    = p.coords(prob.coordsIdx,:);
det.coordsIdx  = ismember(d.coords,prob.coords,'rows');
det.coords     = d.coords(det.coordsIdx,:);
prob.rmse      = prob.rmse( prob.coordsIdx);
det.rmse       = det.rmse( det.coordsIdx);
clear p d

%% (3.2) Make a scatter plot of the RMSE of the two tractography models
fh(4) = scatterPlotRMSE(det,prob,Figure_7);

%% (3.3) Compute the strength-of-evidence (S) and the Earth Movers Distance.
% Compare the RMSE of the two models using the Stregth-of-evidence and the
% Earth Movers Distance.
se = feComputeEvidence(prob.rmse,det.rmse);

%% (3.4) Strength of evidence in favor of Probabilistic tractography. 
% Plot the distributions of resampled mean RMSE
% used to compute the strength of evidence (S).
fh(5) = distributionPlotStrengthOfEvidence(se,Figure_8);

%% (3.5) RMSE distributions for Probabilistic and Deterministic tractography. 
% Compare the distributions using the Earth Movers Distance.
% Plot the distributions of RMSE for the two models and report the Earth
% Movers Distance between the distributions.
fh(6) = distributionPlotEarthMoversDistance(se,Figure_9);

end

function fh = scatterPlotRMSE(det,prob,Figure_7)
figNameRmse = sprintf('prob_vs_det_rmse_common_voxels_map');
fh = mrvNewGraphWin(figNameRmse);
[ymap,x]  = hist3([det.rmse;prob.rmse]',{[10:1:70], [10:1:70]});
ymap = ymap./length(prob.rmse);
sh   = imagesc(flipud(log10(ymap)));
cm   = colormap(flipud(hot)); view(0,90);
axis('square')      
set(gca, ...
    'xlim',[1 length(x{1})],...
    'ylim',[1 length(x{1})], ...
    'ytick',[1 (length(x{1})/2) length(x{1})], ...
    'xtick',[1 (length(x{1})/2) length(x{1})], ...
    'yticklabel',[x{1}(end) x{1}(round(end/2)) x{1}(1)], ...
    'xticklabel',[x{1}(1)   x{1}(round(end/2)) x{1}(end)], ...
    'tickdir','out','ticklen',[.025 .05],'box','off', ...
    'fontsize',14,'visible','off')
hold on
plot3([1 length(x{1})],[length(x{1}) 1],[max(ymap(:)) max(ymap(:))],'k-','linewidth',1)
ylabel('Deterministic_{rmse}','fontsize',14)
xlabel('Probabilistic_{rmse}','fontsize',14)
cb = colorbar;
tck = get(cb,'ytick');
set(cb,'yTick',[min(tck)  mean(tck) max(tck)], ...
    'yTickLabel',round(1000*10.^[min(tck),...
    mean(tck), ...
    max(tck)])/1000, ...
    'tickdir','out','ticklen',[.025 .05],'box','on', ...
    'fontsize',14,'visible','off')

print(Figure_7,'-dpng')

end

function fh = distributionPlotStrengthOfEvidence(se,Figure_8)

y_e        = se.s.unlesioned_e;
ywo_e      = se.s.lesioned_e;
dprime     = se.s.mean;
std_dprime = se.s.std;
xhis       = se.s.unlesioned.xbins;
woxhis     = se.s.lesioned.xbins;

histcolor{1} = [0 0 0];
histcolor{2} = [.95 .6 .5];
figName = sprintf('Strength_of_Evidence_test_PROB_vs_DET_model_rmse_mean_HIST');
fh = mrvNewGraphWin(figName);
patch([xhis,xhis],y_e(:),histcolor{1},'FaceColor',histcolor{1},'EdgeColor',histcolor{1});
hold on
patch([woxhis,woxhis],ywo_e(:),histcolor{2},'FaceColor',histcolor{2},'EdgeColor',histcolor{2}); 
set(gca,'tickdir','out', ...
        'box','off', ...
        'ticklen',[.025 .05], ...
        'ylim',[0 .2], ... 
        'xlim',[min(xhis) max(woxhis)], ...
        'xtick',[min(xhis) round(mean([xhis, woxhis])) max(woxhis)], ...
        'ytick',[0 .1 .2], ...
        'fontsize',14)
ylabel('Probability','fontsize',14)
xlabel('rmse','fontsize',14')

title(sprintf('Strength of evidence:\n mean %2.3f - std %2.3f',dprime,std_dprime), ...
    'FontSize',14)
legend({'Probabilistic','Deterministic'})

print(Figure_8,'-dpng')

end

function fh = distributionPlotEarthMoversDistance(se,Figure_9)

prob = se.nolesion;
det  = se.lesion;
em   = se.em;

histcolor{1} = [0 0 0];
histcolor{2} = [.95 .6 .5];
figName = sprintf('EMD_PROB_DET_model_rmse_mean_HIST');
fh = mrvNewGraphWin(figName);
plot(prob.xhist,prob.hist,'r-','color',histcolor{1},'linewidth',4);
hold on
plot(det.xhist,det.hist,'r-','color',histcolor{2},'linewidth',4); 
set(gca,'tickdir','out', ...
        'box','off', ...
        'ticklen',[.025 .05], ...
        'ylim',[0 .12], ... 
        'xlim',[0 95], ...
        'xtick',[0 45 90], ...
        'ytick',[0 .06 .12], ...
        'fontsize',14)
ylabel('Proportion white-matter volume','fontsize',14)
xlabel('RMSE (raw MRI scanner units)','fontsize',14')
title(sprintf('Earth Movers Distance: %2.3f (raw scanner units)',em.mean),'FontSize',14)
legend({'Probabilistic','Deterministic'})

print(Figure_9,'-dpng')

end