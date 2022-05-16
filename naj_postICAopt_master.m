%% naj_postICAopt_master
% Comparing five differennt pipelines post ICA decomposition to find the
% otimal one for this dataset.
%
% preprocessing up to this point described by naj_neurCorrYoung_master
%
% this is the master script, calling all other scripts in the correct oder

%% preparation
% copy ICA decomposed data from naj_neurCorrYoung_master up to 
% naj_neurCorrYoung_ICAdecomp (scrips available at [LINK HERE])
% into yourfolder/derivates/ICA_decomp

% config files
PATH = naj_postICAopt_paths; %'LAPTOP-796NEANK',DESKTOP-5V16SQU --> define for further machines
cfg  = naj_postICAopt_config(fullfile(PATH.config, 'naj_postICAopt_cfg.mat')); % processing params
sii  = cfg.subjects;

%% gait ERSP of raw data
task_gaitERSP_raw(sii, PATH, cfg); % time-frequency decomposition of raw data
% and aggregating over subjects (as comparison to artifact attenuation
% pipelines)

%% artifact attenuation
%% A only keep ICs brain >.7 (Reiser, Scanlon)
fieldName = 'clean_a';
task_clean_a(sii, PATH, cfg); % reject ICA components
task_gaitERSP_clean(sii, PATH, cfg, fieldName);% time-frequency decomposition
task_GA_gaitERSP_clean(sii, PATH, fieldName); % aggregate over subjects

%% B default IClabel (remove eye and muscle >.9)
fieldName = 'clean_b';
task_clean_b(sii, PATH, cfg); % reject ICA components
task_gaitERSP_clean(sii, PATH, cfg, fieldName);% time-frequency decomposition
task_GA_gaitERSP_clean(sii, PATH, fieldName); % aggregate over subjects

%% prepare repetitive clustering
% generate gait ERPS required for clustering (cealn_c and clean_d)
task_gaitERP(sii, PATH, cfg); 

%% C repetitive clustering (BeMoBil)
fieldName = 'clean_c';
task_clean_c(sii, PATH, cfg); % cluster data
cluster_sii = task_gaitERSP_cluster(PATH, cfg, fieldName); % load info from 
% best fitting cluster and only keep data from included subjects and components
task_gaitERSP_clean(cluster_sii, PATH, cfg, fieldName); % time-frequency decomposition
task_GA_gaitERSP_clean(cluster_sii, PATH, fieldName);% aggregate over subjects

%% D repetitive clustering of dipolar ICs
fieldName = 'clean_d';
task_clean_d(sii, PATH, cfg);% cluster data
cluster_sii = task_gaitERSP_cluster(PATH, cfg, fieldName);% load info from 
% best fitting cluster and only keep data from included subjects and components
task_gaitERSP_clean(cluster_sii, PATH, cfg, fieldName);% time-frequency decomposition
task_GA_gaitERSP_clean(cluster_sii, PATH, fieldName);% aggregate over subjects

%% E remove eye ICs and spectral PCA
% This script is based on work by Martin Seeber shared during an workshop,
% we are currently awaiting his reply before sharing the respective script
% online (May 2022). This unfortunatly means that this pipeline cannot be
% run as is without producing errors from this point on
% please call the respective functions without 'clean_e' string to compare the other pipelines
task_clean_e(sii, PATH, cfg); % spectral cleaning (including time-frequency decomposition)
task_GA_gaitERSP_clean(sii, PATH, 'clean_e');% aggregate over subjects

%% Group average evaluation
% Footprint
task_GA_footprint(PATH, cfg,...
    {'raw', 'clean_a', 'clean_b', 'clean_c', 'clean_d', 'clean_e'});%
plot_footprint(PATH, cfg,...
    {'raw', 'clean_a', 'clean_b', 'clean_c', 'clean_d', 'clean_e'});

% ERSP and GPM at Cz
plot_Cz_ERSP_all_clean(PATH, cfg,...
    {'raw', 'clean_a', 'clean_b', 'clean_c', 'clean_d', 'clean_e'});

% cluster ERSP and GPM
plot_cluster_ERSP(sii,PATH,cfg, {'clean_c', 'clean_d'});
