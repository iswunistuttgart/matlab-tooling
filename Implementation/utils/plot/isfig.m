function flag = isfig(H, All)
% ISFIG checks whether the given handle is a figure handle or not
%
%   ISFIG(H) checks the current handle to be of type 'figure' or not
%
%   Inputs
%
%   H       MxN array of handles to be checked for valid type
%
%   Outputs
%
%   FLAG    TRUE if H is a valid figure handle, and FALSE otherwise.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-06-15
% Changelog:
%   2016-06-15
%       * Initial release



%% Argument defaults
if nargin < 2
    All = false;
end



%% Validate arguments
% H must be an array of handles to begin with
assert(all(ishandle(H)), 'Argument [H] must be a valid handle');
% All must be a logical value
assert(any(All == [false, true]), 'Argument [All] must be logical TRUE or FALSE');



%% Process arguments
aHandles = H;
bAll = All;



%% Do the MATLABgic
% Get all handles' types
ceTypes = get(aHandles, 'type');

% Compare the type of every handle to be of type 'figure'
vFlag = strcmp(ceTypes, 'figure');

if bAll
    vFlag = all(vFlag);
end



%% Assign outputs
flag = vFlag;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
