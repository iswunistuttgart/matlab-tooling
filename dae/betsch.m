function varargout = betsch(odefun, tsp, x0, v0, options, varargin)%#codegen
% BETSCH implements BETSCH's ODE time-stepping scheme for mechanical systems
%
%   BETSCH gives an energy-consistent numerical integration of mechanical
%   systems with mixed holonomic and non-holonomic constraints. It is based on
%   integration of the second-order DAE system with holonomic and non-holonomic
%   constraints.
%
%   SOL = BETSCH(ODEFUN, TSPAN, X0, V0) performs numerical integration of the
%   constrained system given through the ODE-function ODEFUN.
%
%   SOL = LEAPFROG(ODEFUN, TSPAN, X0, V0) performs Leapfrog integration of the
%   ODE given in ODEFUN over the time span given in TSPAN with initial position
%   states X0 and initial velocity states V0.
%
%   [T, XV] = BETSCH(...) returns the Kx1 time vector, the Kx2N position vector
%   and KxN velocity vector.
%
%   [T, X, V] = BETSCH(...) returns the Kx1 time vector, the KxN position
%   vector, and the KxN velocity vector.
%
%   Inputs:
%
%   ODEFUN              Function handle to the ODE's right-hand side.
%
%   TSPAN               2x1 vector of [t_start, t_end] or Kx1 vector of time
%                       values at which to integrate the DAE for.
%
%   X0                  Nx1 vector of initial position states for t == t_start.
%
%   V0                  Nx1 vector of initial velocity states for t == t_n-1/2
%
%   OPTIONS             Structure array of options to be passed to the ODE
%                       integrator obtained from ODESET.
%
%   Outputs:
%
%   T                   Kx1 vector of time stamps at which the ODE was
%                       evaluated.
%
%   X                   KxN vector of the solution position states.
%
%   V                   KxN vector of the solution velocity states.
%
%   XV                  Kx2N vector of the solution position and velocity
%                       states.
%
%   See also
%
%   ODESET



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-30
% Changelog:
%   2018-08-30
%       * Code cleanup
%       * Fix step size calculation such that final value of T matches the given
%       final time value
%       * Also fix missing the last time step value in the integration process
%   2018-08-23
%       * Initial release



%% No validation of arguments to support %#codegen
% If only three arguments are given, or OPTIONS is empty or OPTIONS does not
% exist as variable, create a default value for it
if nargin < 5 || isempty(options) || exist('options', 'var') == 0
  options = [];
end



%% Parse arguments
% Default ODE options
stDefaultOptions = odeset({});

% Make sure we have all default DAE options
stOptions = daeset(stDefaultOptions, options);

% Set solver name
chSolverName = 'betsch';

% Check if ODEFUN is a function handle or if it points to a file
loFHUsed = isa(odefun, 'function_handle');

% Number of function evaluations
nFuncEval = 0;

% Parse the DAE arguments using our own DAEARGUMENTS function
[nEquations, vTspan, nTime, next, dTime_0, dTime_T, dTime_Dirn, x0, v0, f0, odeArgs, odefun, ...
 stOptions, threshold, rtol, normcontrol, normy, hmax, htry, htspan, dataType] = ...
    daearguments(loFHUsed, chSolverName, odefun, tsp, x0, v0, stOptions, varargin);

% ODE function was once evaluated inside ODEARGUMENTS
nFuncEval = nFuncEval + 1;

% Get step size from options
dStepsize = daeget(stOptions, 'MaxStep', -1, 'fast');

% No step size given in options, so infer it from vTspan
if dStepsize == -1
  % Get the default step size from the call to `ODEARGUMENTS`
  dStepsize = htspan;
end
% % Pre-calculate half of the step size
% dStepsizeHalf = 1/2*dStepsize;
% % Pre-calculate double of the step size
% dStepsizeDouble = 2*dStepsize;



%% Handle mass matrix
% nMass_Type == 0: no mass matrix
% nMass_Type == 1: M
% nMass_Type == 2: M(t)
% nMass_Type == 3: M(t, q)
% nMass_Type == 4: M(t, q, Dq)
[nMass_Type, aMass_0, fhMass, ceMass_arg, stMass_Options] = daemass(loFHUsed, odefun, dTime_0, x0, v0, stOptions, varargin);
% Stucture containing information on the mass matrix
stMass = struct( ...
    'Type', nMass_Type ...
  , 'Value', aMass_0 ...
  , 'Function', fhMass ...
  , 'Arguments', {{}} ...
  , 'Options', [] ...
);
if ~isempty(ceMass_arg)
  stMass.Arguments = ceMass_arg;
end
if isa(stMass_Options, 'struct')
  stMass.Options = stMass_Options;
end
% Adjust for ODEMASS returning a mass matrix of size 2Nx2N when there isn't any
% mass matrix given in OPTIONS
if size(stMass.Value, 1) == 2*nEquations
  stMass.Value = stMass.Value(end-(nEquations-1):end,end-(nEquations-1):end);
