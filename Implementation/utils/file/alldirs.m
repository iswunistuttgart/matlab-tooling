function Dirs = alldirs(Dir, varargin)
% ALLDIRS Finds all files in directory DIR and returns them in a structure
%
%   FILES = ALLDIRS(DIR) scans through directory DIR and returns all files. This
%   is basically the same as calling the `dir` function. However, the power lies
%   in the magic of this function. Read more to see what is meant.
%
%   FILES = ALLDIRS(DIR, 'csv') scans through directory DIR and returns all
%   files with extension 'csv' (or, '.csv' to be more precise).
%
%   See also: dir



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-09
% Changelog:
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
% File prefix: char
chPrefix = ip.Results.Prefix;
% File suffix: char
chSuffix = ip.Results.Suffix;
% Include system: char, {'yes', 'no'}
chIncludeSystem = ip.Results.IncludeSystem;




%% Magic, collect the files
chPath = sprintf('%s%s%s*%s', chDir, filesep, chPrefix, chSuffix);

% Get all the files in the given directory
stFiles = dir(chPath);

% Proceed only from here on if there were any files found
if ~isempty(stFiles)
    % Do we need to filter the system files like '.' and '..'?
    if strcmpi(chIncludeSystem, 'no')
        % Remove all system directories from the found items
        stFiles(ismember({stFiles(:).name}, {'.', '..'})) = [];
    end
    
    % Remove files
    stFiles = stFiles([stFiles.isdir]);
end




%% Assign output quantities
Dirs = stFiles;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
