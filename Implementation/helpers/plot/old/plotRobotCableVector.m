function plotRobotCableVector(Pose, CableAttachment, CableVector, varargin)
% PLOTROBOTCABLEVECTOR Plot the cable vector of the robot at the specified pose
% 
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR) plots the columns
%   of CABLEVECTOR as cable vectors starting at the adjuste cable attachment
%   point taken from the columns of CABLEATTACHMENT and shifted to be relative
%   to POSE.
%   
%   PLOTROBOTCABLEVECTOR(TIME, POSES, 'LineSpec', LineSpecs) forces the given
%   line specs on the 2D or 3D plot. See LINESPEC
%   
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'Viewport',
%   viewport, ...) adjusts the viewport of the 3d plot to the set values.
%   Allowed values are 2, 3, [az, el], or [x, y, z]. See documentation of view
%   for more info. Only works in standalone mode.
%   
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'Grid', Grid, ...)
%   to define the grid style. Any of the following options are allowed
%   
%       'on'        turns major grid on
%       'off'       turns all grids off
%       'minor'     turns minor and major grid on
%   
%   Only works in standalone mode.
%
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'Title', Title,
%   ...) puts a title on the figure. Only works in standalone mode.
%
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'TitleSpec',
%   TitleSpec, ...) allows for setting custom properties on the title by
%   providing a cell array compliant with text properties.
%
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'XLabel', XLabel,
%   ...) sets the x-axis label to the specified char. Only works in standalone
%   mode.
%
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'YLabel', YLabel,
%   ...) sets the y-axis label to the specified char. Only works in standalone
%   mode.
%
%   PLOTROBOTCABLEVECTOR(POSE, CABLEATTACHMENT, CABLEVECTOR, 'ZLabel', ZLabel,
%   ...) sets the z-axis label to the specified char. Only works in standalone
%   mode.
%   
%   PLOTROBOTCABLEVECTOR(AX, POSE, CABLEATTACHMENT, CABLEVECTOR) plots the cable
%   vectors into the specified axes
%   
%   Inputs:
%   
%   POSE: Matrix of poses of the platform center of gravity where each row is
%   the [x, y, z] tuple of platform center of gravity positon at the time
%   corresponding to that value
%
%   CABLEATTACHMENT: Matrix of 3xM cable attachment points given in mobile
%   platform coordinates
%
%   CABLEVECTOR: Matrix of 3xm cable direction vectors relative to each cable
%   attachment point. Basically, these are the l_i
%
%   See also: VIEW, QUIVER3, LINESPEC, GRID, TITLE, XLABEL, YLABEL, ZLABEL
%



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-30
% Changelog:
%   2016-03-30
%       * Initial release


end


function out = inCharToValidArgument(in)

switch lower(in)
    case {'on', 'yes', 'please'}
        out = 'on';
    case {'off', 'no', 'never'}
        out = 'off';
    otherwise
        out = 'off';
end
% end ```switch lower(in)```

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
