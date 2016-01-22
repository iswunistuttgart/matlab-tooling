if exist(fullfile(pwd, '..', '..', 'Matlab', 'Helper', 'startup.m'), 'file')
    try
        run(fullfile(pwd, '..', '..', 'Matlab', 'Helper', 'startup.m'));
    catch exc
        warning('PHILIPPTEMPEL:startup:runStartupFailed', 'Could not run startup script of the helpers because %s', strrep(exc.message, '\', '\\'));
    end
end

addpath(fullfile(pwd, 'Implementation'));
addpath(fullfile(pwd, 'Implementation', 'algorithms'));
addpath(genpath(fullfile(pwd, 'Implementation', 'helpers')));
addpath(genpath(fullfile(pwd, 'Implementation', 'mat')));
addpath(genpath(fullfile(pwd, 'Implementation', 'plot-tools')));
addpath(genpath(fullfile(pwd, 'Implementation', 'robots')));
addpath(genpath(fullfile(pwd, 'Implementation', 'tests')));
addpath(genpath(fullfile(pwd, 'Implementation', 'wip')));
