function task_clean_c(sii, PATH, cfg)
% Artifact attenuate ICA decomposed single subject EEG data epoched around gait cycle
% by clustering ICs and finding the best fitting cluster close to an a priory defined ROI
% Use repetitive clustering to overcome limits of kmean clustering, as random seeds
% and get more reliable results
% Adapted from MoBI Workshop 1.0 hands-on session for study level and IC clustering
% 
% with single subject ICA decomposed EEG data PATHIN named file_in
%
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
% 
% OUTPUT
% [file] preclustered STUDY in PATHOUT named file_out
% [file] clustered STUDY in PATHOUT named [file_out, 'clean_c'] and
% clustering solutions
% 
% Author: Marius Klug, TU Berlin, 2021,
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% directories
PATHIN = PATH.gaitERP;
PATHOUT = PATH.clean_c;

file_out = fullfile(PATHOUT,[cfg.study_name, '.study']); % output file

%% epoch around gait events and create study
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG =[]; CURRENTSET=[];
df = [];
for si = sii
    % sub ID
    ID = sprintf('sub-%03d',si);
        
    % input file
    file_in = fullfile(PATHIN, ID,[ID,'_gaitERP.set']);
    
    % build data frame for study
        df{end+1} = {'index', si,...
            'load', file_in,...
            'subject', ID,...
            'session', 1,...
            'run', 1};
end % subject loop

%% create study
[STUDY, ALLEEG] = std_editset(STUDY, ALLEEG,...
    'name',cfg.study_name,...
    'task', cfg.task,...
    'commands',df,...
    'updatedat','on',...
    'rmclust','off' );

[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

%% create component measures
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, 'components',...
    'savetrials','on',...
    'allcomps','on',...
    'erp','on',...% no erp baseline
    'scalp','on',...
    'spec','on','specparams',{'specmode','fft','logtrials','off','recompute','off'});
eeglab redraw

%% build preclustering array
% saves additional info, needed for iterations later (not possible w/ GUI)
[STUDY, ALLEEG, EEG] = bemobil_precluster(STUDY, ALLEEG, EEG, ...
    cfg.clustering_weights, cfg.freqrange, cfg.timewindow);

%% save study
[STUDY EEG] = pop_savestudy( STUDY, EEG,...
    'filename', cfg.study_name,...
    'filepath', PATHOUT);

%% load study
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
[STUDY ALLEEG] = pop_loadstudy('filename', [cfg.study_name, '.study'],...
    'filepath', PATHOUT);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

%% Repeated clustering of ICs
% depending on the number of iterations this can take quite some time, but the iterations are saved on the disk and can
% be loaded, so this is used here. feel free to delete them and compute it yourself!
[STUDY, ALLEEG, EEG] = bemobil_repeated_clustering_and_evaluation(STUDY, ALLEEG, EEG,...
    cfg.outlier_sigma, cfg.n_clust, cfg.n_repetitions, cfg.ROI_talairach, cfg.repeated_clustering_weights,...
    0, 1, STUDY.filepath,[cfg.study_name, '_clean_c'],...
    fullfile(STUDY.filepath,'clustering'),...
    [cfg.study_name, '_clustering_solutions_' num2str(cfg.n_repetitions)],...
    fullfile(STUDY.filepath,'clustering'), 'multivariate_data_SMC_1000');
close all;

disp(['Done with ', mfilename])
end % end function
