function [L, varargout] = cableShapeFor_FiniteSegment(vEnd, AttachedMass, NodeCount, CableProperties)

nDiscretizationPoints = 10e3;

dGravityConstant = 9.81;

dAttachedMass = AttachedMass;

vEnd = vEnd(:);

nNodeCount = NodeCount;

stCableProperties = CableProperties;
% dCablePropUnstrainedSection = stCableProperties.UnstrainedSection;
% dCablePropDensity = stCableProperties.Density;


%% Initialize the parameters for the optimization function
nIndexLength = 1;
nIndexAngles = 2;
nIndexForces = 3;

% This is the state we will perform optimziation over which is
% [L, theta_P];
%%% [L, theta_1, F_1, theta_2, F_2, ..., theta_q, F_q, theta_p, F_p] q is the count of nodes
vInitialStateForOptimization = zeros(2, 1);

%%% Linear equality constraints Ax = b
% Linear equality constraints matrix A
aLinearEqualityConstraints = [];
% aLinearEqualityConstraints = zeros(2, 1 + 2*(nNodeCount+1));
% aLinearEqualityConstraints(1,[nIndexAngles(end-1), nIndexAngles(end)]) = [1, -1];
% aLinearEqualityConstraints(2,[nIndexForces(end-1), nIndexForces(end)]) = [1, -1];
% Linear equality constraints vector b
vLinearEqualityConstraints = [];
% vLinearEqualityConstraints = [0; ...
%                                 0];


%%% Linear inequality constraints Ax <= b
% Linear inequality constraints matrix A
aLinearInequalityConstraints = [];
% Linear inequality constraints vector b
vLinearInequalityConstraints = [];
% Initial cable length is just the standard cable length
dInitialLength = cableShapeFor_Standard(vEnd);
vInitialStateForOptimization(nIndexLength) = dInitialLength;

% Initial angle of all nodes is just the angle between start and end
dInitAngle = atan2(vEnd(2), vEnd(1));
vInitialStateForOptimization(nIndexAngles) = dInitAngle;

