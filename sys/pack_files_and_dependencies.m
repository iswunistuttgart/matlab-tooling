function success = pack_files_and_dependencies(Files, Target, varargin)
% PACK_FILES_AND_DEPENDENCIES packs dependent files into one folder
%
% PACK_FILES_AND_DEPENDENCIES(FILES, TARGET) packs files FILES and all their
% dependencies into directory FOLDER. This allows to have a directory with all
% files necessary to execute a certain task.
%
% PACK_FILES_AND_DEPENDENCIES(FILES, TARGET, 'Name', 'Value', ...) allows
% setting optional inputs using name/value pairs.
%
% The function will throw exceptions if something didn't go as planned and will
% display warnings in case there were errors during packaging.
%
% What this function does not do:
% * Copy data like .mat or .txt files to the chosen directory
%
%
% IMPORTANT: This function requires MATLAB's CODETOOLS package to work.
%
%
% Inputs
% 
% FILES                 A cell array containing all files that ought to be
%                       packaged.
%
% TARGET                Char array stating the directory into which files FILES
%                       should be packaged.
%
% Optional Inputs -- specified as parameter value pairs
%
% DependenciesList      Char toggle that enables {'on', 'yes'} or disables
%                       {'off', 'no'} the creation of a file called
%                       'MatlabDepdendencies.txt' in the target directory which
%                       will list all MATLAB dependencies necessary to run the
%                       packaged code. This includes the basic MATLAB software
%                       as well as possibly other toolboxes.
%
% Overwrite             Allows the user to force overriding the directry in case
%                       it already exists. This will not require user input for
%                       confirming overriding directory contents and is thus
%                       good for automated scripts.
%
% See also: MATLAB.CODETOOLS.REQUIREDFILESANDPRODUCTS



%% File information
% Author: Christoph Hinze <christoph.hinze@isw.uni-stuttgart.de>
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-19
% Todo:
%   * Scan source code of files for keywords like LOAD, TEXTREAD or FOPEN, this
%   still has to be done manually.
% Changelog:
%   2018-05-19
%       * Add `narginchk` and `nargoutchk`
%   2017-08-31
%       * Introduce input parser for input parsing
%       * Turn argument 'bGenerateMatlabDepList' into 'DependenciesList' and
%       make it an (optional) char array much like we are used to it by MATLAB
%       itself.
%       * Add input argument list option 'Override' to enfore overriding content
%       without asking for user permission. This can come in handy with
%       automated scripts.
%       * Update code signature to require a cell array as the first argument.
%       This makes the code more robust and removes all sorts of argument
%       checking in the background
%       * Adjust help block to match other files in this package.
%       * Add file footer
%   2015-11-19
%       * Initial release



%% Backwards compatability

% Backwards compatability for 
% pack_files_and_dependencies(file, folder, ...)
if ischar(Files)
    Files = {Files};
end

% Backwards compatability for
% pack_files_and_dependencies(files, folder, true/false)
if nargin == 3 && islogical(varargin{1})
    chLogicalConversion = {'off', 'on'};
    varargin{1} = chLogicalConversion{varargin{1} + 1};
end



%% Input argument checking
narginchk(2, 6);
nargoutchk(0, 1);



%% Define the input parser
ip = inputParser;

% Files: required; char or cell; non-empty
valFcn_Files = @(x) validateattributes(x, {'char', 'cell'}, {'nonempty'}, mfilename, 'Files');
addRequired(ip, 'Files', valFcn_Files);

% Target: required; char; non-empty
valFcn_Target = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Target');
addRequired(ip, 'Target', valFcn_Target);

% AnchorSpec. Cell or numeric. Non-empty.
valFcn_DependenciesList = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'DependenciesList'));
addOptional(ip, 'DependenciesList', 'off', valFcn_DependenciesList);

