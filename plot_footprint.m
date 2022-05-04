function plot_footprint(PATH, cfg, fieldNames)
% Plot the previously calculated  gait artifact footprint proposed by Jacobsen et al.,2020
% The group-average footprint will be plottdt across the raw data and five
% different artifact attenuation strategies in one spider plot 
% download toolbox at
% https://de.mathworks.com/matlabcentral/fileexchange/59561-spider_plot and
% add to path!
%
% INPUT
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% - fieldNames: cell with strings of field in PATH structure were data to
% be compared is stired, the gait-artifact footprint of this data has to be
% calculated already
%
% OUTPUT
% spider plot with footprint features B-F across processing pipelines
% stored at PATHOUT as ['sub-all_GA_footprint.png']
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenbrug, April 2022


cnt = 0; % counter artifact attenuation pipelines (fi)
% directories
for fi = fieldNames
    cnt = cnt+1;
    
    PATHIN = PATH.(fi{:});
    PATHOUT = PATH.plotFootprint;
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ['sub-all_', fi{:}, '_footprint.mat']);
    % output file
    file_out = fullfile(PATHOUT, ['sub-all_', fi{:}, '_footprint.png']);
    reportName = {['sub-all_GA_footprint.png']};
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        load(file_in)
        features(:,:,cnt) = FOOTPRINT.Variables;
    end
end

% prepare GA data
GA_features = squeeze(mean(features, 1,'omitnan'));
% average across subjects -> plot mean; omit subjects that were not
% clustered!

%% plot
%  get radar plot from https://de.mathworks.com/matlabcentral/fileexchange/59561-spider_plot
axes_limits = repmat([floor(min(GA_features,[],'all'));ceil(max(GA_features,[],'all'))],1,5);
spider_plot(GA_features',...
    'AxesLabels', cfg.axes_labels,...
    'AxesInterval', cfg.axes_interval,...
    'AxesPrecision', cfg.axes_precision,...
    'AxesDisplay', cfg.axes_display,...
    'AxesLimits', axes_limits,...
    'FillOption', cfg.fill_option,...%
    'Color', cfg.edgeColors,...
    'LineWidth', cfg.line_width,...
    'Marker', cfg.marker_type,...
    'AxesFontSize', cfg.axes_font_size,...
    'LabelFontSize', cfg.label_font_size,...
    'AxesLabelsEdge', 'none');

% legend
lgd = legend(fieldNames, 'Fontsize', cfg.label_font_size);
title(lgd,'Artifact attenuation', 'Fontsize', cfg.label_font_size);
legend('boxoff');
set(lgd, 'Position',[0.3 0.08 0.4 0.22]);

set(gcf, 'units', 'centimeters', 'Position',[0 0 10 20])
print(fullfile(PATHOUT, reportName{1}),'-dpng'); %close;
save(fullfile(PATHOUT, reportName{1}(1:end-4)),'GA_features');
end