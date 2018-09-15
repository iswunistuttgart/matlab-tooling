function mrgb = rgb(r, g, b)%#codegen
% RGB converts a conventional RGB representation into MATLAB RGB format
%
%   Inputs:
%
%   R                   Nx1 matrix of Red values from 0..255.
%
%   G                   Nx1 matrix of Green values from 0..255.
%
%   B                   Nx1 matrix of Blue values form 0..255.
%
%   Outputs:
%
%   MRGB                Nx1 matrix of RGB values scaled between 0..1.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-12
% Changelog:
%   2018-09-12
%       * Initial release



%% Do your code magic here

% Simple, but efficient
mrgb = horzcat(r, g, b)./255;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
