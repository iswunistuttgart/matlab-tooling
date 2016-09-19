function startup

chPath = fileparts(mfilename('fullpath'));

cePaths = {
    fullfile(chPath, 'Implementation');
    genpath(fullfile(chPath, 'Implementation', 'utils'));
};

registerPaths(cePaths{:});

end
