function [f, varargout] = test_inverseKinematicsCatenary_Myself()
load(fullfile(pwd, '..', 'IPAnema3-2'));

dE = 200*10^9;
dA0 = 32.6/1000;
dRho = 350/1000;
dG = 9.81;
dFmin = 100;
dFmax = 3000;

vPose = [0,0,0, 1,0,0, 0,1,0, 0,0,1];
vPosition = reshape(vPose(1:3), 3, 1);
aRotation = reshape(vPose(4:12), 3, 3)';

% First, we need to get the angles of the connection line from a_i to b_i
vAngleOfRotationOfKc = zeros(size(cfg_gears_a, 2));

for iCable = 1:Robot.Meta.NumberOfWires
    vDirectionAi2Bi = ( vPosition + aRotation*Robot.Platform.Anchor.Position(:, iCable) ) - Robot.Pulley.Position(:, iCable);
    
    vAngleOfRotationOfKc(iCable) = atan2d(vDirectionAi2Bi(2), vDirectionAi2Bi(1));
end

%% Create conditions for optimization
% The vector we will be optimizing is x \in R^{1 \times 3*m} = \R^{1 \times 24}
% x = [F1x, F1z, L1, F2x, F2z, L2, ..., Fmx, Fmz, Lm];

% Set some handy indeces to quickly access Fix, Fiz, or Li
nIndexForcesX = 1:3:(3*Robot.Meta.NumberOfWires);
nIndexForcesZ = 2:3:(3*Robot.Meta.NumberOfWires);
nIndexLength = 3:3:(3*Robot.Meta.NumberOfWires);


%%% Initial conditions for guessing
% Initial length from straight line
[vInitLength, aCableVector, aCableUnitVector] = inverseKinematics(vPose, Robot.Pulley.Position, Robot.Platform.Anchor.Position);
% Initial force distribution
vInitForceDistribution = algoForceDistribution_AdvancedClosedForm([Robot.Environment.ForceFieldDirection.*Robot.Environment.GravitationalConstant; 0; 0; 0], getStructureMatrix(Robot.Platform.Anchor.Position, aCableVector), 100, 3000);

vInitState = zeros(3*Robot.Meta.NumberOfWires, 1);

aAnchorPositionsIn0 = zeros(3, Robot.Meta.NumberOfWires);


%%% Linear equality contraints Ax = B
aAeq = zeros(6, 3*Robot.Meta.NumberOfWires);
vBeq = zeros(6, 1);
vBeq(1:3,:) = -(Robot.Environment.GravitationalConstant*Robot.Environment.ForceFieldDirection*Robot.Platform.Mass);

for iCable = 1:Robot.Meta.NumberOfWires
    dOffset = (iCable - 1)*(3 -1);
    % Anchor positions in 0
    aAnchorPositionsIn0(:, iCable) = aRotation*Robot.Platform.Anchor.Position(:, iCable);
    
    % Forces
    aTransformCto0 = rotz(vAngleOfRotationOfKc(iCable));
    aAeq(1:3, nIndexForcesX(iCable)) = aTransformCto0(:, 1);
    aAeq(1:3, nIndexForcesZ(iCable)) = aTransformCto0(:, 3);
    
    % Torques
    vPlatformAnchorIn0 = aRotation*Robot.Platform.Anchor.Position(:, iCable);
    aTorqueOfCableIn0 = vec2skew(vPlatformAnchorIn0)*aTransformCto0;
    aAeq(4:6, nIndexForcesX(iCable)) = aTorqueOfCableIn0(:, 1);
    aAeq(4:6, nIndexForcesZ(iCable)) = aTorqueOfCableIn0(:, 3);
    
    % Initial state
    vForceInBi = transpose(aTransformCto0)*aCableUnitVector(:, iCable).*vInitForceDistribution(iCable);
    vInitState(iCable + 0 + dOffset) = vForceInBi(1);
    vInitState(iCable + 1 + dOffset) = vForceInBi(3);
    vInitState(iCable + 2 + dOffset) = vInitLength(iCable);
end

%%% Linear inequality constraints 
aA = [];
vB = [];


%%% Bounds
% Upper bounds (length doesn't matter but forces must be smaller than force
% maximum)
vBoundsUpper = Inf(3*Robot.Meta.NumberOfWires, 1);
% vBoundsUpper(nIndexForcesX) = 0;
% vBoundsUpper(nIndexForcesZ) = 0;
% Limit the cable length to the maximum of all available cable lengths for the
% given pose using pulley kinematics?
% vBoundsUpper(nIndexLength) = max(inverseKinematics(vPose, Robot.Pulley.Position, Robot.Platform.Anchor.Position, 'pulley', 'PulleyRadius', Robot.Pulley.Radius, 'PulleyRotation', Robot.Pulley.Rotation));

% Lower bounds (length must be greater than zero and the forces must be greater
% than force minimum)
vBoundsLower = -Inf(3*Robot.Meta.NumberOfWires, 1);
% vBoundsLower(nIndexForcesX) = 0;
% vBoundsLower(nIndexForcesZ) = 0;
% Minimum length for the cables must obviously be zero ;)
vBoundsLower(nIndexLength) = 0;


%%% Non-linear inequality constraints


%% Run the optimization

inOptimizationFunction = @(x) norm(vInitLength(:) - reshape(x(nIndexLength), Robot.Meta.NumberOfWires, 1)) + norm(sqrt(x(nIndexForcesX).^2 + x(nIndexForcesZ).^2) - vInitForceDistribution);


[f, fval, exitflag, output] = fmincon(inOptimizationFunction, vInitState, aA, vB, aAeq, vBeq, vBoundsLower, vBoundsUpper, @(x) nonlcon(x, aAnchorPositionsIn0, dE, dA0, dRho, dG, dFmin, dFmax));

if nargout >= 1
    varargout{1} = fval;
end
if nargout >= 2
    varargout{2} = exitflag;
end
if nargout >= 3
    varargout{3} = output;
end

end
