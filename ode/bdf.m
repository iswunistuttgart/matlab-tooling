function varargout = bdf(odefun, tspan, y0, options, varargin)%#codegen
% BDF implements a linear multistep method to solve ODEs with BDF approximation
%
%   Inputs:
%
%   ODEFUN              Function handle of the ODE function or filename to the
%                       file. The ODE function must, in any case take two
%                       arguments (t, y) and return one argument, dydt.
%
%   TSPAN               2-element vector of [start, end] time values or Nx1
%                       vector of time values at which to evaluate the ODE. If a
%                       2-element vector is given, the step size from
%                       OPTIONS.MaxStep is taken. Defaults to 1e-3.
%
%   Y0                  Kx1 vector of initial states of the first-order ODE.
%
%   OPTIONS             Structure as returned by ODESET. Set MAXORDER to your
%                       desired value of the BDF algorithm. MAXORDER must be
%                       between 1 and 6.
%
%   Outputs:
%
%   T                   Nx1 vector of time steps at which the ODE was solved.
%
%   Y                   NxK vector of solution states of the ODE.
%
%   SOL                 Structure containing the time (.x), the solution (.y),
%                       and additional debugging information.
%
%   See also
%
%   ODESET



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-02
% Changelog:
%   2018-09-02
%       * Add support for 'OutputFcn'
%   2018-08-31
%       * Make sure BDF order is in 1..6
%   2018-08-30
%       * Use the step size calculated in ODEARGUMENTS if the actual step size
%       is not given in OPTIONS
%   2018-08-20
%       * Initial release



%% No validation of arguments to support %#codegen
% If only three arguments are given, or OPTIONS is empty or OPTIONS does not
% exist as variable, create a default value for it
if nargin < 4 || isempty(options) || exist('options', 'var') == 0
  options = [];
end



%% Parse arguments
% Default ODE options
% stDefaultOptions = odeset( ...
%     'MaxOrder', 3 ...
% );

% Make sure we have all default ODE options
stOptions = odeset(options);

% Make sure BDF's MaxOrder is within the range of 1..6
stOptions = odeset(stOptions, 'MaxOrder', limit(odeget(stOptions, 'MaxOrder', 3, 'fast'), 1, 6));

% Number of the BDF we use
nBDF = stOptions.MaxOrder;

% Set solver name
chSolverName = sprintf('bdf%g', nBDF);

% Check if ODEFUN is a function handle or points to a file
loFHUsed = isa(odefun, 'function_handle');

% Number of function evaluations
nFuncEval = 0;

% Parse the ODE arguments using MATLAB's built-in ODEARGUMENTS function
[nEquations, vTspan, nTime, next, dTime_0, dTime_T, dTime_Dirn, y0, f0, odeArgs, odefun, ...
 stOptions, threshold, rtol, normcontrol, normy, hmax, htry, htspan, dataType] = ...
    odearguments(loFHUsed, chSolverName, odefun, tspan, y0, stOptions, varargin);

% ODE function was once evaluated inside ODEARGUMENTS
nFuncEval = nFuncEval + 1;

% Get step size from options
dStepsize = odeget(stOptions, 'MaxStep', -1, 'fast');
% No step size given in options, so infer it from vTspan
if dStepsize == -1
  % Set the step size from the step size inferred in ODEARGUMENTS
  dStepsize = htspan;
end



%% Handle mass matrix
% nMass_Type == 0: no mass matrix
% nMass_Type == 1: M
% nMass_Type == 2: M(t)
% nMass_Type == 3: M(t, y)
[nMass_Type, aMass_0, fhMass, ceMass_arg, stMass_Options] = odemass(loFHUsed, odefun, dTime_0, y0, stOptions, varargin);
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

% Determine function callback of mass matrix
switch stMass.Type
  case 0 % []
    stMass.Function = @(t, y) stMass.Value;
  case 1 % M
    stMass.Function = @(t, y) stMass.Value;
  case 2 % M(t)
    stMass.Function = @(t, y) stMass.Function(t);
  case 3 % M(t, y)
    % Nothing to be done here, everything's as it's supposed to be
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

% Output time
tout = zeros(1, nChunk, dataType);
% Output state
yout = zeros(nEquations, nChunk, dataType);

% Set initial values
nout = 1;
tout(nout) = dTime_0;
yout(:,nout) = y0;

% Options for fsolve
stOptsFsolve = optimoptions( ...
    'fsolve' ...
    , 'Algorithm', 'levenberg-marquardt' ...
    , 'Display', 'off' ...
    , 'FunctionTolerance', dStepsize^5 ...
    , 'StepTolerance', dStepsize^4 ...
);



