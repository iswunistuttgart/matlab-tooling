function copy_plotstyles()
% COPY_PLOTSTYLES copies the ISW US plot styles to PREFDIR()



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-16
% Changelog:
%   2018-05-16
%       * Initial release



%% Copy plotstyles

% Path to the `.touch` file
chTouch_Path = fullfile(fileparts(mfilename('fullpath')), '..', 'plotstyles', '.touch');
% Path to the `.installed` file
chInstall_Path = fullfile(fileparts(mfilename('fullpath')), '..', 'plotstyles', '.installed');

% By default we will copy the files
loCopy = true;

% Check if the `.touch` file exists
if 2 == exist(chTouch_Path, 'file')
    % Read the touch file
    ceTouch = strip(fileread(chTouch_Path));
    
    % Convert it to a datetime object
    dtTouch = datetime(ceTouch, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:SSZ', 'TimeZone', 'Europe/Zurich');

    % Check both the the `.install` and `.touch` file exists
    if 2 == exist(chInstall_Path, 'file')
        % Read the install file
        ceInstall = strip(fileread(chInstall_Path));
        
        % Try to read the datetime string as a datetime object
        try
            % Ensure we have content in the file
            assert(~isempty(ceInstall), 'PHILIPPTEMPEL:MATLABTOOLING:STARTUP:COPY_PLOTSTYLES:EmptyInstallDate', 'Installation date cannot be empty. Defaulting to NOW');
            
            % Convert the file content to a datetime object
            dtInstall = datetime(ceInstall, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:SSZ', 'TimeZone', 'Europe/Zurich');
            
            % Install only necessary if the files have been touch after we had last
            % installed them
            loCopy = dtInstall < dtTouch;
            
            % And default to installing now
            dtInstall = datetime('now', 'TimeZone', 'Europe/Zurich');
        catch me
            % Failure, so display warning to the user
            warning(me.identifier, '%s', me.message);
            % And default to installing now
            dtInstall = datetime('now', 'TimeZone', 'Europe/Zurich');
            
            % Mark for copy
            loCopy = true;
        end
    % No install file exists, so install NOW
    else
        % Install now
        dtInstall = datetime('now', 'TimeZone', 'Europe/Zurich');
        
        % And mark for installation
        loCopy = true;
    end
    
end

% If we need to copy the files as they have been changed
if loCopy
    try
        % First, copy all the files to where MATLAB will look for them
        copyfile(fullfile(fileparts(mfilename('fullpath')), '..', 'plotstyles', '*.txt'), fullfile(prefdir(0), 'ExportSetup'));
    
        % And then save the current installation date to a file
        dtInstall.Format = 'yyyy-MM-dd''T''HH:mm:SSZ';
        
        % Open file
        hFid = fopen(chInstall_Path, 'w');
        
        % Cleanup object to close file nicely on success and error
        coCleaner = onCleanup(@() fclose(hFid));
        
        % Write the content
        fprintf(hFid, '%s', dtInstall);
    catch me
        warning(me.identifier, '%s', me.message);
    end
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
