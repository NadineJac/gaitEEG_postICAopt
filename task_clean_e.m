function task_clean_e(sii, PATH, cfg)
% Add task description here
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config

% directories
PATHIN = PATH.ICAdecomp;
PATHOUT = PATH.clean_e;

% load processing info
load(cfg.info_file);

for si = sii % loop through all subjects
    
    % sub ID
    ID = sprintf('sub-%03d',si);
    
    PATHOUTsi = fullfile(PATHOUT, ID);
    if ~exist(PATHOUTsi), mkdir(PATHOUTsi);end
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN, ID,[ID,'_ICAdecomp.set']);
    % output file
    file_out = fullfile(PATHOUTsi,[ID,'_ICArej_e.set']); % file
    % report files
    reportNames = {'_allIC_rej.png'};
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    %also check scripts that are being called!
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        disp('entering loop')
        % load data
        EEG = pop_loadset(file_in);
        
        %% reject components
        % remove ICs with eye > .7
        rmEye = EEG.etc.ic_classification.ICLabel.classifications(:,3)> cfg.IC_eye;
        procInfo(si).IC_Eye = sum(rmEye);
                
        % visualize
%         nComp = size(EEG.icawinv,2);
%         procInfo(si).IC_num = nComp;
%         EEG.setname = file_out;
%         rejComp = strjoin(string(find(rmEye)),', ');
%         pop_topoplot(EEG, 0, [1:nComp],...
%             [ID, ', rejected: ', rejComp{:}],...
%             [ceil(sqrt(nComp)) ceil(sqrt(nComp))] ,0,...
%             'electrodes','on','iclabel','on');
%         set(gcf, 'Units','normalized','Position',[0 0 1 1]);
%         print('-dpng', fullfile(PATHOUTsi, [ID, reportNames{1}])); % save
%         close;
%         
        % reject components
        EEG = pop_subcomp( EEG, find(rmEye), 0); %add muscle here for ERP calc!
        
        % update info
        EEG.etc.ICA.ICremain = size(EEG.icawinv,2);
        procInfo(si).IC_kept = EEG.etc.ICA.ICremain;
        
        % save time series data 
        pop_saveset(EEG,file_out);
        
        % spectral denoising
        task_sPCA_sensor_condTogether(si, PATH, cfg);
    end
    fprintf('Done with sub-%03d!\n', si);
end % subject loop

save(cfg.info_file, 'procInfo');
disp(['Done with ', mfilename])
end %end function