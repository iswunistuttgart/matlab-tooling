function [Shape] = algoCableShape_CatenaryElastic(Length, LocalCableForces, PulleyAngle, CableProperties, GravityConstant, DiscretizationPoints)%#codegen
% ALGOCABLESHAPE_CATENARYELASTIC - Determines the cable shape for the hefty
%   non-elastic kinematics
%   
%   SHAPE = ALGOCABLESHAPE_CATENARYELASTIC(LENGTH, LOCALCABLEFORCES, PULLEYANGLES,
%   CABLEPROPERTIES) draws the cable shape of the non-elastic hefty cables
%   starting at [0,0,0] and going towards the cable's local b_i with a
%   discretization of 1e3 points per cable length and a gravity constant of
%   9.81[kg m/s^2]
% 
%   SHAPE = ALGOCABLESHAPE_CATENARYELASTIC(..., GRAVITYCONSTANT) draws the same
%   cable shape as before but now considers GRAVITYCONSTANT in [kg m/^2] as the
%   gravity constant
% 
%   SHAPE = ALGOCABLESHAPE_CATENARYELASTIC(..., DISCRETIZATIONPOINTS) draws the
%   same cable shape as before but now spreads DISCRETIZATIONPOINTS points over
%   the length discretizing it more or less precisley
%   
%   
%   Inputs:
%   
%   LENGTH: Vector of m cable lengths as determined by the inverse kinematics
%   for non-elastic catenary
%
%   LOCALCABLEFORCES: A matrix of 2xM (or 3xM) forces applied to the cable at
%   its anchorage point on the platform. The first row must be the amount of
%   force in the x-direction of the cable's local frame while the second (or
%   third) row must contain the force in direction of z_c
%   
%   PULLEYANGLE: Vector or matrix of m columns where the first row keeps the
%   angle of rotation of the pulley about its local z-axis to make its x-axis
%   point towards b_i
%
%   CABLEPROPERTIES: Struct containing at least the fields {Density,
%   UnstrainedSection} (case-sensitive) to determine the behavior of the cable
%   under gravity and own mass
%
%   GRAVITYCONSTANT: The constant of gravity acting upon the cable. It is
%   assumed the cable hangs in the z-axis i.e., the world and cable's z-axis
%   points in the opposite direction of the force of gravity. If not given or
%   empty, defaults to 9.81 [kg m/s^2]
%
%   DISCRETIZATIONPOINTS: Number of points to discretize the cable length with.
%   Can be omitted to use 1e3 as its default value
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
% In case no gravity constant is given or it is set empty i.e., []
if nargin < 5 || isempty(GravityConstant)
    GravityConstant = 9.81;
end
% In case no discretization points were given
if nargin < 6
    DiscretizationPoints = 1e3;
end



%% Assertion
% Assert cable length
assert(~isempty(Length));
assert(isa(Length, 'numeric'));
assert(ismatrix(Length));
assert(isvector(Length));
assert( numel(Length) == size(UnitVector, 2) );
assert(all(all(Length > 0)));
% Assert the cable forces
assert(~isempty(LocalCableForces));
assert(isa(LocalCableForces, 'numeric'));
assert(ismatrix(LocalCableForces));
assert(size(LocalCableForces, 2) == numel(Length));
% Assert cable vectors
assert(~isempty(PulleyAngle));
assert(isa(PulleyAngle, 'numeric'));
assert(ismatrix(PulleyAngle));
assert(size(PulleyAngle, 1) >= 1);
assert(size(PulleyAngle, 2) == numel(Length));
% Assert pulley orientations
assert(~isempty(CableProperties));
assert(isa(CableProperties, 'struct'));
assert(isfield(CableProperties, 'Density'));
assert(isfield(CableProperties, 'UnstrainedSection'));
assert(isfield(CableProperties, 'YoungsModulus'));
% Asserrt gravity constant
assert(isa(GravityConstant, 'numeric'));
assert(isscalar(GravityConstant));
assert(GravityConstant > 0);
% Asserrt discretization points
assert(isa(DiscretizationPoints, 'numeric'));
assert(isscalar(DiscretizationPoints));
assert(DiscretizationPoints > 0);



%% Assigning local variables
nNumberOfCables = numel(Length);
% Vector of cable lengths
vCableLength = Length;
% Matrix of [F_x; F_z] per cable
aCableForces = LocalCableForces;
% Get cable forces in the cable's local x direction
vCableForcesX = aCableForces(1,:);
% Get the cable forces in the cable's local z direction
vCableForcesZ = aCableForces(end,:);
% Get the pulley angles
vPulleyAngle = PulleyAngle;
% Struct of cable properties
stCableProps = CableProperties;
% Gravitational constant needed for calculation of the cable shape
dGravityConstant = GravityConstant;
% Discretization
nDiscretizationPoints = DiscretizationPoints;
% Final cable shape
aCableShape = zeros(3,DiscretizationPoints,nNumberOfCables);



%% Do the magic
% Calculate the cable coordinates for the catenary line
for iCable = 1:nNumberOfCables
    % Get the linspace of discretization points for the cable length
    vLinspaceCableLength = linspace(0, vCableLength(iCable), nDiscretizationPoints);
    
    % Keeps the cable's local shape
    aCableShapeLocal = zeros(3, nDiscretizationPoints);
    
    % X-Coordinate
    aCableShapeLocal(1,:,iCable) = 0 ... %vCableForcesX(iCable).*vLinspaceCableLength./((stCableProps.YoungsModulus)*(stCableProps.UnstrainedSection)) ...
        + abs(vCableForcesX(iCable))./((stCableProps.Density).*dGravityConstant).*(asinh((vCableForcesZ(iCable) + (stCableProps.Density).*dGravityConstant.*(vLinspaceCableLength - vCableLength(iCable)))./vCableForcesX(iCable)) - asinh((vCableForcesZ(iCable) - (stCableProps.Density).*dGravityConstant.*vCableLength(iCable))./vCableForcesX(iCable)));

    % Z-Coordinate
    aCableShapeLocal(3,:,iCable) = 0 ...%vCableForcesZ(iCable)./((stCableProps.YoungsModulus).*dCablePropUnstrainedSection).*vLinspaceCableLength ...
        ...%+ (stCableProps.Density).*dGravityConstant./((stCableProps.YoungsModulus).*dCablePropUnstrainedSection).*(vLinspaceCableLength./2 - vCableLength(iCable)).*vLinspaceCableLength ...
        + 1./((stCableProps.Density).*dGravityConstant)*(sqrt(vCableForcesX(iCable).^2 + (vCableForcesZ(iCable) + (stCableProps.Density).*dGravityConstant.*(vLinspaceCableLength - vCableLength(iCable))).^2) - sqrt(vCableForcesX(iCable).^2 + (vCableForcesZ(iCable) - (stCableProps.Density).*dGravityConstant.*vCableLength(iCable)).^2));
    
    % And transform the local cable shape to a global shape
    aCableShape(:,:,iCable) = rotz(vPulleyAngle(1,iCable))*aCableShapeLocal;
end

% Avoid numerical issues by setting anything smaller than eps to zero
aCableShape(aCableShape < eps) = 0;



%% Output assignment
Shape = aCableShape;


end
