classdef trial < handle ...
    & matlab.mixin.Heterogeneous ...
    & dynamicprops
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
    
    % Config of the trial
    Config
    
    % Path to the config file
    ConfigPath
    
    % Additional data of the trial
    Data
    
    % Path to the data file
    DataPath
    
    % Hierarchical path
    Hierarchy
    
    % Loaded scope data
    Scope
    
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
    
    % Number of media objects
    NMedia
    
    % Number of videos
    NVideo
    
    % Number of images
    NImage
    
    % Flag if there is a config file of this project
    HasConfig
    
    % Flag if there is a data file of this project
    HasData
    
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
    Project@exps.project
    
  end
  
  
  
  %% HIDDEN PROPERTIES
  properties ( Constant, Hidden )
    
    % Name of the media folder
    MediaFolder = 'media'
    
    % Extension of images to find automatically
    ImageExtensions = {'cr2', 'png', 'jpeg', 'jpg', 'tif', 'tiff'}
    
    % Extensions of videos to find automatically
    VideoExtensions = {'mp4', 'mov', 'mpg', 'mpeg', 'mkv'}
    
    % Name of the file containing configuration data
    ConfigName = 'config'
    
    % Name of the file containing the scope data (i.e., recorded data)
    ScopeName = 'scope'
    
    % Name of the file providing the input to the experiment
    InputName = 'input'
    
    % Name of file providing additional data from the experiment
    DataName = 'data';
    
  end
  
  
  %% PROTECTED PROPERTIES
  properties ( Access = protected )
    
    % Actual loaded config
    Config_ = struct();
    
    % Actual loaded data
    Data_ = struct();
    DataLoaded = false;
    
    % Actual scope data
    Scope_
    
  end
  
  
  %% STATIC METHODS
  methods ( Static )
    
%     function b = loadobj(a)
%       %% LOADOBJ
%       
%       
%       % Copy object
%       b = a;
%       
%       % Load config and data
%       b.Config = load_config(a);
%       b.Data = load_data(a);
%       
%     end
    
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
      
      % Load configuration
      this.Config = load_config(this);
      
      % Load data
      this.Data = load_data(this);
      
    end
    
    
    function varargout = create(this)
      %% CREATE creates the folder structure for a new project
      
      
      try
        % CREATE(THIS)
        narginchk(1, 1);
        
        % CREATE(THIS)
        % SUCCESS = CREATE(THIS)
        % [SUCCESS, MESSAGE] = CREATE(THIS)
        % [SUCCESS, MESSAGE, MESSAGEID] = CREATE(THIS)
        nargoutchk(0, 3);
        
        % Create this trials's folder
        [loSuccess, chMessage, chMessageId] = mkdir(this.Path);
        
        % Create the 'media' directory
        if 0 == exist(this.MediaPath, 'dir')
          mkdir(this.MediaPath);
        end
        
        % Here, we should copy all the files that are assigned to this
        % new trial to the target trial's folder (i.e., media, scope,
        % etc.)
        
        % Success logical
        if nargout > 0
          varargout{1} = loSuccess;
        end
        
        % Return message
        if nargout > 1
          varargout{2} = chMessage;
        end
        
        % Return message ID
        if nargout > 2
          varargout{3} = chMessageId;
        end
        
      catch me
