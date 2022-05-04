function task_footprint_GA(sii, PATH, cfg, fieldNames)
% Add task description here
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config

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
        
        %% load data: use group averaged data already
        load(file_in);
        % gait ERSP.ERSP = times x chans x freqs --> TFdata = chans x freqs x pnts (HS to HS)
        ERSP = permute(gaitERSP.ERSP(:,cfg.idx_EEG_chan,:,:), [2 3 1 4]);
        
        %% calculate feature
        for si = sii % subject loop
            ERSPsi = ERSP(:,:,:,si);
            tmp = ERSPsi; % only use positive values
            tmp(tmp<0) = missing;
            
            % skip feature A as no ERP after sPCA available!
            % B) correlation across frequencies --------------------------
            dat = squeeze(mean(ERSPsi,1));               % average over channels
            Z = atanh(corr(dat','type', 'Pearson'));    % z transformed pearson correlation
            triuZ = triu(Z,1);                          % only keep upper triangle of correlation matrix (w/o diagonal)
            meanZ = sum(triuZ,'all')/sum(triuZ~=0, 'all');% average all nonzero elements
            meanR = tanh(meanZ);                        % transform back to r
            feature(si,1) = meanR.^2;                    % store squared mean correlation --> coefficient of Determination
            
            % C) power ratio lateral/medial channels -------------------------
            powLat = mean(tmp(cfg.lateralChanIdx, :,:), 'all', 'omitnan');
            powMed = mean(tmp(setdiff(cfg.idx_EEG_chan, cfg.lateralChanIdx),:,:), 'all', 'omitnan');
            feature(si,2) = powLat/powMed;
            
            % D) power at neck electrodes contralateral to HS/ipsi --------------
            powContra = sum(tmp(cfg.neckChanL,:,cfg.pntsRHS),'all','omitnan')+...
                sum(tmp(cfg.neckChanR,:,cfg.pntsLHS),'all','omitnan');
            powIpsi = sum(tmp(cfg.neckChanL,:,cfg.pntsLHS),'all','omitnan')+...
                sum(tmp(cfg.neckChanR,:,cfg.pntsRHS),'all', 'omitnan');
            feature(si,3) = powContra/powIpsi;
            
            % E) power double support/single supp gait cycle power -------------
            powD = sum(ERSPsi(:,:,cfg.pntsDouble), 'all');
            powS = sum(ERSPsi, 'all')-powD;
            feature(si,4) = powD/powS;
            
            % F) S/W power ratio --------------------------------------
            feature(si,5) = mean(ERSPsi, 'all');
        end % subject loop
        
        ID = {procInfo.ID};
        FOOTPRINT = table(feature(:,1),feature(:,2), feature(:,3), feature(:,4), feature(:,5),...
            'VariableNames', { 'B', 'C', 'D', 'E', 'F'},...
            'RowNames', ID(sii)');
        save(file_out, 'FOOTPRINT');
%         FEATURES{cnt} = feature;
    end %run script
end % processing stage loop


% % %% statistical evaluation
% distFootprint = nan(length(sii),1);
% for si = 1:length(distFootprint)
%     distFootprint(si) = norm(allFootprint(si,:,2)-allFootprint(si,:,1));
% end
% footprint = table(distFootprint, 'VariableNames', {'dist'});
% writetable(footprint, [PATHOUT filesep 'distances']);
%
% % length footprint
% lengthFootprint_pre = nan(length(sii),1);
% lengthFootprint_post = nan(length(sii),1);
% for si = 1:length(lengthFootprint_pre)
%     lengthFootprint_pre(si) = norm(allFootprint(si,:,1));
%     lengthFootprint_post(si) = norm(allFootprint(si,:,2));
% end
%
% footprint_pre = table(lengthFootprint_pre, 'VariableNames', {'dist'});
% writetable(footprint_pre, [PATHOUT filesep 'length_pre']);
%
% footprint_post = table(lengthFootprint_post, 'VariableNames', {'dist'});
% writetable(footprint_post, [PATHOUT filesep 'length_post']);
end %end function