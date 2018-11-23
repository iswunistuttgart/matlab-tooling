function cmyk = rgb2cmyk(rgb)
%% RGB2CMYK convert RGB colors to CMYK colors
%
%   Inputs:
%
%   RGB                 Nx3 array of RGB values.
%
%   Outputs:
%
%   CMYK                Nx4 array of corresponding CMYK values



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% See: http://mooring.ucsd.edu/software/matlab/doc/toolbox/graphics/color/rgb2cmyk.html
% Date: 2018-11-23
% Changelog:
%   2018-11-23
%       * Initial release



%% Validate arguments

% RGB2CMYK(RGB)
narginchk(1, 1);

% RGB2CMYK(RGB)
% CMYK = RGB2CMYK(RGB);
nargoutchk(0, 1);

% Validate
validateattributes(rgb, {'numeric'}, {'nonempty', 'ncols', 3, 'finite', 'nonnegative', '<=', 255}, mfilename, 'rgb');



%% Conversion

% Check if input was uint8
lonorm = any(rgb > 1);

% Get class of original input data
crgb = class(rgb);

% Convert to doubles
rgb = double(rgb);

% Normalize RGB to [0, 1]
if lonorm
   rgb = rgb/255;
end

% Init CMYK array
cmyk = zeros(size(rgb, 1), 4);

% Get kern/black color
cmyk(:,4) = min(1 - rgb, [], 2);

% Get cyan, magneta, and yellow
cmyk(:,1:3) = (1 - rgb - cmyk(:,4))./ ( 1 - cmyk(:,4) );

% Typecast back into the original data type
cmyk = cast(round(cmyk*100), crgb);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
