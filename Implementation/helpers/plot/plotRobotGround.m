function [varargout] = plotRobotGround(Winches, varargin)
% PLOTROBOTGROUND plots the ground layer for the robot
%
%   PLOTROBOTGROUND(WINCHES) plots the ground as a patch right below the lowest
%   winch.
%
%   Optional Inputs -- specified as parameter value pairs
%   GroundSpec      Cell array of plot specs that will be applied to the ground
%                   patch.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-02
% Changelog:
%   2016-08-02
%       * Change to using ```axescheck``` and ```newplot```
%       * Update doc block
%   2016-07-14
%       * Wrap IP-parse in try-catch to have nicer error display
%       * Wedge out param-value pairs to only the needed ones
%       * Introduce option 'LabelSpec'
%   2016-06-23
%       * Initial release (from plotRobotFrame and plotRobotPlatform)



%% Define the input parser
ip = inputParser;

% Require: Winches. Must be a 3xN array
valFcn_Winches = @(x) validateattributes(x, {'numeric'}, {'2d', 'nrows', 3}, mfilename, 'Winches');
addRequired(ip, 'Winches', valFcn_Winches);

% Optional 1: GroundSpec. One-dimensional or two-dimensional cell-array
valFcn_GroundSpec = @(x) validateattributes(x, {'cell'}, {'nonempty', 'row'}, mfilename, 'GroundSpec');
addParameter(ip, 'GroundSpec', {}, valFcn_GroundSpec);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    varargin = [{Winches}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Assigned parsed arguments to local variables
% Get a valid axes handle
haTarget = newplot(haTarget);
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');
% Winches: Array, 3xN
aWinches = ip.Results.Winches;
% Patch specs: cell row
cePatchSpecs = ip.Results.GroundSpec;



%% Plot the damn thing
% First, determine the three winches with the smallest z-value
dMinZ = min(aWinches(3,:));
vMinMax_X = minmax(aWinches(1,:));
vMinMax_Y = minmax(aWinches(2,:));

% Create the vertices as a combination of min/max X, min/max Y, and Z
aVertices = transpose(combvec(vMinMax_X, vMinMax_Y, dMinZ));

% Faces that have to be created: just one
vFaces = [1, 2, 4, 3];

% Plot the ground as a patch object
hpGround = patch(...
    'Vertices', aVertices ...
    , 'Faces', vFaces ...
    , 'FaceColor', [225, 225, 225]./255 ...
);

% Set custom ground specs?
if ~isempty(cePatchSpecs)
    set(hpGround, cePatchSpecs{:});
end

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end

% Finally, make sure the figure is drawn
drawnow



%% Assign output quantities
if nargout > 0
    varargout{1} = hpGround;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
