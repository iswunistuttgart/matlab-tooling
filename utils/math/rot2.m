function R = rot2(t)
% ROT2 creates the 2D rotation matrix of angle T.
%
%   Inputs:
%
%   T                   Angle of rotation given in degree.
%
%   Outputs:
%
%   R                   2x2 rotation matrix in space.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-03
% Changelog:
%   2017-01-03
%       * Initial release



%% Do your code magic here

R = [cosd(t), -sind(t) ; ...
    sind(t), cosd(t) ...
];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
