function [U, Axes, UInh] = oneDimWaveDamped_OneCable(TOrDeltaT, DeltaX, StartPosition, StartVelocity, BoundaryLeft, BoundaryRight)

%% Argument defaults
dT = 10;
dDeltaT = 1e-3;
dDeltaX = 1e-2;
fhStartPosition = @(x) x.*0;
fhStartVelocity = @(x) x.*0;
fhBoundaryLeft = @(t) 0;
fhBoundaryRight = @(t) 0;



%% Assertion
assert(nargin < 1 || isempty(TOrDeltaT) || isa(TOrDeltaT, 'double') && all(0 < TOrDeltaT) && all(TOrDeltaT < Inf) );
assert(nargin < 2 || isempty(DeltaX) || isa(DeltaX, 'double') && isscalar(DeltaX) && 0 < DeltaX && DeltaX < 1 );
assert(nargin < 3 || isempty(StartPosition) || isa(StartPosition, 'function_handle'));
assert(nargin < 4 || isempty(StartVelocity) || isa(StartVelocity, 'function_handle'));
assert(nargin < 5 || isempty(BoundaryLeft) || isa(BoundaryLeft, 'function_handle'));
assert(nargin < 6 || isempty(BoundaryRight) || isa(BoundaryRight, 'function_handle'));



%% Argument parsing
if nargin >= 1 && ~isempty(TOrDeltaT)
    if isscalar(TOrDeltaT)
        if TOrDeltaT < 1
            dDeltaT = TOrDeltaT;
        else
            dT = TOrDeltaT;
        end
    else
        dDeltaT = min(TOrDeltaT);
        dT = max(TOrDeltaT);
    end
end

if nargin >= 2 && ~isempty(DeltaX)
    dDeltaX = DeltaX;
end

if nargin >= 3 && ~isempty(StartPosition)
    fhStartPosition = StartPosition;
end

if nargin >= 4 && ~isempty(StartVelocity)
    fhStartVelocity = StartVelocity;
end

if nargin >= 5 && ~isempty(BoundaryLeft)
    fhBoundaryLeft = BoundaryLeft;
end

if nargin >= 6 && ~isempty(BoundaryRight)
    fhBoundaryRight = BoundaryRight;
end



%% Variables for solving
% Wave speed
c = 1;

% Length of simulation
TSim = dT;
% Discretization of T
dt = dDeltaT;

% Length of the beam
L = 1;
% Discretization of L
dx = dDeltaX;

% Create the linear vectors of time ...
t = 0:dt:TSim;
% Number of nodes in time
nt = numel(t);
% ... and space
x = 0:dx:L;
% Number of nodes in space
nx = numel(x);

% Ratio of time to space with regards to speed of wave
r = c*dt/dx;

% Gravity
g = 0.5*9.81*1e-10;

% Check stability criterion for simulation
if r > 1
    error('Not running numerically unstable simulation');
end


%% Initialize the wave equation
% Holds the homogenous solution
U_hom = zeros(nt, nx);
U_inh = zeros(nt, nx);

%%% Initial conditions
% Initial deflection
U_startPos = fhStartPosition;
% Initial velocity
U_startVel = fhStartVelocity;

%%% Boundary conditions
% Left side (x = 0)
U_left = fhBoundaryLeft;
% Right side (x = L)
U_right = fhBoundaryRight;

%%% Leapfrog vector and matrix for inner ndoes
% Leapfrog vector
% b = @(t) r^2.*[U_left(t), zeros(1, nx-2), U_right(t)];
b = @(t) r^2.*[U_left(t), zeros(1, nx-4), U_right(t)];
% Leapfrog matrix
% B = diag(2*(1-r^2)*ones(nx,1),0) + diag(r^2*ones(nx-1,1),1) + diag(r^2*ones(nx-1,1),-1);
% B = diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1);
B = sparse(diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1));

% Inhomogeneous function
h = @(t,x) -g.*ones(size(x, 1), size(x, 2));



