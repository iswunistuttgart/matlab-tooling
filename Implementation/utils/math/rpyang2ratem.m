function [RateM] = rpyang2ratem(Angle)
% RPYANG2RATEM converts Tait-Bryan tuple (roll, pitch, yaw) to its angular
% velocity rate matrix P.
%
%   RATEM = RPYANG2RATEM(ANGLE) determines the transformation matrix to convert
%   Tait-Bryan angles ANGLE (given in [roll, pitch, yaw] or [phi, theta, psi])
%   to body-fixed angular velocities.
%
%   Inputs:
%
%   ANGLE       Mx3 matrix of Tait-Bryan RPY angular positions ordered as
%               [roll, pitch, yaw] or [phi, theta, psi].
%
%   Outputs:
%
%   RATEM       3x3xM matrix of rate matrices to convert Tait-Bryan angular
%               velocities to body-fixed angular velocities.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-08-26
% Changelog:
%   2016-08-26
%       * Initial release



%% Input Assertion
% Angle has to be doubles
assert(isa(Angle, 'double') || isa(Angle, 'sym'), 'PHILIPPTEMPEL:RPYANG2RATEM:invalidTypeAngle', 'Angle must be double or symbolic.');
% Angle has to have 3 columns
assert(size(Angle, 2) == 3, 'PHILIPPTEMPEL:RPYANG2RATEM:invalidNcolsAngle', 'Angle must have three columns.');



%% Local variables
% Array of angles
aAng = Angle;
% Number of angles
nAngles = size(aAng, 1);



%% Do your code magic here
% Transpose the angles and rates for correct use of cat later one
aAng = transpose(aAng);
% Reshapte the angles in the depth dimension
aAng2 = reshape(aAng, [3, 1, nAngles]);

% Quick-access variables
vZeros = zeros(1, 1, nAngles);
vOnes = ones(1, 1, nAngles);
% vSinOne = sin(aAng2(1,1,:));
% vCosOne = sin(aAng2(1,1,:));
vSinTwo = sin(aAng2(2,1,:));
vCosTwo = cos(aAng2(2,1,:));
vSinThree = sin(aAng2(3,1,:));
vCosThree = cos(aAng2(3,1,:));

% Cast the big 3D matrix of P^{-1}
aPInv_Temp = cat(1 ...
    ,  vCosTwo.*vCosThree,   vSinThree,  vZeros ...
    , -vCosTwo.*vSinThree,   vCosThree,  vZeros ...
    ,  vSinTwo,              vZeros,     vOnes ...
);
aPInv = reshape(aPInv_Temp, [3, 3, nAngles]);



%% Assign output quantities

% Only one output argument: rate matrices
RateM = aPInv;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
