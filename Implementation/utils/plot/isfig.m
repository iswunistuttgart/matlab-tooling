function flag = isfig(H)
% ISFIG checks whether the given handle is a figure handle or not
%
%   ISFIG(H) checks the current handle to be of type 'figure' or not
%
%   Inputs
%
%   H           MxN array of handles to be checked for valid type.
%
%   Outputs
%
%   FLAG        TRUE if H is a valid figure handle, and FALSE otherwise.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-20
% Changelog:
%   2016-09-20
%       * Minor comment formatting
%   2016-08-09
%       * Remove second argument 'All'
%       * Update check for figure handles. It's now safer to run it, especially
%       with non-figure arguments
%   2016-06-15
%       * Initial release



%% Input assertion
try
    narginchk(1, 1);
    % H: non-empty
    assert(~isempty(H), 'PHILIPPTEMPEL:MATLAB_TOOLING:ISFIG:EmptyArgument', 'Argument [%s] must be non-empty.', 'H');
catch me
    throwAsCaller(me);
end



%% Do the MATLABgic
flag = ~isempty(H) && ( isa(H, 'double') || isa(H, 'matlab.ui.Figure') );


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