%% Numeric intergration
% Very first state is the position given in U_startPos
U_hom(1,:) = U_startPos(x);
U_inh(1,:) = U_startPos(x);
% The second row of U contains the speed at this moment which we will
% interpolate
% U_hom(2,:) = 1/2.*transpose(B*transpose(U_hom(1,:))) + dt*U_startVel(x) + 1/2.*b(U_hom(1,:));
U_hom(2,2:end-1) = 1/2.*transpose(B*transpose(U_hom(1,2:end-1))) + dt*U_startVel(x(2:end-1)) + 1/2.*b(U_hom(1,2:end-1));
U_inh(2,2:end-1) = 1/2.*transpose(B*transpose(U_inh(1,2:end-1))) + dt*U_startVel(x(2:end-1)) + 1/2.*b(U_inh(1,2:end-1));

% Run the approxmiation
for iTime = 2:nt-1
%     U_hom(iTime+1,:) = transpose(B*transpose(U_hom(iTime,:))) - U_hom(iTime-1,:) + b(t(iTime));
    U_hom(iTime+1,1) = U_left(t(iTime));
    U_hom(iTime+1,2:end-1) = transpose(B*transpose(U_hom(iTime,2:end-1))) - U_hom(iTime-1,2:end-1) + b(t(iTime));
    U_hom(iTime+1,end) = U_right(t(iTime));
    
    U_inh(iTime+1,1) = U_left(t(iTime));
    U_inh(iTime+1,2:end-1) = transpose(B*transpose(U_inh(iTime,2:end-1))) - U_inh(iTime-1,2:end-1) + b(t(iTime)) + h(t(iTime),U_inh(iTime,2:end-1));
    U_inh(iTime+1,end) = U_right(t(iTime));
end


%% Assign output quantities
% First output is the wave equation
U = U_hom;

% Second output is information about the simulation i.e., the vectors t, x and
% the constants dt, dx
if nargout > 1
    Axes = struct();
    Axes.DimT = t;
    Axes.DimX = x;
    Axes.DeltaT = dt;
    Axes.DeltaX = dx;
end

% Third output is the inhomogeneous wave equation
if nargout > 2
    UInh = U_inh;
end


endfunction [U, Axes, UInh] = oneDimWave_OneCable(TorDeltaT, DeltaX, StartPosition, StartVelocity, BoundaryLeft, BoundaryRight)

%% Argument defaults
dT = 10;
dDeltaT = 1e-3;
dDeltaX = 1e-2;
fhStartPosition = @(x) x.*0;
fhStartVelocity = @(x) x.*0;
fhBoundaryLeft = @(t) 0;
fhBoundaryRight = @(t) 0;



%% Assertion
assert(nargin < 1 || isempty(TOrDeltaT) || isa(TOrDeltaT, 'double') && all(0 < TOrDeltaT) && all(TOrDeltaT < Inf) );
assert(nargin < 2 || isempty(DeltaX) || isa(DeltaX, 'double') && isscalar(DeltaX) && 0 < DeltaX && DeltaX < 1 );
assert(nargin < 3 || isempty(StartPosition) || isa(StartPosition, 'function_handle'));
assert(nargin < 4 || isempty(StartVelocity) || isa(StartVelocity, 'function_handle'));
assert(nargin < 5 || isempty(BoundaryLeft) || isa(BoundaryLeft, 'function_handle'));
assert(nargin < 6 || isempty(BoundaryRight) || isa(BoundaryRight, 'function_handle'));



%% Argument parsing
if nargin >= 1 && ~isempty(TOrDeltaT)
    if isscalar(TOrDeltaT)
        if TOrDeltaT < 1
            dDeltaT = TOrDeltaT;
        else
            dT = TOrDeltaT;
        end
    else
        dDeltaT = min(TOrDeltaT);
        dT = max(TOrDeltaT);
    end
end

if nargin >= 2 && ~isempty(DeltaX)
    dDeltaX = DeltaX;
end

if nargin >= 3 && ~isempty(StartPosition)
    fhStartPosition = StartPosition;
end

if nargin >= 4 && ~isempty(StartVelocity)
    fhStartVelocity = StartVelocity;
end

if nargin >= 5 && ~isempty(BoundaryLeft)
    fhBoundaryLeft = BoundaryLeft;
