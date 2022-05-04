function task_gaitERSP_raw(sii, PATH, cfg)
% Calculate gait ERSPs of unprocessed data (serves as comparison for
% artifact attenuated data)
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% directories
PATHIN = PATH.main;% BIDS rawdata
PATHOUT = PATH.raw;

% load processing info
load(cfg.info_file);

for si = sii % loop through all subjects
    
    % sub ID
    ID = sprintf('sub-%03d',si);
    
    PATHOUTsi = fullfile(PATHOUT, ID);
    if ~exist(PATHOUTsi), mkdir(PATHOUTsi);end
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ID,'eeg',[ID,'_task-neurCorrYoung_eeg.set']);
    % output file
    file_out = fullfile(PATHOUTsi,[ID,'_raw_ERSP.mat']); % file
    file_out_group = fullfile(PATHOUT,['sub-all_raw_ERSP.mat']); % file
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    %also check scripts that are being called!
    runScript = 1;%naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        %% load data
        EEG = pop_loadset(file_in);
        
        %% prune data
        % discard gait initiation
        FROM = EEG.event(strcmp({EEG.event.type}, cfg.startExperiment)).latency-60*EEG.srate;
        TO = EEG.event(end).latency;
        EEG = pop_select(EEG, 'point', [FROM TO]);
        
        %% only keep EEG chans
        EEG = pop_select(EEG, 'channel', cfg.idx_EEG_chan);
        
        %% downsample
        EEG = pop_resample( EEG, cfg.sampling_rate);
        
        %% bandpass filter
        data_unfiltered = EEG.data;
        EEG = pop_eegfiltnew(EEG, 'locutoff',cfg.bandpass_fmin);
        
        % 135 Hz LPF: performing 57 point lowpass filtering, transition band width: 30 Hz
        % passband edge(s): 120 Hz, cutoff frequency(ies) (-6 dB): 135 Hz, (zero-phase, non-causal)
        EEG = pop_eegfiltnew(EEG, 'hicutoff',cfg.bandpass_fmax);
        
        %% channel rejection w/ ASR
        % store original chanlocs in EEG.etc
        EEG.etc.orgChanlocs = EEG.chanlocs;
        
        EEG = pop_clean_rawdata(EEG, ...
            'FlatlineCriterion',cfg.ASR_FlatlineCriterion,...
            'ChannelCriterion',cfg.ASR_ChannelCriterion,...
            'LineNoiseCriterion',cfg.ASR_LineNoiseCriterion,...
            'Highpass','off',...
            'BurstCriterion','off',...
            'WindowCriterion','off',...
            'BurstRejection','off',...
            'Distance','Euclidian');
        %% interpolate channels w EEG.etc.orgChanlocs
        EEG = pop_interp(EEG, EEG.etc.orgChanlocs, 'spherical');
        
        %% full rank average Ref
        EEG = fullRankAveRef(EEG); % instead of EEG = pop_reref(EEG, []);
        
        %% standing BL TF
        EEG_stand = pop_select(EEG, 'point', [EEG.event(ismember({EEG.event.type}, cfg.cond_stand)).latency]);
        
        EEG_stand = threshContinous(EEG_stand, cfg.V_tsh*2);
        EEG_stand.data = EEG_stand.data(:,EEG_stand.etc.valid_eeg); % only keep "good data", chop rest out
        
        [F_Rest, Noise_cov] = baselineF(EEG_stand, cfg.f_axis, cfg.FWHM); %chanxfreq
        close;
        
        %% gait cycle ERSPs
        % for all cond together --> sPCA
        FROM = [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,1))).latency];
        TO =  [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,2))).latency];
        EEG_block = pop_select(EEG, 'point', [FROM; TO]' );
        EEG_block = threshContinous(EEG_block, cfg.V_tsh*2); % should this be extracted here?????
        
        [Gait_avg, ERSP, GPM, cycle_cnt, valid_cycle_cnt] = gait_ersp(EEG_block, F_Rest,...
            cfg.N_freq, cfg.f_axis, cfg.FWHM,...
            cfg.gait_event, cfg.gait_timeNextHs, cfg.gait_event_order);
        
             
        % save all info together
        gaitERSP.ID        = ID;
        gaitERSP.Noise_cov = Noise_cov;% noise cov for kernel computation
        gaitERSP.F_Rest    = F_Rest;
        gaitERSP.TF        = Gait_avg;
        gaitERSP.ERSP      = ERSP;
        gaitERSP.GPM       = GPM;
        gaitERSP.numStrides= cycle_cnt;
        gaitERSP.numValidStrides = valid_cycle_cnt;
        gaitERSP.chanlocs  = EEG.chanlocs;
        save(file_out, 'gaitERSP');
        
        procInfo(si).numStrides_raw = gaitERSP.numStrides;
        procInfo(si).numValidStrides_raw = gaitERSP.numValidStrides;
        
        TMP.ERSP(:,:,:,si) = gaitERSP.ERSP;
        TMP.GPM(:,:,:,si) = gaitERSP.GPM;
        TMP.chanlocs = gaitERSP.chanlocs;
        
    end
end % subject loop
fprintf('Done with sub-%03d!\n', si);
gaitERSP = TMP;
save(file_out_group, 'gaitERSP');

save(cfg.info_file, 'procInfo');
disp(['Done with ', mfilename])
end % end function