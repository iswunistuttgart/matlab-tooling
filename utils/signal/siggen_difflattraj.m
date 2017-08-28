function [Trajectory, varargout] = siggen_difflattraj(Start, End, varargin)
% SIGGEN_DIFFLATTRAJ creates a differentially flat trajectory.
%
%   TRAJECTORY = SIGGEN_DIFFLATTRAJ(START, END) creates a differentially flat /
%   smooth trajectory between start point START and end point END. Transition
%   time defaults to 1 [s] and sampling rate equals to 1 [ms].
%
%   TRAJECTORY = SIGGEN_DIFFLATTRAJ(START, END, 'Name', 'Value', ...)
%   additionally allows further options to be set using name/value pairs.
%
%   [TRAJECTORY, DTRAJECTORY] = SIGGEN_DIFFLATTRAJ(...) returns the first
%   derivative of TRAJECTORY with respect to time.
%
%   [TRAJECTORY, DTRAJECTORY, ..., D^{n+2}TRAJECTORY] = SIGGEN_DIFFLATTRAJ()
%   returns the first till (n+2)th derivative of the trajectory as well
%
%   Inputs:
%
%   START           1xM vector of start positions of the trajectory.
%
%   END             1xM vector of end positions of the trajectory.
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
%   TRAJECTORY      Time series of the trajectory.
%
%   DTRAJECTORY     Time series of the first derivative of the trajectory.
%
%   DDTRAJECTORY    Time series of the second derivative of the trajectory.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-08-28
% Changelog:
%   2017-08-28
%       * Fix incorect determination of derivatives of signal: now we are using
%       MAPLE code-generated functions inline. These are less error-prone and
%       additionally should be much faster than the actual code execution in
%       MATLAB
%       * Add code directives since the inline functions are never used
%       explicitly
%   2017-08-25
%       * Add variable output arguments for derivatives up to n+2
%   2016-08-26
%       * Add option 'Name' to allow for direct naming of the time series object
%       * Change option 'Time' to 'Sampling' and remove support for a time
%       vector in favor of providing a sampling time
%   2016-08-25
%       * Initial release



%% Code Directives
%#ok<*DEFNU>
%#ok<*INUSL>



%% Validate nargins and nargouts
% Need 2 inputs, require at most ten
narginchk(2, 10);



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



%% Parse input parser result
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

% Number of time steps
nTime = dTransition/dSampling + 1;
% Create time vector
vTime = ((0:(nTime-1)).*dSampling).';

% We allow returning the position, velocity, acceleration, and jerk of the
% signal
nargoutchk(0, nSystemOrder + 2);



%% Generate trajectory
% Function handle to the actual trajectory
fhTrajectory = str2func(sprintf('in_sys%i_diff%i', nSystemOrder, 0));

% Function handles for all kth derivatives (from k = 0..2n+1)
ceFunctionCallbacks = cell(nargout - 1, 1);
% Create function handles for each derivative
for iDeriv = 1:(nargout - 1)
    ceFunctionCallbacks{iDeriv} = str2func(sprintf('in_sys%i_diff%i', nSystemOrder, iDeriv));
end



%% Assign output quantities
% Only one output argument
Trajectory = timeseries(fhTrajectory(vTime, vStart, vEnd, dTransition), vTime, 'Name', chName);

% Also calculate the signal's derivatives?
if nargout > 1
    % For each derivative, we will calculate its polyomial
    for iDeriv = 1:(nargout - 1)
        varargout{iDeriv} = timeseries(ceFunctionCallbacks{iDeriv}(vTime, vStart, vEnd, dTransition), vTime, 'Name', sprintf('%s: %i%s derivative', chName, iDeriv, ord(iDeriv))); %#ok<AGROW>
    end
end


end


function D0z = in_sys1_diff0(t, z0, z1, T)

t1 = 1 ./ T;
D0z = (z1 - z0) .* t1 .^ 2 .* t .^ 2 .* (-2 .* t1 .* t + 3) + z0;

end



function D1z = in_sys1_diff1(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t1 .^ 2);
D1z = -6 .* t .* (z1 - z0) .* (t - T) .* t1 .* t2;

end



