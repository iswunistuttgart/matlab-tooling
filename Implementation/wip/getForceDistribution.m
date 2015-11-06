function [distribution, varargout] = getForceDistribution(Wrench, StructureMatrix, ForceLimits, varargin)
% GETFORCEDISTRIBUTION Determines a valid cable force distribution
% 
%   DISTRIBUTION = GETFORCEDISTRIBUTION(WRENCH, STRUCTUREMATRIX, FORCELIMITS)
%   
%   Inputs:
%   
%   WRENCH: Column vector of the external wrench consisting of [f_p, t_p]' that
%   shall be used for determination of the force distribution
% 
%   STRUCTUREMATRIX: 6xM matrix that represents the structure matrix at the
%   point of interest
% 
%   FORCELIMITS: 2-column matrix of force limits. Should be given as [f_min,
%   f_max], but must not be
%   
%   ALGORITHM: Choose from a list of available algorithms to determine the force
%   distribution for the options. The available algorithms are
%   'ClosedForm'
%   'AdvancedClosedForm'
%   
%   'WinchOrientations': Matrix of orientations for each winch w.r.t. the
%   global coordinate system. Every winch's orientation is stored in a
%   column where the first row is the orientation about x-axis, the second
%   about y-axis, and the third about z-axis. This means, WINCHORIENTATIONS
%   must be a matrix of 3xN values. The number of orientations, i.e., N,
%   must match the number of winches in WINCHPOSITIONS (i.e., its column
%   count) and the order must match the order winches in WINCHPOSITIONS
% 
%   'WinchPulleyRadius': Vector of pulley radius per winch given in meter
%   i.e., WINCHPULLEYRADIUS is a vector of 1xN values where N must match
%   the number of winches in WINCHPOSITIONS and the order must be the same,
%   too.
% 
%   Outputs:
% 
%   LENGTH: Length is a vector of size 1xN with the cable lengths
%   determined using either simple or advanced kinematics
% 
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2015-04-03
% Changelog:
%   2015-04-03: Initial release


%------------- BEGIN CODE --------------

end