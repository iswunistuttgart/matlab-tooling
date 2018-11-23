function rgb = cmyk2rgb(cmyk)
%% CMYK2RGB convert CMYK colors to RGB colors
%
%   Inputs:
%
%   CMYK                Nx4 array of corresponding CMYK values
%
%   Outputs:
%
%   RGB                 Nx3 array of RGB values.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% See: http://mooring.ucsd.edu/software/matlab/doc/toolbox/graphics/color/CMYK2RGB.html
% Date: 2018-11-23
% Changelog:
%   2018-11-23
%       * Initial release



%% Validate arguments

% CMYK2RGB(CMYK)
narginchk(1, 1);

% CMYK2RGB(CMYK)
% RGB = CMYK2RGB(CMYK);
nargoutchk(0, 1);

% Validate
validateattributes(cmyk, {'numeric'}, {'nonempty', 'ncols', 4, 'finite', 'nonnegative', '<=', 100}, mfilename, 'cmyk');



%% Conversion

% Check if input was uint8
lonorm = any(cmyk > 1);

% Get class of original input data
ccmyk = class(cmyk);

% Convert to doubles
cmyk = double(cmyk);

% Normalize CMYK to [0, 1]
if lonorm
   cmyk = cmyk/100;
end

% Conversion
rgb = ( 1 - cmyk(:,[1,2,3]) ) .* ( 1 - cmyk(:,4) );

% Typecast back into the original data type
rgb = cast(rgb, ccmyk);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
