% Gravitational constant
dGravitationConstant = 9.81; % [kg m/s^2]
% Weight of the cable in total
dCableWeight = 0.5; % [kg]
% Number of nodes
nNodes = 25; % []
% Weight of each node
dNodeWeight = dCableWeight./nNodes; % [kg]
% Length of Cable
nCableLength = 5;
% Distance between each node
dNodeDistance = nCableLength./nNodes; % [m]
% Number of "lengths" we have
nNodeLengths = nNodes + 1;
% Array of forces on each node
aNodeForceDirections = zeros(2, nNodes+1);
vNodeForceAmounts = zeros(1, nNodes+1);
vNodeForceAngle = zeros(1, nNodes+1);

% Force applied to bi
dLoadForceAmount = 5; % [N]
% Angle of force with respect to global x-axis
dLoadForceAngle = deg2rad(-25); % [deg]


aNodeForceDirections(1,end) = dLoadForceAmount.*cos(dLoadForceAngle);
aNodeForceDirections(2,end) = dLoadForceAmount.*sin(dLoadForceAngle);
vNodeForceAmounts(end) = dLoadForceAmount;
vNodeForceAngle(end) = dLoadForceAngle;

vNodeGravitationalForce = dNodeWeight.*dGravitationConstant.*[0; -1];

for iNode = nNodes:-1:1
    iNodeIndex = iNode;
    vNodeForce = (aNodeForceDirections(:,iNodeIndex+1) + vNodeGravitationalForce);
    aNodeForceDirections(:,iNodeIndex) = vNodeForce;
    vNodeForceAmounts(iNodeIndex) = norm(aNodeForceDirections(:,iNodeIndex));
    vNodeForceAngle(iNodeIndex) = atan2(aNodeForceDirections(2,iNodeIndex), aNodeForceDirections(1,iNodeIndex));
end

% To keep the calculated node positions, note that this array is two larger than
% the number of nodes which is because it will be keeping a_i and b_i in the
% first and last column respectively
aNodePositions = zeros(2, nNodes+2);

for iNode = 1:nNodes+1
    iNodeIndex = iNode;
    aNodePositions(:,iNodeIndex+1) = aNodePositions(:,iNodeIndex) + dNodeDistance.*[cos(vNodeForceAngle(iNodeIndex)); sin(vNodeForceAngle(iNodeIndex))];
end

clear iNode* vNodeForce;

figure; plot(aNodePositions(1, :), aNodePositions(2, :), '-*', aNodePositions(1, [1, end]), aNodePositions(2, [1, end]), 'r');


return;








































% Total length of cable
dLength = 10; % [m]
% Unit weight of the cable
dUnitWeight = 1.500; % [kg/m]%
% Mass of the cable
dMassCable = dUnitWeight*dLength; % [kg]
dMassNode = dMassCable/(nNodes+2); % [kg]
% Distance between nodes
dNodeDistance = dLength/(nNodes+1); % [m]
% Nominal force that pulls at node N+1
Fp = 50; % [N]
% Fp = 0;
% Fp = 10*dMassCable*g;
% Angle the force Fp has with the x-axis at node N+1
phi = deg2rad(-23);
% phi = deg2rad(0);
% phi = deg2rad(180);






























% aLoadForceDirn = zeros(2, nNodes + 2);
% vLoadForceAngle = zeros(1, nNodes + 2);
% vLoadForceMag = zeros(1, nNodes + 2);
% vNodePosition = zeros(2, nNodes + 2);
% 
% aLoadForceDirn(:, end) = (Fp.*[cos(phi); sin(phi)] + dMassNode*g.*[0; -1]);
% vLoadForceAngle(end) = atan2(aLoadForceDirn(2, end), aLoadForceDirn(1, end));
% 
% % Loop over all nodes starting at the last node to calculate their load forces
% % and angles of these forces
% for iNode = fliplr(1:nNodes+1)
%     aLoadForceDirn(:, iNode) = aLoadForceDirn(:, iNode + 1) + dMassNode.*g.*[0; -1];
%     vLoadForceAngle(iNode) = atan2(aLoadForceDirn(2, iNode), aLoadForceDirn(1, iNode));
%     vLoadForceMag(end) = sqrt(sum(aLoadForceDirn(:, iNode).^2));
% end
% 
% for iNode = 1:size(vNodePosition, 2)
%     vNodePosition(:, iNode + 1) = dNodeDistance.*[cos(vLoadForceAngle(iNode)); sin(vLoadForceAngle(iNode))] + vNodePosition(:, iNode);
% end








