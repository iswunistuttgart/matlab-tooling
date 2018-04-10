function D = alldirs(Dir, varargin)
% ALLDIRS Finds all files in directory DIR and returns them in a structure
%
%   DIRS = ALLDIRS(DIR) scans through directory DIR and returns all
%   directories. This basically behaves like the built-in `dir` function,
%   however, provides some very convenient additional features.
%
%   DIRS = ALLDIRS(DIR, 'Name', 'Value', ...) allows setting optional inputs
%   using name/value pairs.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Prefix              Prefix of folder names to match. Performs a matching of
%                       the folder name to begin with PREFIX.
%
%   Suffix              Suffix of folder names to match. Performs a matching of
%                       the folder name to end in SUFFIX.
%
%   IncludeSystem       Toggle flag whether to include '.' and '..' directories.
%                       Possible values are
%                       'on', 'yes'
%                       'off', 'no'
%                       Defaults to 'off'
%
%   See also: dir



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-04
% Changelog:
%   2018-04-04
%       * Update help block
%   2016-09-09
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

% Find directories with a certain folder name prefix?
valFcn_Prefix = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Prefix');
addParameter(ip, 'Prefix', '', valFcn_Prefix);

% Find directories with a certain folder name suffix?
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
    throwAsCaller(me);
end



%% Assign parser variables to local variables
% Get the directory to look at: char
chDir = fullpath(ip.Results.Dir);
% File prefix: char
chPrefix = ip.Results.Prefix;
% File suffix: char
chSuffix = ip.Results.Suffix;
% Include system: char, {'yes', 'no'}
chIncludeSystem = ip.Results.IncludeSystem;



%% Magic, collect the files
chPath = sprintf('%s%s%s*%s', chDir, filesep, chPrefix, chSuffix);

% Get all the files in the given directory
stDirs = dir(chPath);

% Proceed only from here on if there were any files found
if ~isempty(stDirs)
    % Do we need to filter the system files like '.' and '..'?
    if strcmpi(chIncludeSystem, 'no')
        % Remove all system directories from the found items
        stDirs(ismember({stDirs(:).name}, {'.', '..'})) = [];
    end
    
    % Remove files
    stDirs = stDirs([stDirs.isdir]);
end



%% Assign output quantities
D = stDirs;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
