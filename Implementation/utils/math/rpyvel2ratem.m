function [RateM] = rpyvel2ratem(Angle, Velocity)
% RPYVEL2RATEM converts Tait-Bryan tuple (roll, pitch, yaw) and its angular
% velocities to its angular acceleration rate matrix dP
%
%   RATEM = RPYVEL2RATEM(ANGLE, VELOCITY) determines the transformation matrix
%   to convert Tait-Bryan angles ANGLE (given in [roll, pitch, yaw] or
%   [phi, theta, psi]) and angle rate VELOCITY (given in [droll, dpitch, dyaw]
%   or [dphi, dtheta, dpsi] to body-fixed angular accelerations.
%
%   Inputs:
%
%   ANGLE           Mx3 matrix of Tait-Bryan RPY angular positions ordered as
%                   [roll, pitch, yaw] or [phi, theta, psi].
%
%   VELOCITY        Mx3 matrix of Tait-Bryan RPY angular velocities ordered as
%                   [droll, dpitch, dyaw] or [dphi, dtheta, dpsi].
%
%   Outputs:
%
%   RATEM           3x3xM matrix of rate matrices to convert Tait-Bryan angular
%                   velocities and accelerations to body-fixed angular
%                   accelerations.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-26
% Changelog:
%   2016-08-26
%       * Initial release



%% Input Assertion
% Angle has to be doubles
assert(isa(Angle, 'double') || isa(Angle, 'sym'), 'PHILIPPTEMPEL:RPYVEL2RATEM:invalidTypeAngle', 'Angle must be double or symbolic.');
% Angle has to have 3 columns
assert(size(Angle, 2) == 3, 'PHILIPPTEMPEL:RPYVEL2RATEM:invalidNcolsAngle', 'Angle must have three columns.');
% Velocity has to be doubles
assert(isa(Velocity, 'double') || isa(Angle, 'sym'), 'PHILIPPTEMPEL:RPYVEL2RATEM:invalidTypeVelocity', 'Velocity must be double or symbolic.');
% Velocity has to have 3 columns
assert(size(Velocity, 2) == 3, 'PHILIPPTEMPEL:RPYVEL2RATEM:invalidNcolsVelocity', 'Velocity must have three columns.');
% Angle and velocity must have same number of rows
assert(size(Angle, 1) == size(Velocity, 1), 'PHILIPPTEMPEL:RPYVEL2RATEM:dimensionMismatch', 'Angle and Velocity must have same number of rows.');



%% Local variables
% Array of angles
aAng = Angle;
% Array of velocities
aVel = Velocity;
% Number of angles
nAngles = size(aAng, 1);



%% Do your code magic here
% Transpose the angles and rates for correct use of cat later one
aAng = transpose(aAng);
aVel = transpose(aVel);
% Reshapte the angles in the depth dimension
aAng2 = reshape(aAng, [3, 1, nAngles]);
aVel2 = reshape(aVel, [3, 1, nAngles]);

% Quick-access variables
vZeros = zeros(1, 1, nAngles);
vPhiDot = aVel2(1,1,:);
vThetaDot = aVel2(2,1,:);
vSinTheta = sin(aAng2(2,1,:));
vCosTheta = cos(aAng2(2,1,:));
vSinPsi = sin(aAng2(3,1,:));
vCosPsi = cos(aAng2(3,1,:));

% Cast the big 3D matrix of dP^{-1}/dn
aPInvDot_Temp = cat(1 ...
    , vZeros,   -vPhiDot.*vSinTheta.*vCosPsi,   -vThetaDot.*vCosPsi - vPhiDot.*vCosTheta.*vCosPsi ...
    , vZeros,   -vPhiDot.*vSinTheta.*vSinPsi,    vPhiDot.*vCosTheta.*vCosPsi + vThetaDot.*vSinPsi ...
    , vZeros,   -vPhiDot*vCosTheta,              vZeros ...
);
aPInvDot = reshape(aPInvDot_Temp, [3, 3, nAngles]);



%% Assign output quantities

% Only one output
RateM = aPInvDot;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
