function startup

chPath = fileparts(mfilename('fullpath'));

cePaths = {
    fullfile(chPath, '..', '..', 'Matlab', 'Helper');
    fullfile(chPath, 'Implementation');
    fullfile(chPath, 'Implementation', 'algorithms');
    genpath(fullfile(chPath, 'Implementation', 'helpers'));
    fullfile(chPath, 'Implementation', 'mat');
    fullfile(chPath, 'Implementation', 'robots');
    genpath(fullfile(chPath, 'Implementation', 'utils'));
};

registerPaths(cePaths{:});

end