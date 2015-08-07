function [L, varargout] = cableShapeFor_Catenary(vEnd, AttachedMass, CableProperties)

nDiscretizationPoints = 10e3;

dGravityConstant = 9.81;

dAttachedMass = AttachedMass;

vEnd = vEnd(:);

% Get the cable properties struct
stCableProperties = CableProperties;
% And extract its fields
dCablePropYoungsModulus = stCableProperties.YoungsModulus;
dCablePropUnstrainedSection = stCableProperties.UnstrainedSection;
dCablePropDensity = stCableProperties.Density;
dCableForceMaximum = stCableProperties.ForceMaximum;
dCableForceMinimum = stCableProperties.ForceMinimum;


%% Initialize the parameters for the optimization function
% This is the state we will perform optimziation over which is
% [theta, L_0]
vInitialStateForOptimization = zeros(2, 1);

%%% Linear equality constraints Ax = b
% Linear equality constraints matrix A
% aLinearEqualityConstraints = zeros(2, 3);
aLinearEqualityConstraints = [];
% Linear equality constraints vector b
% Wrench = dGravityConstant.*dAttachedMass.*[0; -1];
% vLinearEqualityConstraints = zeros(2, 1) - Wrench;
% vLinearEqualityConstraints = zeros(2, 1);% - Wrench;
vLinearEqualityConstraints = [];


%%% Linear inequality constraints Ax <= b
% Linear inequality constraints matrix A
% aLinearInequalityConstraints = zeros(2, 3);
aLinearInequalityConstraints = [];
% Linear inequality constraints vector b
% vLinearInequalityConstraints = zeros(2, 1);
vLinearInequalityConstraints = [];

% nIndexForceX = 1;
% nIndexForceZ = 2;
% nIndexLength = 3;
nIndexAngle = 1;
nIndexLength = 2;

dInitialLength = cableShapeFor_Simple(vEnd);
vInitialStateForOptimization(nIndexLength) = dInitialLength;

dInitForceDistribution = dAttachedMass*dGravityConstant;
vInitialStateForOptimization(nIndexAngle) = atan2(vEnd(2), vEnd(1));

%%% Boundaries
% Lower boundaries: Forces are not bound (wrt linear boundaries) but the
% minimum cable length is set to 0
vLowerBoundaries = -Inf(2, 1);
vLowerBoundaries(nIndexLength) = 0;

% Upper boundaries: Totally unlimited
vUpperBoundaries = Inf(2, 1);

% Optimization target function with x = [Thetag_1, L_01] %% x = [F_x1, F_z1, L_01]
inOptimizationTargetFunction = @(x) norm(x(nIndexLength) - vInitialStateForOptimization(nIndexLength)) + norm(x(nIndexAngle) - vInitialStateForOptimization(nIndexAngle));



%% Run optimization
[xFinal, fval, exitflag, output] = fmincon(inOptimizationTargetFunction, vInitialStateForOptimization, ...
    aLinearInequalityConstraints, vLinearInequalityConstraints, ...
    aLinearEqualityConstraints, vLinearEqualityConstraints, ...
    vLowerBoundaries, vUpperBoundaries, ...
    @(vOptimizationVector) cableShapeFor_Catenary_nonlinearBoundaries(vOptimizationVector, vEnd, dCablePropYoungsModulus, dCablePropUnstrainedSection, dCablePropDensity, dGravityConstant, dCableForceMinimum, dCableForceMaximum, dInitForceDistribution));

% exitflag
% fval

% Extract the solutions from the final optimized vector
% Forces X
dCableForceX = dInitForceDistribution*cos(xFinal(1));
% Forces Z
dCableForceZ = dInitForceDistribution*sin(xFinal(1));
% Cable length
dCableLength = xFinal(nIndexLength);

L = dCableLength;

