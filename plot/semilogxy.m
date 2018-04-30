function varargout = semilogxy(varargin)
% SEMILOGXY plots a 3D plot with logarithmic X- and Y-axis
%
%   SEMILOGXY(X, Y, Z), where X, Y and Z are three vectors of the same length,
%   plots a line in 3-space through the points whose coordinates are the
%   elements of X, Y, and Z.
%  
%   SEMILOGXY(X,Y,Z), where X, Y and Z are three matrices of the same size,
%   plots several lines obtained from the columns of X, Y and Z.
%  
%   Various line types, plot symbols and colors may be obtained with
%   SEMILOGXY(X,Y,Z,s) where s is a 1, 2 or 3 character string made from the
%   characters listed under the PLOT command.
%  
%   SEMILOGXY(x1,y1,z1,s1,x2,y2,z2,s2,x3,y3,z3,s3,...) combines the plots
%   defined by the (x,y,z,s) fourtuples, where the x's, y's and z's are vectors
%   or matrices and the s's are strings.
%
%   SEMILOGXY returns a column vector of handles to lineseries objects, one
%   handle per line. The X,Y,Z triples, or X,Y,Z,S quads, can be followed by
%   parameter/value pairs to specify additional properties of the lines.
%
%   See also: PLOT3, PLOT, LINE, AXIS, VIEW, MATH, SURF



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-20
% Changelog:
%   2016-09-20
%       * Add help comment



%% Code magic
% Pass drawing on to plot3
hp3Drawing = plot3(varargin{:});

% Get the target axes
haTarget = hp3Drawing(1).Parent;

% Set the XScale and YScale properties to 'log'
set(haTarget, 'XScale', 'log', 'YScale', 'log');



%% Assign output quantities
if nargout > 0
    varargout{1} = hp3Drawing;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
