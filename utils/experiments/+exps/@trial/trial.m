classdef trial < handle & matlab.mixin.Heterogeneous
    % TRIAL An experimental trial object containing information on all files
    
    
    properties
        
        % Name of the trial
        Name
        
        % All images of this experiment
        Images
        
        % All videos of this experiment
        Videos
        
        % All media files of this experiment i.e., images and videos
        Media
        
        % Path to the scope file
        Scope
        
        % Path to the Input file
        Input
        
    end
    
    
    properties ( Dependent )
        
        % Path to the trial's folder
        Path
        
        % Flag whether the trial exist or not. True if the folder path does
        % exist
        Exists
        
        % Flag if trial is new or not. True if the folder path does not exist
        IsNew
        
        % Project that this trial corresponds to
        Project
        
    end
    
    
    properties ( SetAccess = immutable )
        
        % Corresponding parent session object for the trial
        Session@exps.session
        
    end
    
    
    properties ( Constant , Hidden )
        
        ImageExtensions = {'cr2', 'png', 'jpeg', 'jpg', 'tiff'}
        
        VideoExtensions = {'mp4', 'mov', 'mpg', 'mpeg', 'mkv'}
        
        ScopeName = 'scope'
        
        InputName = 'input'
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = trial(name, sess)
            
            
            % Validate arguments
            try
                narginchk(2, 2);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
                validateattributes(sess, {'exps.session'}, {'nonempty'}, mfilename, 'sess');
            catch me
                throwAsCaller(me);
            end
            
            % Assign the name
            this.Name = name;
            
            % Assign the parent session
            this.Session = sess;
            
            % Get all media files
            this.Media = dir(fullfile(this.Path, 'media'));
            % Remove any folders from the content of the trials 'media'
            % directory
            this.Media([this.Media.isdir]) = [];
            
            % Grab all images from the array of image files
            this.Images = this.Media(~cellfun(@isempty, regexp({this.Media.name}, sprintf('.*%s.$', strjoin(this.ImageExtensions, '|')))));
            % If we found images, sort the naturally
            if ~isempty(this.Images)
                [~, idxSorted] = strnatsort({this.Images.name});
                this.Images = this.Images(idxSorted);
            end
            
            % Grab all videos from the array of media files
            this.Videos = this.Media(~cellfun(@isempty, regexp({this.Media.name}, sprintf('.*%s.$', strjoin(this.VideoExtensions, '|')))));
            % If we found videos, sort the naturally
            if ~isempty(this.Videos)
                [~, idxSorted] = strnatsort({this.Videos.name});
                this.Videos = this.Videos(idxSorted);
            end
            
            % Build the path to the scope file
            chScopePath = fullfile(this.Path, sprintf('%s.csv', this.ScopeName));
            % But only assign it if the file exists
            if 2 == exist(chScopePath, 'file')
                this.Scope = dir(chScopePath);
            end
            
            % Build the path to the input file
            chInputPath = fullfile(this.Path, sprintf('%s.tcsv', this.InputName));
            % If there is no '.TCSV' file, we will check for a '.NC' file
            if 2 ~= exist(chInputPath, 'file')
                chInputPath = fullfile(this.Path, sprintf('%s.nc', this.InputName));
            end
            % But only assign it if the file exists
            if 2 == exist(chInputPath, 'file')
                this.Input = dir(chInputPath);
            end
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new project
            
            
            try
                assert(this.IsNew, 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:MATLAB:TRIAL:TrialNotNew', 'Cannot create trial folder: trial is not new.');
            catch me
                throwAsCaller(me);
            end
            
            
            try
                % Create this trials's folder
                mkdir(this.Path);
                
                % Create the 'media' directory
                mkdir(fullfile(this.Path, 'media'));
                
                % Here, we should copy all the files that are assigned to this
                % new trial to the target trial's folder (i.e., media, scope,
                % etc.)
            catch me
                % Delete the directory i.e., 'cleanup'
                rmdir(this.Path, 's');
                
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function p = get.Path(this)
            %% GET.PATH creates the path for this project's session's folder name
            
            
            p = fullfile(this.Session.Path, exps.manager.valid_name(this.Name));
            
        end
        
        
        function flag = get.Exists(this)
            %% GET.EXISTS flags if the experimental session exists or not
            
            
            flag = 7 == exist(this.Path, 'dir');
            
        end
        
        
        function flag = get.IsNew(this)
            %% GET.ISNEW flags if the experimental session is new or not
            
            
            flag = ~this.Exists;
            
        end
        
        
        function p = get.Project(this)
            %% GET.PROJECT gets the trials' project object
            
            
            p = this.Session.Project;
            
        end
        
    end
    
end

