function task_gaitERSP_clean(sii, PATH, cfg, fieldName)
% Calculate gait ERSPs of processed data stored at PATH.fieldName
% with artifact attenuated single subject EEG datasets stored as file_in at PATHIN
% 
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% 
% OUTPUT
% [FILE] gaitERSP stored as file_out in PATHOUT
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% directories
PATHIN = PATH.(fieldName);
PATHOUT = PATH.(fieldName);

% load processing info
load(cfg.info_file);

for si = sii % loop through all subjects
    
    % sub ID
    ID = sprintf('sub-%03d',si);
    
    PATHOUTsi = fullfile(PATHOUT, ID);
    if ~exist(PATHOUTsi), mkdir(PATHOUTsi);end
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ID,[ID,'_', fieldName,'.set']);
    % output file
    file_out = fullfile(PATHOUTsi,[ID,'_', fieldName,'_ERSP.mat']); % file
    
    % report files
    reportNames = {'_standBL_power.png',...
        '_allChan_ERSP.png',...
        '_allChan_GPM.png'};
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        EEG = pop_loadset(file_in);
        
        %% standing BL TF
        EEG_stand = pop_select(EEG, 'point', [EEG.event(ismember({EEG.event.type}, cfg.cond_stand)).latency]);
        
        EEG_stand = threshContinous(EEG_stand, cfg.V_tsh);
        procInfo(si).standBL_valid = sum(EEG_stand.etc.valid_eeg)/ EEG_stand.pnts;
        EEG_stand.data = EEG_stand.data(:,EEG_stand.etc.valid_eeg); % only keep "good data", chop rest out
        
        [F_Rest, Noise_cov] = baselineF(EEG_stand, cfg.f_axis, cfg.FWHM); %chanxfreq
        print(fullfile(PATHOUTsi, [ID, reportNames{1}]),'-dpng');close;
        
        %% gait cycle ERSPs
        % for all cond together --> sPCA
        FROM = [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,1))).latency];
        TO =  [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,2))).latency];
        EEG_block = pop_select(EEG, 'point', [FROM; TO]' );
        EEG_block = threshContinous(EEG_block, cfg.V_tsh);
        
        [Gait_avg, ERSP, GPM, cycle_cnt, valid_cycle_cnt] = gait_ersp(EEG_block, F_Rest,...
            cfg.N_freq, cfg.f_axis, cfg.FWHM,...
            cfg.gait_event, cfg.gait_timeNextHs, cfg.gait_event_order);
                
        % save all info together
        gaitERSP.ID         = ID;
        gaitERSP.Noise_cov  = Noise_cov;% noise cov for kernel computation
        gaitERSP.F_Rest     = F_Rest;
        gaitERSP.TF         = Gait_avg;
        gaitERSP.ERSP       = ERSP;
        gaitERSP.GPM        = GPM;
        gaitERSP.numStrides = cycle_cnt;
        gaitERSP.numValidStrides = valid_cycle_cnt;
        gaitERSP.chanlocs   = EEG.chanlocs;
        save(file_out, 'gaitERSP');       
    end
    fprintf('Done with sub-%03d!\n', si);
end % subject loop

save(cfg.info_file, 'procInfo');
disp(['Done with ', mfilename])
end % end function