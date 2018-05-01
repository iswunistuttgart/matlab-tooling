classdef trial < handle & matlab.mixin.Heterogeneous
    % TRIAL An experimental trial object containing information on all files
    
    
    %% PUBLIC PROPERTIES
    properties
        
        % Name of the trial
        Name
        
        % Corresponding parent session object for the trial
        Session@exps.session
        
    end
    
    
    %% PUBLIC DEPENDENT PROPERTIES
    properties ( Dependent )
        
        % Path to the trial's folder
        Path
        
        % Config of the project
        Config
        
        % Path to the config file
        ConfigPath
        
        % All images of this experiment
        Image
        
        % All videos of this experiment
        Video
        
        % All media files of this experiment i.e., images and videos
        Media
        
        % Path to the media files
        MediaPath
        
        % Path to the scope file
        ScopePath
        
        % Path to the Input file
        InputPath
        
        % Flag if there is a config file of this project
        HasConfig
        
        % Flag if there are images
        HasImage
        
        % Flag if there are videos
        HasVideo
        
        % Flag if there is media or not
        HasMedia
        
        % Flag if there is a scope file or not
        HasScope
        
        % Flag if there is an input file or not
        HasInput
        
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
        
        % Name of the media folder
        MediaFolder = 'media'
        
        % Extension of images to find automatically
        ImageExtensions = {'cr2', 'png', 'jpeg', 'jpg', 'tif', 'tiff'}
        
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
            %% TRIAL creates a new trial object
            
            
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
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new project
            
            
            try
                % If the trial folder does not exist, create it
                if ~this.Exists
                    % Create this trials's folder
                    mkdir(this.Path);
                end
                
                % Create the 'media' directory
                if 0 == exist(this.MediaPath, 'dir')
                    mkdir(this.MediaPath);
                end
                
                % Here, we should copy all the files that are assigned to this
                % new trial to the target trial's folder (i.e., media, scope,
                % etc.)
            catch me
%                 % Delete the directory i.e., 'cleanup'
%                 rmdir(this.Path, 's');
                
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function c = get.Config(this)
            %% GET.CONFIG gets the config
            
            
            % If there is a config file...
            if this.HasConfig
                % Load it
                c = load(this.ConfigPath);
            % No config file exists
            else
                % Default to an empty structure
                c = struct();
            end
            
        end
        
        
        function p = get.Path(this)
            %% GET.PATH creates the path for this project's session's folder name
            
            
            p = fullfile(this.Session, exps.manager.valid_name(this.Name));
            
        end
        
        
        function p = get.InputPath(this)
            %% GET.INPUTPATH returns the path to the input file
            
            
            p = fullfile(this, sprintf('%s.nc', this.InputName));
            
        end
        
        
        function p = get.ScopePath(this)
            %% GET.SCOPEPATH returns the path to the scope file
            
            
            p = fullfile(this, sprintf('%s.csv', this.ScopeName));
            
        end
        
        
        function p = get.MediaPath(this)
            %% GET.MEDIAPATH returns the path to the media directory
            
            
            p = fullfile(this, this.MediaFolder);
            
        end
        
        
        function m = get.Media(this)
            %% GET.MEDIA returns all media of this project
            
            
            % Just return the scan of the directory
            m = dir(fullfile(this, this.MediaFolder));
            % Remove top-level directories
            m(ismember({m.name}, {'.', '..'})) = [];
            
        end
        
        
        function im = get.Image(this)
            %% GET.IMAGE returns all images of this experiment
            
            
            % Pass through to the media filtering function
            im = this.filter_media(this.ImageExtensions);
            
        end
        
        
        function vi = get.Video(this)
            %% GET.VIDEO returns all videos of this experiment
            
            
            % Pass through to the media filtering function
            vi = this.filter_media(this.VideoExtensions);
            
        end
        
        
        function f = get.HasInput(this)
            %% GET.HASINPUT flags if there is an input file or not
            
            
            f = 2 == exist(this.InputPath, 'file');
            
        end
        
        
        function f = get.HasScope(this)
            %% GET.HASSCOPE flags if there is a scope file or not
            
            
            f = 2 == exist(this.ScopePath, 'file');
            
        end
        
        
        function f = get.HasMedia(this)
            %% GET.HASMEDIA flags if there is media files or not
            
            
            f = 0 ~= numel(this.Media);
            
        end
        
        
        function f = get.HasImage(this)
            %% GET.HASIMAgE flags if there is image files or not
            
            
            f = 0 ~= numel(this.Image);
            
        end
        
        
        function f = get.HasVideo(this)
            %% GET.HASVIDEO flags if there is videos files or not
            
            
            f = 0 ~= numel(this.Video);
            
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
    
    
    
    %% SETTERS
    methods
        
        function set.Config(this, c)
            %% SET.CONFIG sets the config for this object
            
            
            % Validate arguments
            try
                validateattributes(c, {'struct'}, {}, mfilename, 'Config');
            catch me
                throwAsCaller(me);
            end
            
            % And save the config
            save(this.ConfigPath, '-struct', 'c'); %#ok<MCSUP>
            
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
        
        
        function flag = isequal(this, that)
            %% ISEQUAL compares THIS and THAT to be the same project
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function flag = isequaln(this, that)
            %% ISEQUALN compares THIS and THAT to be the same project
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function flag = eq(this, that)
            %% EQ compares if two PROJECT objects are the same
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function flag = neq(this, that)
            %% NEQ compares if two PROJECT objects are not the same
            
            
            flag = ~strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function c = char(this)
            %% CHAR convers this object to a char
            
            
            % Allow multiple arguments to be passed
            if numel(this) > 1
                c = {this.Name};
            % Single argument passed, so just get its name
            else
                c = this.Name;
            end
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function fil = filter_media(this, exts)
            %% FILTER_MEDIA filters the media by the given extension filter
            
            
            % Get all media
            m = this.Media;
            
            % Build the regexp
            chRegexp = sprintf('\\.(%s)$', strjoin(exts, '|'));
            
            % Then filter
            fil = m(~cellfun(@isempty, regexpi({m.name}, chRegexp)));
            
        end
        
    end
    
end