end

% Determine function callback of mass matrix
switch stMass.Type
  case 0 % []
    stMass.Function = @(t, y) stMass.Value;
  case 1 % M
    stMass.Function = @(t, y) stMass.Value;
  case 2 % M(t)
    stMass.Function = @(t, y) stMass.Function(t);
  case {3, 4} % M(t, x, v)
    % Nothing to be done here, everything's as it's supposed to be
end



%% Handle position constraints
% nConQ_Type == 0: no constraints
% nConQ_Type == 4: PhiQ(t, q)
% [conType, con0, conN, conFcn, conArgs, dVoptions]
[nConQ_Type, vConQ_0, nConQ, fhConQ, ceConQ_Arg, stConQ_Options] = daeconstraint('ConstraintsQ', dTime_0, x0, v0, stOptions, varargin);
% Stucture containing information on the mass matrix
stConQ = struct( ...
    'Type', nConQ_Type ...
  , 'Value', vConQ_0 ...
  , 'Number', nConQ ...
  , 'Function', fhConQ ...
  , 'Arguments', {{}} ...
  , 'Options', [] ...
);
if ~isempty(ceConQ_Arg)
  stConQ.Arguments = ceConQ_Arg;
end
if isa(stConQ_Options, 'struct')
  stConQ.Options = stConQ_Options;
end



%% Handle position constraints Jabocian
% nConJQ_Type == 0: no constraints
% nConJQ_Type == 4: JPhiQ(t, q)
[nConJQ_Type, vConJQ_0, ~, fhConJQ, ceConJQ_Arg, stConJQ_Options] = daeconstraint('JConstraintsQ', dTime_0, x0, v0, stOptions, varargin);
% Stucture containing information on the mass matrix
stConJQ = struct( ...
    'Type', nConJQ_Type ...
  , 'Value', vConJQ_0 ...
  , 'Function', fhConJQ ...
  , 'Arguments', {{}} ...
  , 'Options', [] ...
);
if ~isempty(ceConJQ_Arg)
  stConJQ.Arguments = ceConJQ_Arg;
end
if isa(stConJQ_Options, 'struct')
  stConJQ.Options = stConJQ_Options;
end



%% Handle velocity constraints
% nConDQ_Type == 0: no constraints
% nConDQ_Type == 4: PhiDQ(t, q)
[nConDQ_Type, vConDQ_0, nConDQ, fhConDQ, ceConDQ_Arg, stConDQ_Options] = daeconstraint('ConstraintsDQ', dTime_0, x0, v0, stOptions, varargin);
% Stucture containing information on the mass matrix
stConDQ = struct( ...
    'Type', nConDQ_Type ...
  , 'Value', vConDQ_0 ...
  , 'Function', fhConDQ ...
  , 'Arguments', {{}} ...
  , 'Options', [] ...
);
if ~isempty(ceConDQ_Arg)
  stConDQ.Arguments = ceConDQ_Arg;
end
if isa(stConDQ_Options, 'struct')
  stConDQ.Options = stConDQ_Options;
end



%% Output Function

% Handle the output
if nargout > 0
  outputFcn = odeget(stOptions, 'OutputFcn', [], 'fast');
else
  outputFcn = odeget(stOptions, 'OutputFcn', @odeplot, 'fast');
end
outputArgs = {};      
if isempty(outputFcn)
  haveOutputFcn = false;
else
  haveOutputFcn = true;
  outputSel = odeget(stOptions, 'OutputSel', 1:nEquations, 'fast');
  if isa(outputFcn,'function_handle')  
    % With MATLAB 6 syntax pass additional input arguments to outputFcn.
    outputArgs = varargin;
  end  
end



%% Init output
% Don't refine output values: we already sample at a fixed step size
refine = 1;
% Calculation of 
nChunk = min(max(100,50*refine), refine+floor((2^11)/nEquations));

% Options for fsolve
stOptsFsolve = optimoptions( ...
    'fsolve' ...
    , 'Algorithm', 'levenberg-marquardt' ...
    , 'InitDamping', 5*1e-6 ...
    , 'ScaleProblem', 'jacobian' ...
    , 'Display', 'off' ...
    , 'FunctionTolerance', dStepsize*1e-3 ...
    , 'StepTolerance', dStepsize*1e-3 ...
    , 'OptimalityTolerance', 1e-6 ...
    , 'MaxFunctionEvaluations', 1337*(nEquations + nConQ + nConDQ) ...
    , 'MaxIterations', 999 ...
    ... , 'UseParallel', true ...
);

% Output time
tout = zeros(1, nChunk, dataType);
% Positions and velocities at time steps
xout = zeros(nEquations, nChunk, dataType);
vout = zeros(nEquations, nChunk, dataType);
% Lagrange multipliers Lambda (position constraints) and Mu (velocity
% constraints)
llout = zeros(nConQ, nChunk, dataType);
lmout = zeros(nConDQ, nChunk, dataType);