% PlotStyle: Char. Matches {'2D', '3D'}.
valFcn_Overwrite = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Overwrite'));
addParameter(ip, 'Overwrite', '', valFcn_Overwrite);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % PACK_FILES_AND_DEPENDENCIES(FILES, TARGET)
    % PACK_FILES_AND_DEPENDENCIES(FILES, TARGET, 'Name', 'Value', ...)
    narginchk(2, Inf);
    % PACK_FILES_AND_DEPENDENCIES(FILES, TARGET)
    nargoutchk(0, 0);
    
    args = [{Files}, {Target}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Files to process
ceFiles = ip.Results.Files;
% Target directory
chTargetDir = fullpath(ip.Results.Target);
% Create dependencies list?
chCreateDependenciesList = parseswitcharg(ip.Results.DependenciesList);
% Name of the dependencies list
chDependenciesFile = 'MatlabDependencies.txt';
% Force overwriting without asking?
chOverwrite = parseswitcharg(ip.Results.Overwrite);



%% Do the packaging

% Check the target directory exists
loTargetExists = exist(chTargetDir, 'dir') == 7;

% If the target folder exists ask for permission to overwrite
if loTargetExists && ~isempty(allfiles(chTargetDir)) && ~strcmp('on', chOverwrite)
    chOverwrite = '';
    
    % As long as the user isn't deciding on 'no' for overwriting the files, ask
    % him/her what to do now
    while ~ ( strcmpi(chOverwrite, 'y') || strcmpi(chOverwrite, 'n') )
        chOverwrite = input('The specified target directory already exists. Nevertheless use this directory and override contents with the same name? (y/N) ', 's');
    end %while
    
    % User said 'n' to overwriting?
    if strcmpi(chOverwrite, 'n')
        % Then bail out
        throwAsCaller(MException('ISWUNISTUTTGART:MATLAB_TOOLBOX:PACKFILESANDDEPENDENCIES:NoOverwrite', 'Bailing out. Will not overwrite existing folder.'));
    end
elseif ~loTargetExists
    % Create target directory
    mkdir(chTargetDir);
end

% No files given?
if isempty(ceFiles)
    ceFiles = arrayfun(@(st) st.name, allfiles(pwd, 'm'), 'UniformOutput', false);
% One single file given
elseif ischar(ceFiles)
    ceFiles = {ceFiles};
end

% Check existence of all files
for iFile = 1:length(ceFiles)
   if exist(ceFiles{iFile},  'file') ~= 2
      warning('File does not exist. Skipping %s.', escapepath(ceFiles{iFile}));
      ceFiles(iFile) = [];
   end
end

 % No files left because all of them vanished?
if isempty(ceFiles)
    throwAsCaller(MException('ISWUNISTUTTGART:MATLAB_TOOLBOX:PACKFILESANDDEPENDENCIES:NoFiles', 'No Files found.'));
end



%% Package files

% Trouble MATLAB CodeTools' function to get all the required files
[ceFiles, stProducts] = matlab.codetools.requiredFilesAndProducts(ceFiles);

% Loop over all given files
for iFile = 1:length(ceFiles)
    % Conver the file path to somethign that's understood for copying
    [f, d] = path2copyable(ceFiles{iFile});
    % If the target directory does not exist (in case of packages or classes
    % possible)
    if 7 ~= exist(fullfile(chTargetDir, d), 'dir')
        % Create the target folder
        mkdir(fullfile(chTargetDir, d));
    end
    % Now copy the file to its target directory
    if ~copyfile(ceFiles{iFile}, fullfile(chTargetDir, d, f), 'f')
        warning('ISWUNISTUTTGART:MATLAB_TOOLBOX:PACKFILESANDDEPENDENCIES:FileNotCopied', 'File %s could not be copied.', escapepath(ceFiles{iFile})); 
    end
end

% Create a list of dependencies?
if strcmp('on', chCreateDependenciesList)
    chDependenciesFile_Path = fullpath(fullfile(chTargetDir, chDependenciesFile));
    % Open the dependecies file
    fidDependencies = fopen( chDependenciesFile_Path, 'w');
    
    % Failed opening the file?
    if ~fidDependencies
        warning('ISWUNISTUTTGART:MATLAB_TOOLBOX:PACKFILESANDDEPENDENCIES:DependenciesFileFailed', 'Error writing the dependencies file in %s.', escapepath(chDependenciesFile_Path));
    else
        % Write file "header"
        fprintf(fidDependencies, 'MATLAB-dependencies to run files in this directory:\n');
        fprintf(fidDependencies, '-----------------------------\n\n');
        
        % Write all dependencies into the file
        arrayfun(@(stDep) cellfun(@(row) fprintf(fidDependencies, '%s\n', row), printstruct(stDep, 'Structname', 'Product Dependency')), stProducts, 'UniformOutput', false);

        % Close file again
        fclose(fidDependencies);
    end
end

% Get the last warning
[~, chWarnID] = lastwarn;
% Check if the last warning's ID was created by this function
loSuccess = ~contains(chWarnID, 'ISWUNISTUTTGART:MATLAB_TOOLBOX:PACKFILESANDDEPENDENCIES');



%% Assign output quantities
success = loSuccess;


end


function [f, d] = path2copyable(p)
%% PATH2COPYABLE converts a file path to something copyable
%
%   [F, D] = PATH2COPYABLE(P) converts the path P to a file into a filename F
%   and a directory D that contains the given file. If filepath P points to a
%   packaged or classed file, then D will be the directory necessary to create
%   and F will be the target filename. If filepath P points to a file not within
%   a package, D will be empty
%
%   Inputs
%
%   P                   Char of a file path to a file to inspect.
%
%   Outputs:
%
%   F                   Filename of the file to copy.
%
%   D                   Directory of the file in case it is inside a package or
%                       is a class.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-19
% Changelog:
%   2018-05-19
%       * Initial release



%% Process path

try
    % [F, D] = PATH2COPYABLE(P)
    narginchk(1, 1);
    % [F, D] = PATH2COPYABLE(P)
    nargoutchk(2, 2);
    
    % Make sure P is a char array
    validateattributes(p, {'char'}, {'nonempty'}, [mfilename , '/path2copyable'], 'p');
    % And make sure P is a path to an existing file
    assert(2 == exist(p, 'file'), 'File does not exist');
catch me
    throwAsCaller(me);
end

% Split the path into directory, filename, and extension
[chFile_Path, chFile_Name, chFile_Ext] = fileparts(p);

%%% Now we will need to inspect the file path
% First, split the file path by the directory separator
ceFile_PathComponents = strsplit(chFile_Path, filesep);
% If the current path contains a class folder (starting with '@'), a package
% folder (starting with '+'), or is inside a `private` function directory,
% we need to remember that as we need to recreate this folder in the target
% directory
cePackagePath = ceFile_PathComponents(contains(ceFile_PathComponents, {'@', '+', 'private'}));

% Now we have the relative path of the file i.e., both the final filename as
% well as any class or package folder names above the file



%% Assign output quantities
% Build a valid directory name for the given file by concatenating all found
% package and class folder path components
if ~isempty(cePackagePath)
    d = fullfile(cePackagePath{:});
else
    d = [];
end

% And the filename of what to copy
f = [chFile_Name , chFile_Ext];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
