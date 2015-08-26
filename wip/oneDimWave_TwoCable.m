function [U, Axes] = oneDimWave_TwoCable(TOrDeltaT, DeltaX, StartPosition, StartVelocity, BoundaryLeft, BoundaryRight)

%% Argument defaults
dT = 10;
dDeltaT = 1e-3;
dDeltaX = 1e-2;
fhStartPositionLeft = @(x) x.*0;
fhStartPositionRight = @(x) x.*0;
fhStartVelocityLeft = @(x) x.*0;
fhStartVelocityRight = @(x) x.*0;
fhBoundaryLeft = @(t) 0;
fhBoundaryRight = @(t) 0;



%% Assertion
assert(nargin < 1 || isempty(TOrDeltaT) || isa(TOrDeltaT, 'double') && all(0 < TOrDeltaT) && all(TOrDeltaT < Inf) );
assert(nargin < 2 || isempty(DeltaX) || isa(DeltaX, 'double') && isscalar(DeltaX) && 0 < DeltaX && DeltaX < 1 );
assert(nargin < 3 || isempty(StartPosition) || isa(StartPosition, 'function_handle') || ( iscell(StartPosition) && arrayfun(@(el) isa(el, 'function_handle'), StartPosition ) ) );
assert(nargin < 4 || isempty(StartVelocity) || isa(StartVelocity, 'function_handle') || ( iscell(StartVelocity) && arrayfun(@(el) isa(el, 'function_handle'), StartVelocity ) ) );
assert(nargin < 5 || isempty(BoundaryLeft) || isa(BoundaryLeft, 'function_handle') || ( iscell(BoundaryLeft) && arrayfun(@(el) isa(el, 'function_handle'), BoundaryLeft ) ) );
assert(nargin < 6 || isempty(BoundaryRight) || isa(BoundaryRight, 'function_handle') || ( iscell(BoundaryRight) && arrayfun(@(el) isa(el, 'function_handle'), BoundaryRight ) ) );



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
    if isa(StartPosition, 'function_handle')
        fhStartPositionLeft = StartPosition;
        fhStartPositionRight = StartPosition;
    else
        fhStartPositionLeft = StartPosition{1};
        fhStartPositionRight = StartPosition{2};
    end
end

if nargin >= 4 && ~isempty(StartVelocity)
    if isa(StartVelocity, 'function_handle')
        fhStartVelocityLeft = StartVelocity;
        fhStartVelocityRight = StartVelocity;
    else
        fhStartVelocityLeft = StartVelocity{1};
        fhStartVelocityRight = StartVelocity{2};
    end
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

% Tension on the left string
T_left = 1;
% Tension on the right string
T_right = 1;
% Mass of the lumped object
LumpedMass = 1;
% Gravity constant
dGravity = 1;

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

% Check stability criterion for simulation
if r > 1
    error('Not running numerically unstable simulation');
end


%% Initialize the wave equation
% Holds the homogenous solution
U_homLeft = zeros(nt, nx);
U_homRight = zeros(nt, nx);
U_mass = zeros(nt, 1);

%%% Initial conditions
% Initial deflection
U_startPosLeft = fhStartPositionLeft;
U_startPosRight = fhStartPositionRight;
% Initial velocity
U_startVelLeft = fhStartVelocityLeft;
U_startVelRight = fhStartVelocityRight;

%%% Boundary conditions
% Left side (x = 0)
U_left = fhBoundaryLeft;
% Right side (x = L)
U_right = fhBoundaryRight;

%%% Leapfrog vector and matrix for inner ndoes
% Leapfrog vector
% b = @(t) r^2.*[U_left(t), zeros(1, nx-2), U_right(t)];
bLeft = @(t) r^2.*[U_left(t), zeros(1, nx-4), U_right(t)];
bRight = @(t) r^2.*[U_left(t), zeros(1, nx-4), U_right(t)];
% Leapfrog matrix
% B = diag(2*(1-r^2)*ones(nx,1),0) + diag(r^2*ones(nx-1,1),1) + diag(r^2*ones(nx-1,1),-1);
% B = diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1);
BLeft = sparse(diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1));
BRight = sparse(diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-1-2,1),1) + diag(r^2*ones(nx-1-2,1),-1));



%% Numeric intergration
% Very first state is the position given in U_startPos
U_homLeft(1,:) = U_startPosLeft(x);
U_homRight(1,:) = U_startPosRight(x);
% The second row of U contains the speed at this moment which we will
% interpolate
% U_hom(2,:) = 1/2.*transpose(B*transpose(U_hom(1,:))) + dt*U_startVel(x) + 1/2.*b(U_hom(1,:));
U_homLeft(2,2:end-1) = 1/2.*transpose(BLeft*transpose(U_homLeft(1,2:end-1))) + dt*U_startVelLeft(x(2:end-1)) + 1/2.*bLeft(U_homLeft(1,2:end-1));
U_homRight(2,2:end-1) = 1/2.*transpose(BRight*transpose(U_homRight(1,2:end-1))) + dt*U_startVelRight(x(2:end-1)) + 1/2.*bRight(U_homRight(1,2:end-1));
U_mass(2) = dt/(dt-1)*(1+2)*U_mass(1);
U_homLeft(2,end) = U_mass(2);
U_homRight(2,end) = U_mass(2);

% Run the approxmiation
for iTime = 2:nt-1
    % Simulate the mass
    U_mass(iTime+1) = 1/(LumpedMass)*(T_left*sin(tan(U_homLeft(iTime,end-1)/dx)) + T_right*sin(tan((U_homRight(iTime,1)/dx))) - dGravity)*(dt^2) ...
                    + (U_mass(iTime) + U_mass(iTime-1));
    % Left boundary condition of the left string
    U_homLeft(iTime+1,1) = U_left(t(iTime));
    % Simulate the movement of the interior nodes of the left string
    U_homLeft(iTime+1,2:end-1) = transpose(BLeft*transpose(U_homLeft(iTime,2:end-1))) - U_homLeft(iTime-1,2:end-1) + bLeft(t(iTime));
    % The position of the left string at x = L is the position of the mass
    U_homLeft(iTime,end) = U_mass(iTime);
    U_homLeft(iTime+1,end) = U_mass(iTime+1);
    % The position of the right string at x = 0 is the position of the mass as
    % we calculated above
    U_homRight(iTime,1) = U_mass(iTime);
    U_homRight(iTime+1,1) = U_mass(iTime+1);
    % Simulate the movement of the interior nodes of the right string
    U_homRight(iTime+1,2:end-1) = transpose(BRight*transpose(U_homRight(iTime,2:end-1))) - U_homRight(iTime-1,2:end-1) + bRight(t(iTime));
    % Boundary condition 
    U_homRight(iTime+1,end) = U_right(t(iTime));
end


%% Assign output quantities
% First output is the wave equation
U = zeros(nt, nx, 2);
U(:,:,1) = U_homLeft;
U(:,:,2) = U_homRight;

% Second output is information about the simulation i.e., the vectors t, x and
% the constants dt, dx
if nargout >= 2
    Axes = struct();
    Axes.DimT = t;
    Axes.DimX = x;
    Axes.DeltaT = dt;
    Axes.DeltaX = dx;
end


end