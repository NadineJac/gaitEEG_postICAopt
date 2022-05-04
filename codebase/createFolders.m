function createFolders(PATH)
%% createFolders
% check whether folders specified at all fiels of PATH structure exist, if
% not create them
FIELDNAMES = fieldnames(PATH);
for fi = 1:length(FIELDNAMES)
    if ~ exist(PATH.(FIELDNAMES{fi}), 'dir')
        mkdir(PATH.(FIELDNAMES{fi}));
    end
end
end