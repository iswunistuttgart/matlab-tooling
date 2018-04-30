classdef trial < handle & matlab.mixin.Heterogeneous
    % TRIAL An experimental trial object containing information on all files
    
    
    %% PUBLIC PROPERTIES
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
        
        % Corresponding parent session object for the trial
        Session@exps.session
        
    end
    
    
    %% PUBLIC DEPENDENT PROPERTIES
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
    
    
    %% HIDDEN PROPERTIES
    properties ( Constant , Hidden )
        
        % Extension of images to find automatically
        ImageExtensions = {'cr2', 'png', 'jpeg', 'jpg', 'tiff'}
        
        % Extensions of videos to find automatically
        VideoExtensions = {'mp4', 'mov', 'mpg', 'mpeg', 'mkv'}
        
        % Name of the file containing the scope data (i.e., recorded data)
        ScopeName = 'scope'
        
        % Name of the file providing the input to the experiment
        InputName = 'input'
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = trial(name, varargin)
            
            
            % Validate arguments
            try
                % TRIAL(NAME)
                % TRIAL(NAME, 'Name', 'Value', ...);
                narginchk(1, Inf);
                
                % TRIAL(NAME, ...)
                % T = TRIAL(NAME, ...)
                nargoutchk(0, 1);
                
                % Validate the name
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
            catch me
                throwAsCaller(me);
            end
            
            % Assign the name
            this.Name = name;
            
            % Assign variable list of arguments
            for iArg = 1:2:numel(varargin)
                this.(varargin{iArg}) = varargin{iArg + 1};
            end
            
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
            
            
            p = fullfile(this.Session, exps.manager.valid_name(this.Name));
            
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
    
    
    
    %% OVERRIDERS
    methods
        
        function p = path(this)
            %% PATH returns the path of this trial
            
            
            p = this.Path;
            
        end
        
        
        function ff = fullfile(this, varargin)
            %% FULLFILE returns the full filepath of this trial
            
            
            ff = fullfile(this.Path, varargin{:});
            
        end
        
    end
    
end

