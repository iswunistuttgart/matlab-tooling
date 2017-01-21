function focus_editor()
% FOCUS_EDITOR gives programmatic focus to the editor



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-01-05
% Changelog:
%   2017-01-05
%       * Rename variable `desktop` to `desk` so it won't interfer with built-in
%       function `DESKTOP`
%   2017-01-02
%       * Initial release



%% Do your code magic here

try
    % Matlab 7
    desk = com.mathworks.mde.desk.MLDesktop.getInstance;
    jEditor = desk.getGroupContainer('Editor').getTopLevelAncestor;
    % we get a com.mathworks.mde.desk.MLMultipleClientFrame object
catch
    % Matlab 6
    % Unfortunately, we can't get the Editor handle from the Desktop handle in Matlab 6:
    %desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;
 
    % So here's the workaround for Matlab 6:
    openDocs = com.mathworks.ide.editor.EditorApplication.getOpenDocuments;  % a java.util.Vector
    firstDoc = openDocs.elementAt(0);  % a com.mathworks.ide.editor.EditorViewContainer object
    jEditor = firstDoc.getParent.getParent.getParent;
    % we get a com.mathworks.mwt.MWTabPanel or com.mathworks.ide.desktop.DTContainer object
end

jEditor.show();


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
