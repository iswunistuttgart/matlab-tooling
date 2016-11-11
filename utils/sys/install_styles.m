function install_styles(varargin)
% INSTALL_STYLES installes all styles stored in `styles` into the user's
% `ExportSetup` dir
%
%   INSTALL_STYLES('Name', 'Value', ...) allows setting optional inputs
%   using name/value pairs.
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Overwrite       Overwrites the styles with the ones found in this project.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-11-11
% Changelog:
%   2016-11-11
%       * Initial release



%% Define the input parser
ip = inputParser;

% Overwrite: Char. Matches {'on', 'off', 'yes', 'no'}.
valFcn_Overwrite = @(x) any(validatestring(lower(x), {'on', 'off', 'yes', 'no'}, mfilename, 'Overwrite'));
addParameter(ip, 'Overwrite', 'off', valFcn_Overwrite);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    parse(ip, varargin{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% Overwrite existing styles?
chOverwrite = parseswitcharg(ip.Results.Overwrite);



%% Do your code magic here
persistent chBasepath

% No base path of the styles found?
if isempty(chBasepath)
    chStylespath = fullpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'styles'));
    
    % Check the folder exists
    if 7 ~= exist(chStylespath, 'dir')
        throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:INSTALL_STYLES:InvalidStylesDirectory', 'No valid styles directory at %s found.', chStylespath));
    end
    
    chBasepath = chStylespath;
end

% Find all style files
stFiles = allfiles(chBasepath, 'txt');

% No styles found?
if isempty(stFiles)
    throw(MException('PHILIPPTEMPEL:MATLAB_TOOLING:INSTALL_STYLES:NoStyles', 'No styles found at %s', chBasepath));
end

% Copy each file to the user's ExportSetup directory
for iFile = 1:numel(stFiles)
    % Create target filename
    chTarget_Path = fullfile(prefdir(0), 'ExportSetup', stFiles(iFile).name);
    % If the file exists and overwrite is 'on' or the file does not exist, then
    % overwrite it
    if 2 == exist(chTarget_Path, 'file') ...
        && strcmp('on', chOverwrite) ...
        || 2 ~= exist(chTarget_Path, 'file')
        copyfile(fullfile(chBasepath, stFiles(iFile).name), chTarget_Path);
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
