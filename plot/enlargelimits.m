function enlargelimits(varargin)
% ENLARGELIMITS Automatically enlarge limits of the curent axis
%
%   ENLARGELIMITS() automatically enlarges the limits on the current axis such
%   that the limits span the full range of data plotted inside the axes.
%
%   ENLARGELIMITS(AXIS) enlarges the limits only on the specified axis (not to be
%   confused with the axes). Defaults to 'x'. Possible options are
%       x       Enlarge only x-axis limits
%       y       Enlarge only y-axis limts
%       z       Enlarge only z-axis limuits
%       xy      Enlarge both x- and y-axis limits
%       yz      Enlarge both y- and z-axis limits
%       xz      Enlarge both x- and z-axis limts
%       xyz     Enlarge all three axes' limits
%
%   ENLARGELIMITS(AXIS, MIN) enlarges the minimum axis limits of the specified axes as
%   given by the user. This way, only the MAX values are set automatically.
%
%   ENLARGELIMITS(AXIS, MIN, MAX) enlarges the maximum axis limits of the specified
%   axes as given by the user. This way, only the MIN values are set
%   automatically.
%
%   ENLARGELIMITS(AXIS, MIN, MAX, EXTEND) extends the axes' limits by EXTEND which
%   is a rational factor of the overall size of the axes. Defaults to 0.05 i.e.,
%   5% extension
%
%   ENLARGELIMITS('Name', 'Value', ...) allows using name/value pairs for setting
%   the axes limits
%
%   Optional Inputs -- specified as parameter value pairs
%
%   Axis            Using this option, only the specified axes will have their
%       limits changed. Defaults to 'x'. Possible options are
%           x       Enlarges only x-axis limits
%           y       Enlarges only y-axis limts
%           z       Enlarges only z-axis limuits
%           xy      Enlarges both x- and y-axis limits
%           yz      Enlarges both y- and z-axis limits
%           xz      Enlarges both x- and z-axis limts
%           xyz     Enlarges all three axes' limits
%
%   Min             1xM vector of minimum values per axis. Defined in [x,y,z]
%       manner, even if e.g., no y or z axis scaling is desired.
%
%   Max             1xM vector of maximum values per axis. Defined in [x,y,z]
%       manner, even if e.g., no y or z axis scaling is desired.
%
%   Extend          Rational factor of the overall extension of the axes over
%       their actual set length. By default, ENLARGELIMITS fits the axes tight
%       around the data. Using EXTEND, this tightness can be avoided by
%       providing a percentage of extension along each direction. Defaults to
%       0.05 i.e., 5%
%
%   See also: XLIM YLIM ZLIM



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2019-01-10
% Changelog:
%   2019-01-10
%     * Fix default value of 'Extend' being `0.00`, rather than `0.05`
%     * Rename to `enlargelimits`
%     * Reformat using only 2 spaces per indentation level
%   2016-09-20
%     * Add support for axis-specific Mins and Maxs, as well as axis-specific
%     extend values
%     * Add help section
%     * Add File information section



%% Define the input parser
ip = inputParser;

% Optional a set of axis to set limits on
valFcn_Axis = @(x) any(validatestring(x, {'x', 'y', 'z', 'xy', 'yz', 'xz', 'xyz', 'all'}, mfilename, 'Axis'));
addOptional(ip, 'Axis', 'x', valFcn_Axis);

% The min and max values may be provided, otherwise it will default to whatever
% the axis has set as min and max limits
valFcn_Min = @(x) validateattributes(x, {'numeric'}, {'vector', 'finite'}, mfilename, 'Min');
addOptional(ip, 'Min', -Inf, valFcn_Min);

valFcn_Max = @(x) validateattributes(x, {'numeric'}, {'vector', 'finite'}, mfilename, 'Max');
addOptional(ip, 'Max', Inf, valFcn_Max);

% The extend margin may be provided, too
valFcn_Extend = @(x) validateattributes(x, {'numeric'}, {'vector', 'finite', 'positive'}, mfilename, 'Exctend');
addOptional(ip, 'Extend', 0.05, valFcn_Extend);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
  [haTarget, args, ~] = axescheck(varargin{:});
    
  parse(ip, args{:});
