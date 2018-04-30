function create_docs()
% CREATE_DOCS creates the docs for project MATLAB-Tooling from each functions'
%   help block



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-08-17
% Changelog:
%   2017-08-17
%       * Wiki directory is now created, if it does not exist
%       * Replace sort_nat() function with MATLAB built-in `sortrows` function
%   2017-01-05
%       * Update to support other formats of H1 lines such as
%           `%funcname`
%           `% funcname`
%   2016-10-23
%       * Initial release



%% Do your code magic here
% Persistently store the path of this file
persistent chBasepath chBasepath_Wiki;

% If the file is run the first time, chBasepath will be empty
if isempty(chBasepath)
    % Get the location of this file as all code is relative to here
    chBasepath = fileparts(mfilename('fullpath'));
    chBasepath_Wiki = fullfile(chBasepath, 'wiki');
end

% Check the directory of the wiki exists
assert( (7 == exist(chBasepath_Wiki, 'file') || mkdir(chBasepath_Wiki)) && isdir(chBasepath_Wiki), 'PHILIPPTEMPEL:MATLAB_TOOLING:CREATE_DOCS:DirectoryNotFound', 'Directory [%s] was not found at [%s] and could not be created. Please checkout the wiki repository into the aforementioned directory.', 'wiki', escapepath(chBasepath));

% Open the file containing a markdown-formatted list of all functions
[fidFunctions, chMessage] = fopen(fullfile(chBasepath_Wiki, 'functions.md'), 'w');

% Create a cleanup object
coCleanup = onCleanup(@() in_onCleanup({fidFunctions}));

% Collect all functions
ceFunctions = in_collectFunctions(chBasepath);

if ~isempty(chMessage)
    throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:CREATE_DOCS:FailedOpenFile', 'Failed opening file [%s] with error; %s', sprintf('%s.md', chFunctionname), chMessage));
end

% Write the file "header"
fprintf(fidFunctions, '# List of Functions\n\n');
fprintf(fidFunctions, '## Alphabetical list\n\n');

% Sort the functions naturally alphabetically
ceFunctions_Alphabetical = sortrows(ceFunctions);

% Process all functions alphabetically
for iFunc = 1:numel(ceFunctions_Alphabetical)
    chFunction_Path = which(ceFunctions_Alphabetical{iFunc});
    % Get the function "namespace"
    ceNamespace = strsplit(strrep(fileparts(chFunction_Path), chBasepath, ''), filesep);
    [~, chFunction_Name, ~] = fileparts(chFunction_Path);
    
    % Get the H1 comment line from the file
    chH1Comment = in_getH1Comment(chFunction_Name);
    
    % Write a list-item line for the function linking to its markdown file
    fprintf(fidFunctions, '  * [%s](wiki/%s)', chFunction_Name, chFunction_Name);
    % Append the H1 comment if it's not empty
    if ~isempty(chH1Comment)
        fprintf(fidFunctions, ' %s', chH1Comment);
    end
    % Newline
    fprintf(fidFunctions, '\n');
    
    
%     % Create a namespace folder inside the wiki if it does exist yet
%     if 7 ~= exist(fullfile(chBasepath_Wiki, ceNamespace{:}), 'file')
%         mkdir(fullfile(chBasepath_Wiki, ceNamespace{:}));
%     end
%     
%     % Grab the function/file name from the file path
%     [~, chFunctionname, ~] = fileparts(which(ceFunctions{iFunc}));
%     % Create the path to the file's docs directory and file's doc file.
%     chDocs_Dir = fullfile(chBasepath_Wiki, ceNamespace{:});
%     chDocs_Path = fullfile(chDocs_Dir, sprintf('%s.md', chFunctionname));
%     
%     % Get the help string for the function
%     chHelp = evalc(sprintf('help %s', chFunctionname));
%     
%     % Write the function help to a file
%     try
%         [fidDoc, chMessage] = fopen(chDocs_Path, 'w');
%         if ~isempty(chMessage)
%             throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:CREATE_DOCS:FailedOpenFile', 'Failed opening file [%s] with error; %s', sprintf('%s.md', chFunctionname), chMessage));
%         end
%         
%         % Write help string to the document
%         fprintf(fidDoc, '%s', chHelp);
%         
%         % Close the file
%         fclose(fidDoc);
%     catch me
%         warning(me.message, me.identifier);
%         continue
%     end
end


