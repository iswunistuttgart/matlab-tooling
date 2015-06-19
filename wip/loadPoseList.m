function [poselist, varargout] = loadPoseList(Filename, varargin)
% LOADPOSELIST - Loads the specified pose list
%   Inverse kinematics means to determine the values for the joint
%   variables (in this case cable lengths) for a given endeffector pose.
%   This is quite a simple setup for cable-driven parallel robots because
%   the equation for the kinematic loop has to be solved, which is the sole
%   purpose of this method.
%   It can determine the cable lengths for any given robot configuration
%   (note that calculations will be done as if we were looking at a 3D/6DOF
%   cable robot following necessary conventions, so adjust your variables
%   accordingly). To determine the cable lengths, different algorithms may be
%   used (please see below for the 'ALGORITHM' option). Note that all cable
%   lengths will always be from the PulleyPosition to the platform, any free
%   cable length that you might have before the last pulley needs to be added by
%   you manually after running this method
% 
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS)
%   performs simple inverse kinematics with the cables running from a_i to
%   b_i for the given pose
%   
%   LENGTH = INVERSEKINEMATICS(POSE, PULLEYPOSITIONS, CABLEATTACHMENTS,
%   ALGORITHM) performs inverse kinematics according to the selected algorithm.
%   Implemented algorithms are
%       'Simple'            Standard straight-line model
%       'Pulley'            Pulley kinematics with pulley radius and rotation
%                           included
%       'CatenarySimple'    TO COME Using a catenary approach the cable length will be
%                           calculated assuming ideal cable entry points (i.e.,
%                           no rotation or radius of the pulleys.
%       'CatenaryPulley'    TO COME Most advanced algorithm to determine catenary cable
%                           line with the inclusion of pulleys that is rotation
%                           of the pulley and cable wrapping around the pulley.
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'PulleyOrientations',
%   mPulleyOrientations) performs non-standard inverse kinematics given the
%   specified pulley orientations.
%   
%   LENGTH = INVERSEKINEMATICS(POSE, ..., 'PulleyRadius', vPulleyRadius)
%   performs advanced inverse kinematics taking into account the specified
%   pulley radius.
% 
%   [LENGTH, CABLEVECTORS] = INVERSEKINEMATICS(...) also provides the
%   vectors of the cable directions from platform to attachment point given
%   in the global coordinate system
% 
%   [LENGTH, CABLEVECTORS, CABLEUNITVECTORS] = INVERSEKINEMATICS(...) also
%   provides the unit vectors for each cable which might come in handy at
%   times
%   
%   Inputs:
%   
%   POSE: The current robots pose given as a 12-column row vector that has
%   the [x, y, z] position in the first three entries and then follwing are
%   the entries of the rotation matrix such that the vector POSE looks
%   something like this
%   pose = [x, y, z, R11, R12, R13, R21, R22, R23, R31, R32, R33]
% 
%   PULLEYPOSITIONS: Matrix of pulley positions w.r.t. the world frame. Each
%   pulley has its own column and the rows are the x, y, and z-value,
%   respectively i.e., PULLEYPOSITIONS must be a matrix of 3xM values. The
%   number of pulleyes i.e., M, must match the number of cable attachment
%   points in CABLEATTACHMENTS (i.e., its column count) and the order must
%   mach the real linkage of pulley to cable attachment on the platform
% 
%   CABLEATTACHMENTS: Matrix of cable attachment points w.r.t. the
%   platforms coordinate system. Each attachment point has its own column
%   and the rows are the x, y, and z-value, respectively, i.e.,
%   CABLEATTACHMENTS must be a matrix of 3xM values. The number of cables
%   i.e., M, must match the number of pulleyes in PULLEYPOSITIONS (i.e., its
%   column count) and the order must match the real linkage of cable
%   attachment on the platform to pulley.
% 
%   USEADVANCED: Optional positional parameter argument that tells the
%   script to use advanced inverse kinematics algorithms to determining the
%   cable length. Must be a logical value i.e, true or false
%   
%   'PulleyOrientations': Matrix of orientations for each pulley w.r.t. the
%   global coordinate system. Every pulley's orientation is stored in a
%   column where the first row is the orientation about x-axis, the second
%   about y-axis, and the third about z-axis. This means, WINCHORIENTATIONS
%   must be a matrix of 3xM values. The number of orientations, i.e., M,
%   must match the number of pulleyes in PULLEYPOSITIONS (i.e., its column
%   count) and the order must match the order pulleyes in PULLEYPOSITIONS
% 
%   'PulleyRadius': Vector of pulley radius per pulley given in meter
%   i.e., WINCHPULLEYRADIUS is a vector of 1xM values where M must match
%   the number of pulleyes in PULLEYPOSITIONS and the order must be the same,
%   too.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xM with the cable lengths
%   determined using either simple or advanced kinematics
%
%   CABLEVECTOR: Vectors of each cable from attachment point to (corrected)
%   pulley point
%   
%   CABLEUNITVECTOR: Normalized vector for each cable from attachment point
%   to its (corrected) pulley point
% 
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-06-18
% Changelog:
%   2015-06-18
%       * Initial release



