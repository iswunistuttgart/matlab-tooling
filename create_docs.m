function create_docs()
% CREATE_DOCS creates the docs for project MATLAB-Tooling from each functions'
%   help block



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-10-12
% Changelog:
%   2016-10-12
%       * Initial release



%% Do your code magic here
% Get the location of this file as all code is relative to here
chBasepath = fileparts(mfilename('fullpath'));

% Check a directory called 'docs' exists
if 7 ~= exist(fullfile(chBasepath, 'docs'), 'file')
    mkdir(fullfile(chBasepath, 'docs'));
end

% Collect all functions
stFunctions = in_collectFunctions(chBasepath);

% Process all functions


end


function stFunctions = in_collectFunctions(chDir)

% Holds return value
stFunctions = struct();

% Get all files and folders in the given directory
stFiles = allfiles(chDir);
stDirs = alldirs(chDir);

% Loop over each file
for iFile = 1:numel(stFiles)
    % Quicker, more handy access to the current file
    stFile = stFiles(iFile);

    % Skip
    %   - System or hidden files
    %   - Files not ending in '.m'
    %   - Files starting with 'Untitled'
    if strcmp(stFile.name(1), '.') ...
            || ~strcmp(stFile.name(end-1:end), '.m') ...
            || ~isempty(strfind(stFile.name, 'Untitled'))
        continue
    end

    % Get the function name from the filename
    chFunctionname = stFiles(iFile).name(1:end-2);

    % Check the file is a function and not a script
    if 2 == exist(chFunctionname, 'file')
        % Create a directory for the current file
        chDocs = evalc(sprintf('help %s', chFunctionname));
    end
end

end



function in_processDir(Dir)

% Get all files and folders in the current directory
stFiles = allfiles(Dir);
stDirs = alldirs(Dir);

% Loop over each file
if ~isempty(stFiles)
    for iFile = 1:numel(stFiles)
    end
end

% And process all folders recursively
if ~isempty(stDirs)
    for iDir = 1:numel(stDirs)
        % Quicker, more handy access to the current directory
        stDir = stDirs(iDir);
        
        % Skip
        %   - directories that should be excluded from the docs
        %   - system or hidden folders
        if 2 == exist(fullfile(Dir, stDir.name, '.docsignore'), 'file') ...
                || strcmp(stDir.name(1), '.')
            continue
        end
        
        in_processDir(fullfile(Dir, stDirs(iDir).name));
    end
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
