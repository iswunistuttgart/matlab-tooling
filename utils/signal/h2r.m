function r = h2r(h)%#codegen
% H2R converts Hertz to radian per second
%
%   R = H2R(H) converts the frequency H given in [ 1 / s ] to frequency R given
%   in [ rad / s ].
%
%   Inputs:
%
%   H                   Frequency in Hertz i.e., one per second.
%
%   Outputs:
%
%   R                   Frequency in radian per second.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-12-14
% Changelog:
%   2016-12-14
%       * Initial release



%% Do your code magic here

r = h.*2.*pi;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