end


function ceFunctions = in_collectFunctions(chDir)

% Holds return value
ceFunctions = cell(0);

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
    %   - File 'Contents.m' created from Contents Report
    if strcmp(stFile.name(1), '.') ...
            || ~strcmp(stFile.name(end-1:end), '.m') ...
            || ~isempty(strfind(stFile.name, 'Untitled')) ...
            || strcmp(stFile.name, 'Contents.m')
        continue
    end

    % Get the function name from the filename
    chFunctionname = stFiles(iFile).name(1:end-2);

    % Check the file is a function and not a script
    if 2 == exist(chFunctionname, 'file')
        ceFunctions = [ceFunctions, chFunctionname];
    end
end

% Process each directory contained in the current directory from here on
for iDir = 1:numel(stDirs)
    % Quicker, more handy access to the current directory
    stDir = stDirs(iDir);

    % Skip
    %   - directories that should be excluded from the docs
    %   - system or hidden folders
    if 2 == exist(fullfile(chDir, stDir.name, '.docsignore'), 'file') ...
            || strcmp(stDir.name(1), '.')
        continue
    end
    
    % Merge the struct of functions with the 
    ceDirFunctions = in_collectFunctions(fullfile(chDir, stDir.name));
    ceFunctions = [ceFunctions, ceDirFunctions];
end

end


function chH1Comment = in_getH1Comment(chFunction_Name)

% Default comment
chH1Comment = '';

% Get the path of the file
chFunction_Path = which(chFunction_Name);

% Open the file
[fidFunction, chMessage] = fopen(chFunction_Path, 'r');

% Got an error opening the file?
if ~isempty(chMessage)
    throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:CREATE_DOCS:FailedOpenFile', 'Failed opening file [%s] with error: %s', escapepath(chFunction_Path), chMessage));
end

% Holds a counter to the current line
iCurrLine = 0;
iLineH1 = 2;

% Cleanup objects are nicer than manually dealing with errors and open files
coCleanup = onCleanup(@() fclose(fidFunction));

% Loop over the lines of the file
while ~feof(fidFunction)
    % Advance the line counter
    iCurrLine = iCurrLine + 1;
    
    try
        % Get the current line
        ceLine = deblank(fgetl(fidFunction));
        
        % Skip empty lines or the first line
        if isempty(ceLine) || iCurrLine == 1
            continue
        end
        
        % Skip lines containing '#codegen'
        if ~isempty(strfind('#codegen', ceLine))
            iLineH1 = 3;
            
            continue
        end
        
        % If the current line number matches the expected line number of the H1
        % comment, we will pass the line to the H1 Comment
        if iCurrLine == iLineH1
            chH1Comment = ceLine;
        end
        
        break
    catch me
        warning('PHILIPPTEMPEL:MATLAB_TOOLING:CREATE_DOCS:LineProcessingFailed', 'Failed processing line %i of file [%s] with error: %s', iCurrLine, escapepath(chFunction_Path), me.message);
    end
end

% Post-process the H1 line if it's not empty
if ~isempty(chH1Comment)
    % Split the H1 line into a cell array
    ceH1Comment = strsplit(chH1Comment, ' ');
    % H1 line contains a comment-character? Then remove it
    ceH1Comment(strcmpi('%', ceH1Comment)) = [];
    % H1 line contains the function name? Then remove it
    ceH1Comment(strcmpi(chFunction_Name, ceH1Comment)) = [];
    % H1 line contains the function name directly preceeded with a
    % comment-character? Then remove it
    ceH1Comment(strcmpi(['%' , chFunction_Name], ceH1Comment)) = [];
    % Join H1 line cell array back to a char array
    chH1Comment = strjoin(ceH1Comment, ' ');
end


end


function in_onCleanup(ceOpenFiles)

for iFile = 1:numel(ceOpenFiles)
    try
        fclose(ceOpenFiles{iFile});
    catch me
        warning(me.message, me.identifier);
    end
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
