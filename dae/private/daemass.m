function [massType, massM, massFcn, massArgs, dMoptions] = ...
    daemass(FcnHandlesUsed,ode,t0,q0,Dq0,options,extras)
%DAEMASS  Helper function for the mass matrix function in DAE solvers
%    DAEMASS determines the type of the mass matrix, initializes massFcn to
%    the mass matrix function and creates a cell-array of extra input
%    arguments. DAEMASS evaluates the mass matrix at(t0,q0,Dq0).  
%
%   See also BETSCH

%   Jacek Kierzenka
%   Copyright 1984-2011 The MathWorks, Inc.

massType = 0;  
massFcn = [];
massArgs = {};
massM = speye(length(q0));  
dMoptions = [];    % options for odenumjac computing d(M(t,q,Dq)*v)/dy

if FcnHandlesUsed     % function handles used    
  Moption = daeget(options,'Mass',[],'fast');
  if isempty(Moption)
    return    % massType = 0
  elseif isnumeric(Moption)
    massType = 1;
    massM = Moption;            
  else % try feval
    massFcn = Moption;
    massArgs = extras;  
    Mstdep = daeget(options,'MStateDependence','weak','fast');
    switch lower(Mstdep)
      case 'none' % M(t)
        massType = 2;
      case 'weak' % M(t, q)
        massType = 3;
      case 'strong' % M(t, q, Dq)
        massType = 4;
        
        dMoptions.diffvar  = 3;       % d(odeMxV(Mfun,t,y)/dy
        dMoptions.vectvars = [];  
        
        atol = daeget(options,'AbsTol',1e-6,'fast');
        dMoptions.thresh = zeros(size(q0))+ atol(:);  
        
        dMoptions.fac  = [];
        
        Mvs = daeget(options,'MvPattern',[],'fast'); 
        if ~isempty(Mvs)
          dMoptions.pattern = Mvs;          
          dMoptions.g = colgroup(Mvs);
        end
                  
      otherwise
        error(message('MATLAB:odemass:MStateDependenceMassType'));    
    end
    if massType > 3   % position and velocity state dependent
      massM = feval(massFcn,t0,q0,Dq0,massArgs{:});
    elseif massType > 2   % state-dependent
      massM = feval(massFcn,t0,q0,massArgs{:});
    else   % time-dependent only
      massM = feval(massFcn,t0,massArgs{:});
    end
  end  
  
else % ode-file
  mass = lower(daeget(options,'Mass','none','fast'));

  switch(mass)
    case 'none', return;  % massType = 0
    case 'm', massType = 1;
    case 'm(t)', massType = 2;
    case 'm(t,q)', massType = 3;
    case 'm(t,q,Dq)', massType = 4;
    otherwise
      error(message('MATLAB:odemass:InvalidMassProp', mass));
  end
  massFcn = ode;  
  massArgs = [{'mass'}, extras];
  massM = feval(massFcn,t0,q0,Dq0,massArgs{:});    

end



end
