function MinValue = minplotvalue(Axis)
% MINPLOTVALUE Determine the minimum plotted value along all axes
% 
%   MINVALUE = MINPLOTVALUE() gets the minimum plotted value for x, y, and
%   possibly z axis for the given axis handle.
% 
%   MINVALUE = MINPLOTVALUE(ax) gets the minimum plotted value for x, y, and
%   possibly z for the given axis handle.
%   
%   Inputs:
%   
%   AXIS:       A valid axis handle to return the minimum plotted range for.
%
%   Outputs:
%   
%   MINVALUE:   An array of [minX, minY] or [minX, minY, minZ] plot range for 2D
%       plots or 3D plots, respectively.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-20
% Changelog:
%   2016-09-20
%       * Comment formatting
%   2016-03-25
%       * Add help
%   2016-03-23
%       * Initial release



%% Argument defaults
% Make sure we have an axis handle
if nargin == 0
    Axis = gca;
end



%% Actual code

% Call the plotrange function and assign output
MinValue = plotrange(Axis, 'min');


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
