function [Trajectory] = siggen_difflattraj(Start, End, varargin)
% SIGGEN_DIFFLATTRAJ creates a differentially flat trajectory.
%
%   TRAJECTORY = SIGGEN_DIFFLATTRAJ(START, END) creates a differentially flat /
%   smooth trajectory between start point START and end point END. Transition
%   time defaults to 1 [s] and sampling rate equals to 1 [ms].
%
%   TRAJECTORY = SIGGEN_DIFFLATTRAJ(START, END, 'Name', 'Value', ...)
%   additionally allows further options to be set using name/value pairs.
%
%   Inputs:
%
%   START           1xM vector of start positions of the trajectory.
%
%   END             1xM vector of end positions of the trajectory.
%
%
%   Outputs:
%
%   TRAJECTORY      Time series of the trajectory.
%
%   Optional Inputs -- specified as parameter value pairs
%   Name            Name of the generated time series.
%
%   Order           Order of system i.e., smoothness of trajectory. Defaults to
%                   6 [ ].
%
%   Sampling        Sampling time for the trajectory generation. Defaults to
%                   1e-3 [s].
%
%   Transition      Transition time of the motion. Must be a scalar and will be
%                   applied to all transitions. Might change in a future
%                   release. Defaults to 1 [s].
%
%   Outputs:
%
%   TRAJECTORY      NxM matrix representing trajectory



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-26
% Changelog:
%   2016-08-26
%       * Add option 'Name' to allow for direct naming of the time series object
%       * Change option 'Time' to 'Sampling' and remove support for a time
%       vector in favor of providing a sampling time
%   2016-08-25
%       * Initial release



%% Define the input parser
ip = inputParser;

% Required: Start. Numeric. Vector. Row. Non-empty
valFcn_Start = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'ncols', numel(End)}, mfilename, 'Start');
addRequired(ip, 'Start', valFcn_Start);

% Required: End. Numeric. Vector. Row. Non-empty
valFcn_End = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'ncols', numel(Start)}, mfilename, 'End');
addRequired(ip, 'End', valFcn_End);

% Optional: Time series name. Char. Non-empty
valFcn_Name = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Order');
addParameter(ip, 'Name', 'SmoothTrajectory', valFcn_Name);

% Optional: System order. Numeric. Scalar. Non-negative.
valFcn_Order = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'positive', 'nonzero', '>=', 1, '<=', 7}, mfilename, 'Order');
addParameter(ip, 'Order', 6, valFcn_Order);

% Optional: Time. Numeric. Scalar. Non-negative.
valFcn_Sampling = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'positive'}, mfilename, 'Sampling');
addParameter(ip, 'Sampling', 1e-3, valFcn_Sampling);

% Optional: Transition time. Numeric. Scalar. Non-negative.
valFcn_Transition = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'positive'}, mfilename, 'Transition');
addParameter(ip, 'Transition', 1, valFcn_Transition);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args= [{Start}, {End}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse input parse
% Start pose
vStart = asrow(ip.Results.Start);
% End pose
vEnd = asrow(ip.Results.End);
% Transition time
dTransition = ip.Results.Transition;
% Time to evaluate trajectory on
dSampling = ip.Results.Sampling;
% System order
nSystemOrder = ip.Results.Order;
% Time series name
chName = ip.Results.Name;

% How many trajectories to generate?
nTrajectories = numel(vStart);
% Number of time steps
nTime = dTransition/dSampling;
% Create time vector
vTime = (0:(nTime-1)).*dSampling;



%% Generate trajectory
% Get coefficients for system order
vCoefficients = in_sysOrderCoeffs(nSystemOrder);

% Vector of powers
vPowers = (nSystemOrder + 1):1:(2*nSystemOrder + 1);
% Build a matrix of rows of vPowers
aPowers = repmat(vPowers, nTime, 1);

% Vector of (1/T)^i with i = [n+1, ..., 2n+1]
aTransitionTimePowers = diag(repmat(1/dTransition, 1, nSystemOrder + 1).^(vPowers));

% Pre-Multiply coefficients with time scaling
vCoeffsPerTime = transpose(vCoefficients*aTransitionTimePowers);

% Build matrix of all powers of time. Rows are by the power of system order and
% columns are by increasing time.
aTimeMatrix = repmat(vTime(:), 1, nSystemOrder + 1).^(aPowers);

% Calculate the trajectory matrix with some repeated matrices and things like
% that
aTrajec = repmat(vStart, nTime, 1) + repmat(vEnd - vStart, nTime, 1).*(repmat(aTimeMatrix*vCoeffsPerTime, 1, nTrajectories));



%% Assign output quantities
% Only one output argument
Trajectory = timeseries(aTrajec, vTime, 'Name', chName);


end



function vCoeffs = in_sysOrderCoeffs(nSysOrder)

switch nSysOrder
    case 1
        vCoeffs = [3 -2];
    case 2
        vCoeffs = [10 -15 6];
    case 3
        vCoeffs = [35 -84 70 -20];
    case 4
        vCoeffs = [126 -420 540 -315 70];
    case 5
        vCoeffs = [462 -1980 3465 -3080 1386 -252];
    case 6
        vCoeffs = [1716 -9009 20020 -24024 16380 -6006 924];
    case 7
        vCoeffs = [6435 -40040 108108 -163800 150150 -83160 25740 -3432];
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
