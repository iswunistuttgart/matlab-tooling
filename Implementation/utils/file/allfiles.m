function Files = allfiles(Dir, varargin)
% ALLFILES Finds all files in directory DIR and returns them in a structure
%
%   FILES = ALLFILES(DIR) scans through directory DIR and returns all files.
%   This is basically the same as calling the `dir` function. However, the power
%   lies in the magic of this function. Read more to see what is meant
%
%   FILES = ALLFILES(DIR, 'csv') scans through directory DIR and returns all
%   files with extension 'csv' (or, '.csv' to be more precise).



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
%   2016-09-09
%       * Fix bug due to incorrect referencing of 'isdir' attribute
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%   2016-07-04:
%       * Initial release



%% Pre-process arguments
% If no arguments are given
if nargin == 0
    % The directory defaults to the current
    Dir = pwd;
end



%% Define the input parser
ip = inputParser;

% Require: Marks. Must be a 3xN array
valFcn_Dir = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Dir');
addRequired(ip, 'Dir', valFcn_Dir);

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
valFcn_IncludeSystem = @(x) any(validatestring(lower(x), {'yes', 'no'}, mfilename, 'IncludeSystem'));
addParameter(ip, 'IncludeSystem', 'no', valFcn_IncludeSystem);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, Dir, varargin{:});
catch me
    throw(MException(me.identifier, me.message));
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
chIncludeSystem = ip.Results.IncludeSystem;




%% Magic, collect the files
chPath = sprintf('%s%s%s*%s.%s', chDir, filesep, chPrefix, chSuffix, chExtension);

% Get all the files in the given directory
stFiles = dir(chPath);

% Proceed only from here on if there were any files found
if ~isempty(stFiles)
    % Do we need to filter the system files like '.' and '..'?
    if strcmpi(chIncludeSystem, 'no')
        % Remove all directories from the found items
        vIsDir = [stFiles(:).isdir];
        stFiles(vIsDir) = [];
    end
    
    % Remove directories
    stFiles = stFiles(~[stFiles.isdir]);
end




%% Assign output quantities
Files = stFiles;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