% First optional output argument is the cable shape
if nargout > 1
    aShape = zeros(2, nDiscretizationPoints);
    
    vLinspaceCableLength = linspace(0, dCableLength, nDiscretizationPoints);
    % X-Coordinate
    aShape(1,:) = dCableForceX.*vLinspaceCableLength./(dCablePropYoungsModulus*dCablePropUnstrainedSection) ...
        + abs(dCableForceX)./(dCablePropDensity.*dGravityConstant).*(asinh((dCableForceZ + dCablePropDensity.*dGravityConstant.*(vLinspaceCableLength - dCableLength))./dCableForceX) - asinh((dCableForceZ - dCablePropDensity.*dGravityConstant.*dCableLength)./dCableForceX));

    % Z-Coordinate
    aShape(2,:) = dCableForceZ./(dCablePropYoungsModulus.*dCablePropUnstrainedSection).*vLinspaceCableLength ...
        + dCablePropDensity.*dGravityConstant./(dCablePropYoungsModulus.*dCablePropUnstrainedSection).*(vLinspaceCableLength./2 - dCableLength).*vLinspaceCableLength ...
        + 1./(dCablePropDensity.*dGravityConstant)*(sqrt(dCableForceX.^2 + (dCableForceZ + dCablePropDensity.*dGravityConstant.*(vLinspaceCableLength - dCableLength)).^2) - sqrt(dCableForceX.^2 + (dCableForceZ - dCablePropDensity.*dGravityConstant.*dCableLength).^2));
    
    varargout{1} = aShape;
end

% Second optional output argument is the resulting cable force components
if nargout > 2
    varargout{2} = [dCableForceX; dCableForceZ];
end


end


function [c, ceq] = cableShapeFor_Catenary_nonlinearBoundaries(vOptimizationVector, aAnchorPositionsInC, dCablePropYoungsModulus, dCablePropUnstrainedCableSection, dCablePropDensity, dGravity, dForceMinimum, dForceMaximum, dInitForceDistribution)

%% Quickhand variables
% Number of wires
nNumberOfCables = size(aAnchorPositionsInC, 2);
% For forces F_x
vForcesX = [dInitForceDistribution*cos(vOptimizationVector(1))];
% For forces F_z
vForcesZ = [dInitForceDistribution*sin(vOptimizationVector(1))];
% Length L_0 components
vLength = vOptimizationVector(2);


%% Initialize the output variables
% Nonlinear inequality constraints are f_max and f_min
c = zeros(nNumberOfCables*2, 1);
% Nonlinear equality constraints are x_{end, i} and z_{end, i}
ceq = zeros(nNumberOfCables*2, 1);
% ceq = zeros(nNumberOfCables*3, 1);

iCable = 1;

%% Do the magic
% Set the equality constraints
% for iCable = 1:nNumberOfCables
    dOffset = (iCable-1)*2;
    
    %%% Equalities
    % Position x
    ceq(iCable + 0 + dOffset) = vForcesX(iCable)*vLength(iCable)/(dCablePropYoungsModulus*dCablePropUnstrainedCableSection) ...
        + abs(vForcesX(iCable))/(dCablePropDensity*dGravity)*(asinh(vForcesZ(iCable)/vForcesX(iCable)) - asinh((vForcesZ(iCable) - dCablePropDensity*dGravity*vLength(iCable))/vForcesX(iCable))) ...
        - aAnchorPositionsInC(1, iCable);
    % Position z
    ceq(iCable + 1 + dOffset) = vForcesZ(iCable)*vLength(iCable)/(dCablePropYoungsModulus*dCablePropUnstrainedCableSection) ...
        - dCablePropDensity*dGravity*vLength(iCable)^2/(2*dCablePropYoungsModulus*dCablePropUnstrainedCableSection) ...
        + 1/(dCablePropDensity*dGravity)*(sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - sqrt(vForcesX(iCable)^2 + (vForcesZ(iCable) - dCablePropDensity*dGravity*vLength(iCable))^2)) ...
        - aAnchorPositionsInC(2, iCable);
    
    % Amount of force on the cable must be equal to the amount of
    % gravitational force of the attached mass
%     ceq(iCable + 2 + dOffset) = dInitForceDistribution - vOptimizationVector(1);
    
%     %%% Inequalities
%     % Min force
%     c(iCable + 0 + dOffset) = dForceMinimum - sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2);
%     % Max force
%     c(iCable + 1 + dOffset) = sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - dForceMaximum;
% end

end
