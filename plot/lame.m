function varargout = lame(D, varargin)
% LAME plots the LAMÉ superellipses
%
%   LAME(D) plots the Lamé superellipses for the given N degrees D.
%
%   LAME(D, 'Name', 'Value', ...) passes the name/value pairs to the underlying
%   plot command.
%
%   LAME(AX, ...) plots into the given axes object.
%
%   H = LAME(D) returns a Nx1 array of graphics objects of the superellipses.
%
%   Inputs:
%
%   D                   1xN vector of ellipses to plot.
%
%   Outputs
%
%   H                   Nx1 array of line series objects of the lamé ellipses.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-06-12
% Changelog:
%   2018-06-12
%       * Initial release



%% Validate arguments
try
    % LAME(D)
    % LAME(D, 'Name', 'Value', ...)
    % LAME(AX, ...)
    narginchk(1, Inf);
    % LAME(...)
    % H = LAME(...)
    nargoutchk(0, 1);
    
    varargin = [{D}, varargin];
    [haTarget, args, ~] = axescheck(varargin{:});
    D = args{1};
    args = args(2:end);
    
    validateattributes(D, {'numeric'}, {'vector', 'row', 'nonempty', 'positive', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'D');
catch me
    throwAsCaller(me);
end



%% Prepare plot data
% Get the degrees
vDegrees = D;
% Linear spaced vector of the parameter
vParam = linspace(0, 2*pi, 360).';
% Ellipses primary axes lengths
dAxis_X = 1;
dAxis_Y = 1;
% Calculate all the data
X = dAxis_X.*sign(cos(vParam)).*(abs(cos(vParam))).^(2./vDegrees);
Y = dAxis_Y.*sign(sin(vParam)).*(abs(sin(vParam))).^(2./vDegrees);



%% Plot
% Get a valid axes handle
haTarget = newplot(haTarget);

% Old hold state
lOldHold = ishold(haTarget);

% Hold axes
hold(haTarget, 'on');

% Plot all lames
goLame = plot(haTarget ...
    , X, Y ...
    , args{:} ...
);

% Finally, make sure the figure is drawn
drawnow

% Reset the old hold state if it wasn't set
if ~lOldHold
    hold(haTarget, 'off');
end



%% Assign output quantities
% H = LAME(D)
if nargout > 0
    varargout{1} = goLame;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
