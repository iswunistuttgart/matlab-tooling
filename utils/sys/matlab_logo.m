function h = matlab_logo(varargin)
% MATLAB_LOGO 
%
%   Outputs:
%
%   H       Description of argument H



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-11-07
% Changelog:
%   2016-11-07
%       * Initial release



%% Parse arguments
[haTarget, ~, ~] = axescheck(varargin{:});

% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);



%% Do your code magic here

% Generate surface data for the logo
aMembrane = 160*membrane(1, 100);

% Create a surface fromthe surface data an turn off the lines in the surface
hSurface = surface(aMembrane);
hSurface.EdgeColor = 'none';
% Set a nicer viewport
view(haTarget, [-37.5, 30])

% Adjust the axes limits so that the axes are tight around the logo.
haTarget.XLim = [1, 201];
haTarget.YLim = [1, 201];
haTarget.ZLim = [-53.4, 160];

% Adjust the view of the logo using the camera properties of the axes
haTarget.CameraPosition = [-145.5, -229.7, 283.6];
haTarget.CameraTarget = [77.4, 60.2, 63.9];
haTarget.CameraUpVector = [0, 0, 1];
haTarget.CameraViewAngle = 36.7;

% Change the position of the axes and the x, y, and z aspect ratio to fill the
% extra space in the figure window.
haTarget.Position = [0.13, 0.06, 0.775, 0.815];
haTarget.DataAspectRatio = [1, 1, 1];

% Create lights to illuminate the logo. The light itself is not visible but its
% properties can be set to change the appearance of any patch or surface object
% in the axes.
hLight_1 = light;
hLight_1.Position = [160, 400, 80];
hLight_1.Style = 'local';
hLight_1.Color = [0, 0.8, 0.8];
hLight_2 = light;
hLight_2.Position = [.5, -1, .4];
hLight_2.Color = [0.8, 0.8, 0];

% Change the color of the logo.
hSurface.FaceColor = [0.9, 0.2, 0.2];

% Use the lighting and specular (reflectance) properties of the surface to
% control the lighting effects.
hSurface.FaceLighting = 'gouraud';
hSurface.AmbientStrength = 0.3;
hSurface.DiffuseStrength = 0.6; 
hSurface.BackFaceLighting = 'lit';
hSurface.SpecularStrength = 1;
hSurface.SpecularColorReflectance = 1;
hSurface.SpecularExponent = 7;

% If no return argument is given, we will make the full MATLAB logo i.e., black
% baground and such
if nargout == 0
    haTarget.Position = [0 0 1 1];
    haTarget.DataAspectRatio = [1 1 .9];
    axis(haTarget, 'off');
    haTarget.Parent.Color = 'black';
end

% Update figure before returning
drawnow

% Reset the hold state if we turned it on
if ~lOldHold
    hold(haTarget, 'off');
end


%% Assign output quantities
% Return argument is the axes handle
if nargout > 0
    h = haTarget;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
