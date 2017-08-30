function bSuccess = pack_files_and_dependencies( files, folder, bGenerateMatlabDepList )
%PACKFILESANDDEPENDENCIES(files, folder) identifies the dependencies of the files given in 'files' 
%and copies the files with all dependencies in one folder. If 'bGenerateMatlabDepList' is set to true,
%a file 'MatlabDependencies.txt' will be generated which provides information about the required 
%MALTAB-Plugins to succesfully run the 'files'.

%
% Input:    files                   (Cell-String) files to check the dependencies for. If files is empty
%                                    all .m-Files of the current directory are selected.
%           folder                  (String) folder name. If the folder already exists the user has 
%                                   to confirm manually if folder contents may be overwritten.
%           bGenerateMatlabDepList  (bool) true=> 'MatlabDependencies.txt' will be generated
%
% Output:   bSuccess                true, if the files and dependencies were copied to the given 
%                                   folder successfully, false otherwise.
%
% What this function does not do:
% - Copying data like .mat or .txt files to the chosen directory -> todo: scan source code of files
%   for keywords like load(), textread() or fopen(), this has still to be done manually.
%
% Example: packFilesAndDependencies({}, 'Folder', true); % packs files with depending files in
%                                                        % folder 'Folder' and adds a MATLAB 
%                                                        % dependency report.

%% File information
% Author: Christoph Hinze<christoph.hinze@isw.uni-stuttgart.de>
% Date: 2015-11-19
% Changelog:
%   2015-11-19
%       * Initial release

sDependenciesFile = 'MatlabDependencies.txt';
bSuccess = true;
bFolderExists = false;
if exist(folder, 'dir')==7
   bFolderExists = true;
   yn = '';
   while (strcmpi(yn, 'y')~=1 && strcmpi(yn, 'n')~=1)
       yn = input('The specified folder already exists. Writing in this folder nevertheless and overwrite contents with the same name?(y/n)', 's');
   end %while
else
    %create folder:
    mkdir(folder);
end

if (bFolderExists && strcmpi(yn, 'y')==1)||~bFolderExists
    bOverwrite = true;
else        
    bOverwrite = false;
end

% check if files exist:
if(isempty(files))
    files_temp = ls('*.m');
    for i=1:size(files_temp,1)
        files{i} = strtrim(files_temp(i,:));
    end
elseif(ischar(files))
    %if only one string is given -> convert to cell array for further processing
    files = {files};
end

for i=1:length(files)
   if exist(files{i},  'file')~=2
      warning('File %s does not exist. Resuming without this.', files{i})
      files(i) = [];
   end
end

if(isempty(files))
   warning('There were no valid files for processing. Aborted.')
   bSuccess = false;
elseif ~bOverwrite
    warning('The Folder already exists and this program is not allowed to overwrite possible contents. Aborted.')
   bSuccess = false;    
else
    %if there are files to process:
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(files);
    for i=1:length(fList)
       if ~copyfile(fList{i}, folder, 'f')
          warning('File %s could not be copied.', fList{i}) 
          bSuccess = false;
       end
    end
    
    if (nargin>=3 && bGenerateMatlabDepList)
       fid = fopen( [folder, '/', sDependenciesFile], 'w');
       if fid>0
           fprintf(fid, 'MATLAB-dependencies to run this folder:\n-----------------------------\n\n');
           for i=1:length(pList)
            fprintf(fid, '%s\n\n',  evalc('disp(pList(i))') );
           end
           fclose(fid);
       else
           warning('Error creating/opening the Dependencise file in %s.', [folder, '/', sDependenciesFile])
       end
    end
end


end

