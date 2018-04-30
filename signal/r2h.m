function h = r2h(r)%#codegen
% R2H converts radian per second to Hertz
%
%   H = R2H(R) converts the frequency R given in [ rad / s ] to frequency H
%   given in [ 1 / s ].
%
%   Inputs:
%
%   H                   Frequency in radian per second.
%
%   Outputs:
%
%   R                   Frequency in Hertz i.e., one per second.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-14
% Changelog:
%   2016-12-14
%       * Initial release



%% Do your code magic here

h = r./2./pi;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
