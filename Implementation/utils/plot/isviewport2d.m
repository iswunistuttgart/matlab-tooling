function [res, varargout] = isviewport2d(Axis)


%% Pre-process inputs
if nargin == 0
    Axis = gca;
end



%% Magic
% Get the local axis
haTarget = Axis;

% Get the view port
[dAzimut, dElevation] = view(haTarget);

% We need to this because the viewport is a ring of 360 degree ```view()``` does
% not care if the view is something like [0, 90] or [0, 450] (it's the freaking
% same for ```view()```...
dAzimut = rem(abs(dAzimut), 360);
dElevation = rem(abs(dElevation), 360);

% Generally, there are three kinds of 2D plots: x-y, y-z, and x-z each having
% their own set of [az el] combinations

% Looking down or up the z-axis
if dAzimut == 90 

elseif dAzimut == 270
% Y-Z plot
if dAzimut == 90 && dElevation == 0
    chType = 'y-z';
    bIsTwodimPlot = true;
% X-Z plot
elseif dAzimut == 0 && dElevation == 0
    chType = 'x-z';
    bIsTwodimPlot = true;
% X-Y plot
elseif dAzimut == 0 && dElevation == 90
    chType = 'x-y';
    bIsTwodimPlot = true;
% Something we don't understand thus 3D plot
else
    bIsTwodimPlot = false;
end



%% Assign output quantities
% Result is the result
res = bIsTwodimPlot;

% First optional output is the type i.e., 'x-y', 'y-z', or 'x-z'
if nargout > 1
    varargout{1} = chType;
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