catch me
  throwAsCaller(me);
end



%% Parse input string
% Get the string of the axis to get
chAxis = ip.Results.Axis;
% Get the provided min and max axis values
vMin = repmat(asrow(ip.Results.Min), 1, 3); vMin = vMin(1:3);
vMax = repmat(asrow(ip.Results.Max), 1, 3); vMax = vMax(1:3);
% Quickhand boolean variable to check whether we have to get the limits from the
% axis or if they're given
vGetMin = vMin == -Inf;
vGetMax = vMax == Inf;
% Get valid axis handle if none was given => default to current axes
if isempty(haTarget)
  haTarget = gca;
end
% Old hold state
lOldHold = ishold(haTarget);
% Extension of axes limits
vExtend = repmat(asrow(ip.Results.Extend), 1, 3); vExtend = vExtend(1:3);



%% Parse


% Keeps our target limits
vLims = zeros(6, 1);
% Get the min axis values from the provided axis
if any(vGetMin)
  if vGetMin(1)
    vLims(1) = min(xlim(haTarget));
  end
  if vGetMin(2)
    vLims(3) = min(ylim(haTarget));
  end
  if vGetMin(3)
    vLims(5) = min(zlim(haTarget));
  end
% Get the min axis values from the provided value
else
  vLims(1) = vMin(1);
  vLims(3) = vMin(2);
  vLims(5) = vMin(3);
end
% Get the max axis values from the provided axis
if any(vGetMax)
  if vGetMax(1)
    vLims(2) = max(xlim(haTarget));
  end
  if vGetMax(2)
    vLims(4) = max(ylim(haTarget));
  end
  if vGetMax(3)
    vLims(6) = max(zlim(haTarget));
  end
% Get the max axis values from the provided value
else
  vLims(2) = vMax(1);
  vLims(4) = vMax(2);
  vLims(6) = vMax(3);
end
% Get the span of the limits
dXSpan = vLims(2) - vLims(1);
dYSpan = vLims(4) - vLims(3);
dZSpan = vLims(6) - vLims(5);



%% Do the magic
switch chAxis
  case 'x'
    xlim(haTarget, [vLims(1), vLims(2)] + vExtend(1).*[-dXSpan, dXSpan]);
  case 'y'
    ylim(haTarget, [vLims(3), vLims(4)] + vExtend(2).*[-dYSpan, dYSpan]);
  case 'z'
    zlim(haTarget, [vLims(5), vLims(6)] + vExtend(3).*[-dZSpan, dzSpan]);
  case 'xy'
    xlim(haTarget, [vLims(1), vLims(2)] + vExtend(1).*[-dXSpan, dXSpan]);
    ylim(haTarget, [vLims(3), vLims(4)] + vExtend(2).*[-dYSpan, dYSpan]);
  case 'yz'
    ylim(haTarget, [vLims(3), vLims(4)] + vExtend(2).*[-dYSpan, dYSpan]);
    zlim(haTarget, [vLims(5), vLims(6)] + vExtend(3).*[-dZSpan, dZSpan]);
  case 'xz'
    xlim(haTarget, [vLims(1), vLims(2)] + vExtend(1).*[-dXSpan, dXSpan]);
    zlim(haTarget, [vLims(5), vLims(6)] + vExtend(3).*[-dZSpan, dZSpan]);
  case {'xyz', 'all'}
    xlim(haTarget, [vLims(1), vLims(2)] + vExtend(1).*[-dXSpan, dXSpan]);
    ylim(haTarget, [vLims(3), vLims(4)] + vExtend(2).*[-dYSpan, dYSpan]);
    zlim(haTarget, [vLims(5), vLims(6)] + vExtend(3).*[-dZSpan, dZSpan]);
  otherwise
    ylim(haTarget, [vLims(3), vLims(4)] + vExtend(2).*[-dYSpan, dYSpan]);
end

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
  hold(haTarget, 'off');
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