% Set initial values
nout = 1;
tout(nout) = dTime_0;
xout(:,nout) = x0;
vout(:,nout) = v0;

% Keep track of if we're done integrating or not
done = false;

% Determine indices of the position state and the Lagrange multipliers in the
% optimization vector
idxQ = 1:nEquations;
idxDQ = nEquations + (1:nEquations);
idxLL = 2*nEquations + (1:nConQ);
idxLM = 2*nEquations + nConQ + (1:nConDQ);


% First, we want to determine consistent lagrange multipliers for the current
% state
% Guess for initial state
q0 = [x0; v0; zeros(nConQ, 1); zeros(nConDQ, 1)];
% Determine consistent initial conditions (mostly Lagrange multipliers)
[q0new, ~, ~, output] = fsolve( ...
  @(qftest) betsch_ic(odefun ...
    , dTime_0, x0, v0 ...
    , qftest(idxLL), qftest(idxLM) ...
    , stMass ...
    , stConQ, stConDQ, stConJQ ...
  ) ...
  , q0 ...
  , stOptsFsolve ...
);
% Advance function evaluation counter by the number of function evaluations
% inside `fsolve`
nFuncEval = nFuncEval + output.funcCount;

% Update initial values
nout = 1;
llout(:,nout) = q0new(idxLL);
lmout(:,nout) = q0new(idxLM);

% Initialize the output function.
if haveOutputFcn
  feval(outputFcn, [dTime_0, dTime_T], q0new, 'init', outputArgs{:});
end

% Continue integrating while we're not done
while ~done
  
  % Current and next time values
  tcurr = (nout - 1)*dStepsize;
  tnew = tcurr + dStepsize;
  
  % Current positions and velocities
  xcurr = xout(:,nout);
  vcurr = vout(:,nout);
  % Current constraint forces
  llcurr = llout(:,nout);
  lmcurr = lmout(:,nout);
  
  % Guess of next state from simple Euler forward
  qfnew_guess = [ ...
    xcurr + dStepsize*vcurr ; ...
    vcurr ; ...
    llcurr ; ...
    lmcurr ; ...
  ];
  
  % Determine the next constraint satisfying positions and the constraint
  % enforcing Lagrange multiplier
  [qnew, fval, exitflag, output, jacobian] = fsolve( ...
    @(qftest) betsch_acceleration( ...
        odefun ...
      , tcurr, xcurr, vcurr ...
      , qftest(idxQ), qftest(idxDQ), qftest(idxLL), qftest(idxLM) ...
      , dStepsize ...
      , stMass ...
      , stConQ, stConDQ, stConJQ ...
    ) ...
    , qfnew_guess ...
    , stOptsFsolve ...
  );
  
  % Advance function evaluation counter by the number of function evaluations
  % inside `fsolve`
  nFuncEval = nFuncEval + output.funcCount;
  
  % Increase state counter
  nout = nout + 1;
  
  % Enlarge time and solution storage if it's insufficiently small
  if nout > length(tout)
    tout = [tout, zeros(1, nChunk, dataType)];
    xout = [xout, zeros(nEquations, nChunk, dataType)];
    vout = [vout, zeros(nEquations, nChunk, dataType)];
    llout = [llout, zeros(nConQ, nChunk, dataType)];
    lmout = [lmout, zeros(nConDQ, nChunk, dataType)];
  end
  
  % Next time value
  tout(nout) = tnew;
  
  % Next positions values
  xnew = qnew(idxQ);
  xout(:,nout) = xnew;
  
  % Update velocities for next time step
  vout(:,nout) = 2/dStepsize*(xnew - xcurr) - vcurr;
  
  % Next Lagrange multipliers values (Lambda; position constraints)
  llout(:,nout) = qnew(idxLL);
  
  % Next Lagrange mutlipliers values (Mu; velocity constraints)
  lmout(:,nout) = qnew(idxLM);
  
  % Determine finalization state
  done = nout == nTime;
  
  % Call output function?
  if haveOutputFcn
    
    % Call output function and await return
    stop = feval(outputFcn, tnew, qnew, '', outputArgs{:});
    
    % Stop requested from output function?
    if stop
      done = true;
    end  
  end
  
end

% Finalize data
tout = tout(1:nout);
xout = xout(:,1:nout);
vout = vout(:,1:nout);

% Call output function on done?
if haveOutputFcn
  feval(outfun, [], [], 'done', outputArgs{:});
end



%% Assign output quantities

% LEAPFROG(...)
% SOL = LEAPFROG(...)
if nargout < 2
  varargout{1} = struct( ...
      'x', tout ...
    , 'y', xout ...
    , 'z', vout ...
  );
end

% [T, [X, V]] = LEAPFROG(...)
if nargout < 3
  varargout{1} = transpose(tout);
  varargout{2} = [transpose(xout), transpose(vout)];
end

% [T, X, V] = LEAPFROG(...)
if nargout < 4
  varargout{1} = transpose(tout);
  varargout{2} = transpose(xout);
  varargout{3} = transpose(vout);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
