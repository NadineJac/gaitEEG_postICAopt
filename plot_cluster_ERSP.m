function plot_cluster_ERSP(sii,PATH,cfg, fieldNames)
% Plot ERSP and GPM at clusters
% with single subject gait ERSPS of ICs and clustering solutions at data
% PATHIN named file_in
%
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
%
% OUTPUT
% [file] plot of cluster ERSPs and GPMs PATHOUT named file_out for all
% fieldNames
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

PATHIN = PATH.ICAdecomp;
PATHOUT_file = PATH.plotCleaning;

%plot params
chanIdx =1;
clim1 = 4; %ERSP
clim2 = 1; %GPM
colorbr = 0;
FOI = 4:60;

fig = figure; set(fig,'units', 'centimeters','Position', [0 0 13 20])
for fi = 1:length(fieldNames) % loop though all clusters to be plotted
    
    PATHOUT = PATH.(fieldNames{fi});
    
    % load clustered study
    [STUDY ALLEEG] = pop_loadstudy('filename', [cfg.study_name,'_', fieldNames{fi}, '.study'],...
        'filepath', PATHOUT);
    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
    
    % identify best cluster
    clust_idx(1) = STUDY.etc.bemobil.clustering.cluster_ROI_index;
    
    % load all GPMs
    for si = sii
        ID = sprintf('sub-%03d',si);
        file_in = fullfile(PATHIN, ID,[ID,'_ICAdecomp_ERSP.mat']);
        load(file_in, 'gaitERSP');
        ERSP{si} = gaitERSP.ERSP;
        GPM{si} = gaitERSP.GPM;
    end
    clearvars gaitERSP
    
    GPM_sub = []; GPM_clust=[];GPM_clust_corr=[];
    ERSP_sub = []; ERSP_clust=[];ERSP_clust_corr=[];
    cluster = [];count = 0;
    
    % aggregate data
    count=0;
    for ci = clust_idx
        count = count+1;
        sub_id = unique(STUDY.cluster(ci).sets);
        for si = sub_id
            % pick out involeved ICs
            ic_idx = STUDY.cluster(ci).comps(STUDY.cluster(ci).sets == si);
            
            % ERSP
            ERSP_sub = ERSP{si}(:,ic_idx,:); % pnts x IC x freq;
            ERSP_clust = cat(2, ERSP_clust, ERSP_sub);
            % average ICs if more than one is involved per subject
            ERSP_clust_corr = cat(2, ERSP_clust_corr, mean(ERSP_sub,2));
            
            GPM_sub = GPM{si}(:,ic_idx,:); % pnts x IC x freq;
            GPM_clust = cat(2, GPM_clust, GPM_sub);
            
            % average ICs if more than one is involved per subject
            GPM_clust_corr = cat(2, GPM_clust_corr, mean(GPM_sub,2));
        end
        cluster(count).label = cfg.clust_label{count};
        cluster(count).sets = STUDY.cluster(clust_idx).sets;
        cluster(count).ERSP = ERSP_clust;
        cluster(count).ERSP_corr = ERSP_clust_corr;
        cluster(count).GPM = GPM_clust;
        cluster(count).GPM_corr = GPM_clust_corr;
        
        %% plot
        % plot IC locs
        subplot(4,length(fieldNames),fi)%will crash if more than one cluster is plotted
        std_dipplot(STUDY,ALLEEG,'clusters',STUDY.etc.bemobil.clustering.cluster_ROI_index,'figure','off');
        title(fieldNames{fi})
        
        % plot topo
        subplot(4,length(fieldNames),length(fieldNames)+fi)
        std_topoplot(STUDY,ALLEEG,'clusters',STUDY.etc.bemobil.clustering.cluster_ROI_index,'figure','off');
        
        subplot(4,length(fieldNames),2*length(fieldNames)+fi)
        plot_gaitERSP(mean([cluster(count).ERSP],2), chanIdx, FOI, clim1, colorbr, cfg); axis square;
        %         title('ERSP');
        
        subplot(4,length(fieldNames),3*length(fieldNames)+fi)
        plot_gaitERSP(mean([cluster(count).GPM],2), chanIdx, FOI, clim2, colorbr, cfg); axis square;
        %         title('GPM');
        if fi==1; ylabel('Frequency (Hz)'); xlabel ('Gait cycle (%)');end
    end % cluster ci
end % field names fi

% colorbars
c = colorbar(subplot(4,length(fieldNames),2*length(fieldNames)+fi),...
    'Position', [0.88 0.35 0.02 0.11]);
ylabel(c, 'dB change to standing BL')

c = colorbar(subplot(4,length(fieldNames),3*length(fieldNames)+fi),...
    'Position', [0.88 0.13 0.02 0.11]);
ylabel(c, 'dB change to mean gait cycle BL')

set(findall(gcf,'-property','FontSize'),'FontSize',8);

print([PATHOUT_file, 'sub-all_ERSP_clusters', num2str(ci)], '-dpng'); %close;
end % function