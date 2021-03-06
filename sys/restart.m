%% RESTART executes a few functions to reset MATLAB workspace
%
%   Reset of the MATLAB workspace done more ressource friendly than a
%   ```clear('all')``` is.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-08-11
% Changelog:
%   2018-08-11
%       * Add file footer
%   2018-04-10
%       * Change function calls to parantheses syntax
%   2017-08-04
%       * Add help block and File Information section
%   2017-08-03
%       * Add closing of hidden windows and force closing all other windows



%% Code goes here

% Close all open file handles
fclose('all');

% Close all open windows
close('all');

% Hidden windows are not closed when closing open windows, so we need to
% explicitely close them
close('all', 'hidden');

% Windows with a modified DeleteFcn that might not have been closed until now
% need to be closed explicitely, too
close('all', 'force');

% Clear all variables
clear('variables');

% Global variables need to be removed, too, as they are not removed with a call
% to ```clear variables```
clear('global')

% Lastly, we will stop all timers that may still be running in the backgroudn
try
    stopalltimers
catch me
end

% For a clean start we will of course need a clean command window
clc

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original
% author as can be found in the header
% Your contribution towards improving this function will be acknowledged in
% the "Changes" section of the header
