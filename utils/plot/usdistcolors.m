function DistColors = usdistcolors(N)
% USDISTCOLORS creates distinguishable colors complying with University of
% Stuttgart CD
%
%   Inputs:
%
%   N                   Number of distinguishable colors to create.
%
%   Outputs:
%
%   DISTCOLORS          Nx3 array of distinguishable colors.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-02-24
% Changelog:
%   2017-02-24
%       * Initial release



%% Do your code magic here

% The 6 base colors
vCDBaseColors = [...
    62,  68,  76 ; ...
   159, 153, 152 ; ...
     0,  81, 158 ; ...
     0, 190, 255 ; ...
   231,  81,  18 ; ...
   255, 213,   0 ; ...
%    125, 198, 234 ; ...
]./255;

% Combine the base colors with colors distinguishable from these base colors
DistColors = vertcat(vCDBaseColors, distinguishableColors(N - size(vCDBaseColors, 1)));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
