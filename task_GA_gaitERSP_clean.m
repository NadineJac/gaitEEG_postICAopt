function task_GA_gaitERSP_clean(sii, PATH, fieldName)
% Load and average subject-specific ERSPs and save as group average. 
% with subject specific gait ERSPs stored as file_in at PATHIN
%
% INPUT
% - sii: vector of subject IDs to be processed
% - PATH:   structure with all paths leading to diff processing steps
% generated in naj_neurCorGait_paths
% - cfg:    structure with all processing variables generated in naj_neurCorGait_config
%
% OUTPUT
% [FILE] gaitERSP with single subject data at dim 4
% stored as file_out in PATHOUT
%
% version 1.0, written by Nadine Jacobsen, Uni Oldenburg, April 2022

% directories
PATHIN = PATH.(fieldName);
PATHOUT = PATH.(fieldName);

for si = sii % loop through all subjects

    % sub ID
    ID = sprintf('sub-%03d',si);
    
    % filenames:
    % input file
    file_in = fullfile(PATHIN,ID, [ID,'_', fieldName,'_ERSP.mat']);
    % output file
    file_out = fullfile(PATHIN,['sub-all_', fieldName,'_ERSP.mat']); % file
    % report files
    reportNames = {'reportName1.png'};
    
    % check whether output file exists, if so, only run script if it has
    % been modified in the meantime
    %also check scripts that are being called!
    runScript = naj_scriptModified([mfilename('fullpath'),'.m'], file_out);
    if runScript
        load(file_in)
        TMP.ERSP(:,:,:,si) = gaitERSP.ERSP;
        TMP.GPM(:,:,:,si) = gaitERSP.GPM;
        TMP.chanlocs = gaitERSP.chanlocs;
    end
    fprintf('Done with sub-%03d!\n', si);
end % subject loop
gaitERSP = TMP;
save(file_out, 'gaitERSP');

disp(['Done with ', mfilename])

end
