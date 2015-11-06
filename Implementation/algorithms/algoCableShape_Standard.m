function [Shape] = algoCableShape_Standard(Length, UnitVector, PulleyAngle, DiscretizationPoints)
%#codegen
% ALGOCABLESHAPE_STANDARD - Calculates the cable shape for the standard
% kinematics
%   
%   SHAPE = ALGOCABLESHAPE_STANDARD(LENGTH, UNITVECTOR, PULLEYANGLES) draws the
%   cables shapes according to the length and the unit vector (which is going
%   from b_i to a_i by convention) in the cable local frame with 1e3 points over
%   the length
% 
%   SHAPE = ALGOCABLESHAPE_STANDARD(..., 1e4) draws the same cable shape as
%   before but now spreads 1e4 points over the length discretizing it more
%   precisley.
%   
%   
%   Inputs:
%   
%   LENGTH: Vector of m cable lengths as determined by the inverse kinematics
% 
%   UNITVECTOR: Unit vector as pointing from b_i to a_i in the global coordinate
%   system. Can be returned automatically by the inverse kinematics algorithm.
%   
%   PULLEYANGLE: Vector or matrix of m columns where the first row keeps the
%   angle of rotation of the pulley about its local z-axis to make its x-axis
%   point towards b_i
% 
%   Outputs:
% 
%   SHAPE: The shape of the cable in the cable's local frame given as a 3d
%   matrix with the local cable frame coordinates [x,y,z] along the first
%   dimension, the discretization points along the second, and the cable along
%   the third
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-08-31
% Changelog:
%   2015-08-31
%       * Initial release



%% Input defaults
% In case no discretization points were given
if nargin < 4 || isempty(DiscretizationPoints)
    DiscretizationPoints = 1e3;
end



%% Assertion
% Assert cable length
assert(~isempty(Length) && isa(Length, 'numeric') && ismatrix(Length) && isvector(Length) && ( numel(Length) == size(UnitVector, 2) ) && all(all(Length > 0)));
% Assert cable vectors
assert(~isempty(UnitVector) && isa(UnitVector, 'numeric') && ismatrix(UnitVector) && isvector(UnitVector) && ( size(UnitVector, 1) == 3 ) && ( size(UnitVector, 2) == numel(Length) ));
% Assert cable vectors
assert(~isempty(PulleyAngle) && isa(PulleyAngle, 'numeric') && ismatrix(PulleyAngle) && ( size(PulleyAngle, 1) >= 1) && ( size(PulleyAngle, 2) == numel(Length) ) );
% Asserrt discretization points
assert(isa(DiscretizationPoints, 'numeric') && isscalar(DiscretizationPoints) && DiscretizationPoints > 0);



%% Local variables
% Number of cables
nNumberOfCables = numel(Length);
% Cable lengths
vCableLength = Length;
% Cable unit vectors
aCableVector = UnitVector;
% Pulley angles
aPulleyAngles = PulleyAngle;
% Number of discretizaton points
nDiscretizationPoints = DiscretizationPoints;
% And the generated shape holding array
aCableShape = zeros(3, nDiscretizationPoints, nNumberOfCables);



%% Off with the magic

% For each cable
for iCable = 1:nNumberOfCables
    % Rotation matrix about K_C
    aRotation_kC2kA = rotz(aPulleyAngles(1,iCable));
    
    % Just in case, normalize the cable unit vector
    if norm(aCableVector(:,iCable)) ~= 1
        aCableVector(:,iCable) = aCableVector(:,iCable)./norm(aCableVector(:,iCable));
    end

    % Vector from A to B in K_C
    vA2B_in_C = transpose(aRotation_kC2kA)*(-aCableVector(:,iCable));
    
    % Normalize the vector from A^c to B^c
    vCableUnitVector_in_C = vA2B_in_C./norm(vA2B_in_C);
    
    % First, we will calculate the local cable shape
    aCableShapeLocal = zeros(3,nDiscretizationPoints);

    % Get a linspace of the cable length given the number of discretization
    % points
    vLinspaceOfCableLength = linspace(0, vCableLength(iCable), nDiscretizationPoints);
    % Calculate the cable shape quite easily
    aCableShapeLocal(1,:,iCable) = vCableUnitVector_in_C(1).*vLinspaceOfCableLength;
    aCableShapeLocal(3,:,iCable) = vCableUnitVector_in_C(3).*vLinspaceOfCableLength;
    
    % Transform the local cable shape back to the global cable shape
    aCableShape(:,:,iCable) = aRotation_kC2kA*aCableShapeLocal;
end

% Make sure everything smaller than the machine constant eps is balanced equaled
% to 0
aCableShape(abs(aCableShape) < eps) = 0;



%% Output assignment
Shape = aCableShape;



end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this funciton will be acknowledged in
% the "Changes" section of the header
