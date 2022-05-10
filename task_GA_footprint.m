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
        
        % skip feature A as no ERP after sPCA available!
        % B) correlation across frequencies --------------------------
        feature(1) = B_Rfreq(GA_ERSP);
        
        % C) power ratio lateral/medial channels -------------------------
        feature(2) = C_lateralPowRatio(GA_ERSP, cfg.lateralChanIdx);
        
        % D) power at neck electrodes contralateral to HS/ipsi --------------
        feature(3) = D_neckChanRatio(GA_ERSP,cfg.neckChanL, cfg.neckChanR, cfg.pntsLHS, cfg.pntsRHS);
        
        % E) power double support/single supp gait cycle power -------------
        feature(4) = E_doubleSuppRatio(GA_ERSP, cfg.pntsDouble);
        
        % F) S/W power ratio --------------------------------------
        feature(5) = F_swRatio(GA_ERSP);
        
        FOOTPRINT = table(feature(:,1),feature(:,2), feature(:,3), feature(:,4), feature(:,5),...
            'VariableNames', { 'B', 'C', 'D', 'E', 'F'},...
            'RowNames', {'sub-all'});
        save(file_out, 'FOOTPRINT');
    end %run script
end % processing stage loop
end %end function