end

if nargin >= 6 && ~isempty(BoundaryRight)
    fhBoundaryRight = BoundaryRight;
end



%% Variables for solving
% Wave speed
c = 1;

% Length of simulation
TSim = dT;
% Discretization of T
dt = dDeltaT;

% Length of the beam
L = 1;
% Discretization of L
dx = dDeltaX;

% Create the linear vectors of time ...
t = 0:dt:TSim;
% Number of nodes in time
nt = numel(t);
% ... and space
x = 0:dx:L;
% Number of nodes in space
nx = numel(x);

% Ratio of time to space with regards to speed of wave
r = c*dt/dx;

% Gravity
g = 0.5*9.81*1e-10;

% Check stability criterion for simulation
if r > 1
    error('Not running numerically unstable simulation');
end


%% Initialize the wave equation
% Holds the homogenous solution
U_hom = zeros(nt, nx);
U_inh = zeros(nt, nx);

%%% Initial conditions
% Initial deflection
U_startPos = fhStartPosition;
% Initial velocity
U_startVel = fhStartVelocity;

%%% Boundary conditions
% Left side (x = 0)
U_left = fhBoundaryLeft;
% Right side (x = L)
U_right = fhBoundaryRight;

%%% Leapfrog vector and matrix for inner ndoes
% Leapfrog vector
% b = @(t) r^2.*[U_left(t), zeros(1, nx-2), U_right(t)];
b = @(t) r^2.*[U_left(t), zeros(1, nx-4), U_right(t)];
% Leapfrog matrix
% B = diag(2*(1-r^2)*ones(nx,1),0) + diag(r^2*ones(nx-1,1),1) + diag(r^2*ones(nx-1,1),-1);
% B = diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1);
B = sparse(diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1));

% Inhomogeneous function
h = @(t,x) -g.*ones(size(x, 1), size(x, 2));



%% Numeric intergration
% Very first state is the position given in U_startPos
U_hom(1,:) = U_startPos(x);
U_inh(1,:) = U_startPos(x);
% The second row of U contains the speed at this moment which we will
% interpolate
% U_hom(2,:) = 1/2.*transpose(B*transpose(U_hom(1,:))) + dt*U_startVel(x) + 1/2.*b(U_hom(1,:));
U_hom(2,2:end-1) = 1/2.*transpose(B*transpose(U_hom(1,2:end-1))) + dt*U_startVel(x(2:end-1)) + 1/2.*b(U_hom(1,2:end-1));
U_inh(2,2:end-1) = 1/2.*transpose(B*transpose(U_inh(1,2:end-1))) + dt*U_startVel(x(2:end-1)) + 1/2.*b(U_inh(1,2:end-1));

% Run the approxmiation
for iTime = 2:nt-1
%     U_hom(iTime+1,:) = transpose(B*transpose(U_hom(iTime,:))) - U_hom(iTime-1,:) + b(t(iTime));
    U_hom(iTime+1,1) = U_left(t(iTime));
    U_hom(iTime+1,2:end-1) = transpose(B*transpose(U_hom(iTime,2:end-1))) - U_hom(iTime-1,2:end-1) + b(t(iTime));
    U_hom(iTime+1,end) = U_right(t(iTime));
    
    U_inh(iTime+1,1) = U_left(t(iTime));
    U_inh(iTime+1,2:end-1) = transpose(B*transpose(U_inh(iTime,2:end-1))) - U_inh(iTime-1,2:end-1) + b(t(iTime)) + h(t(iTime),U_inh(iTime,2:end-1));
    U_inh(iTime+1,end) = U_right(t(iTime));
end


%% Assign output quantities
% First output is the wave equation
U = U_hom;

% Second output is information about the simulation i.e., the vectors t, x and
% the constants dt, dx
if nargout > 1
    Axes = struct();
    Axes.DimT = t;
    Axes.DimX = x;
    Axes.DeltaT = dt;
    Axes.DeltaX = dx;
end

% Third output is the inhomogeneous wave equation
if nargout > 2
    UInh = U_inh;
end


end