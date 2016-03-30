function [Length, CableUnitVector, PulleyAngle, Benchmark] = algoInverseKinematics_Catenary(Pose, PulleyPositions, CableAttachments, Wrench, CableForceLimits, CableProperties, GravityConstant, SolverOptions)%#codegen
% ALGOINVERSEKINEMATICS_CATENARY - Perform inverse kinematics for the given
%   pose of the virtual robot using catenary lines
%   
%   Inverse kinematics means to determine the values for the joint
%   variables (in this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration
%   (note that calculations will be done as if we were looking at a 3D/6DOF
%   cable robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, both the simple kinematic
%   loop can be used as well as the advanced pulley kinematics (considering
%   pulley radius and rotatability).
% 
%   LENGTH = ALGOINVERSEKINEMATICS_CATENARY(POSE, PULLEYPOSITIONS,
%   CABLEATTACHMENTS, WRENCH, CABLEFORCELIMITS, CABLEPROPERTIES,
%   GRAVITYCONSTANT) performs catenary based inverse kinematics with the cables
%   running from PULLEYPOSITIONS to CABLEATTACHMENTS for the given pose
% 
%   [LENGTH, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_CATENARY(...) also
%   provides the unit vectors for each cable which might come in handy at times
%   
%   [LENGTH, CABLEUNITVECTORS, PULLEYANGLES] =
%   ALGOINVERSEKINEMATICS_CATENARY(...) furthermore returns the angle of
%   rotation of the pulley about its z-axos so that it's pointing towards the
%   platform
%   
%   [LENGTH, CABLEUNITVECTORS, PULLEYANGLES, BENCHMARK] =
%   ALGOINVERSEKINEMATICS_CATENARY(...) will return information on the results
%   of the fmincon optimization
%
%   LENGTH = ALGOINVERSEKINEMATICS_CATENARY(..., SOLVEROPTIONS) allows to
%   override some pre-adjusted solver options. See input argument SOLVEROPTIONS
%   further down for specific details
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleys i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the platforms 
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of pulleys in PULLEYPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
%
%   SOLVEROPTIONS: A struct of optimization options to set for the fmincon
%   solver. All values may be overriden and this function makes use of the
%   following pre-overriden options
%   
%       Algorithm:  'interior-point'
%       Display:    'off'
%       TolCon:     1e-10
%       TolFun:     1e-6
%       TolX:       1e-8
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using either catenary kinematics
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its corrected pulley point as 3xM matrix
%   
%   PULLEYANGLE: Matrix of gamma and beta angles of rotation and
%   wrapping angle of pulley and cable on pulley respectively, given as 2xM
%   matrix
%
%   BENCHMARK: A struct with fields x, fval, exitflag, output, lambda, grad,
%   hessian as returned by the call to fmincon
% 



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-30
% Changelog:
%   2016-03-30
%       * Add info to help about values fof default solver options TolCon and
%       TolFun
%       * Change solver option 'TolX' to 1e-8
%       * Add a few more comments to code
%   2016-03-29
%       * Code cleanup
%   2016-03-04:
%       * Fix wrong transformation matrix from optimization vector to local
%       cable vector
%       * Remove call to 'getStructureMatrix' and replace with 'structureMatrix'
%   2016-02-19
%       * Move the optimization cost functional into an inline function to
%       prepare for it being an optional input parameter
%   2015-08-31
%       * Remove code for shape generation and put into a separate function
%       called algoCableShape_Catenary
%   2015-08-05
%       * Add optional input argument SOLVEROPTIONS
%   2015-07-15
%       * Update documentation
%   2015-06-24
%       * Add return value CABLESHAPE
%   2015-06-22
%       * Initial release



%% Create default arguments
if nargin < 7 || isempty(GravityConstant)
    GravityConstant = 9.81;
end
if nargin < 8 || ~isstruct(SolverOptions)
    SolverOptions = struct();
end



%% Initialize variables
% To unify variable names
aCableAttachments = CableAttachments;
aPulleyPositions = PulleyPositions;
% Get the number of wires
nNumberOfCables = size(aPulleyPositions, 2);
% Holds the actual cable vector
% aCableVector = zeros(3, nNumberOfCables);
% Holds the normalized cable vector
aCableVectorUnit = zeros(3, nNumberOfCables);
% Holds the cable lengths
% vCableLength = zeros(nNumberOfCables, 1);
% Extract the position from the pose
vPlatformPosition = reshape(Pose(1:3), 3, 1);
% Extract rotatin from the pose
aPlatformRotation = rotationRowToMatrix(Pose(4:12));
% Get the cable properties struct
stCableProperties = CableProperties;
dCablePropDensity = stCableProperties.Density;
% Get the gravity constant (7th argument) to the given value
dGravityConstant = GravityConstant;
% Custom solver options may be provided as the 8th argument
stSolverOptionsGiven = SolverOptions;
% Degrees of freedom of the mobile platform
nDegreeOfFreedom = 6;



%% Initialize some local variables
% To quickly access the x coordinates of forces in the cable frame in the
% optimization vector
nIndexForcesX = 1:3:(3*nNumberOfCables);
% To quickly access the z coordinates of forces in the cable frame in the
% optimization vector
nIndexForcesZ = 2:3:(3*nNumberOfCables);
% To quickly access the cable lenghts in the optimization vector
nIndexLength = 3:3:(3*nNumberOfCables);
% Anchor positions in cable frame C are needed for the nonlinear equality
% constraints of the optimizer
aAnchorPositionsInC = zeros(3, nNumberOfCables);
% Angles of the rotation of each pulley
vPulleyAngles = zeros(1, nNumberOfCables);
% Transformation to get the proper values from the optimization variable x (we
% need only F_x and F_z) to be used in the linear equality and ineqaulity
% constraints
aSelectForcesFromOptimVectorAndTransformTo3D = [-1,0,0; 0,-1,0; 0,0,0];



%% Initialize the parameters for the optimization function
% This is the state we will perform optimziation over which is
% [F_x1 F_z1 L_01, F_x2 F_z2 L_02, ..., F_xm F_zm L_0z]
vInitialStateForOptimization = zeros(3*nNumberOfCables, 1);

%%% Linear equality constraints Ax = b
% Linear equality constraints matrix A
aLinearEqualityConstraints = zeros(nDegreeOfFreedom, 3*nNumberOfCables);
% Linear equality constraints vector b
vLinearEqualityConstraints = zeros(nDegreeOfFreedom, 1) - Wrench;

%%% Linear inequality constraints Ax <= b
% Linear inequality constraints matrix A
aLinearInequalityConstraints = [];
% Linear inequality constraints vector b
vLinearInequalityConstraints = [];

% To populate the initial cable lengths and forces, we will use the straight
% line to get initial values
[vInitialLength, aInitCableUnitVector] = inverseKinematics(Pose, aPulleyPositions, aCableAttachments);
vInitialStateForOptimization(nIndexLength) = vInitialLength;

% Initial guessing of the force distribution is necessary, too
vInitForceDistribution = algoForceDistribution_AdvancedClosedForm(Wrench, structureMatrix('3R3T', aCableAttachments, aInitCableUnitVector, aPlatformRotation), min(CableForceLimits), max(CableForceLimits));

%%% Boundaries
% Lower boundaries: Forces are not bound but the minimum cable length is set to
% 0
vLowerBoundaries = -Inf(3*nNumberOfCables, 1);
vLowerBoundaries(nIndexLength) = 0;

% Upper boundaries: Totally unlimited
vUpperBoundaries = Inf(3*nNumberOfCables, 1);

% Optimization target function
inOptimizationTargetFunction = @in_aIK_C_optimizationCostFunctional;



%% Do the magic
% Loop over every pulley and calculate the corrected pulley position i.e.,
% a_{i, corr}
for iCable = 1:nNumberOfCables
    dOffsetColumn = (iCable - 1)*3;
    
    % Get the line from Ai to Bi to determine its rotation about the z-axis
    % regarding K0's z-axis
    vA2B_in_0 = ( vPlatformPosition + aPlatformRotation*aCableAttachments(:,iCable) ) - aPulleyPositions(:,iCable);
    
    % Angle of rotation of the frame C about z_0 in degree
    dRotationAngleAbout_kCz_Degree = atan2d(vA2B_in_0(2), vA2B_in_0(1));
    vPulleyAngles(1,iCable) = dRotationAngleAbout_kCz_Degree;
    
    % Rotation matrix about K_C
    aRotation_kC2k0 = rotz(dRotationAngleAbout_kCz_Degree);
    
    % Anchor positions in C
    aAnchorPositionsInC(:,iCable) = transpose(aRotation_kC2k0)*(vPlatformPosition + aPlatformRotation*aCableAttachments(:,iCable) - aPulleyPositions(:,iCable));
    
    % Forces
    aLinearEqualityConstraints(1:3,(1:3) + dOffsetColumn) = aRotation_kC2k0*aSelectForcesFromOptimVectorAndTransformTo3D;
    
    % Torques are b_i(in 0) \times R_z(gamma) * Selector-from-x * x
    aLinearEqualityConstraints(4:6,(1:3) + dOffsetColumn) = vec2skew(aPlatformRotation*aCableAttachments(:,iCable))*aRotation_kC2k0*aSelectForcesFromOptimVectorAndTransformTo3D;
    
    % From the initial guess, get the forces of the cables on the anchor points
    % in the cable local frame
    vForceOfBiInC = transpose(aRotation_kC2k0)*(-aInitCableUnitVector(:,iCable)).*vInitForceDistribution(iCable);
    vInitialStateForOptimization(nIndexForcesX(iCable)) = vForceOfBiInC(1);
    vInitialStateForOptimization(nIndexForcesZ(iCable)) = vForceOfBiInC(3);
end



%% Run optimization
% Set our default optimization options
opSolverOptions = optimoptions('fmincon');
% trust-region-reflective does not work (read the docs)
opSolverOptions.Display = 'off';
opSolverOptions.TolCon = 1e-10;
opSolverOptions.TolFun = 1e-6;
opSolverOptions.TolX = 1e-8;

% And parse custom solver options
if ~isempty(stSolverOptionsGiven)
    % Get the fields of the struct provided
    ceFields = fieldnames(stSolverOptionsGiven);
    % And assign each given value to the solver options
    for iField = 1:numel(ceFields)
        opSolverOptions.(ceFields{iField}) = stSolverOptionsGiven.(ceFields{iField});
    end
end

% Perform the actual optimization
[xFinal, fval, exitflag, output, lambda, grad, hessian] = fmincon(inOptimizationTargetFunction, ... % Optimization function
    vInitialStateForOptimization, ... % Initial state to start optimization at
    aLinearInequalityConstraints, vLinearInequalityConstraints, ... % Linear inequality constraints
    aLinearEqualityConstraints, vLinearEqualityConstraints, ... % Linear equality constraints
    vLowerBoundaries, vUpperBoundaries, ... % Lower and upper boundaries
    @(vOptimizationVector) aIK_C_nonlinearBoundaries(vOptimizationVector, aAnchorPositionsInC, dCablePropDensity, dGravityConstant, min(CableForceLimits), max(CableForceLimits), nIndexForcesX, nIndexForcesZ, nIndexLength), ... % Nonlinear constraints function
    opSolverOptions ... % Solver options
);

% Make it a column vector
xFinal = xFinal(:);



%% Output parsing
%%% Extract the solutions from the final optimized vector
% Forces X
vCableForcesX = xFinal(nIndexForcesX);
% Forces Z
vCableForcesZ = xFinal(nIndexForcesZ);
% Cable length
vCableLength = xFinal(nIndexLength);

% And assign the frist output quantity
Length = vCableLength;

%%% Further outputs as requested
% Second output is the matrix of normalized cable vectors
if nargout > 1
    % To get the cable force unit vectors we will have to take the forces of the
    % cables at b_i and transform them from frame C to frame 0
    for iCable = 1:nNumberOfCables
        % Get the rotation matrix from C to 0
        aRotation_kC2k0 = rotz(vPulleyAngles(1,iCable));
        
        % Get the force vector in C
        vForceVector_in_C = [vCableForcesX(iCable), 0, vCableForcesZ(iCable)]';
        
        % Transform force vector in K_0. Watch out, the cable forces are the
        % ones that are acting on the platform i.e., pointing outwards from the
        % platform. That's why we are reversing these vectors here with the -1
        vForceVector_in_0 = -1*aRotation_kC2k0*vForceVector_in_C;
        
        % And calculate the force vector from the components of the
        % resulted cable force in K_0
        aCableVectorUnit(:,iCable) = vForceVector_in_0./norm(vForceVector_in_0);
    end
    
    CableUnitVector = aCableVectorUnit;
end

% Third output is the angle of rotation of the cable local frame relative to the
% world frame
if nargout > 2
    PulleyAngle = vPulleyAngles;
end

% Very last output argument is information on the algorithm (basically, all the
% information acquirable by fmincon
if nargout > 3
    stBenchmark = struct();
    stBenchmark.x = xFinal;
    stBenchmark.fval = fval;
    stBenchmark.exitflag = exitflag;
    stBenchmark.output = output;
    stBenchmark.lambda = lambda;
    stBenchmark.grad = grad;
    stBenchmark.hessian = hessian;
    
    Benchmark = orderfields(stBenchmark);
end


end



function value = in_aIK_C_optimizationCostFunctional(vOptimizationVector)%#codegen
% Value of the evaluated cost functional is the norm of the vector
value = norm(vOptimizationVector);


end



function [c, ceq] = aIK_C_nonlinearBoundaries(vOptimizationVector, aAnchorPositionsInC, dCablePropDensity, dGravity, dForceMinimum, dForceMaximum, nIndexForcesX, nIndexForcesZ, nIndexLength)%#codegen

%% Quickhand variables
% Number of wires
nNumberOfCables = size(aAnchorPositionsInC, 2);
% For forces F_x
vForcesX = vOptimizationVector(nIndexForcesX);
% For forces F_z
vForcesZ = vOptimizationVector(nIndexForcesZ);
% Length L_0 components
vLength = vOptimizationVector(nIndexLength);



%% Initialize the output variables
% Nonlinear inequality constraints are f_max and f_min
c = zeros(nNumberOfCables*2, 1);
% Nonlinear equality constraints are x_{end, i} and z_{end, i}
ceq = zeros(nNumberOfCables*2, 1);



%% Do the magic
% Set the equality constraints
for iCable = 1:nNumberOfCables
    dOffset = (iCable-1)*2;
    
    %%% Equalities
    % Position x
    ceq(iCable + 0 + dOffset) = abs(vForcesX(iCable))/(dCablePropDensity*dGravity)*(asinh(vForcesZ(iCable)/vForcesX(iCable)) - asinh((vForcesZ(iCable) - dCablePropDensity*dGravity*vLength(iCable))/vForcesX(iCable))) ...
        - aAnchorPositionsInC(1, iCable);
    % Position z
    ceq(iCable + 1 + dOffset) = 1/(dCablePropDensity*dGravity)*(sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - sqrt(vForcesX(iCable)^2 + (vForcesZ(iCable) - dCablePropDensity*dGravity*vLength(iCable))^2)) ...
        - aAnchorPositionsInC(3, iCable);
    
    %%% Inequalities
    % Min force
    c(iCable + 0 + dOffset) = dForceMinimum - sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2);
    % Max force
    c(iCable + 1 + dOffset) = sqrt(vForcesX(iCable)^2 + vForcesZ(iCable)^2) - dForceMaximum;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
