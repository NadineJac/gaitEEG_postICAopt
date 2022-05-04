function sii = task_gaitERSP_cluster(PATH, cfg, fieldName)
PATHIN = PATH.ICAdecomp;
PATHOUT = PATH.(fieldName);

% load clustered study
[STUDY ALLEEG] = pop_loadstudy('filename', [cfg.study_name, '_',fieldName, '.study'], 'filepath', PATHOUT);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

% identify best cluster
clust_idx(1) = STUDY.etc.bemobil.clustering.cluster_ROI_index;

% reject all IC that are not part of the best cluster
for ci = clust_idx
    sii =unique(STUDY.cluster(ci).sets);
    for si = sii
        
        % sub ID
        ID = sprintf('sub-%03d',si);
        
        PATHOUTsi = fullfile(PATHOUT, ID);
        if ~exist(PATHOUTsi), mkdir(PATHOUTsi);end
        
        % filenames:
        % input file
        file_in = fullfile(PATHIN, ID,[ID,'_ICAdecomp.set']);
        % output file
        file_out = fullfile(PATHOUTsi,[ID,'_', fieldName,'.set']); % file
        % check whether output file exists, if so, only run script if it has
        % been modified in the meantime
        %also check scripts that are being called!
        runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
        if runScript
            disp('entering loop')
            % load data
            EEG = pop_loadset(file_in);
            
            %% reject components
            % remove ICs with brain <= .7
            kpClust = STUDY.cluster(ci).comps(STUDY.cluster(ci).sets == si);
            rmClust = setdiff([1:size(EEG.icaweights,1)],kpClust);
            
            % reject components
            EEG = pop_subcomp( EEG, find(kpClust), 0); %add muscle here for ERP calc!
            
            % update info
            EEG.etc.ICA.ICremain = size(EEG.icawinv,2);
                       
            % save time series data for TF transform
            pop_saveset(EEG,file_out);
        end
    end

end
end
        
        %         % pick out involved ICs
        %         ic_idx = ;
        %
        %         % ERSP
        %         ERSP_sub = ERSP{sii}(:,ic_idx,:); % pnts x IC x freq;
        %         ERSP_clust = cat(2, ERSP_clust, ERSP_sub);
        %         % average ICs if more than one is involved per subject
        %         ERSP_clust_corr = cat(2, ERSP_clust_corr, mean(ERSP_sub,2));
        %
        %         GPM_sub = GPM{sii}(:,ic_idx,:); % pnts x IC x freq;
        %         GPM_clust = cat(2, GPM_clust, GPM_sub);
        %         % average ICs if more than one is involved per subject
        %         GPM_clust_corr = cat(2, GPM_clust_corr, mean(GPM_sub,2));
        %     end
        %     cluster(count).label = cfg.clust_label{count};
        %     cluster(count).sets = STUDY.cluster(clust_idx).sets;
        %     cluster(count).ERSP = ERSP_clust;
        %     cluster(count).ERSP_corr = ERSP_clust_corr;
        %     cluster(count).GPM = GPM_clust;
        %     cluster(count).GPM_corr = GPM_clust_corr;
        % end
        %
        % % load all GPMs
        % for si = sii
        %     ID = sprintf('sub-%03d',si);
        %     file_in = fullfile(PATHIN, ID,[ID,'_ICAdecomp_ERSP.mat']);
        %     load(file_in, 'gaitERSP');
        %     ERSP{si} = gaitERSP.ERSP;
        %     GPM{si} = gaitERSP.GPM;
        % end
        % clearvars gaitERSP
        %
        % GPM_sub = []; GPM_clust=[];GPM_clust_corr=[];
        % ERSP_sub = []; ERSP_clust=[];ERSP_clust_corr=[];
        % cluster = [];count = 0;
        %
        % % plot params
        % count=0;
        % for ci = clust_idx
        %     count = count+1;
        %     sub_id = unique(STUDY.cluster(ci).sets);
        %     for sii = sub_id
        %         % pick out involeved ICs
        %         ic_idx = STUDY.cluster(ci).comps(STUDY.cluster(ci).sets == sii);
        %
        %         % ERSP
        %         ERSP_sub = ERSP{sii}(:,ic_idx,:); % pnts x IC x freq;
        %         ERSP_clust = cat(2, ERSP_clust, ERSP_sub);
        %         % average ICs if more than one is involved per subject
        %         ERSP_clust_corr = cat(2, ERSP_clust_corr, mean(ERSP_sub,2));
        %
        %         GPM_sub = GPM{sii}(:,ic_idx,:); % pnts x IC x freq;
        %         GPM_clust = cat(2, GPM_clust, GPM_sub);
        %         % average ICs if more than one is involved per subject
        %         GPM_clust_corr = cat(2, GPM_clust_corr, mean(GPM_sub,2));
        %     end
        %     cluster(count).label = cfg.clust_label{count};
        %     cluster(count).sets = STUDY.cluster(clust_idx).sets;
        %     cluster(count).ERSP = ERSP_clust;
        %     cluster(count).ERSP_corr = ERSP_clust_corr;
        %     cluster(count).GPM = GPM_clust;
        %     cluster(count).GPM_corr = GPM_clust_corr;
        % end
        %
        %
        %
        % %% plot: ERSP
        % chanIdx =1;
        % clim1 = 2*2; %ERSP
        % clim2 = 0.5*2; %GPM
        % colorbr = 0;
        % FOI = 4:60;
        %
        % fig = figure; set(fig,'units', 'centimeters','Position', [0 0 20 20])
        %
        % subplot(2,2,1)
        % plot_gaitERSP(mean([cluster(count).ERSP_corr],2), chanIdx, FOI, clim1, colorbr, cfg); axis square;
        % title('corrected ERSP of sub-all', 'interp', 'none');
        %
        % subplot(2,2,2)
        % plot_gaitERSP(mean([cluster(count).ERSP],2), chanIdx, FOI, clim1, colorbr, cfg); axis square;
        % title('uncorrected ERSP of sub-all', 'interp', 'none');
        %
        % subplot(2,2,3)
        % plot_gaitERSP(mean([cluster(count).GPM_corr],2), chanIdx, FOI, clim2, colorbr, cfg); axis square;
        % title('corrected GPM of sub-all', 'interp', 'none');
        % ylabel('Frequency (Hz)'); xlabel ('Gait cycle (%)');
        %
        % subplot(2,2,4)
        % plot_gaitERSP(mean([cluster(count).GPM],2), chanIdx, FOI, clim2, colorbr, cfg); axis square;
        % title('uncorrected GPM of sub-all', 'interp', 'none');
        %
        % % colorbars
        % c = colorbar(subplot(2,2,2),'Position', [0.913 0.68 0.02 0.11]);
        % ylabel(c, 'dB change to standing BL')
        %
        % c = colorbar(subplot(2,2,4),'Position', [0.913 0.22 0.02 0.11]);
        % ylabel(c, 'dB change to mean gait cycle BL')
        %
        % sgtitle(['cluster ', cfg.clust_label{count}])
        % set(findall(gcf,'-property','FontSize'),'FontSize',10)
        %
        % print([PATHOUT, 'sub-all_', fieldName, '_ERSP_cluster', num2str(ci)], '-dpng'); close;
        % end