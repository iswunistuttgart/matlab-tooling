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
%   AXIS: A valid axis handle to return the minimum plotted range for
%
%   Outputs:
%   
%   MINVALUE: An array of [minX, minY] or [minX, minY, minZ] plot range for 2D
%   plots or 3D plots, respectively.
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-25
% Changelog:
%   2016-03-25: Add help
%   2016-03-23: Initial release

if nargin == 0
    Axis = gca;
end

MinValue = plotrange(Axis, 'min');

end