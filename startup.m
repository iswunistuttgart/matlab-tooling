if exist(fullfile(pwd, '..', '..', 'Matlab', 'helper', 'startup.m'), 'file')
    try
        run(fullfile(pwd, '..', '..', 'Matlab', 'helper', 'startup.m'));
    catch exc
        warning('PHILIPPTEMPEL:startup:runStartupFailed', 'Could not run startup script of the helpers because %s', strrep(exc.message, '\', '\\'));
    end
end

addpath(fullfile(pwd, 'algorithms'));
addpath(fullfile(pwd, 'helpers'));
addpath(fullfile(pwd, 'plot-tools'));
addpath(fullfile(pwd, 'robots'));
addpath(fullfile(pwd, 'tests'));
addpath(fullfile(pwd, 'wip'));
addpath(fullfile(pwd));