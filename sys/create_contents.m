function create_contents(d)
% CREATE_CONTENTS creates the CONTENTS.M files for this project



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Update to exclude directories not in path
%       * Update to exclude files name "untitled*"
%   2018-11-30
%       *  Fix broken code since ALLFILES works differently now
%   2018-05-21
%       * Initial release



%% Validate arguments
try
    % CREATE_CONTENTS()
    % CREATE_CONTENTS(P)
    narginchk(0, 1)
    
    % CREATE_CONTENTS(...)
    nargoutchk(0, 0);
    
    % Default value for first optional argument
    if nargin < 1
        d = abspath(fullfile(fileparts(mfilename('fullpath')), '..'));
    end
    
    % Validate directory to be a char
    validateattributes(d, {'char'}, {'nonempty'}, mfilename, 'dir');
    
    % Assert the given directory exists, too
    assert(7 == exist(d, 'dir'), 'Directory does not exist');
catch me
    throwAsCaller(me);
end



%% Create files
% Get the root directory where to start off
chRoot = d;

% Get all the directories of this project that contain function definitions: we
% will make use of the `projpath` file
try
    % Current working directory
    chCwd = pwd;
    
    % Change to the MATLAB-Tooling root directory
    cd(chRoot);
    
    % Create a cleanup object so that we change back to the current working
    % directory no matter what is going to happen next
    coCleaner = onCleanup(@() cd(chCwd));
    
    % Run the `projpath` function
    cePaths = projpath();
catch me
    throwAsCaller(me);
end

% Strip the paths given in cePaths (it may contain paths from `genpath()`)
for iPath = 1:numel(cePaths)
    cePaths{iPath} = strsplit(cePaths{iPath}, pathsep);
end

% Flatten the cell array
cePaths = horzcat(cePaths{:});
% Remove empty directories (there might be some because `genpath()` adds
% `pathsep()` after the last directory and that's picked up by `strsplit` into
% an empty cell
cePaths(cellfun(@isempty, cePaths)) = [];

% Count paths
nPaths = numel(cePaths);

% Now we need to loop over each directory and create a CONTENTS.M for it
for iPath = 1:nPaths
    % Create the `CONTENTS.M` file for the current directory
    makecontentsfile(cePaths{iPath}, 'force');
end

% We will now create one toplevel file that contains the Contents.M of the
% toplevel directory and all child directories
vAllContents = allfiles(chRoot, '',  'Prefix', 'Contents', 'Extension', 'm', 'Recurse', 'on');
% Create a container map of 'relative/path => contents.m'
cmContents = containers.Map('KeyType', 'char', 'ValueType', 'any');
% Loop over all contents files
for iContents = 1:numel(vAllContents)
    % Get the relative path
    chRelativePath = [filesep , strip(strrep(fullfile(vAllContents(iContents).folder), chRoot, ''), 'left', filesep) ];
    
    % Now read the `CONTENTS.M` file
    try
        % File identifier
        hFid = fopen(fullfile(vAllContents(iContents).folder, vAllContents(iContents).name), 'r');
        
        % Nicely close the file 
        coCleaner = onCleanup(@() fclose(hFid));
        
        % Read content
        ceContent = textscan(hFid, '%s', 'Delimiter', {'\n', '\r\n'});
        ceContent = ceContent{1};
        
        % Now we will process the content and filter only the lines that
        % contain a function definition
        vMatches = regexp(ceContent, '^%\s*(?<name>\w*)\s{1,}\-\s{1,}(?<desc>.*)$', 'names');
        % Now grab all the matches
        vMatches = vMatches(~cellfun(@isempty, vMatches));
        % And build a structure of arrays
        if ~isempty(vMatches)
            vMatches = vertcat(vMatches{:});
        % No matches, so empty array
        else
            vMatches = [];
        end
        
        % And assign to containers map
        cmContents(chRelativePath) = vMatches;
    catch me
        throwAsCaller(me);
    end
end

% The containers map now contains a (path => files) mapping where each file is
% a struct with fields 'name' and 'desc'

try
    % Open the target Markdown file
    hFid = fopen(fullfile(chRoot, 'FUNCTIONS.md'), 'w');
    
    % Nice cleanup object
    coCleaner = onCleanup(@() fclose(hFid));
    
    % Get all keys of the containers map
    ceNamespaces = cmContents.keys;
    
    % Get MATLAB's full search path
    ceMLPath = regexp(path, pathsep, 'split');
    
    % Write the markdown file header
    fprintf(hFid, '# List of functions');
    fprintf(hFid, '%s', newline());
    fprintf(hFid, '%s', newline());
    
    % Loop over each namespace
    for iNS = 1:numel(ceNamespaces)
        % Continue only if namespace is on path (otherwise it's useless to
        % include the directory)
        
        % Skip directories not on path (Windows is not case-sensitive)
        if ispc && ~any(strcmpi(fullfile(chRoot, ceNamespaces{iNS}), ceMLPath)) ...
            || ~ispc && ~any(strcmp(fullfile(chRoot, ceNamespaces{iNS}), ceMLPath))
            continue
        end
        
        % Write the header
        fprintf(hFid, '## %s%s', strip(ceNamespaces{iNS}, 'left', filesep), filesep);
        fprintf(hFid, '%s', newline());
        
        % Get all files of this namespace
        vFiles = cmContents(ceNamespaces{iNS});
        
        % Write the files
        for iFile = 1:numel(vFiles)
            % Skip files that are called 'untitled*'
            if contains(vFiles(iFile).name, 'untitled')
                continue
            end
            
            fprintf(hFid, '  * `%s`: %s', vFiles(iFile).name, vFiles(iFile).desc);
            fprintf(hFid, newline());
        end
        
        % Couple of new lines to separate H2 headings
        fprintf(hFid, newline());
        fprintf(hFid, newline());
    end
catch me
    throwAsCaller(me);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
