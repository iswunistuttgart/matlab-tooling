function v = colororder_pre2014b()
%% COLORORDER_PRE2014B returns the color order of plot lines pre R2014b
%
%   V = COLORORDER_PRE2014B() returns the 7x3 array of default lines in the pre
%   R2014b versions of MATLAB.
%
%   Outputs:
%
%   V                   7x3 array of RGB color values.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-12-30
% Changelog:
%   2018-12-30
%       * Initial release



%% Do your code magic here

v = [ ...
         0,         0,    1.0000 ; ...
         0,    0.5000,         0 ; ...
    1.0000,         0,         0 ; ...
         0,    0.7500,    0.7500 ; ...
    0.7500,         0,    0.7500 ; ...
    0.7500,    0.7500,         0 ; ...
    0.2500,    0.2500,    0.2500 ; ...
];


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
