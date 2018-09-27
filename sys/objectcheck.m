function [obj, args, nargs] = objectcheck(oc, varargin)
% OBJECTCHECK checks for an object of a calling class in the list of arguments
%
%   Inputs:
%
%   OC                  String of class of object to find.
%
%   Outputs:
%
%   OBJ                 Description of argument OBJ
%
%   ARGS                Description of argument ARGS
%
%   NARGS               Description of argument NARGS



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-09-27
% Changelog:
%   2018-09-27
%       * Initial release



%% Valdiate arguments
try
  % OBJECTCHECK(O, ARG)
  % OBJECTCHECK(O, ARG1, ...)
  narginchk(2, Inf);
  % OBJECTCHECK(...)
  % OBJ = OBJECTCHECK(...)
  % [OBJ, ARGS] = OBJECTCHECK(...)
  % [OBJ, ARGS, NARGS] = OBJECTCHECK(...)
  nargoutchk(0, 3);
catch me
  throwAsCaller(me);
end



%% Do your code magic here

% Init output
args = varargin;
nargs = (nargin - 1);
obj = [];

if nargs > 0 && ( isscalar(args{1}) && isa(args{1}, oc) )
  obj = args{1};
  args = args(2:end);
  nargs = nargs - 1;
end

if nargs > 0
  inds = find(strcmpi('parent', args) );
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    
    % Check for either a scalar handle, or any size array of graphics objects.
    % If the argument is passed using the 'Parent' P/V pair, then we will
    % catch any graphics handle(s), and not just Axes.
    if nargs >= pind && ...
            ((isscalar(args{pind}) && isgraphics(args{pind})) ...
            || isa(args{pind},'matlab.graphics.Graphics'))
      ax = handle(args{pind});
      args(inds) = [];
      nargs = length(args);
    end
  end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
