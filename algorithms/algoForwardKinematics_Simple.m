function [Pose, varargout] = algoForwardKinematics_Simple(CableLength, PulleyPosition, CableAttachment, SolverOptions)
% ALGOFORWARDKINEMATICS_SIMPLE estimates the robot pose with standard
%   pulley kinematics
% 
%   POSE = ALGOFORWARDKINEMATICS_SIMPLE(CABLELENGTH, PULLEYPOSITION,
%   CABLEATTACHMENT) estimates the pose given the cable lengths for the robot
%   defined defined by the given pulley positions and cable attachment points
%   
%   Inputs:
%   
%   CABLELENGTH: Vector of 1xM cable lengths as given by measurement of the
%   inverse kinematics.
% 
%   PULLEYPOSITION: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleyvs i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENT (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENT: Matrix of cable attachment points w.r.t. the platforms 
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENT must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of pulleys in PULLEYPOSITION (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
%
%   SOLVEROPTIONS: A struct of optimization options to set for the lsqnonlin
%   solver. All values may be overriden and this function makes use of the
%   following pre-overriden options
%   
%       Algorithm:  'levenberg-marquardt'
%       Display:    'off'
%       TolX:       1e-12
% 
%   Outputs:
% 
%   POSE: Estimated pose given as 1x12 vector with the interpretation of pose =
%   [x_e, y_e, z_e, R11_e, R12_e, R13_e, R21_e, R22_e, R23_e, R31_e, R32_e, R33_e]
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-08-05
% Changelog:
%   2015-08-05
%       * Initial release



%% Initialize variables
% Get the provided cable length
vCableLength = reshape(CableLength, 1, numel(CableLength));
% Get the provided pulley positions
aPulleyPosition = PulleyPosition;
% Get the provided cable attachment points on the platform
aCableAttachment = CableAttachment;
% Final guessed pose x_guess = [x_g, y_g, z_g, a_g, b_g, c_g]
vPoseEstimate = zeros(1, 6);
% Default additional solver options
stSolverOptionsGiven = struct();
% First optional input argument may be solver options
if nargin >= 4
    stSolverOptionsGiven = SolverOptions;
end

% Estimate the initial pose
vInitialStateForOptimization = algoForwardKinematics_PoseEstimate_Simple(vCableLength, aPulleyPosition, aCableAttachment);



%% Perform optimization of estimation
% Initialize solver options
opSolverOptions = optimoptions('lsqnonlin');
opSolverOptions.Algorithm = 'levenberg-marquardt';
opSolverOptions.Display = 'off';
opSolverOptions.TolX = 1e-12;

% Given any user-defined solver options? Process them now
if ~isempty(stSolverOptionsGiven)
    % Get the fields of the struct provided
    ceFields = fieldnames(stSolverOptionsGiven);
    % And assign each given value to the solver options
    for iField = 1:numel(ceFields)
        opSolverOptions.(ceFields{iField}) = stSolverOptionsGiven.(ceFields{iField});
    end
end

% Optimization target function
inOptimizationTargetVectorFunction = @(vEstimatedPose) algoForwardKinematics_Simple_TargetFunction(vEstimatedPose, vCableLength, aPulleyPosition, aCableAttachment);

% And now finally run the optimization
[xFinal, resnorm, residual, exitflag, output, lambda, jacobian] = lsqnonlin(inOptimizationTargetVectorFunction, ...
    vInitialStateForOptimization, ... % Initial state
    [], [], ... % lower and upper boundaries are not set
    opSolverOptions ... % Custom solver options
);



%% Post processing of the estimated pose
% Extract the position
vPosition = xFinal(1:3);
% Extract the quaternion rotation and ...
% vRotation = xFinal(4:7);
% Extract the yaw-pitch-roll rotation angles and ...
vRotation = xFinal(4:6);
% ... transform it into a rotation matrix
% aRotation = spinCalc('QtoDCM', vRotation, 1e-5, 0);
aRotation = rotz(vRotation(1))*roty(vRotation(2))*rotx(vRotation(1));

% Build the final estimated pose
vPoseEstimate = [reshape(vPosition, 1, 3), reshape(transpose(aRotation), 1, 9)];



%% Assign output quantities
% First and only required output is the estimated pose
Pose = vPoseEstimate;

% Second output, first optional may be the output struct from the optimization
if nargout > 1
    stOutput = output;
    stOutput.resnorm = resnorm;
    stOutput.residual = residual;
    stOutput.exitflag = exitflag;
    stOutput.lambda = lambda;
    stOutput.jacobian = jacobian;
    
    varargout{1} = stOutput;
end



end


function [VectorValuedFunction, Jacobian] = algoForwardKinematics_Simple_TargetFunction(EstimatedPose, TargetCableLength, PulleyPositions, CableAttachments)

%% Preparing variables
% Number of cables
nNumberOfCables = size(PulleyPositions, 2);
% Parse input variables
vEstimatedPose = reshape(EstimatedPose, 1, 6);
aPulleyPositions = PulleyPositions;
aCableAttachments = CableAttachments;
aTargetCableLength = TargetCableLength;
% Extract the position
vPosition = vEstimatedPose(1:3);
% And rotation from the estimated pose
% vRotation = vEstimatedPose(4:7).';
vRotation = vEstimatedPose(4:6).';
% Transform the rotation given in quaternions to a DCM (direct cosine
% matrix)
% aRotation = spinCalc('QtoDCM', vRotation, 1e-4, 0);
aRotation = rotz(vRotation(1))*roty(vRotation(2))*rotx(vRotation(1));
% Create the needed pose for the inverse kinematics algorithm composed of
% [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
vEstimatedPose = [reshape(vPosition, 1, 3), reshape(aRotation, 1, 9)];
% Array holding the Jacobian
aJacobian = zeros(nNumberOfCables, 6);


%% Calculate the cable length for the current pose estimate
% Calculate the cable lengths for the estimated pose using the simple
% inverse kinematics algorithm
vLengths = algoInverseKinematics_Simple(vEstimatedPose, aPulleyPositions, aCableAttachments);


%% And build the target optimization vector
% Get the vector difference of all cable lengths ...
vEvaluatedFunction = vLengths(:) - aTargetCableLength(:);

% Also calculate the Jacobian?
if nargout > 1
    % Code taken from WireCenter, therefore not super beautiful and not
    % following code conventions either, but for now it must work
    t1 = cos(vRotation(1));
	t2 = cos(vRotation(2));
	t3 = t1*t2;
	t5 = sin(vRotation(1));
	t6 = cos(vRotation(3));
	t8 = sin(vRotation(2));
	t10 = sin(vRotation(3));
    
    for iCable = 1:nNumberOfCables
		t4 = t3 * aCableAttachments(1,iCable);
		t9 = t1 * t8;
		t12 = -t5 * t6 + t9 * t10;
		t13 = t12 * aCableAttachments(2,iCable);
		t16 = t5 * t10 + t9 * t6;
		t17 = t16 * aCableAttachments(3,iCable);
		t18 = vPosition(1) + t4 + t13 + t17 - aPulleyPositions(1,iCable);
		t19 = t5 * t2;
		t20 = t19 * aCableAttachments(1,iCable);
		t22 = t5 * t8;
		t24 = t1 * t6 + t22 * t10;
		t28 = -t1 * t10 + t22 * t6;
		t30 = vPosition(2) + t20 + t24 * aCableAttachments(2,iCable) + t28 * aCableAttachments(3,iCable) - aPulleyPositions(2,iCable);
		t32 = t2 * t10;
		t34 = t2 * t6;
		t36 = vPosition(3) - t8 * aCableAttachments(1,iCable) + t32 * aCableAttachments(2,iCable) + t34 * aCableAttachments(3,iCable) - aPulleyPositions(3,iCable);
		t45 = t10 * aCableAttachments(2,iCable);
		t47 = t6 * aCableAttachments(3,iCable);
        aJacobian(iCable,1) = 0.2e1 * t18;
		aJacobian(iCable,2) = 0.2e1 * t30;
        aJacobian(iCable,3) = 0.2e1 * t36;
        aJacobian(iCable,4) = 0.2e1 * t18 * (-t20 - t24 * aCableAttachments(2,iCable) - t28 * aCableAttachments(3,iCable)) + 0.2e1 * t30 * (t4 + t13 + t17);
        aJacobian(iCable,5) = 0.2e1 * t18 * (-t9 * aCableAttachments(1,iCable) + t3 * t45 + t3 * t47) + 0.2e1 * t30 * (-t22 * aCableAttachments(1,iCable) + t19 * t45 + t19 * t47) + 0.2e1 * t36 * (-t2 * aCableAttachments(1,iCable) - t8 * t10 * aCableAttachments(2,iCable) - t8 * t6 * aCableAttachments(3,iCable));
        aJacobian(iCable,6) = 0.2e1 * t18 * (t16 * aCableAttachments(2,iCable) - t12 * aCableAttachments(3,iCable)) + 0.2e1 * t30 * (t28 * aCableAttachments(2,iCable) - t24 * aCableAttachments(3,iCable)) + 0.2e1 * t36 * (t34 * aCableAttachments(2,iCable) - t32 * aCableAttachments(3,iCable));
    end
end



%% Assign output quantities
% ... which is our return value
VectorValuedFunction = vEvaluatedFunction;

% Assign the output Jacobian if requested
if nargout > 1
    Jacobian = aJacobian;
end

end


% function [c, ceq] = algoForwardKinematics_Simple_NonlinearConstraints(vOptimizationVector)
% 
% %% Initialize Variables
% vNonlinearInequalityConstraints = [];
% vNonlinearEqualityConstraints = [];
% % Extract the position from the optimizaton vector
% vPosition = vOptimizationVector(1:3);
% % Extract the quaternion rotation from the optimization vector
% vRotation = vOptimizationVector(4:end);
% % Convert quaternions to a DCM
% aRotation = spinCalc('QtoDCM', vRotation, 1e-5, 0);
% 
% 
% 
% %% Calculate the non-linear equality constraints
% vNonlinearEqualityConstraints(1) = norm(vRotation) - 1;
% 
% 
% 
% %% Assign output quantities
% % Non-linear inequality constraints
% c = vNonlinearInequalityConstraints;
% % Non-linear equality constraints
% ceq = vNonlinearEqualityConstraints;
% 
% 
% 
% end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
