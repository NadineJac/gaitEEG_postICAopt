function plot_Cz_ERSP_all_clean(PATH, cfg, fieldNames)
% Plot ERSP and GPM at Cz of the raw data and clean A-E
% with single subject gait ERSPS at data PATHIN named file_in
%
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% 
% OUTPUT
% [file] plot of group-averaged ERSPs and GPMs at Cz in PATHOUT named file_out
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

%% plot prams
chanIdx = 24;
clim1 = 2; %ERSP
clim2 = 0.5; %GPM
colorbr = 0;
FOI = 4:60;
figure, set(gcf, 'units', 'centimeters', 'position', [0 0 40 15]);
cnt = 0; % plot counter

PATHOUT = PATH.plotCleaning;
for fi = fieldNames
    
    % directories
    PATHIN = PATH.(fi{:});
        
    % load data
    load(fullfile(PATHIN,['sub-all_', fi{:},'_ERSP.mat']), 'gaitERSP');
    ERSP = gaitERSP.ERSP;
    GPM = gaitERSP.GPM;
        
    % plot
    cnt = cnt+1;
    
    % ERSP
    subplot(2,length(fieldNames),cnt)
    plot_gaitERSP(mean(ERSP,4), chanIdx, FOI, clim1, colorbr, cfg); axis square;
    title(fi{:}, 'interp', 'none');
    
    % GPM
    subplot(2,length(fieldNames),length(fieldNames)+cnt)
    plot_gaitERSP(mean(GPM,4), chanIdx, FOI, clim2, colorbr, cfg); axis square;
end

% colorbars
c = colorbar(subplot(2,length(fieldNames),cnt),... % ERSP
    'Position', [0.92 0.68 0.01 0.11]);
ylabel(c, 'dB change to standing BL')

c = colorbar(subplot(2,length(fieldNames),length(fieldNames)+cnt),... %GPM
    'Position', [0.92 0.22 0.01 0.11]);
ylabel(c, 'dB change to main gait cycle BL')

set(findall(gcf,'-property','FontSize'),'FontSize',10)

%sgtitle('Grand average gait ERSPs at Cz')
print(fullfile(PATHOUT,'sub-all_comp_ERSP_Cz'), '-dpng'); %close
end
