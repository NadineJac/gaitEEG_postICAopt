function task_gaitERP(sii, PATH, cfg)
% Calculate gait ERP of processed data stored at PATH.fieldName this is
% required for clustering (clean_c and clean_d)
% with artifact attenuated single subject EEG datasets stored as file_in at PATHIN
% 
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% 
% OUTPUT
% [FILE] gait ERP stored as file_out in PATHOUT
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% directories
PATHIN = PATH.ICAdecomp;
PATHOUT = PATH.gaitERP;

for si = sii % loop through all subjects
    
    % sub ID
    ID = sprintf('sub-%03d',si);
    
    PATHOUTsi = fullfile(PATHOUT, ID);
    if ~exist(PATHOUTsi), mkdir(PATHOUTsi);end
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ID,[ID,'_ICAdecomp.set']);
    % output file
    file_out = fullfile(PATHOUTsi,[ID,'_gaitERP.set']); % file
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        disp('entering loop')
        % load data
        EEG = pop_loadset(file_in);
        
        % extract conds
        FROM = [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,1))).latency];
        TO =  [EEG.event(ismember({EEG.event.type}, cfg.cond_walk(:,2))).latency];
        EEG = pop_select(EEG, 'point', [FROM; TO]' );
        
        % epoch
        EEG = pop_epoch( EEG, {cfg.gait_event}, [0  1.2], 'epochinfo', 'yes');
        EEG = pop_rmbase(EEG, [],[]);
        
        %% check validity of gait cycles
        latGaitEV = zeros(EEG.trials, length(cfg.gait_event_order));
        for i = 2:length(cfg.gait_event_order)
            evalc('latGaitEV(:,i) = eeg_getepochevent(EEG,cfg.gait_event_order(i), [25 1500], ''latency'')');
        end
        % flag epochs w/o all events
        % contain nans
        rmEp1 =any(isnan(latGaitEV),2);
        
        % and events in wrong order
        % negtive difference between events
        rmEp2 = any(diff(latGaitEV,[],2)<0,2);
        
        % reject flagged epochs
        EEG = pop_select(EEG, 'notrial', find(rmEp1+rmEp2));
        
        % reject epochs with extreme parameters
        EEG = pop_jointprob(EEG,1,[1:EEG.nbchan] ,3,3,0,1,0,[],0);
        EEG = eeg_checkset( EEG );
        
        % save
        pop_saveset(EEG,file_out);
        
    end
    fprintf('Done with sub-%03d!\n', si);
end % subject loop

disp(['Done with ', mfilename])
end %end function