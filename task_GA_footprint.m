function task_GA_footprint(PATH, cfg, fieldNames)
% Calculated the gait artifact footprint proposed by Jacobsen et al.,2020
% Since data from the best cluster after independent component clustering
% is included, of which not every subject is part of, only the footprint of
% the group-averaged data will be calculated
%
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% - fieldNames: cell with strings of field in PATH structure were data to
% be compared is stired, this data needs to be time-frequency decomposed
% and aggregated over subjects
%
% OUTPUT
% [FILE] table with footprint features B-F stored at PATHOUT, ['sub-all_', fi{:}, '_footprint.mat']
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% load processing info
load(cfg.info_file);

% directories
for fi = fieldNames
    PATHIN = PATH.(fi{:});
    PATHOUT = PATHIN;
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ['sub-all_', fi{:}, '_ERSP.mat']);
    % output file
    file_out = fullfile(PATHOUT, ['sub-all_', fi{:}, '_footprint.mat']);
    reportName = {['sub-all_', fi{:}, '_footprint.png']};
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    %also check scripts that are being called!
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        
        %% load data: use group aggregated data and average already
        load(file_in);
        % gait ERSP.ERSP = times x chans x freqs --> TFdata = chans x freqs x pnts (HS to HS)
        ERSP = permute(gaitERSP.ERSP(:,cfg.idx_EEG_chan,:,:), [2 3 1 4]);
        
        %% calculate feature
        GA_ERSP = mean(ERSP,4,'omitnan');
        
        tmp = GA_ERSP; % only use positive values
        tmp(tmp<0) = missing;
        
        % skip feature A as no ERP after sPCA available!
        % B) correlation across frequencies --------------------------
        dat = squeeze(mean(GA_ERSP,1));               % average over channels
        Z = atanh(corr(dat','type', 'Pearson'));    % z transformed pearson correlation
        triuZ = triu(Z,1);                          % only keep upper triangle of correlation matrix (w/o diagonal)
        meanZ = sum(triuZ,'all')/sum(triuZ~=0, 'all');% average all nonzero elements
        meanR = tanh(meanZ);                        % transform back to r
        feature(1) = meanR.^2;                    % store squared mean correlation --> coefficient of Determination
        
        % C) power ratio lateral/medial channels -------------------------
        powLat = mean(tmp(cfg.lateralChanIdx, :,:), 'all', 'omitnan');
        powMed = mean(tmp(setdiff(cfg.idx_EEG_chan, cfg.lateralChanIdx),:,:), 'all', 'omitnan');
        feature(2) = powLat/powMed;
        
        % D) power at neck electrodes contralateral to HS/ipsi --------------
        powContra = sum(tmp(cfg.neckChanL,:,cfg.pntsRHS),'all','omitnan')+...
            sum(tmp(cfg.neckChanR,:,cfg.pntsLHS),'all','omitnan');
        powIpsi = sum(tmp(cfg.neckChanL,:,cfg.pntsLHS),'all','omitnan')+...
            sum(tmp(cfg.neckChanR,:,cfg.pntsRHS),'all', 'omitnan');
        feature(3) = powContra/powIpsi;
        
        % E) power double support/single supp gait cycle power -------------
        powD = sum(GA_ERSP(:,:,cfg.pntsDouble), 'all');
        powS = sum(GA_ERSP, 'all')-powD;
        feature(4) = powD/powS;
        
        % F) S/W power ratio --------------------------------------
        feature(5) = mean(GA_ERSP, 'all');
        
        FOOTPRINT = table(feature(:,1),feature(:,2), feature(:,3), feature(:,4), feature(:,5),...
            'VariableNames', { 'B', 'C', 'D', 'E', 'F'},...
            'RowNames', {'sub-all'});
        save(file_out, 'FOOTPRINT');
    end %run script
end % processing stage loop
end %end function