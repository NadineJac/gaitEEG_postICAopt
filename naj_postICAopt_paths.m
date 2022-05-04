function PATH = naj_postICAopt_paths()
% set all relevant folders, create them if they do not exist yet
% add toolbox paths, start eeeeglab w/o GUI
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

if strcmp(getenv('COMPUTERNAME'), 'LAPTOP-796NEANK')
    PATH.main = 'E:\nadine\otto_projects\naj_gait_postICAopt';
    PATH.eeglab = 'E:\nadine\MATLAB\eeglab2020_0';
    
elseif strcmp(getenv('COMPUTERNAME'), 'DESKTOP-5V16SQU')
    PATH.main = 'D:\PhD\otto_projects\naj_gait_postICAopt';
    PATH.eeglab = 'D:\PhD\MATLAB\eeglab2020_0';
    else
    error(['Define study directories for ',getenv('COMPUTERNAME'), ' in ', mfilename()]);
end

PATH.code       = fullfile(PATH.main, 'code');
PATH.codebase   = fullfile(PATH.code, 'codebase');

PATH.config    = fullfile(PATH.code); %, 'rawdata'

% neurophsysiological derivates
PATH.derivates  = fullfile(PATH.main,'derivates');
PATH.ICAdecomp  = fullfile(PATH.derivates, 'ICA_decomp');
PATH.gaitERP    = fullfile(PATH.derivates, 'gaitERP');
PATH.study      = fullfile(PATH.derivates, 'study');

PATH.clean_a   = fullfile(PATH.derivates, 'clean_a');
PATH.clean_b   = fullfile(PATH.derivates, 'clean_b');
PATH.clean_c   = fullfile(PATH.derivates, 'clean_c');
PATH.clean_d   = fullfile(PATH.derivates, 'clean_d');
PATH.clean_e   = fullfile(PATH.derivates, 'clean_e');

PATH.raw   = fullfile(PATH.derivates, 'raw');

% results & figures
PATH.plotCleaning = fullfile(PATH.derivates, 'results','figures', 'Cz_ERSP_GPM');
PATH.plotFootprint = fullfile(PATH.derivates, 'results','figures', 'footprint');

% add paths
addpath(PATH.eeglab); 
addpath(genpath(PATH.code)); % add w/ subfolders
cd(PATH.code);

% create directories
createFolders(PATH);

% start eeglab
eeglab nogui