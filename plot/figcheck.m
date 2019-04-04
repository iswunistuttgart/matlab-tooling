function [fg,args,nargs] = figcheck(varargin)
%% FIGCHECK Process figure objects from input list
% 
%   [FG, ARGS, NARGS] = FIGCHECK(ARG1,ARG2,...) looks for Figures provided in
%   the input arguments. It first checks if ARG1 is a Figure. If so, it is
%   removed from the list in ARGS and the count in NARGS. FIGCHECK then checks
%   the arguments for Name, Value pairs with the name 'Parent'. If a graphics
%   object is found following the last occurance of 'Parent', then all 'Parent',
%   Value pairs are removed from the list in ARGS and the count in NARGS. ARG1
%   (if it is a Figure), or the value following the last occurance of 'Parent',
%   is returned in FG. Double handles to graphics objects are converted to
%   graphics objects. If FG is determined to be a handle to a deleted graphics
%   object, an error is thrown.
%
%   See also:
%   AXESCHECK



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2019-02-28
% Changelog:
%   2019-02-28
%       * Initial release



%% Code
args = varargin;
nargs = nargin;
fg = [];

% Check for either a scalar numeric Figure handle, or any size array of Figures.
% 'isgraphics' will catch numeric graphics handles, but will not catch
% deleted graphics handles, so we need to check for both separately.
if (nargs > 0) && ...
        ( ( isnumeric(args{1}) && isscalar(args{1}) && isgraphics(args{1}, 'Figure') ) ...
          || isa(args{1},'matlab.ui.Figure') ...
        )
  fg = handle(args{1});
  args = args(2:end);
  nargs = nargs-1;
end

if nargs > 0
  % Detect 'Parent' or "Parent" (case insensitive).
  inds = find(cellfun(@(x) (isStringScalar(x) || ischar(x)) && strcmpi('parent', x), args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    
    % Check for either a scalar numeric handle, or any size array of graphics
    % objects. If the argument is passed using the 'Parent' P/V pair, then we
    % will catch any graphics handle(s), and not just Figures.
    if nargs >= pind && ...
            ( (isnumeric(args{pind}) && isscalar(args{pind}) && isgraphics(args{pind}) ) ...
              || isa(args{pind},'matlab.ui.Root') ...
            )
      fg = handle(args{pind});
      args(inds) = [];
      nargs = length(args);
      
    end
    
  end
  
end

% Make sure that the graphics handle found is a scalar handle, and not an
% empty graphics array or non-scalar graphics array.
if (nargs < nargin) && ~isscalar(fg)
  throwAsCaller(MException(message('MATLAB:graphics:figcheck:NonScalarHandle')));
end

% Throw an error if a deleted graphics handle is detected.
if ~isempty(fg) && ~isvalid(fg)
  % It is possible for a non-Figure graphics object to get through the code
  % above if passed as a Name/Value pair. Throw a different error message for
  % Figure vs. other graphics objects.
  if isa(fg,'matlab.ui.Fiure')
    throwAsCaller(MException(message('MATLAB:graphics:figcheck:DeletedFigure')));
  else
    throwAsCaller(MException(message('MATLAB:graphics:figcheck:DeletedObject')));
  end
  
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
