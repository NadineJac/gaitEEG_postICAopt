function   runScript =  naj_scriptModified(scriptName, outputFile)
% check whether output file exists, if so, only run script if it has
% been modified in the meantime
% also check scripts that are being called!
%
% INPUT
% - scriptName  - [string] fullfile of script that should be checked
% - outputFile  - [cell] cell w/ fullfiles of output files which should be
% checked (existence/last modified)
%
% OUTPUT
% - runScript    - [logical] indicating whether script should be run again
% [1 = yes, 0 = no]
    my_script = dir(scriptName);
    
if ~isfile(outputFile) % check whether output exist
    runScript = 1;
    fprintf(['[\b',my_script.name, ' has not been run. Running it now!]\b\n']);
else % get last modification dates of script + output
    my_file = dir(outputFile);
    if my_script.datenum > my_file.datenum % script has been modified run it again
        runScript = 1;
        fprintf(['[\b',my_script.name, ' has been modified. Run again!]\b\n']);
    else
        runScript = 0;
        fprintf([my_script.name, ' has not been modified. Do not run again.\n']);
     
    end
end
end