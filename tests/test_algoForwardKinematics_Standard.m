clc
cle

IPAnema3 = load('IPAnema3-2');



%% Initialize pose and cable length
Position = [0, 0, 0.5];

dRotX = 0;
dRotY = 0;
dRotZ = 0;
Rotation = rotz(dRotZ)*roty(dRotY)*rotx(dRotX);

Pose = [reshape(Position, 1, 3), rotationMatrixToRow(Rotation)];

L_Ref = algoInverseKinematics_Standard(Pose, IPAnema3.cfg_gears_a, IPAnema3.cfg_platform_b);



%% Initialize optimization
stSolverOptions = struct();
stSolverOptions.Display = 'off';
stSolverOptions.TolFun = 1e-8;
stSolverOptions.TolX = 1e-12;

stSolverOptions_JacOf = stSolverOptions;
stSolverOptions_JacOf.Jacobian = 'off';

stSolverOptions_JacOn = stSolverOptions;
stSolverOptions_JacOn.Jacobian = 'on';



%% Test without Jacobian
[PoseEstim_JacOf, Benchmark_JacOf] = algoForwardKinematics_Simple(L_Ref, IPAnema3.cfg_gears_a, IPAnema3.cfg_platform_b, stSolverOptions_JacOf);

ErrorPosition_JacOf = Pose(1:3) - PoseEstim_JacOf(1:3)
ErrorRotation_JacOf = [dRotX, dRotY, dRotZ] - PoseEstim_JacOf(4:6)
Residual_JacOf = Benchmark_JacOf.residual
Jacobian_JacOf = Benchmark_JacOf.jacobian


%% Test with Jacobian
[PoseEstim_JacOn, Benchmark_JacOn] = algoForwardKinematics_Simple(L_Ref, IPAnema3.cfg_gears_a, IPAnema3.cfg_platform_b, stSolverOptions_JacOn);

ErrorPosition_JacOn = Pose(1:3) - PoseEstim_JacOn(1:3)
ErrorRotation_JacOn = [dRotX, dRotY, dRotZ] - PoseEstim_JacOn(4:6)
Residual_JacOn = Benchmark_JacOn.residual
Jacobian_JacOn = Benchmark_JacOn.jacobian


%% Cleanup
clear IPAnema3;