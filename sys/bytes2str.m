function s = bytes2str(b, varargin)
% BYTES2STR turns the number of bytes into a human readable string
%
%   Inputs:
%
%   B                   MxN numeric array of bytes to translate.
%
%   Outputs:
%
%   S                   MxN char array representing bytes B in the lowest human
%                       readable scale.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-06
% Changelog:
%   2018-02-06
%       * Initial release



%% Define the input parser
ip = inputParser;

% Bytes: numeric; positive
valFcn_Bytes = @(x) validateattributes(x, {'numeric'}, {'positive', 'finite', 'nonnan', 'nonsparse'}, mfilename, 'Bytes');
addRequired(ip, 'Bytes', valFcn_Bytes);

% Format: char; non-empty
valFcn_Format = @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Format');
addParameter(ip, 'Format', '%.2f', valFcn_Format);

% Configuration of input parser
ip.KeepUnmatched = true;
ip.FunctionName = mfilename;

% Parse the provided inputs
try
    % BYTES2STR(B)
    % BYTES2STR(B, 'Name', 'Value', ...)
    narginchk(1, Inf);
    % BYTES2STR(B)
    % S = BYTES2STR(B)
    nargoutchk(0, 1);
    
    args = [{b}, varargin];
    
    parse(ip, args{:});
catch me
    throwAsCaller(me);
end



%% Parse IP results
% The vector of bytes to convert
vBytes = ip.Results.Bytes;
% The format to use for each byte
chFormat = ip.Results.Format;

% Run over each element of B and convert it
s = arrayfun(@(bb) in_parsebytes(bb, chFormat), vBytes, 'UniformOutput', false);



end


function s = in_parsebytes(b, fmt)

% Get the scaling factor
dScale = floor(log(b)./log(1024));

% Switch on that scale
switch dScale
    case 0
        s = [sprintf('%.0f', b) ' b'];
    case 1
        s = [sprintf(fmt, b./(1024)) ' kb'];
    case 2
        s = [sprintf(fmt, b./(1024^2)) ' Mb'];
    case 3
        s = [sprintf(fmt, b./(1024^3)) ' Gb'];
    case 4
        s = [sprintf(fmt, b./(1024^4)) ' Tb'];
    case -inf
        % Size occasionally returned as zero (eg some Java objects).
        s = 'Not Available';
    otherwise
       s = 'Over a petabyte!!!';
end

end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
