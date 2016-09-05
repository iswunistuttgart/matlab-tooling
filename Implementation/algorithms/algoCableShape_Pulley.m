function [Shape] = algoCableShape_Pulley(Length, UnitVector, PulleyAngle, PulleyRadius, PulleyOrientation, DiscretizationPoints)%#codegen
% ALGOCABLESHAPE_PULLEY - Calculates the cable shape for the pulley kinematics
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



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-03-29
% Changelog:
%   2016-03-29
%       * Code cleanup
%   2015-08-31
%       * Initial release



%% Input defaults
% In case no discretization points were given
if nargin < 6 || isempty(DiscretizationPoints)
    DiscretizationPoints = 1e3;
end



%% Assertion
% Assert cable length
assert(~isempty(Length));
assert(isa(Length, 'numeric'));
assert(ismatrix(Length));
assert(isvector(Length));
assert(( numel(Length) == size(UnitVector, 2) ));
assert(all(all(Length > 0)));
% Assert cable vectors
assert(~isempty(UnitVector));
assert(isa(UnitVector, 'numeric'));
assert(ismatrix(UnitVector));
assert(( size(UnitVector, 1) == 3 ));
assert(( size(UnitVector, 2) == numel(Length) ));
% Assert cable vectors
assert(~isempty(PulleyAngle));
assert(isa(PulleyAngle, 'numeric'));
assert(ismatrix(PulleyAngle));
assert(( size(PulleyAngle, 1) >= 1));
assert(( size(PulleyAngle, 2) == numel(Length) ) );
% Assert pulley radius
assert(~isempty(PulleyRadius));
assert(isa(PulleyRadius, 'numeric'));
assert(isvector(PulleyRadius));
assert(( numel(PulleyRadius) == numel(Length) ));
assert(all(PulleyRadius > 0) );
% Assert pulley orientations
assert(~isempty(PulleyOrientation));
assert(isa(PulleyOrientation, 'numeric'));
assert(ismatrix(PulleyOrientation));
assert(( size(PulleyOrientation, 1) == 3 ));
assert(( size(PulleyOrientation, 2) == numel(Length) ) );
% Asserrt discretization points
assert(isa(DiscretizationPoints, 'numeric') );
assert(isscalar(DiscretizationPoints) && DiscretizationPoints > 0);



%% Local variables
% Number of cables
nNumberOfCables = numel(Length);
% Cable lengths
vCableLength = Length;
% Cable unit vectors
aCableVector = UnitVector;
% Pulley angles
aPulleyAngles = PulleyAngle;
% Pulley radius
vPulleyRadius = PulleyRadius;
% Pulley orientations
aPulleyOrientation = PulleyOrientation;
% Number of discretizaton points
nDiscretizationPoints = DiscretizationPoints;
% And the generated shape holding array
aCableShape = zeros(3, nDiscretizationPoints, nNumberOfCables);



%% Off with the magic

%%% Perform the calculation of the cable shape only when necessary
for iCable = 1:nNumberOfCables
    % Get length of cable on pulley
    dCableOnPulley = vPulleyRadius(iCable)*d2r(aPulleyAngles(2,iCable));
    % Get length of cable in workspace
    dCableInWorkspace = vCableLength(iCable) - dCableOnPulley;
    
    % First, what's the ratio of cable on the pulley vs cable between pulley
    % and platform?
    dRatioPulleyToTotal = dCableOnPulley/vCableLength(iCable);
    dRatioWorkspaceToTotal = dCableInWorkspace/vCableLength(iCable);
    nDiscretizationPointsOnPulley = round(dRatioPulleyToTotal*nDiscretizationPoints);
    nDiscretizationPointsInWorkspace = round(dRatioWorkspaceToTotal*nDiscretizationPoints);
    
    % Create the linear spaces for the cable part on the pulley
    vLinspaceOfCableOnPulley = linspace(0, aPulleyAngles(2,iCable), nDiscretizationPointsOnPulley);
    % and the part in the workspace
    vLinspaceOfCableInWorkspace = linspace(dCableOnPulley, dCableInWorkspace, nDiscretizationPointsInWorkspace + 1);
    
    % Now transform the local cable shape to the global frame
    aRotation_kC2kP = rotz(aPulleyAngles(1,iCable));
    aRotation_kC2kP(abs(aRotation_kC2kP) < 2*eps) = 0;
    aRotation_kP2kO = eul2rotm(fliplr(aPulleyOrientation(1:3,iCable)./180.*pi), 'ZYX');
    aRotation_kP2kO(abs(aRotation_kP2kO) < 2*eps) = 0;
    
    % Get the unit vector from global frame to local frame
    vCableUnitVectorInKc = transpose(aRotation_kC2kP)*(transpose(aRotation_kP2kO)*(-aCableVector(:,iCable)));
    
    % Keeps the shape in the cable's local frame K_C starting at K_P
    aCableShapeLocal = zeros(3, nDiscretizationPoints);
    
    % First part of the local shape is the part on the pulley
    aCableShapeLocal(1,1:nDiscretizationPointsOnPulley) = vPulleyRadius(iCable).*(1 - cosd(vLinspaceOfCableOnPulley));
    aCableShapeLocal(3,1:nDiscretizationPointsOnPulley) = vPulleyRadius(iCable).*(sind(vLinspaceOfCableOnPulley));
    
    % Second part of the local shape is the part form the corrected pulley point
    % in K_C to b_i (which can be inferred from the unit vector and its length)
    aCableShapeLocal(1,nDiscretizationPointsOnPulley:end) = vPulleyRadius(iCable).*(1 - cosd(aPulleyAngles(2,iCable))) + vCableUnitVectorInKc(1).*vLinspaceOfCableInWorkspace;
    aCableShapeLocal(2,nDiscretizationPointsOnPulley:end) = vCableUnitVectorInKc(2).*vLinspaceOfCableInWorkspace;
    aCableShapeLocal(3,nDiscretizationPointsOnPulley:end) = vPulleyRadius(iCable).*(sind(aPulleyAngles(2,iCable))) + vCableUnitVectorInKc(3).*vLinspaceOfCableInWorkspace;
    
    % Convert the local cable shape to the global cable shape (relative to K_P)
    aCableShape(:,:,iCable) = aRotation_kP2kO*aRotation_kC2kP*aCableShapeLocal;
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
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
