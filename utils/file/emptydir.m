function flag = emptydir(dp)
% EMPTYDIR empties a directory
%
%   Inputs:
%
%   DP                  Path of the directory to be emptied.
%
%   Outputs:
%
%   FLAG                Flag whether empyting the directory was successful



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-05-10
% Changelog:
%   2017-05-10
%       * Initial release



%% Assert arguments
% One input argument required
narginchk(1, 1);
% Maximum one output argument
nargoutchk(0, 1);



%% Define the input parser
ip = inputParser;

% Anchors. Numeric. 2D array. 3 Rows
valFcn_DirPath = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'dp');
addRequired(ip, 'dp', valFcn_DirPath);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = {dp};
    [~, args, ~] = axescheck(args{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse variables of the input parser to local parser
% Directory path
dp = ip.Results.dp;



%% Do your code magic here

% Get content of the directory
ceContent = dir(fullfile(dp));

% Flag the success state
loFlag = true;

% Loop over each content element
for iContent = 1:numel(ceContent)
    % Skip '.' and '..'
    if any(strcmp({'.', '..'}, ceContent(iContent).name))
        continue
    end

    try
        % If we are processing a directory, remove that one
        if ceContent(iContent).isdir
            rmdir(fullfile(dp, ceContent(iContent).name), 's')
        % If we are processing a file, delete that one
        elseif ~ceContent(iContent).isdir
            delete(fullfile(dp, ceContent(iContent).name));
        end
    catch
        loFlag = false;
    end
end



%% Assign output quantities

flag = loFlag;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
