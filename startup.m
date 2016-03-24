function startup

chPath = fileparts(mfilename('fullpath'));

cePaths = {
    fullfile(chPath, '..', '..', 'Matlab', 'Helper');
    fullfile(chPath, 'Implementation');
    fullfile(chPath, 'Implementation', 'algorithms');
    fullfile(chPath, 'Implementation', 'helpers');
    fullfile(chPath, 'Implementation', 'helpers', 'twincat');
    fullfile(chPath, 'Implementation', 'mat');
    fullfile(chPath, 'Implementation', 'plot-tools');
    fullfile(chPath, 'Implementation', 'robots');
};

registerPaths(cePaths{:});

end