%% Create an input parser
% Input parse to easily parse input arguments
ip = inputParser;

%%% This fills in the parameters for the function
% We need the filename
valFcn_Filename = @(x) validateattributes(x, {'char'}, {'nonempty', }, mfilename, 'Filename');
addRequired(ip, 'Filename', valFcn_Filename);

% Allow the user to provide the time range in case it isn't provided in the file
valFcn_Time = @(x) validateattributes(x, {'numeric'}, {'vector', 'nonempty', 'increasing', 'nonnegative'}, mfilename, 'Time');
addParameter(ip, 'Time', [], valFcn_Time);

% Configuratio nfor the input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
parse(ip, Filename, varargin{:});



%% Parse variables so we can use them natively
chFilename = ip.Results.Filename;
vTime = ip.Results.Time;

%% Internal variables
ceSupportedExtensions = {'.csv', '.txt'};
ceExtractVariables    = {'time', 't', 'x', 'y', 'z', 'R_11', 'R_12', 'R_13', 'R_21', 'R_22', 'R_23', 'R_31', 'R_32', 'R_33'};


%% Do the magic
% Check for valid filetype ('.csv' or '.txt');
[chFilePath, chFileName, chFileExt] = fileparts(chFilename);
if isempty(chFilePath)
    chFilePath = pwd;
end

% This script allows for importing '.csv' and '.txt' files, so we will
% check for either one. But first, determine whether there's a file
% extension to filename
if isempty(chFileExt)
    for iExt = 1:numel(ceSupportedExtensions)
        if exist(fullfile([fileNameOrPath, ceSupportedExtensions{iExt}]), 'file')
            chFileExt = ceSupportedExtensions{iExt};
            
            break;
        end
    end
% The provided file has a file extension, so let's check that value
else
    % If the value of fileExt is not a member of the cell array
    % supportedExtensions it means we are having us an unsupported file
    % extension
    if isempty(find(ismember(ceSupportedExtensions, chFileExt), 1))
        throw(MException('PHILIPPTEMPEL:loadPoseList:invalidFileExtension', 'Unsupported file extension ''%s'' found. Please consider exporting as any of the following formats: %s', chFileExt, strjoin(ceSupportedExtensions, ', ')));
    end
end

chQualifiedFile = fullfile(chFilePath, [chFileName, chFileExt]);

% Load the file
[xLoaded, chDelimiterOut, nHeaderlinesOut] = importdata(chQualifiedFile);

% Loaded something with a header line
if isstruct(xLoaded)
    
    for iExtractVariable = 1:numel(ceExtractVariables)
        
    end
% Loaded anything but a csv file
else
    
end

assert(issize(xLoaded, [], 12) && exist('vTime', 'var'), 'PHILIPPTEMPEL:loadPoseList:noTimeInformationFound', 'Could not find any information about the time steps of the loaded pose list');

if ~issize(xLoaded, [], 12)
    
end

% Check we have enough data (12 columns + vTime OR 13 columns and no vTime)

% Process the input


%% Assign output quantities
poselist = zeros(1, 13);

end