function [conType, con0, conN, conFcn, conArgs, dVoptions] = ...
    daeconstraint(type,t0,q0,Dq0,options,extras)
% DAECONSTRAINT Helper function for the position constraint functions in DAEs
%    DAECONSTRAINT determines the type of the constraint vector/matrix,
%    initializes conFcn to the constraint vector/matrix function and creates a
%    cell-array of extra input arguments. DAECONSTRAINT evaluates the
%    constraint vector/matrix at(t0,q0,Dq0).
%
%   See also BETSCH DAEMASS

%   Jacek Kierzenka
%   Copyright 1984-2011 The MathWorks, Inc.

conType = 0;  
conFcn = [];
conArgs = {};
con0 = sparse(0,length(q0));
conN = 0;
dVoptions = [];
 
Voption = daeget(options,type,[],'fast');

if isempty(Voption)
  conFcn = @(t, q) sparse(0, length(q0));
  return;
else % try feval
  conFcn = Voption;
  conArgs = extras;
  if nargin(conFcn) > 2
    error('Constraint function must take exactly 2 arguments (t, q)');
  end
  con0 = feval(conFcn, t0, q0, conArgs{:});
end  

% Get size of the constraints
[conN, n] = size(con0);
% Jacobian constraints must return a KxN matrix
% Constraints matrix for the velocities must return an LxN matrix
if startsWith(type, 'J') || strcmp(type(end-1), 'D')
  if n ~= length(q0)
    error('Constraint function must return %d columns', length(q0));
  end
else
  if n > 1
    error('Constraint function must return a column vector');
  end
end


end
