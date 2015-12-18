if exist(fullfile(pwd, '..', '..', 'Matlab', 'Helper', 'startup.m'), 'file')
    try
        run(fullfile(pwd, '..', '..', 'Matlab', 'Helper', 'startup.m'));
    catch exc
        warning('PHILIPPTEMPEL:startup:runStartupFailed', 'Could not run startup script of the helpers because %s', strrep(exc.message, '\', '\\'));
    end
end

addpath(fullfile(pwd, 'Implementation'));
addpath(fullfile(pwd, 'Implementation', 'algorithms'));
addpath(fullfile(pwd, 'Implementation', 'helpers'));
addpath(fullfile(pwd, 'Implementation', 'mat'));
addpath(fullfile(pwd, 'Implementation', 'plot-tools'));
addpath(fullfile(pwd, 'Implementation', 'robots'));
addpath(fullfile(pwd, 'Implementation', 'tests'));
addpath(fullfile(pwd, 'Implementation', 'wip'));