%         % Delete the directory i.e., 'cleanup'
%         rmdir(this.Path, 's');
        
        throwAsCaller(me);
      end
      
    end
    
    
    function c = load_config(this)
      %% LOAD_CONFIG loads the project's config file
      
      
      % Load only if there is a config file
      if this.HasConfig
        % Load the file
        c = load(this.ConfigPath);
      % No config file exists
      else
        % so set an empty structure
        c = struct();
      end
      
    end
    
    
    function save_config(this)
      %% SAVE_CONFIG saves the project's config to a file
      
      
      % Continue only if the config really is a struct
      if isa(this.Config, 'struct')
        % Get the config
        c = this.Config;
        
        % Save the structure as separate variables
        try
          save(this.ConfigPath, '-struct', 'c');
        catch me
          warning(me.identifier, '%s', me.message);
        end
        
        % Clear memory
        clear('c');
      end
      
    end
    
    
    function c = load_data(this)
      %% LOAD_DATA loads the project's data file
      
      
      % Load only if there is a data file
      if this.HasData
        % Load the file
        c = load(this.DataPath);
      % No config file exists
      else
        % so set an empty structure
        c = struct();
      end
      
    end
    
    
    function save_data(this, varargin)
      %% SAVE_DATA Save additional data associated to this trial
      
      
      % Continue only if the data really is a struct
      if isa(this.Data, 'struct')
        % Get the data
        d = this.Data;
        
        % Save the structure as separate variables
        try
          save(this.DataPath, '-struct', 'd', varargin{:});
        catch me
          warning(me.identifier, '%s', me.message);
        end
        
        % Clear memory
        clear('d');
      end
      
    end
    
  end
  
  
  
  %% GETTERS
  methods
    
    function c = get.Config(this)
      %% GET.CONFIG gets the config
      
      
      c = this.Config_;
      
    end
    
    
    function d = get.Data(this)
      %% GET.DATA gets the data
      
      
      % If data has not been loaded but exists...
      if ~this.DataLoaded && this.HasData
        % Load it
        this.Data_ = load(this.DataPath);
      end
      
      % Flag that we have now at least once loaded data
      this.DataLoaded = true;
      
      % Return data
      d = this.Data_;
      
    end
    
    
    function f = get.HasConfig(this)
      %% GET.HASCONFIG flags if there is a config or not
      
      
      f = 2 == exist(this.ConfigPath, 'file');
      
    end
    
    
    function f = get.HasData(this)
      %% GET.HASDATA flags if there are data or not
      
      
      f = 2 == exist(this.DataPath, 'file');
      
    end
    
    
    function p = get.Hierarchy(this)
      %% GET.HIERARCHY hierarchy path of the project
      
      
      p = [{this.Name}, this.Session.Hierarchy];
      
    end
    
    
    function p = get.Path(this)
      %% GET.PATH creates the path for this project's session's folder name
      
      
      p = fullfile(this.Session, exps.manager.valid_name(this.Name));
      
    end
    
    
    function p = get.ConfigPath(this)
      %% GET.CONFIGPATH returns the path to the config file
      
      
      p = fullfile(this, sprintf('%s.mat', this.ConfigName));
      
    end
    
    
    function p = get.DataPath(this)
      %% GET.DATAPATH returns the path to the data file
      
      
      p = fullfile(this, sprintf('%s.mat', this.DataName));
      
    end
    
    
    function p = get.InputPath(this)
      %% GET.INPUTPATH returns the path to the input file
      
      
      p = fullfile(this, sprintf('%s.nc', this.InputName));
      
    end
    
    
    function p = get.ScopePath(this)
      %% GET.SCOPEPATH returns the path to the scope file
      
      
      % Check if a pre-compiled MAT file exists
      if 2 == exist(fullfile(this, sprintf('%s.mat', this.ScopeName)), 'file')
        p = fullfile(this, sprintf('%s.mat', this.ScopeName));
      else
        p = fullfile(this, sprintf('%s.csv', this.ScopeName));
      end
      
    end
    
    
    function p = get.MediaPath(this)
      %% GET.MEDIAPATH returns the path to the media directory
      
      
      p = fullfile(this, this.MediaFolder);
      
    end
    
    
    function s = get.Scope(this)
      %% GET.SCOPE Return scope data
      
      
      % Check if scope was already loaded
      if isempty(this.Scope_) && this.HasScope
      % Check if scope file is a MAT File
      [~, ~, ext] = fileparts(this.ScopePath);
      
      % .MAT file
      if strcmp('.mat', ext)
        % Load MAT file as MATFILE
        m = matfile(this.ScopePath);
        % Variables in the MAT file
        vars = whos(m);
        % Find the correct variable type
        idxScopes = find(arrayfun(@(f) strcmp(f.class, 'tcscope'), vars), 1, 'first');
        
        % Got some
        if ~isempty(idxScopes)
        % Load variable from the MAT file
        this.Scope_ = m.(vars(idxScopes(1)).name);
        end
      else
        % Load scope from CSV file
        this.Scope_ = csv2tcscope(this.ScopePath);
      end
      
      end
      
      % Return cached scope
      s = this.Scope_;
      
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
      im = filter_media(this, this.ImageExtensions);
      
    end
    
    
    function vi = get.Video(this)
      %% GET.VIDEO returns all videos of this experiment
      
      
      % Pass through to the media filtering function
      vi = filter_media(this, this.VideoExtensions);
      
    end
    
    
    function n = get.NMedia(this)
      %% GET.NMEDIA counts the number of media objects of this trial
      
      
      n = numel(this.Media);
      
    end
    
    
    function n = get.NVideo(this)
      %% GET.NVIDEO counts the number of videos of this trial
      
      
      n = numel(this.Video);
      
    end
    
    
    function n = get.NImage(this)
      %% GET.NIMAGE counts the number of images of this trial
      
      
      n = numel(this.Image);
      
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
      
      
      f = 0 ~= this.NMedia;
      
    end
    
    
    function f = get.HasImage(this)
      %% GET.HASIMAgE flags if there is image files or not
      
      
      f = 0 ~= this.NImage;
      
    end
    
    
    function f = get.HasVideo(this)
      %% GET.HASVIDEO flags if there is videos files or not
      
      
      f = 0 ~= this.NVideo;
      
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
      
      % Set validated property
      this.Config_ = c;
      
    end
    
    
    function set.Data(this, d)
      %% SET.DATA sets the Data for this object
      
      
      % Validate arguments
      try
        validateattributes(d, {'struct'}, {}, mfilename, 'Data');
      catch me
        throwAsCaller(me);
      end
      
      % Set validated property
      this.Data_ = d;
      
    end
    
  end
  
  
  
  %% OVERRIDERS
  methods
    
    function s = find(this, name)
      %% FIND a trial amongst trials
      
      
      try
        % Find matching names
        idxMatches = ismember({this.Name}, name);
        
        % Make sure we found any project
        assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found because it does not exist or names are too ambigious.');
        
        % And return the data
        s = this(idxMatches);
      catch me
        % No match, so let's suggest projects based on their string
        % distance
        pclose = exps.manager.closest(this, name);
        
        % Found similarly sounding trials?
        if ~isempty(pclose)
          throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found. Did you maybe mean one of the following trials?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
        else
          throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found. Make sure there is no typo in the name and that the trial exists.'), me));
        end
      end
      
    end
    
    
    function p = path(this)
      %% PATH returns the path of this trial
      
      
      p = this.Path;
      
    end
    
    
    function varargout = mkdir(this)
      %% MKDIR creates the directory for this experimental trial
      
      
      [varargout{1:nargout}] = create(this);
      
    end
    
    
    function ff = fullfile(this, varargin)
      %% FULLFILE returns the full filepath of this trial
      
      
      ff = fullfile(this.Path, varargin{:});
      
    end
    
    
    function flag = isequal(this, that)
      %% ISEQUAL compares THIS and THAT to be the same project
      
      if isa(this, 'exps.trial') && isa(that, 'exps.trial')
        flag = strcmpi({this.Path}, {that.Path});
      else
        if isa(this, 'char')
          chNeedle = this;
          ceHaystack = {that.Name};
        elseif isa(that, 'char')
          chNeedle = that;
          ceHaystack = {this.Name};
        end
        
        flag = strcmpi(chNeedle, ceHaystack);
      end
      
    end
    
    
    function flag = isequaln(this, that)
      %% ISEQUALN compares THIS and THAT to be the same project
      
      if isa(this, 'exps.trial') && isa(that, 'exps.trial')
        flag = strcmpi({this.Path}, {that.Path});
      else
        if isa(this, 'char')
          chNeedle = this;
          ceHaystack = {that.Name};
        elseif isa(that, 'char')
          chNeedle = that;
          ceHaystack = {this.Name};
        end
        
        flag = strcmpi(chNeedle, ceHaystack);
      end
      
    end
    
    
    function flag = eq(this, that)
      %% EQ compares if two PROJECT objects are the same
      
      
      if isa(this, 'exps.trial') && isa(that, 'exps.trial')
        flag = strcmpi({this.Path}, {that.Path});
      else
        if isa(this, 'char')
          chNeedle = this;
          ceHaystack = {that.Name};
        elseif isa(that, 'char')
          chNeedle = that;
          ceHaystack = {this.Name};
        end
        
        flag = strcmpi(chNeedle, ceHaystack);
      end
      
    end
    
    
    function flag = neq(this, that)
      %% NEQ compares if two PROJECT objects are not the same
      
      if isa(this, 'exps.trial') && isa(that, 'exps.trial')
        flag = ~strcmpi({this.Path}, {that.Path});
      else
        if isa(this, 'char')
          chNeedle = this;
          ceHaystack = {that.Name};
        elseif isa(that, 'char')
          chNeedle = that;
          ceHaystack = {this.Name};
        end
        
        flag = ~strcmpi(chNeedle, ceHaystack);
      end
      
    end
    
    
    function c = char(this)
      %% CHAR converts this object to a char
      
      
      % Allow multiple arguments to be passed
      if numel(this) > 1
        c = {this.Name};
      % Single argument passed, so just get its name
      else
        c = this.Name;
      end
      
    end
    
    
    function c = cellstr(this, varargin)
      %% CELLSTR converts this object to a cell string
      
      
      % Allow multiple arguments to be passed
      if numel(this) > 1
        c = cellstr({this.Name}, varargin{:});
      % Single argument passed, so just get its name
      else
        c = cellstr(this.Name, varargin{:});
      end
      
    end
    
  end
  
  
  
  %% CONVERSION METHODS
  methods
    
    function t = tcscope(this)
      %% TCSCOPE loads the scope CSV file for this object
      
      
      try
        validateattributes(this, {'exps.trial'}, {'scalar'}, mfilename, 'tcscope');
        
        t = csv2tcscope(this.ScopePath);
      catch me
        throwAsCaller(me);
      end
      
    end
    
    
    function vr = VideoReader(this, varargin)
      %% VIDEOREADER creates a VideoReader object of the trial
      
      
       try
        % VIDEOREADER(THIS)
        % VIDEOREADER(THIS, Name, Value, ...)
        narginchk(1, Inf);
        
        % VIDEOREADER(THIS)
        % VR = VIDEOREADER(THIS)
        nargoutchk(0, 1);
        
        % Make sure we have a single trial given
        validateattributes(this, {'exps.trial'}, {'scalar'}, mfilename, 'VideoReader');
        
        % Create empty array holding all our video reader objects
        vr = VideoReader.empty(1, 0);
        
        % Loop over each video
        for iVideo = 1:this.NVideo
          % Create a video reader object of the video file
          vr(iVideo) = VideoReader(fullfile(this.Video(iVideo).folder, this.Video(iVideo).name), varargin{:});
        end
        
       catch me
         throwAsCaller(me);
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

