function [Flag] = inpath(varargin)
% INPATH Checks whether the given path is part of MATLAB's environment path
%
%   Inputs:
%
%   PATH        Path to check for existence. Can be absolute or relative.
%
%   Outputs:
%
%   FLAG        True of PATH is known in MATLAB's environment path, FALSE
%       otherwise.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-12
% Changelog:
%   2016-09-12
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Processor. Char. Non-Empty
valFcn_Path = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Path');
addRequired(ip, 'Path', valFcn_Path);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
%     varargin = [{Fullpath}, varargin];
    
    parse(ip, varargin{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end


%% Parse IP results
% Get the path passed
chPath = ip.Results.Path;



%% Do your code magic here

% Get list of all paths known to MATLAB
cePathList = regexp(path, pathsep, 'Split');

% And find the path in the list of all paths
Flag = ismember(fullpath(chPath), cePathList);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
