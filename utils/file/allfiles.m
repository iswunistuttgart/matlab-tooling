function Files = allfiles(varargin)
% ALLFILES Finds all files in directory DIR and returns them in a structure
%
%   FILES = ALLFILES() scans through current working directory and returns all
%   files. This is basically the same as calling the `dir` function. However,
%   the power lies in the magic of this function. Read more to see what is
%   meant.
%
%   FILES = ALLFILES(DIR) scans through directory DIR and returns all files.
%
%   FILES = ALLFILES(DIR, 'csv') scans through directory DIR and returns all
%   files with extension 'csv' (or, '.csv' to be more precise).
%
%   FILES = ALLFILES('Name', 'Value', ...) with additional options specified by
%   one or more Name,Value pair arguments.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Dir             Directory to list files from. Defaults to `pwd`.
%
%   Extension       Extension to match. Allows for easy filtering of all
%       'csv' files in a given directory. Extension must be without the trailing
%       period and also without any placeholders. Defaults to '*'.
%
%   Prefix          Prefix to match files against. When given, only files
%       starting with 'Prefix' are searched and returned. Defaults to ''.
%
%   Suffix          Suffix to match files against. When given, only files ending
%       with 'Suffix' are searched and returned. Defaults to ''.
%
%   IncludeHidden   Switch to include hidden files i.e., files starting with a
%       '.' (period). Possible options are:
%           'on', 'yes'     Include hidden files
%           'off', 'no'     Do not include hidden files
%       Defaults to 'off'.
%
%   See also: dir



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Update logic to work correctly and a bit more efficiently
%       * Rename parameter 'IncludeSystem' to 'IncludeHidden' to make it more
%       meaningful
%       * Fix bug due to incorrect referencing of 'isdir' attribute
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-07-04:
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Marks. Must be a 3xN array
valFcn_Dir = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Dir');
addOptional(ip, 'Dir', pwd, valFcn_Dir);

% Include system files like '.', or '..'?
valFcn_Extension = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Extension');
addParameter(ip, 'Extension', '*', valFcn_Extension);

% Include system files like '.', or '..'?
valFcn_Prefix = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Prefix');
addParameter(ip, 'Prefix', '', valFcn_Prefix);

% Include system files like '.', or '..'?
valFcn_Suffix = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Suffix');
addParameter(ip, 'Suffix', '', valFcn_Suffix);

% Include system files like '.', or '..'?
valFcn_IncludeHidden = @(x) any(validatestring(lower(x), {'on', 'yes', 'off', 'no'}, mfilename, 'IncludeHidden'));
addParameter(ip, 'IncludeHidden', 'off', valFcn_IncludeHidden);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Assign parser variables to local variables
% Get the directory to look at: char
chDir = fullpath(ip.Results.Dir);
% File extension to retrieve: char
chExtension = ip.Results.Extension;
% File prefix: char
chPrefix = ip.Results.Prefix;
% File suffix: char
chSuffix = ip.Results.Suffix;
% Include system: char, {'yes', 'no'}
chIncludeHidden = parseswitcharg(ip.Results.IncludeHidden);




%% Magic, collect the files
chPath = sprintf('%s%s%s*%s.%s', chDir, filesep, chPrefix, chSuffix, chExtension);

% Get all the files in the given directory
stFiles = dir(chPath);

% Proceed only from here on if there were any files found
if ~isempty(stFiles)
    % Remove the system entries '.' and '..'
    stFiles(ismember({stFiles(:).name}, {'.', '..'})) = [];
    
    % Remove directories
    stFiles([stFiles.isdir]) = [];
    
    % Do we need to filter the system files like '.' and '..'?
    if strcmpi('off', chIncludeHidden)
        % Remove all directories from the found items
        stFiles(find(1 == cell2mat(regexp({stFiles(:).name}, '^\..*')))) = [];
    end
end




%% Assign output quantities
Files = stFiles;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
