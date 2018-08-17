function [t, y] = odeXb(odefun, tspan, y0, options)
% ODEXB solves an ODE with X-th order BDF Euler
%
%   Inputs:
%
%   ODEFUN              Function handle to the ODE of the form @(t, y)
%
%   TSPAN               1x2 vector of [T0, TE] or a 1xN vector of time values at
%                       which to integrate the ODE.
%
%   Y0                  Kx1 vector of initial values
%
%   OPTIONS             Structure containing optional arguments to configure the
%                       solver.
%
%   Outputs:
%
%   T                   Nx1 vector of time values at which ODEFUN was evaluated.
%
%   Y                   NxK vector of solution of ODEFUN.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-17
% Changelog:
%   2018-08-17
%       * Initial release



%% Validate arguments
try
    % ODEXB(ODEFUN, TSPAN, Y0)
    % ODEXB(ODEFUN, TSPAN, Y0, OPTIONS)
    narginchk(3, 4);
    
    % ODEXB(ODEFUN, TSPAN, Y0)
    % SOL = ODEXB(ODEFUN, TSPAN, Y0)
    % [T, Y] = ODEXB(ODEFUN, TSPAN, Y0)
    nargoutchk(0, 2);
    
    % Default options
    if nargin < 4
        options = odeset({});
    end
    
    % ODE function callback
    validateattributes(odefun, {'function_handle'}, {'nonempty'}, mfilename, 'odefun');
    
    % Time vector: increasing
    validateattributes(tspan, {'numeric'}, {'nonempty', 'increasing', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'tspan');
    
    % Initial state
    validateattributes(y0, {'numeric'}, {'vector', 'column', 'nonempty', 'nonnan', 'finite', 'nonsparse'}, mfilename, 'y0');
    
    % ODE options
catch me
    throwAsCaller(me);
end



%% Parse arguments
% Default ODE options
stDefaultOptions = odeset( ...
      'MaxOrder', 3 ...
    , 'MaxStep', 1e-4 ...
);

% Make sure we have all default ODE options
stOptions = odeset(stDefaultOptions, options);

% Create a uniformly spaced time-vector from the first and last time value
if numel(tspan) == 2
    vTime = tspan(1):stOptions.MaxStep:tspan(2);
% Time vector is given
% @TODO check time vector is uniform
else
    vTime = tspan;
end

% Column vectors are preferred
vTime = vTime(:);

% Count entries in time vector
nTime = numel(vTime);

% Get step size from time vector
dStepsize = diff(vTime([1, 2]));

% Make sure we have a column vector
y0 = y0(:);

% Butcher tableau
aButcher = [ ...
    [      0,       0,      0,        0,       0,       -1] ; ...
    [      0,       0,      0,        0,     1/3,     -4/3] ; ...
    [      0,       0,      0,    -2/11,    9/11,   -18/11] ; ...
    [      0,       0,   3/25,   -16/25,   36/25,   -48/25] ; ...
    [ 60/137, -12/137, 75/137, -200/137, 300/137, -300/137] ; ...
    [ 10/147,  -24/49,  75/49, -400/147,  150/49,  -120/49] ; ...
];

% Weights of step sizes
vWeights = [ ...
         1 ; ...
       2/3 ; ...
      6/11 ; ...
     12/25 ; ...
    60/137 ; ...
    60/147 ; ...
];

% Number of the BDF we use
nBDF = stOptions.MaxOrder;

% Initialize the result state vector
aSolution = zeros(numel(y0),nTime);
aSolution(:,1) = y0;

% Options for fsolve
stOptsFsolve = optimoptions( ...
    'fsolve' ...
    , 'Algorithm', 'levenberg-marquardt' ...
    , 'Display', 'off' ...
);

% Number of function evaluations
nFuncEval = 0;



%% Set up further states by increasing Euler Backward
% Init the first N - 1 steps with increasing Euler Backward calculation
for iTime = 1:nBDF-1
    % Current time value
    tn = vTime(iTime);
    % New time value
    tn1 = tn + dStepsize;
    % All previous till current states
    ynr = aSolution(:,1:iTime);
    % Current state vector
    yn = ynr(:,end);
    
    % Initial value for yn1 for fsolve based on Euler forward
    yn1_0 = yn(:) + dStepsize*feval(odefun, tn, yn);
    
    % Solve the implicit equation for y_n+1
    [aSolution(:,iTime + 1), ~, output] = fsolve( ...
        @(yn1) yn1 + ynr*transpose(aButcher(iTime,end-(iTime-1):end)) - vWeights(iTime)*dStepsize*feval(odefun, tn1, yn1) ...
        , yn1_0 ...
        , stOptsFsolve ...
    );
    
    % Add to function evaluation count the number of function evaluations inside
    % `fsolve`
    nFuncEval = nFuncEval + output.funcCount;
end



%% Following steps: Euler Backward of desired order

% Loop over every time value
for iTime = nBDF:(nTime - 1)
    % Current time value
    tn = vTime(iTime);
    % New time value
            tn1 = tn + dStepsize;
    % All previous till current states
    ynr = aSolution(:,iTime-(nBDF-1):iTime);
    % Current state vector
    yn = ynr(:,end);
    
    % Initial value for yn1 for fsolve based on Euler forward
    yn1_0 = yn + dStepsize*feval(odefun, tn, yn);
    
    % Solve the implicit equation for y_n+1
    [aSolution(:,iTime + 1), ~, output] = fsolve( ...
        @(yn1) yn1 + ynr*transpose(aButcher(nBDF,end-(nBDF-1):end)) - vWeights(nBDF)*dStepsize*feval(odefun, tn1, yn1) ...
        , yn1_0 ...
        , stOptsFsolve ...
    );
    
    % Add to function evaluation count the number of function evaluations inside
    % `fsolve`
    nFuncEval = nFuncEval + output.funcCount;
end



%% Assign output quantities
% Time vector
t = vTime;
% Solution vector
y = transpose(aSolution);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
