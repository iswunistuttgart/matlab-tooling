function [varargout] = plotRobot3d(Pose, WinchPositions, CableAttachments, varargin)
% PLOTROBOT3D Plot the robot in 3d view with the frame and the platform
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


%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

% Allow the pose to be a row vector of
% [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33];
valFcn_Pose = @(x) isrow(x) && numel(x) == 12;
% Allow the winch positions to be given as
% [a_1x, a_2x, ..., a_nx; ...
%  a_1y, a_2y, ..., a_ny; ...
%  a_1z, a_2z, ..., a_nz];
valFcn_WinchPositions = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(CableAttachments, 2);
% Allow the cable attachments to be given as
% [b_1x, b_2x, ..., b_nx; ...
%  b_1y, b_2y, ..., b_ny; ...
%  b_1z, b_2z, ..., b_nz];
valFcn_CableAttachmens = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(WinchPositions, 2);
% Allow the winch orientations to be given as
% [a_1, a_2, ..., a_3; ...
%  b_1, b_2, ..., b_3; ...
%  c_1, c_2, ..., c_3];
% for a rotation result of R_i = rotz(c_i)*roty(b_i)*rotx(a_i);
valFcn_WinchOrientations = @(x) ismatrix(x) && size(x, 1) == 3 && size(x, 2) == size(CableAttachments, 2);
% Allow the winch pulley radius to only be a matrix of one radius per winch
valFcn_WinchPulleyRadius = @(x) isscalar(x) || ( isrow(x) && size(x, 2) == size(WinchPositions, 2) );

%%% This fills in the parameters for the function
% We need the current pose...
addRequired(ip, 'Pose', valFcn_Pose);
% We need the a_i's ...
addRequired(ip, 'WinchPositions', valFcn_WinchPositions);
% And we need the b_i's
addRequired(ip, 'CableAttachments', valFcn_CableAttachmens);
% Optional parameter to allow the figure handle to be given
addOptional(ip, 'Handle', false, @ishandle);
% Allow the pulleys to be toggled on or off
addParameter(ip, 'WithPulleys', false, @islogical);
% We might want to use the winch orientations (for plotting the pulleys as
% well)
addParameter(ip, 'WinchOrientations', zeros(3, size(WinchPositions, 2)), valFcn_WinchOrientations);
% We might want the pulley radius to be defined if we are plotting with
% pulleys
addParameter(ip, 'WinchPulleyRadius', zeros(1, size(WinchPositions, 2)), valFcn_WinchPulleyRadius);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = 'plotRobot3d';

% Parse the provided inputs
parse(ip, Pose, WinchPositions, CableAttachments, varargin{:});


%% Extract the input variables so we can use them locally
hFig = ip.Results.Handle;
vPose = ip.Results.Pose;
mWinchPositions = ip.Results.WinchPositions;
mCableAttachments = ip.Results.CableAttachments;
mWinchOrientations = ip.Results.WinchOrientations;
mWinchPulleyRadius = ip.Results.WinchPulleyRadius;
iNumberOfWires = size(mWinchPositions, 2);


%% Do the magic
% No handle to a figure?
if islogical(ip.Results.FigureHandle) && ~ip.Results.FigureHandle
    % Create our own figure handle
    hFig = figure();
else
    hFig = ip.Results.FigureHandle;
end
% Better viewport
view([-15, 16]);
hold on;

%%% First, plot the winch positions and its bounding box
for iUnit = 1:iNumberOfWires
    plot3(mWinchPositions(1, iUnit), mWinchPositions(2, iUnit), mWinchPositions(3, iUnit), 'Marker', '*');
end
% Plot the bounding box of the winches
[mWinchPositionsBoundingBox, mWinchPositionsBoundingBoxFaces] = boundingbox3(mWinchPositions(1, :), mWinchPositions(2, :), mWinchPositions(3, :));
patch('Vertices', mWinchPositionsBoundingBox', 'Faces', mWinchPositionsBoundingBoxFaces, 'FaceColor', 'none');

%%% Plot the robot frame (with rotation)

vPlatformPosition = reshape(vPose(1:3), 3, 1);
mPlatformOrientation = reshape(vPose(4:12), 3, 3)';
% Determine the global coordinates of the frame
mCableAttachmentsGlobal = zeros(3, iNumberOfWires);
for iUnit = 1:iNumberOfWires
    mCableAttachmentsGlobal(:, iUnit) = vPlatformPosition + mPlatformOrientation*mCableAttachments(:, iUnit);
end
[mCableAttachmentsGlobalBoundingBox, mCableAttachmentsGlobalBoundingBoxFaces] = boundingbox3(mCableAttachmentsGlobal(1, :), mCableAttachmentsGlobal(2, :), mCableAttachmentsGlobal(3, :));
patch('Vertices', mCableAttachmentsGlobalBoundingBox', 'Faces', mCableAttachmentsGlobalBoundingBoxFaces, 'FaceColor', 'b');





%% Assign output quantities
if nargout
    if nargout >= 1
        varargout{1} = hFig;
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original au
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
