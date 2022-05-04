function cfg = naj_postICAopt_config(file_out)%% Config file
% Configuration parameters for the study.
% These are all the relevant parameters for the analysis organized
% according to the script they are used in
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

subjects = 1:19;
tmp = dir(file_out);
info_file = fullfile(tmp.folder, 'naj_postICAopt_info.mat');
if isfile(info_file)
    load(info_file);
else
    procInfo = [];
    for si = subjects
        procInfo(si).ID  = sprintf('sub-%03d', si);
    end
    save(info_file, 'procInfo');
end

% prune data
startExperiment = {'start_restEEG'};

% sampling rate: downsample EEG data
sampling_rate = 250;

% channel indices of diff sensors
idx_EEG_chan = 1:64;
idx_headAcc_chan = 65:67;

% Band-pass filter limits.
bandpass_fmin = 0.2;  % Hz
bandpass_fmax = 60;  % Hz passband --> cut-off 67.5 Hz

% ASR parameters
ASR_baseline_events = {'start_standing', 'end_standing'};
ASR_FlatlineCriterion = 5;
ASR_ChannelCriterion = 0.8;
ASR_LineNoiseCriterion = 4;

% IC label thresholds
IC_eye = .9;
IC_muscle = .9;
IC_brain = .7;

% gait ERSPs
V_tsh = 300; % threshold for marking "bad" data sections to be excluded, as Seeber in his scripts
f_axis = 2:2:60; % data filtered at 60 so going up until 80 does not make sense!
t_axis = 1:100;
FWHM = log2(f_axis);
N_freq = length(f_axis);
N_ds = 8;
gait_event = 'RightHS'; % event for extracting gait epochs and warping
gait_event_order = {'RightHS', 'LeftTO', 'LeftHS', 'RightTO', 'RightHS'};% order of gait events within each gait cycle
gait_timeNextHs = [.5 1.5]; % time of next RHS in s
cond_stand ={'start_standing', 'end_standing'};
cond_walk = {'start_easy_button', 'end_easy_button';...
    'start_easy', 'end_easy';...
    'start_difficult_button', 'end_difficult_button'
    'start_difficult', 'end_difficult'};
% f_surface = {'even', 'even', 'uneven', 'uneven'};
% f_task = {'DT', 'ST', 'DT', 'ST'};
% cond_names = {'DTeasy', 'STeasy', 'DTdifficult','STdifficult'};


% % gait ERPs
% gait_epoch = [0 1.5]; % length of epoch in s
% gait_timeNextEV = [25 1500]; %delay (ms) ind which next gait events can occur

% footprint ________________________________________
gait_event_newLat   = [1 18 50 68 100]; % % new latencies in pnts
pntsRHS             = gait_event_newLat(1):gait_event_newLat(2);          % double support following right-heel strike
pntsLHS             = gait_event_newLat(3):gait_event_newLat(4);         % double support following left-heel strike
pntsDouble          = [pntsRHS,pntsLHS];

% channel indices (dim 1 of the time-frequency decomposed data)
% [ADAPT] channel selection basel on you layout (here: custom 64ch layout)
lateralChanIdx = [1,4,5,6,9,10,15,16,17,18,20,21,26,27,30,31,32,33,35,37,41,44,45,46,48,49,51,52,53,57,61,64]; % index of channels labelled as lateral
neckChanR      = [49 52 18 51];  % index of channels located over the right side of the neck
neckChanL      = [45 48 46 16];  % index of channels located over the left side of the neck

% radar plot parameters
axes_interval = 4;% Axes properties
axes_precision = 2;
axes_display = 'one';
marker_type = 'none';
axes_font_size = 10;
label_font_size = 12;
axes_labels = {'B','C','D','E','F'}; % Axes labels
fill_option = 'off';
orange = [230 159 0]/255;
purple = [204 0 153]/255;
lightpurple = [255 93 213]/255;
blue = [0 114 178]/255;
lightblue = [86 180 233]/255;
% add two more colors for clustering
green = [0 158 115]/255;
edgeColors = [orange;blue;lightblue;purple;lightpurple;green];

line_width = 1;
axes_limits = repmat([-1; 2],1,6);

%% EEGLAB STUDY
task = 'overground walking';

%% preclustering array
clustering_weights = struct('spec',1,'erp',1,'scalp',1,'dipoles',3);
freqrange = [3 25];
timewindow = []; % full time window

%% repetitive clustering
study_name = 'naj_walk';
% subjects,
% ICs/subjects,
% normalized spread,
% mean RV,
% distance from ROI,
% mahalanobis distance from median of multivariate distribution (put this very high to get the most "normal" solution)
repeated_clustering_weights = [3 -1 -1 -1 -2 -1];

n_clust = 50; % usually having a few less than the number of ICs is a good idea to make sure they all get some entries
outlier_sigma = 3; % to remove ICs that do not fit in a cluster. set to 100 to switch off
force_clustering = 0;
force_multivariate_data = 1;

n_repetitions = 1000;

clust_label = {'SMC'};
ROI_talairach = struct('x',-1,'y',-26,'z',62);

%% save
save(file_out);
cfg = load(file_out);

end