% 
% 
% % Keeps the calculated angles
% vAngles = zeros(1, nNodes);
% vAngles(nNodes) = phi;
% % Keep the direction 
% aLoadForces = zeros(2, nNodes);
% aLoadForces(:, end) = (Fp.*[cos(phi); sin(phi)] + dMassNode*g.*[0; -1]);
% % aLoadForces(:, nNodes + 1) = (Fp.*[cos(phi); sin(phi)] + dMassNode*g.*[0; -1]);
% % aForces(:,nNodes + 1) = -(Fp.*[cos(phi); sin(phi)] + dMassNode*g.*[0; -1]);
% % Keeps the nominal forces at each node
% vForces = zeros(1, nNodes);
% % vForces = sqrt(sum(aLoadForces.^2));
% % Keep the position of each node
% vPositions = zeros(2, nNodes);
% 
% % Loop over all nodes starting at the last node
% for iNode = fliplr(2:nNodes)
%     aForceOnNode = aLoadForces(:, iNode);
%     aResultingForce = -(aForceOnNode + dMassNode*g.*[0; -1]);
%     
%     aLoadForces(:, iNode-1) = -aResultingForce;
%     
%     vForces(iNode) = sqrt(sum(aLoadForces(:, iNode).^2));
%     vAngles(iNode) = atan2(aLoadForces(2, iNode), aLoadForces(1, iNode));
% end
% 
% % for iNode = fliplr(1:nNodes)
% %     aForces(:, iNode) = -aForces(:, iNode + 1);
% %     vForces(iNode) = sqrt(sum(aForces(:, iNode).^2));
% %     
% %     vAngles(iNode) = atan2(-aForces(2, iNode), -aForces(1, iNode));
% %     
% % %     Fx = vForces(iNode + 1)*cos(vAngles(iNode + 1));
% % %     Fz = dMassNode*g + vForces(iNode + 1)*sin(vAngles(iNode + 1));
% % %     vForces(iNode) = sqrt( Fx.^2 + Fz.^2 );
% % %     
% % % %     vAngles(iNode) = 1/2*acos(2*Fx*Fz/(vForces(iNode).^2));
% % %     
% % % %     vAngles(iNode) = atan2( dMassNode*g + vForces(iNode+1)*sin(vAngles(iNode+1)), vForces(iNode+1)*cos(vAngles(iNode+1)) );
% % %     vAngles(iNode) = atan2(Fz, Fx);
% % % %     vAngles(iNode) = atan( ( dMassNode*g + vForces(iNode+1)*sin(vAngles(iNode+1)) )/( vForces(iNode+1)*cos(vAngles(iNode+1)) ) );
% % %     
% % %     aForces(:,iNode) = vForces(iNode).*[cos(vAngles(iNode)); sin(vAngles(iNode))];
% % end
% 
% for iNode = 1:size(vPositions, 2)-1
%     vPositions(:, iNode+1) = dNodeDistance.*[cos(vAngles(iNode)); sin(vAngles(iNode))] + vPositions(:, iNode);
% end
% % rad2deg(vAngles)
% % vPositions

figure; plot(vNodePosition(1, :), vNodePosition(2, :), vNodePosition(1, [1, end]), vNodePosition(2, [1, end]));
