function fig = gpf(h)
% GPF Get the given handles parent figure
%
%   FIG = GPF(H) gets the parent figure for the given handle H. Handle H can be
%   anything: an axes, line, chat, even a figure itself.
%
%   Inputs:
%
%   H:          Valid handle of any type.
%
%   Outputs:
%
%   FIG:        Handle to the parent figure to H or H itself, if it is already a
%       figure.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-20
% Changelog:
%   2016-09-20
%       * Comment formatting
%   2016-06-15
%       * Minor adjustments to error function message
%   2016-06-10
%       * Initial release



%% Argument defaults
% If no argument was given, use the current axis to determine the parent
if nargin < 1
    h = gca;
end



%% Assertion
assert(ishandle(h), 'Argument [h] must be a valid handle.');



%% Process inputs
% Assign the given handle to the figure to be assessed
fig = h;



%% MATLAB, do your thing!
% While the handle we got is not empty and its type does not compare positively
% to 'figure'
try
    while ~isempty(fig) && ~strcmpi('figure', get(fig, 'type'))
        % We will get the handle's parent
        fig = get(fig, 'parent');
    end
catch me
    me = addCause(me, MException('PHILIPPTEMPEL:MATLAB_TOOLING:GPF:ErrorFetchingParent', 'Unknown error occured trying to fetch the handle''s parent figure'));
    
    throwAsCaller(me);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
