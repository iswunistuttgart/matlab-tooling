function Cyclic = cycliccell(Cell, Count, varargin)
% CYCLICCELL repeats a cell as a cycle
%
%   CYCLIC = CYCLICCELL(CELL, COUNT) repeats cell CELL COUNT times.
%
%   Inputs:
%
%   CELL:   Cell array or array of cell arrays to be repeated. Cells will be
%   appended vertically i.e., repeated along the columsn.
%
%   COUNT:  Positive integer how many times CELL shall be repeated in the
%   returned array.
%
%   Outputs:
%
%   CYCLIC: Array of cyclically repeated cells concatenated along the rows.
%
%   See:
%       repmat



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-09-07
% Changelog:
%   2016-09-07
%       * Fix bug with cycled cells not being created correctly in case a
%       multi-dim cell array was given
%   2016-08-02
%       * Initial release



%% Define the input parser
ip = inputParser;

% Require: Axis. Must be 'x' or 'y'
valFcn_Cell = @(x) validateattributes(x, {'cell', 'numeric'}, {}, mfilename, 'Cell');
addRequired(ip, 'Cell', valFcn_Cell);

% Allow the plot to have user-defined spec
valFcn_Count = @(x) validateattributes(x, {'double'}, {'scalar', 'nonempty', 'finite', 'positive'}, mfilename, 'Count');
addRequired(ip, 'Count', valFcn_Count);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    args = [{Cell}, {Count}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(MException(me.identifier, me.message));
end



%% Parse arguments
% Input cell array
ceInput = asrow(ip.Results.Cell);
% Repetition count
nCount = ip.Results.Count;

% Default return value
ceCycled = cell(0);



%% Do the magic
% If its not already a multi-dim cell arrray, we will make it one
if ~isempty(ceInput)
    if ~iscell(ceInput{1})
        ceInput = {ceInput};
    end
    
    % Repeat the cell array n times horizontally
    ceCycled = repmat(ceInput, 1, nCount);
    ceCycled = ceCycled(1:nCount);
end



%% Assign outputs
Cyclic = ceCycled;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
