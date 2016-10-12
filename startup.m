function startup

chPath = fileparts(mfilename('fullpath'));

cePaths = {
    chPath;
    genpath(fullfile(chPath, 'utils'));
};

registerPaths(cePaths{:});

end