%% Set up first states by increasing Euler Backward
% Some people like to use explicit Runge-Kutta for the first n-1 steps, but I
% prefer to use an adaptive-order BDF formulation

% Keep track of if we're done or not
done = false;

% Initialize the output function.
if haveOutputFcn
  feval(outputFcn, [dTime_0, dTime_T], [xFull(:,nout); vFull(:,nout)], 'init', outputArgs{:});
end

% Do not stop while we are not done (d'uh)
while ~done
    
  % Time value of current step
  tcurr = tout(nout);

  % Time value of next step
  tnew = tcurr + dStepsize;

  % All previous till current states
  yprevs = yout(:,1:nout);

  % Initial value for yn1 for fsolve based on Euler forward
  ynew_guess = yprevs(:,end) + dStepsize*feval(odefun, tnew, yprevs(:,end));

  % Solve the implicit equation for y_n+1
  [ynew, ~, ~, output] = fsolve( ...
      @(ynew) bdf_acceleration(odefun, nout, yprevs, tnew, ynew, dStepsize, stMass) ...
      , ynew_guess ...
      , stOptsFsolve ...
  );

  % Advance current state counter
  nout = nout + 1;

  % Add to function evaluation count the number of function evaluations inside
  % `fsolve`
  nFuncEval = nFuncEval + output.funcCount;

  % Enlarge time and solution storage if it's insufficiently small
  if nout > length(tout)
    tout = [tout, zeros(1, nChunk, dataType)];
    yout = [yout, zeros(nEquations, nChunk, dataType)];
  end

  % Append time and solution to storage
  tout(nout) = tnew;
  yout(:,nout) = ynew;

  % Stop loopp if we are at the last iteration of the BDF initalization
  done = nout > nBDF;
  
  % Call output function?
  if haveOutputFcn
    
    % Call output function and await return
    stop = feval(outputFcn, tnew, ynew, '', outputArgs{:});
  end
  
end



%% Following steps: Euler Backward of desired order
  
% Pre-calculate index span of solution vector
idxBdfSpan = -(nBDF-1):0;

% Keep track of if we're done or not
done = false;

% Do not stop while we are not done (d'uh)
while ~done
    
  % Time value of current step
  tcurr = tout(nout);

  % Time value of next step
  tnew = tcurr + dStepsize;

  % All previous till current states
  yprevs = yout(:,nout + idxBdfSpan);

  % Initial value for yn1 for fsolve based on Euler forward
  ynew_guess = yprevs(:,end) + dStepsize*feval(odefun, tnew, yprevs(:,end));

  % Solve the implicit equation for y_n+1
  [ynew, ~ , ~, output] = fsolve( ...
      @(ynew) bdf_acceleration(odefun, nBDF, yprevs, tnew, ynew, dStepsize, stMass) ...
      , ynew_guess ...
      , stOptsFsolve ...
  );

  % Advance current state counter
  nout = nout + 1;

  % Add to function evaluation count the number of function evaluations inside
  % `fsolve`
  nFuncEval = nFuncEval + output.funcCount;

  % Enlarge time and solution storage if it's insufficiently small
  if nout > length(tout)
    tout = [tout, zeros(1, nChunk, dataType)];
    yout = [yout, zeros(nEquations, nChunk, dataType)];
  end

  % Append time and solution to storage
  tout(nout) = tnew;
  yout(:,nout) = ynew;

  % Stop loop if we less than one time step away from the final value
  done = nout == nTime;
  
  % Call output function?
  if haveOutputFcn
    
    % Call output function and await return
    stop = feval(outputFcn, tnew, ynew, '', outputArgs{:});
    
    % Stop requested from output function?
    if stop
      done = true;
    end
  end
  
end

% Reduce the step counter by one since we stopped one step after the final time
% nout = nout - 1;

% Get indices that are to be returned
% idxOut = find(tout <= dTime_T, ;

% Finalize data
tout = tout(1:nout);
yout = yout(:,1:nout);

% Call output function on done?
if haveOutputFcn
  feval(outfun, [], [], 'done', outputArgs{:});
end



%% Assign output quantities

% BDF(...)
% SOL = BDF(...)
if nargout < 2
  varargout{1} = struct( ...
      'x', tout ...
    , 'y', yout ...
  );
end

% [T, Y] = BDF(...)
if nargout < 3
  varargout{1} = transpose(tout);
  varargout{2} = transpose(yout);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