% Initial force distribution among nodes is "same amount of force on all nodes"
% (we could extend that to include the angle and add the following node weights
% to each previous node if algorithm isn't sufficiently good)
% dInitForce = dAttachedMass;
% vInitialStateForOptimization(end) = dInitForce;
% vInitialStateForOptimization(nIndexForces) = dInitForce;

%%% Boundaries
% Lower boundaries: Forces are not bound (wrt linear boundaries) but the
% minimum cable length is set to 0, minimum cable force set to 0, too
vLowerBoundaries = -Inf(numel(vInitialStateForOptimization), 1);
% vLowerBoundaries(nIndexLength) = 0;
% vLowerBoundaries(nIndexForces) = 0;

% Upper boundaries: Totally unlimited
vUpperBoundaries = Inf(numel(vInitialStateForOptimization), 1);

% Optimization target function with x = [Thetag_1, L_01] %% x = [F_x1, F_z1, L_01]
% inOptimizationTargetFunction = @(x) norm(x(nIndexLength) - vInitialStateForOptimization(nIndexLength)) + norm(x(nIndexAngles) - vInitialStateForOptimization(nIndexAngles));
inOptimizationTargetFunction = @(x) norm(x(nIndexLength) - vInitialStateForOptimization(nIndexLength));
% inOptimizationTargetFunction = @(x) norm(x(nIndexLength));



%% Run optimization
[xFinal, fval, exitflag, output] = fmincon(inOptimizationTargetFunction, vInitialStateForOptimization, ...
    aLinearInequalityConstraints, vLinearInequalityConstraints, ...
    aLinearEqualityConstraints, vLinearEqualityConstraints, ...
    vLowerBoundaries, vUpperBoundaries, ...
    @(vOptimizationVector) cableShapeFor_FiniteSegment_nonlinearBoundaries(vOptimizationVector, vEnd, dAttachedMass, nNodeCount, dGravityConstant, stCableProperties, nIndexLength, nIndexAngles));

% exitflag
% fval

% Total cable length
dCableLength = xFinal(nIndexLength);
% Angles of all nodes
vNodeAngles = xFinal(nIndexAngles);
% Amount of force on each node
% vNodeForces = xFinal(nIndexForces);
vNodeForces = [];

% Output quantity
L = dCableLength;

% First optional output argument is the cable shape
if nargout > 1
    aShape = zeros(2, nDiscretizationPoints);
    
%     vLinspaceCableLength = linspace(0, dCableLength, nDiscretizationPoints);
%     % X-Coordinate
%     aShape(1,:) = dCableForceX.*vLinspaceCableLength./(dCablePropYoungsModulus*dCablePropUnstrainedSection) ...
%         + abs(dCableForceX)./(dCablePropDensity.*dGravityConstant).*(asinh((dCableForceZ + dCablePropDensity.*dGravityConstant.*(vLinspaceCableLength - dCableLength))./dCableForceX) - asinh((dCableForceZ - dCablePropDensity.*dGravityConstant.*dCableLength)./dCableForceX));
% 
%     % Z-Coordinate
%     aShape(2,:) = dCableForceZ./(dCablePropYoungsModulus.*dCablePropUnstrainedSection).*vLinspaceCableLength ...
%         + dCablePropDensity.*dGravityConstant./(dCablePropYoungsModulus.*dCablePropUnstrainedSection).*(vLinspaceCableLength./2 - dCableLength).*vLinspaceCableLength ...
%         + 1./(dCablePropDensity.*dGravityConstant)*(sqrt(dCableForceX.^2 + (dCableForceZ + dCablePropDensity.*dGravityConstant.*(vLinspaceCableLength - dCableLength)).^2) - sqrt(dCableForceX.^2 + (dCableForceZ - dCablePropDensity.*dGravityConstant.*dCableLength).^2));
    
    varargout{1} = aShape;
end

% Second optional output argument is the resulting cable force components
if nargout > 2
    varargout{2} = vNodeAngles;
end

% Third optional output argument may be the vector of nominal forces on each
% node
if nargout > 3
    varargout{3} = vNodeForces;
end


end


function [c, ceq] = cableShapeFor_FiniteSegment_nonlinearBoundaries(vOptimizationVector, vEnd, dAttachedMass, nNodeCount, dGravityConstant, stCableProperties, nIndexLength, nIndexAngles)

%% Quickhand variables
% Number of wires
% nNumberOfCables = size(vEnd, 2);
% Length L_0 components
dLengthTotal = vOptimizationVector(nIndexLength);
dLengthBetweenNodes = dLengthTotal/(nNodeCount+1);
% Angles of forces on each node
dLastNodeForceAngle = vOptimizationVector(nIndexAngles);
% Amount of force on each node
% vNodeForceAmount = vOptimizationVector(nIndexForces);
% Extract cable properties from the struct
dCablePropDensity = stCableProperties.Density;
dCablePropUnstrainedSection = stCableProperties.UnstrainedSection;

% The weight of each node is a function of the length (and density, unstrainde
% cable section, and number of nodes) thus we have to calculate that every time
% anew
dWeightOfNode = dCablePropDensity*dCablePropUnstrainedSection*dLengthTotal/nNodeCount;
vNodeLoadGravitation = dWeightOfNode.*dGravityConstant.*[0; -1];


%% Initialize the output variables
% Nonlinear inequality constraints are f_max and f_min
% c = zeros(nNumberOfCables*2, 1);
c = [];


% Nonlinear equality constraints are x_{end, i} and z_{end, i}
ceq = [];
% ceq = zeros(nNumberOfCables*2, 1);
% ceq = zeros(nNumberOfCables*3, 1);



%% Calculate the angle at each node
vNodeForceAngles = zeros(nNodeCount+1, 1);
vNodeForceAngles(end) = dLastNodeForceAngle;
aNodeForceDirections = zeros(2, nNodeCount+1);
aNodeForceDirections(:,end) = dAttachedMass.*[cos(dLastNodeForceAngle); ...
                                                sin(dLastNodeForceAngle)];

% Calculate the angles that the connection between node i and j forms with the
% x-axis
for iNode = nNodeCount:-1:1
    vNodeForce = aNodeForceDirections(:,iNode+1) + vNodeLoadGravitation;
    vNodeForceAngles(iNode) = atan2(vNodeForce(2), vNodeForce(1));
end

%%% Necessary nonlinear equality constraints are
% The resulting final x-coordinate of the cable must match the given bi(x)
ceq(1) = dLengthBetweenNodes*sum(cos(vNodeForceAngles)) - vEnd(1);
% The resulting final z-coordinate of the cable must match the given bi(z)
ceq(2) = dLengthBetweenNodes*sum(sin(vNodeForceAngles)) - vEnd(2);



% % Load on all nodes
% aNodeLoads = zeros(2, nNodeCount+1);
% % Load on last node
% aNodeLoads(:,end) = vNodeForceAmount(end).*[cos(vNodeForceAngles(end)); sin(vNodeForceAngles(end))];

% dOffset = 1;
% % Make sure we have a force equilibrium at each node
% for iNode = nNodeCount:-1:1
%     dOffset = dOffset + 2;
%     
%     % Calculate the assumed node load by the given parameters
%     aNodeLoads(:,iNode) = aNodeLoads(:,iNode+1) + vNodeLoadGravitation;
%     
%     % The assumed node load's angle must match the one just being iterated over
%     ceq(dOffset + 0) = atan2(aNodeLoads(2,iNode), aNodeLoads(1,iNode)) - vNodeForceAngles(iNode);
%     ceq(dOffset + 1) = norm(aNodeLoads(:,iNode)) - vNodeForceAmount(iNode);
%     
% %     iNodeIndex = iNode;
% %     dOffset = dOffset + 2;
% %     % Calculate the total vector force on the i-th node
% %     vLoadOnNode = aNodeLoads(:,iNodeIndex) + vNodeLoadGravitation;
% %     aNodeLoads(:, iNodeIndex) = vLoadOnNode;
% %     vNodeResultingForce = vLoadOnNode - vNodeForceAmount(iNode).*[cos(vNodeForceAngles(iNode)); sin(vNodeForceAngles(iNode))];
% %     ceq(dOffset) = vNodeResultingForce(1);
% %     ceq(dOffset+1) = vNodeResultingForce(2);
% end


end
