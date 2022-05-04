function plot_gaitERSP(data, chanIdx, f_axis, clim, colorbr, cfg)

FOI = ismember(cfg.f_axis, f_axis);
freqs = cfg.f_axis(FOI);
times = cfg.t_axis;


f_ticks = 5:5:cfg.f_axis(end);%or 10?
f_tickLab = {'','10','','20','','30','','40','','50','','60'}; % make dynamic!
t_ticks = linspace(times(1), times(end), 21);
t_tickLab = {'0','','','','','25','','','','','50','','','','','75','','','','','100'};%0:10:100; %labels in percent

data = squeeze(mean(data(:,chanIdx,FOI),2));
contourf(times, freqs, data', 50,'linecolor','none'); hold on % plot ERSP

caxis([-clim clim]); %        colorbar
try %try brainstorm's mandrill colormap is in path, otherwise use jet
    colormap(cmap_mandrill)%colormap(cmap_royal_gramma)
catch
    colormap jet; %better would be colormap turbo, until implemented     recently
end
box off

xticks(t_ticks); xticklabels(t_tickLab);xtickangle(0);
yticks(f_ticks); yticklabels(f_tickLab);
if colorbr
    h = colorbr('Position',[0.92 0.54 0.01 0.05]);
    ylabel(h, unit)
end

% han=axes(gcf,'visible','off');
% han.XLabel.Visible='on';xlabel(han,'Gait cycle (%)');
% han.YLabel.Visible='on';ylabel(han,'Frequency (Hz)');

set(findall(gcf,'-property','FontSize'),'FontSize',6)

end