function D2z = in_sys1_diff2(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 6;
t3 = (t1 .^ 2);
D2z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3;

end



function D3z = in_sys1_diff3(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -12;
t3 = (t1 .^ 2);
D3z = t2 .* (z1 - z0) .* t1 .* t3;

end



function D0z = in_sys2_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t1 .^ 2);
D0z = (z1 - z0) .* t1 .* t2 .* t .^ 3 .* (t1 .* t .* (6 .* t1 .* t - 15) + 10) + z0;

end



function D1z = in_sys2_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 30;
t4 = (t2 .^ 2);
D1z = t3 .* (z1 - z0) .* t .^ 2 .* t1 .^ 2 .* t2 .* t4 .^ 2;

end



function D2z = in_sys2_diff2(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t1 .^ 2);
D2z = -60 .* t .* (z1 - z0) .* (t - T) .* (T - 2 .* t) .* t1 .* t2 .^ 2;

end



function D3z = in_sys2_diff3(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 60;
t3 = (t1 .^ 2);
D3z = t2 .* (z1 - z0) .* (-6 .* t .* (T - t) + T .^ 2) .* t1 .* t3 .^ 2;

end



function D4z = in_sys2_diff4(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -360;
t3 = (t1 .^ 2);
D4z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3 .^ 2;

end



function D5z = in_sys2_diff5(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 720;
t3 = (t1 .^ 2);
D5z = t2 .* (z1 - z0) .* t1 .* t3 .^ 2;

end



function D0z = in_sys3_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t .^ 2);
t3 = (t1 .^ 2);
t4 = t1 .* t;
D0z = (z1 - z0) .* t3 .^ 2 .* t2 .^ 2 .* (t4 .* (t4 .* (-20 .* t1 .* t + 70) - 84) + 35) + z0;

end



function D1z = in_sys3_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -140;
t4 = (t1 .^ 2);
t5 = (t2 .^ 2);
t2 = (t2 .* t5);
D1z = t3 .* (z1 - z0) .* t .^ 3 .* t1 .* t4 .* t2 .* t5 .^ 2;

end



function D2z = in_sys3_diff2(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 420;
t4 = (t2 .^ 2);
t2 = (t2 .* t4);
D2z = t3 .* (z1 - z0) .* t .^ 2 .* t1 .^ 2 .* (T - 2 .* t) .* t2 .* t4 .^ 2;

end



function D3z = in_sys3_diff3(t, z0, z1, T)

t1 = (t .* (t - T));
t2 = 1 ./ T;
t3 = (t2 .^ 2);
t2 = (t2 .* t3);
D3z = -840 .* t1 .* (z1 - z0) .* (T .^ 2 + 5 .* t1) .* t2 .* t3 .^ 2;

end



function D4z = in_sys3_diff4(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 840;
t3 = (t1 .^ 2);
t1 = (t1 .* t3);
D4z = t2 .* (z1 - z0) .* (T - 2 .* t) .* (-10 .* t .* (T - t) + T .^ 2) .* t1 .* t3 .^ 2;

end



function D5z = in_sys3_diff5(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -10080;
t3 = (t1 .^ 2);
t1 = (t1 .* t3);
D5z = t2 .* (z1 - z0) .* (-5 .* t .* (T - t) + T .^ 2) .* t1 .* t3 .^ 2;

end



function D6z = in_sys3_diff6(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 50400;
t3 = (t1 .^ 2);
t1 = (t1 .* t3);
D6z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3 .^ 2;

end



function D7z = in_sys3_diff7(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -100800;
t3 = (t1 .^ 2);
t1 = (t1 .* t3);
D7z = t2 .* (z1 - z0) .* t1 .* t3 .^ 2;

end



function D0z = in_sys4_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t .^ 2);
t3 = (t1 .^ 2);
t4 = t1 .* t;
D0z = (z1 - z0) .* t1 .* t3 .^ 2 .* t .* t2 .^ 2 .* (t4 .* (t4 .* (t4 .* (70 .* t1 .* t - 315) + 540) - 420) + 126) + z0;

end



function D1z = in_sys4_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 630;
t4 = (t .^ 2);
t1 = t1 .^ 2;
t5 = (t2 .^ 2);
t5 = t5 .^ 2;
D1z = t3 .* (z1 - z0) .* t4 .^ 2 .* t1 .^ 2 .* t2 .* t5 .^ 2;

end



function D2z = in_sys4_diff2(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -2520;
t4 = (t2 .^ 2);
t4 = t4 .^ 2;
t5 = (t1 .^ 2);
D2z = t3 .* (z1 - z0) .* t .^ 3 .* t1 .* t5 .* (T - 2 .* t) .* t2 .* t4 .^ 2;

end



function D3z = in_sys4_diff3(t, z0, z1, T)

t1 = T - t;
t2 = 0.1e1 ./ T;
t3 = t2 .^ 2;
t3 = t3 .^ 2;
D3z = 0.7560e4 .* t .^ 2 .* (-0.14e2 ./ 0.3e1 .* t .* t1 + T .^ 2) .* (z1 - z0) .* t1 .^ 2 .* t2 .* t3 .^ 2;

end



function D4z = in_sys4_diff4(t, z0, z1, T)

t1 = (t .* (t - T));
t2 = 1 ./ T;
t3 = (t2 .^ 2);
t3 = t3 .^ 2;
D4z = -15120 .* t1 .* (z1 - z0) .* (T - 2 .* t) .* (T .^ 2 + 7 .* t1) .* t2 .* t3 .^ 2;

end



function D5z = in_sys4_diff5(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = 15120;
t4 = (t2 .^ 2);
t4 = t4 .^ 2;
D5z = t3 .* (z1 - z0) .* ((-20 .* T .* t1 + ((-140 .* T + 70 .* t) .* t + 90 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t4 .^ 2;

end



function D6z = in_sys4_diff6(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -302400;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
D6z = t2 .* (z1 - z0) .* (T - 2 .* t) .* (-7 .* t .* (T - t) + T .^ 2) .* t1 .* t3 .^ 2;

end



function D7z = in_sys4_diff7(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 907200;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
D7z = t2 .* (z1 - z0) .* (-14 .* t .* (T - t) + 3 .* T .^ 2) .* t1 .* t3 .^ 2;

end



function D8z = in_sys4_diff8(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -12700800;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
D8z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3 .^ 2;

end



function D9z = in_sys4_diff9(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 25401600;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
D9z = t2 .* (z1 - z0) .* t1 .* t3 .^ 2;

end



function D0z = in_sys5_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t .^ 2);
t3 = (t2 .^ 2);
t4 = (t1 .^ 2);
t5 = (t4 .^ 2);
t6 = t1 .* t;
D0z = (z1 - z0) .* t4 .* t5 .* t2 .* t3 .* (t6 .* (t6 .* (t6 .* (t6 .* (-252 .* t1 .* t + 1386) - 3080) + 3465) - 1980) + 462) + z0;

end



function D1z = in_sys5_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -2772;
t4 = (t .^ 2);
t5 = (t2 .^ 2);
t6 = (t5 .^ 2);
t7 = (t1 .^ 2);
D1z = t3 .* (z1 - z0) .* t .* t4 .^ 2 .* t1 .* t7 .^ 2 .* t2 .* t5 .* t6 .^ 2;

end



function D2z = in_sys5_diff2(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 13860;
t4 = (t .^ 2);
t1 = t1 .^ 2;
t5 = (t2 .^ 2);
t6 = (t5 .^ 2);
D2z = t3 .* (z1 - z0) .* t4 .^ 2 .* t1 .^ 2 .* (T - 2 .* t) .* t2 .* t5 .* t6 .^ 2;

end



function D3z = in_sys5_diff3(t, z0, z1, T)

t1 = -3 .* t;
t2 = t - T;
t3 = 1 ./ T;
t4 = t2 .^ 2;
t5 = t3 .^ 2;
t6 = t5 .^ 2;
D3z = -27720 .* t .^ 3 .* (t1 + T) .* (2 .* T + t1) .* (z1 - z0) .* t2 .* t4 .* t3 .* t5 .* t6 .^ 2;

end



function D4z = in_sys5_diff4(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = (t2 .^ 2);
t4 = (t3 .^ 2);
D4z = 166320 .* t .^ 2 .* (z1 - z0) .* t1 .^ 2 .* (T - 2 .* t) .* (T .^ 2 + 6 .* t .* t1) .* t2 .* t3 .* t4 .^ 2;

end



function D5z = in_sys5_diff5(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = (t2 .^ 2);
t4 = (t3 .^ 2);
D5z = -332640 .* t .* (z1 - z0) .* (t - T) .* ((-14 .* T .* t1 + ((-84 .* T + 42 .* t) .* t + 56 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t3 .* t4 .^ 2;

end



function D6z = in_sys5_diff6(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = 332640;
t4 = (t2 .^ 2);
t5 = (t4 .^ 2);
D6z = t3 .* (z1 - z0) .* (T - 2 .* t) .* ((-28 .* T .* t1 + ((-252 .* T + 126 .* t) .* t + 154 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t4 .* t5 .^ 2;

end



function D7z = in_sys5_diff7(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = -9979200;
t4 = (t2 .^ 2);
t5 = (t4 .^ 2);
D7z = t3 .* (z1 - z0) .* ((-14 .* T .* t1 + ((-84 .* T + 42 .* t) .* t + 56 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t4 .* t5 .^ 2;

end



function D8z = in_sys5_diff8(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 139708800;
t3 = (t1 .^ 2);
t4 = (t3 .^ 2);
D8z = t2 .* (z1 - z0) .* (T - 2 .* t) .* (-6 .* t .* (T - t) + T .^ 2) .* t1 .* t3 .* t4 .^ 2;

end



function D9z = in_sys5_diff9(t, z0, z1, T)

t1 = -3 .* t;
t2 = 1 ./ T;
t3 = -558835200;
t4 = (t2 .^ 2);
t5 = (t4 .^ 2);
D9z = t3 .* (t1 + T) .* (2 .* T + t1) .* (z1 - z0) .* t2 .* t4 .* t5 .^ 2;

end



function D10z = in_sys5_diff10(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 5029516800;
t3 = (t1 .^ 2);
t4 = (t3 .^ 2);
D10z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3 .* t4 .^ 2;

end



function D11z = in_sys5_diff11(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -10059033600;
t3 = (t1 .^ 2);
t4 = (t3 .^ 2);
D11z = t2 .* (z1 - z0) .* t1 .* t3 .* t4 .^ 2;

end



function D0z = in_sys6_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t .^ 2);
t3 = (t .* t2);
t4 = (t1 .^ 2);
t5 = (t1 .* t4);
t1 = (t1 .* t);
D0z = (z1 - z0) .* t5 .* t4 .^ 2 .* t3 .* t2 .^ 2 .* (t1 .* (t1 .* (t1 .* (t1 .* (t1 .* (924 .* t1 - 6006) + 16380) - 24024) + 20020) - 9009) + 1716) + z0;

end



function D1z = in_sys6_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 12012;
t4 = (t .^ 2);
t5 = (t4 .^ 2);
t6 = (t2 .^ 2);
t6 = t6 .^ 2;
t2 = (t2 .* t6);
t1 = (t1 .^ 2);
t7 = (t1 .^ 2);
D1z = t3 .* (z1 - z0) .* t4 .* t5 .* t1 .* t7 .* t2 .* t6 .^ 2;

end



function D2z = in_sys6_diff2(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -72072;
t4 = (t .^ 2);
t5 = (t1 .^ 2);
t6 = (t2 .^ 2);
t6 = t6 .^ 2;
t2 = (t2 .* t6);
D2z = t3 .* (z1 - z0) .* t .* t4 .^ 2 .* t1 .* t5 .^ 2 .* (T - 2 .* t) .* t2 .* t6 .^ 2;

end



function D3z = in_sys6_diff3(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 72072;
t4 = (t .^ 2);
t5 = (t2 .^ 2);
t5 = t5 .^ 2;
t2 = (t2 .* t5);
t6 = (t1 .^ 2);
D3z = t3 .* (z1 - z0) .* t4 .^ 2 .* t6 .^ 2 .* (5 .* T .^ 2 + 22 .* t .* t1) .* t2 .* t5 .^ 2;

end



function D4z = in_sys6_diff4(t, z0, z1, T)

t1 = (t - T);
t2 = 0.1e1 ./ T;
t3 = t1 .^ 2;
t4 = t2 .^ 2;
t4 = t4 .^ 2;
t2 = t2 .* t4;
D4z = -0.1441440e7 .* (t .^ 3) .* (T - 2 .* t) .* (z1 - z0) .* t1 .* t3 .* (0.11e2 ./ 0.2e1 .* t .* t1 + (T .^ 2)) .* t2 .* t4 .^ 2;

end



function D5z = in_sys6_diff5(t, z0, z1, T)

t1 = (t - T);
t2 = (T .^ 2);
t3 = 1 ./ T;
t4 = (t3 .^ 2);
t4 = t4 .^ 2;
t3 = (t3 .* t4);
D5z = 4324320 .* t .^ 2 .* (z1 - z0) .* t1 .^ 2 .* ((-12 .* T .* t2 + ((-66 .* T + 33 .* t) .* t + 45 .* t2) .* t) .* t + t2 .^ 2) .* t3 .* t4 .^ 2;

end



function D6z = in_sys6_diff6(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = (t2 .^ 2);
t3 = t3 .^ 2;
t2 = (t2 .* t3);
D6z = -8648640 .* t .* (z1 - z0) .* (t - T) .* (T - 2 .* t) .* ((-18 .* T .* t1 + ((-132 .* T + 66 .* t) .* t + 84 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t3 .^ 2;

end



function D7z = in_sys6_diff7(t, z0, z1, T)

t1 = (T .^ 2);
t2 = (t1 .^ 2);
t3 = 1 ./ T;
t4 = 8648640;
t5 = (t3 .^ 2);
t5 = t5 .^ 2;
t3 = (t3 .* t5);
D7z = t4 .* (z1 - z0) .* ((-42 .* T .* t2 + ((-1680 .* T .* t1 + ((-2772 .* T + 924 .* t) .* t + 3150 .* t1) .* t) .* t + 420 .* t2) .* t) .* t + t1 .* t2) .* t3 .* t5 .^ 2;

end



function D8z = in_sys6_diff8(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = -363242880;
t4 = (t2 .^ 2);
t4 = t4 .^ 2;
t2 = (t2 .* t4);
D8z = t3 .* (z1 - z0) .* (T - 2 .* t) .* ((-18 .* T .* t1 + ((-132 .* T + 66 .* t) .* t + 84 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t4 .^ 2;

end



function D9z = in_sys6_diff9(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = 7264857600;
t4 = (t2 .^ 2);
t4 = t4 .^ 2;
t2 = (t2 .* t4);
D9z = t3 .* (z1 - z0) .* ((-12 .* T .* t1 + ((-66 .* T + 33 .* t) .* t + 45 .* t1) .* t) .* t + t1 .^ 2) .* t2 .* t4 .^ 2;

end



function D10z = in_sys6_diff10(t, z0, z1, T)

t1 = 0.1e1 ./ T;
t2 = t1 .^ 2;
t2 = t2 .^ 2;
t1 = t1 .* t2;
D10z = (-87178291200 .* T + 174356582400 .* t) .* (z1 - z0) .* (-0.11e2 ./ 0.2e1 .* t .* (T - t) + (T .^ 2)) .* t1 .* t2 .^ 2;

end



function D11z = in_sys6_diff11(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 130767436800;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
t1 = (t1 .* t3);
D11z = t2 .* (z1 - z0) .* (-22 .* t .* (T - t) + 5 .* T .^ 2) .* t1 .* t3 .^ 2;

end



function D12z = in_sys6_diff12(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -2876883609600;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
t1 = (t1 .* t3);
D12z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t3 .^ 2;

end



function D13z = in_sys6_diff13(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 5753767219200;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
t1 = (t1 .* t3);
D13z = t2 .* (z1 - z0) .* t1 .* t3 .^ 2;

end



function D0z = in_sys7_diff0(t, z0, z1, T)

t1 = 1 ./ T;
t2 = (t .^ 2);
t2 = t2 .^ 2;
t3 = (t1 .^ 2);
t3 = t3 .^ 2;
t4 = t1 .* t;
D0z = (z1 - z0) .* t3 .^ 2 .* t2 .^ 2 .* (t4 .* (t4 .* (t4 .* (t4 .* (t4 .* (t4 .* (-3432 .* t1 .* t + 25740) - 83160) + 150150) - 163800) + 108108) - 40040) + 6435) + z0;

end



function D1z = in_sys7_diff1(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -51480;
t4 = (t .^ 2);
t5 = (t .* t4);
t6 = (t2 .^ 2);
t7 = t6 .^ 2;
t2 = (t2 .* t6 .* t7);
t6 = (t1 .^ 2);
t1 = (t1 .* t6);
D1z = t3 .* (z1 - z0) .* t5 .* t4 .^ 2 .* t1 .* t6 .^ 2 .* t2 .* t7 .^ 2;

end



function D2z = in_sys7_diff2(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = 360360;
t4 = (t .^ 2);
t5 = (t4 .^ 2);
t1 = (t1 .^ 2);
t6 = (t1 .^ 2);
t7 = t2 .^ 2;
t8 = (t7 .^ 2);
t2 = (t2 .* t7 .* t8);
D2z = t3 .* (z1 - z0) .* t4 .* t5 .* t1 .* t6 .* (T - 2 .* t) .* t2 .* t8 .^ 2;

end



function D3z = in_sys7_diff3(t, z0, z1, T)

t1 = (t - T);
t2 = 1 ./ T;
t3 = -720720;
t4 = (t .^ 2);
t5 = (t2 .^ 2);
t6 = t5 .^ 2;
t2 = (t2 .* t5 .* t6);
t5 = (t1 .^ 2);
D3z = t3 .* (z1 - z0) .* t .* t4 .^ 2 .* t1 .* t5 .^ 2 .* (3 .* T .^ 2 + 13 .* t .* t1) .* t2 .* t6 .^ 2;

end



function D4z = in_sys7_diff4(t, z0, z1, T)

t1 = T - t;
t2 = 0.1e1 ./ T;
t3 = t .^ 2;
t4 = t2 .^ 2;
t5 = t4 .^ 2;
t2 = t2 .* t4 .* t5;
t4 = t1 .^ 2;
D4z = 0.10810800e8 .* t3 .^ 2 .* (-0.26e2 ./ 0.5e1 .* t .* t1 + T .^ 2) .* (T - 0.2e1 .* t) .* (z1 - z0) .* t4 .^ 2 .* t2 .* t5 .^ 2;

end



function D5z = in_sys7_diff5(t, z0, z1, T)

t1 = (t - T);
t2 = (T .^ 2);
t3 = 1 ./ T;
t4 = -8648640;
t5 = (t3 .^ 2);
t6 = (t5 .^ 2);
t3 = (t3 .* t5 .* t6);
t5 = (t1 .^ 2);
D5z = t4 .* (z1 - z0) .* t .^ 3 .* t1 .* t5 .* ((-55 .* T .* t2 + ((-286 .* T + 143 .* t) .* t + 198 .* t2) .* t) .* t + 5 .* t2 .^ 2) .* t3 .* t6 .^ 2;

end



function D6z = in_sys7_diff6(t, z0, z1, T)

t1 = (t - T);
t2 = (T .^ 2);
t3 = (t2 .^ 2);
t4 = 1 ./ T;
t5 = t4 .^ 2;
t6 = (t5 .^ 2);
t4 = (t4 .* t5 .* t6);
D6z = 43243200 .* t .^ 2 .* (z1 - z0) .* t1 .^ 2 .* (3 .* T .* t3 + ((275 .* T .* t2 + ((715 .* T - 286 .* t) .* t - 660 .* t2) .* t) .* t - 50 .* t3) .* t) .* t4 .* t6 .^ 2;

end



function D7z = in_sys7_diff7(t, z0, z1, T)

t1 = (T .^ 2);
t2 = (t1 .^ 2);
t3 = 1 ./ T;
t4 = t3 .^ 2;
t5 = (t4 .^ 2);
t3 = (t3 .* t4 .* t5);
D7z = -259459200 .* t .* (z1 - z0) .* (t - T) .* ((-27 .* T .* t2 + ((-825 .* T .* t1 + ((-1287 .* T + 429 .* t) .* t + 1485 .* t1) .* t) .* t + 225 .* t2) .* t) .* t + t1 .* t2) .* t3 .* t5 .^ 2;

end



function D8z = in_sys7_diff8(t, z0, z1, T)

t1 = (T .^ 2);
t2 = (t1 .^ 2);
t3 = 1 ./ T;
t4 = 259459200;
t5 = t3 .^ 2;
t6 = (t5 .^ 2);
t3 = (t3 .* t5 .* t6);
D8z = t4 .* (z1 - z0) .* (T - 2 .* t) .* ((-54 .* T .* t2 + ((-2904 .* T .* t1 + ((-5148 .* T + 1716 .* t) .* t + 5742 .* t1) .* t) .* t + 648 .* t2) .* t) .* t + t1 .* t2) .* t3 .* t6 .^ 2;

end



function D9z = in_sys7_diff9(t, z0, z1, T)

t1 = (T .^ 2);
t2 = (t1 .^ 2);
t3 = 1 ./ T;
t4 = -14529715200;
t5 = t3 .^ 2;
t6 = (t5 .^ 2);
t3 = (t3 .* t5 .* t6);
D9z = t4 .* (z1 - z0) .* ((-27 .* T .* t2 + ((-825 .* T .* t1 + ((-1287 .* T + 429 .* t) .* t + 1485 .* t1) .* t) .* t + 225 .* t2) .* t) .* t + t1 .* t2) .* t3 .* t6 .^ 2;

end



function D10z = in_sys7_diff10(t, z0, z1, T)

t1 = (T .^ 2);
t2 = (t1 .^ 2);
t3 = 1 ./ T;
t4 = 130767436800;
t5 = t3 .^ 2;
t6 = (t5 .^ 2);
t3 = (t3 .* t5 .* t6);
D10z = t4 .* (z1 - z0) .* (3 .* T .* t2 + ((275 .* T .* t1 + ((715 .* T - 286 .* t) .* t - 660 .* t1) .* t) .* t - 50 .* t2) .* t) .* t3 .* t6 .^ 2;

end



function D11z = in_sys7_diff11(t, z0, z1, T)

t1 = (T .^ 2);
t2 = 1 ./ T;
t3 = -1307674368000;
t4 = t2 .^ 2;
t5 = (t4 .^ 2);
t2 = (t2 .* t4 .* t5);
D11z = t3 .* (z1 - z0) .* ((-55 .* T .* t1 + ((-286 .* T + 143 .* t) .* t + 198 .* t1) .* t) .* t + 5 .* t1 .^ 2) .* t2 .* t5 .^ 2;

end



function D12z = in_sys7_diff12(t, z0, z1, T)

t1 = 1 ./ T;
t2 = t1 .^ 2;
t3 = (t2 .^ 2);
t1 = (t1 .* t2 .* t3);
D12z = (-373994869248000 .* t .* (T - t) + 71922090240000 .* T .^ 2) .* (T - 2 .* t) .* (z1 - z0) .* t1 .* t3 .^ 2;

end



function D13z = in_sys7_diff13(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -172613016576000;
t3 = t1 .^ 2;
t4 = (t3 .^ 2);
t1 = (t1 .* t3 .* t4);
D13z = t2 .* (z1 - z0) .* (-13 .* t .* (T - t) + 3 .* T .^ 2) .* t1 .* t4 .^ 2;

end



function D14z = in_sys7_diff14(t, z0, z1, T)

t1 = 1 ./ T;
t2 = 2243969215488000;
t3 = t1 .^ 2;
t4 = (t3 .^ 2);
t1 = (t1 .* t3 .* t4);
D14z = t2 .* (z1 - z0) .* (T - 2 .* t) .* t1 .* t4 .^ 2;

end



function D15z = in_sys7_diff15(t, z0, z1, T)

t1 = 1 ./ T;
t2 = -4487938430976000;
t3 = t1 .^ 2;
t4 = (t3 .^ 2);
t1 = (t1 .* t3 .* t4);
D15z = t2 .* (z1 - z0) .* t1 .* t4 .^ 2;

end


%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
