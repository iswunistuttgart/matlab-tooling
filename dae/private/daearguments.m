function [neq, tspan, ntspan, next, t0, tfinal, tdir, Q0, DQ0, f0, args, odeFcn, ...
          options, threshold, rtol, normcontrol, normy, hmax, htry, htspan, ...
          dataType ] =   ...
    daearguments(FcnHandlesUsed, solver, ode, tspan, Q0, DQ0, options, extras)
%DAEARGUMENTS  Helper function that processes arguments for all DAE solvers.
%
%   See also BETSCH

%   Mike Karr, Jacek Kierzenka
%   Copyright 1984-2017 The MathWorks, Inc.

if strcmp(solver,'ode15i')
  FcnHandlesUsed = true;   % no MATLAB v. 5 legacy for ODE15I
end  

if FcnHandlesUsed  % function handles used
  if isempty(tspan) || isempty(Q0) || isempty(DQ0)
    error(message('MATLAB:odearguments:TspanOrY0NotSupplied', solver));
  end      
  if length(tspan) < 2
    error(message('MATLAB:odearguments:SizeTspan', solver));
  end  
  htspan = abs(tspan(2) - tspan(1));  
  tspan = tspan(:);
  ntspan = length(tspan);
  t0 = tspan(1);  
  next = 2;       % next entry in tspan
  tfinal = tspan(end);     
  args = extras;                 % use f(t,y,p1,p2...) 

else  % ode-file used   (ignored when solver == ODE15I)
  % Get default tspan and y0 from the function if none are specified.
  if isempty(tspan) || isempty(Q0) || isempty(DQ0)
    if exist(ode)==2 && ( nargout(ode)<3 && nargout(ode)~=-1 ) 
      error(message('MATLAB:odearguments:NoDefaultParams', funstring( ode ), solver, funstring( ode )));      
    end
    [def_tspan,def_x0,def_v0, def_options] = feval(ode,[],[],'init',extras{:});
    if isempty(tspan)
      tspan = def_tspan;
    end
    if isempty(Q0)
      Q0 = def_x0;
    end
    if isempty(DQ0)
      DQ0 = def_v0;
    end
    options = daeset(def_options,options);
  end  
  tspan = tspan(:);
  ntspan = length(tspan);
  if ntspan == 1    % Integrate from 0 to tspan   
    t0 = 0;          
    next = 1;       % Next entry in tspan.
  else              
    t0 = tspan(1);  
    next = 2;       % next entry in tspan
  end
  htspan = abs(tspan(next) - t0);
  tfinal = tspan(end);   
  
  % The input arguments of f determine the args to use to evaluate f.
  if (exist(ode)==2)
    if (nargin(ode) == 3)           
      args = {};                   % f(t,y,yp)
    else
      args = [{''} extras];        % f(t,y,yp,'',p1,p2...)
    end
  else  % MEX-files, etc.
    try 
      args = [{''} extras];        % try f(t,y,yp,'',p1,p2...)     
      feval(ode,tspan(1),Q0(:),DQ0(:),args{:});
    catch
      args = {};                   % use f(t,y,yp) only
    end
  end
end

Q0 = Q0(:);
DQ0 = DQ0(:);
neq = length(Q0);

% Test that tspan is internally consistent.
if any(isnan(tspan))
  error(message('MATLAB:odearguments:TspanNaNValues'));
end
if t0 == tfinal
  error(message('MATLAB:odearguments:TspanEndpointsNotDistinct'));
end
tdir = sign(tfinal - t0);
if any( tdir*diff(tspan) <= 0 )
  error(message('MATLAB:odearguments:TspanNotMonotonic'));
end

f0 = feval(ode,t0,Q0,DQ0,args{:});
[m,n] = size(f0);
if n > 1
  error(message('MATLAB:odearguments:FoMustReturnCol', funstring( ode )));
elseif m ~= neq
  error(message('MATLAB:odearguments:SizeIC', funstring( ode ), m, neq, funstring( ode )));
end

% Determine the dominant data type
classT0 = class(t0);
classX0 = class(Q0);
classV0 = class(DQ0);
classF0 = class(f0);
dataType = superiorfloat(t0,Q0,DQ0,f0);

if ~( strcmp(classT0,dataType) && strcmp(classX0,dataType) && strcmp(classV0,dataType) && ...
      strcmp(classF0,dataType))
  input1 = '''t0'', ''Q0'', ''DQ0'''; 
  input2 = '''f(t0,q0,DQ0)''';
  warning(message('MATLAB:odearguments:InconsistentDataType',input1,input2,solver));
end        

% Get the error control options, and set defaults.
rtol = daeget(options,'RelTol',1e-3,'fast');
if (length(rtol) ~= 1) || (rtol <= 0)
  error(message('MATLAB:odearguments:RelTolNotPosScalar'));
end
if rtol < 100 * eps(dataType) 
  rtol = 100 * eps(dataType);
  warning(message('MATLAB:odearguments:RelTolIncrease', sprintf( '%g', rtol )))
end
atol = daeget(options,'AbsTol',1e-6,'fast');
if any(atol <= 0)
  error(message('MATLAB:odearguments:AbsTolNotPos'));
end
normcontrol = strcmp(daeget(options,'NormControl','off','fast'),'on');
if normcontrol
  if length(atol) ~= 1
    error(message('MATLAB:odearguments:NonScalarAbsTol'));
  end
  normy = norm(y0);
else
  if (length(atol) ~= 1) && (length(atol) ~= neq)
    error(message('MATLAB:odearguments:SizeAbsTol', funstring( ode ), neq)); 
  end
  atol = atol(:);
  normy = [];
end
threshold = atol / rtol;

% By default, hmax is 1/10 of the interval.
safehmax = 16.0*eps(dataType)*max(abs(t0),abs(tfinal));  % 'inf' for tfinal = inf
defaulthmax = max(0.1*(abs(tfinal-t0)), safehmax);
hmax = min(abs(tfinal-t0), abs(daeget(options,'MaxStep',defaulthmax,'fast')));
if hmax <= 0
  error(message('MATLAB:odearguments:MaxStepLEzero'));
end
htry = abs(daeget(options,'InitialStep',[],'fast'));
if ~isempty(htry) && (htry <= 0)
  error(message('MATLAB:odearguments:InitialStepLEzero'));
end

odeFcn = ode;

end
