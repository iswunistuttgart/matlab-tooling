function [Distribution, varargout] = algoForceDistribution_ClosedForm(Wrench, StructureMatrix, ForceMinimum, ForceMaximum)
% ALGOFORCEDISTRIBUTION_CLOSEDFORM - Determine the force distribution for
%   the given robot using the closed-form force distribution algorithm
% 
%   LENGTH = ALGOINVERSEKINEMATICS_SIMPLE(POSE, WINCHPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
% 
%   [LENGTH, CABLEVECTORS] = ALGOINVERSEKINEMATICS_SIMPLE(...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
% 
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS] = ALGOINVERSEKINEMATICS_SIMPLE(...)
%   also provides the unit vectors for each cable which might come in handy
%   at times
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   WINCHPOSITIONS: Matrix of winch positions w.r.t. the world frame. Each
%   winch has its own column and the rows are the x, y, and z-value,
%   respectively i.e., WINCHPOSITIONS must be a matrix of 3xM values. The
%   number of winches i.e., N, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of winch to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., N, must match the number of winches in WINCHPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to winch.
% 
%   Outputs:
% 
%   DISTRIBUTION: Vector of force distribution values as determined by the
%   algorithm
%
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-22
% Changelog:
%   2015-04-22: Initial release


%------------- BEGIN CODE --------------


%%% Assert and parse variables
% Wrench
vWrench = Wrench;
% Structure matrix to determine force distribution for
mStructureMatrixAt = StructureMatrix;
% Number of cables (is being used quite often in the following code)
iNumberOfWires = size(mStructureMatrixAt, 2);

% Force minimum, can be given a scalar or a vector
if isscalar(ForceMinimum)
    vForceMinimum = ForceMinimum.*ones(iNumberOfWires, 1);
else
    vForceMinimum = ForceMinimum;
end
% Force maximum, can be given a scalar or a vector
if isscalar(ForceMaximum)
    vForceMaximum = ForceMaximum.*ones(iNumberOfWires, 1);
else
    vForceMaximum = ForceMaximum;
end
% Vector of mean force values
vForceMean = 0.5.*(vForceMinimum + vForceMaximum);



%% Do the magic
% Simple case where the number of wires matches the number of degrees of
% freedom, we can just solve the linear equation system At*f = -w;
if issquare(mStructureMatrixAt)
    mForceDistribution = mStructureMatrixAt\(-vWrench);
% Non standard case, where we have more cables than degrees of freedom
else
    % Solve A^t f_v & = - ( w + A^t f_m )
    % Determine the pseudo inverse of A^t
    mStructureMatrixPseudeoInverse = transpose(mStructureMatrixAt)/(mStructureMatrixAt*transpose(mStructureMatrixAt));
    % And determine the force distribution
    mForceDistribution = vForceMean - mStructureMatrixPseudeoInverse*(vWrench + mStructureMatrixAt*vForceMean);
end



%% Create output quantities
Distribution = mForceDistribution;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
