function zoomax(f, varargin)
% ZOOMAX in or out into an axes depending on the scaling factor
%
%   ZOOMAX(F) zoom by factor F in or out of the given axes. If F is positive, we
%   zoomax into the given axes, if F is negative, we zoomax out of the axes i.e.,
%   with F = 0.1 we zoomax in by 10%, with F = -0.1, we zoomax out by 10%.
%
%   ZOOMAX(AX, F) zoom in to the given axes object
%
%   Inputs:
%
%   AX                  Specific axes object to zoomax in to / out of.
%
%   F                   Zoom factor given in decimals of percent.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-30
% Changelog:
%   2018-09-30
%       * Change from using `newplot()` to `gca()`
%   2018-09-25
%       * Initial release



%% Parse Inputs

% Create an input parser object
ip = inputParser();

% F: zoomaxing factor
ip.addRequired('Factor', @(x) validateattributes(x, {'numeric'}, {'scalar', '<=', 1, '>=', -1, 'nonnan', 'finite', 'nonsparse'}, mfilename, 'f'));

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Validate arguments
try
  % Try to extract an axes handle
  varargin = [{f}, varargin];
  [haTarget, args, ~] = axescheck(varargin{:});
  
  % Parse results
  ip.parse(args{:});
catch me
  throwAsCaller(me);
end



%% Do zoomaxing
% If there is no axes provided, grab one
if isempty(haTarget)
  % Get a valid axes handle
  haTarget = gca();
end
% Old hold state
lOldHold = ishold(haTarget);
% Tell figure to add next plots
hold(haTarget, 'on');
% Scaling factor
dScale = ip.Results.Factor;

% Get all axes limits
aLims = vertcat(haTarget.XLim, haTarget.YLim, haTarget.ZLim);
% Get the range of all axes
vRange = 0.5.*( aLims(:,2) - aLims(:,1) );
% Get mean values of the axes
vMeans = 1/2 .* ( aLims(:,2) + aLims(:,1) );

% Scale the range
vRange = (1 - dScale).*vRange;
vRange = repmat([-1, 1].*vRange, 3, 1);

% And push back into the axes
haTarget.XLim = vRange(1,:) + vMeans(1);
haTarget.YLim = vRange(2,:) + vMeans(2);
haTarget.ZLim = vRange(2,:) + vMeans(3);

% Revert to old hold state
if ~lOldHold
  hold(haTarget, 'off');
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
