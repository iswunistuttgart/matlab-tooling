classdef session < handle ...
  & matlab.mixin.Heterogeneous
  % SESSION an experimental session object containing many trials

  
  %% PUBLIC PROPERTIES
  properties
    
    % Human readable name of the session
    Name
    
    % All trials of this session
    Trial@exps.trial = exps.trial.empty(1, 0)
    
    % Corresponding parent project of this session
    Project@exps.project
    
  end
  
  
  %% PUBLIC DEPENDENT PROPERTIES
  properties ( Dependent )
    
    % Config of the session
    Config
    
    % Data of the session
    Data
    
    % All images of this experiment
    Image
    
    % All videos of this experiment
    Video
    
    % All media files of this experiment i.e., images and videos
    Media
    
    % Number of media objects
    NMedia
    
    % Number of videos
    NVideo
    
    % Number of images
    NImage
    
    % Path to the config file
    ConfigPath
    
    % Path to the data file
    DataPath
    
    % Path to the media files
    MediaPath
    
    % Path to the Input file
    InputPath
    
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
    
    % Hierarchical path
    Hierarchy
    
    % Path to the sessions folder
    Path
    
    % Number of trials
    NTrial
    
    % Flag whether the session exist or not. True if the folder path does
    % exist
    Exists
    
    % Flag if session is new or not. True if the folder path does not exist
    IsNew
    
  end
  
  
  %% PROTECTED PROPERTIES
  properties ( Access = protected )
    
    % Actual loaded config
    Config_ = struct();
    
    % Actual loaded config
    Data_ = struct();
    DataLoaded = false;
    
  end
  
  
  
  %% HIDDEN PROPERTIES
  properties ( Constant , Hidden )
    
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
    
    function this = session(name, varargin)
      %% SESSION creates a new experimental session project
      
      % Validate arguments
      try
        % SESSION(NAME)
        % SESSION(NAME, 'Name', 'Value')
        narginchk(1, Inf);
        
        % SESSION(NAME, ...)
        % S = SESSION(NAME, ...)
        nargoutchk(0, 1);
        
        % Validate the name
        validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'Name');
      catch me
        throwAsCaller(me);
      end
      
      % Set name
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
      %% CREATE creates the folder structure for a new session
      
      
      try
        % CREATE(THIS)
        narginchk(1, 1);
        
        % CREATE(THIS)
        % SUCCESS = CREATE(THIS)
        % [SUCCESS, MESSAGE] = CREATE(THIS)
        % [SUCCESS, MESSAGE, MESSAGEID] = CREATE(THIS)
        nargoutchk(0, 3);
        
        
        % Create this sessions's folder
        [loSuccess, chMessage, chMessageId] = mkdir(this.Path);
        
        % Create each trial
        for iTrial = 1:this.NTrial
          this.Trial(iTrial).create();
        end
        
        % Create the 'media' directory
        if 0 == exist(this.MediaPath, 'dir')
          mkdir(this.MediaPath);
        end
        
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
    
    
    function d = load_data(this)
      %% LOAD_DATA loads the project's data file
      
      
      % Load only if there is a config file
      if this.HasData
        % Load the file
        d = load(this.DataPath);
      % No config file exists
      else
        % so set an empty structure
        d = struct();
      end
      
    end
    
    
    function save_data(this, varargin)
      %% SAVE_DATA saves the project's data to a file
      
      
      % Continue only if the config really is a struct
      if isa(this.Data, 'struct')
        % Get the config
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
    
    
    function p = get.ConfigPath(this)
      %% GET.CONFIGPATH gets the path to the config file of this project
      
      
      p = fullfile(this, sprintf('%s.mat', this.ConfigName));
      
    end
    
    
    function p = get.DataPath(this)
      %% GET.DATAPATH gets the path to the data file of this project
      
      
      p = fullfile(this, sprintf('%s.mat', this.DataName));
      
    end
    
    
    function p = get.MediaPath(this)
      %% GET.MEDIAPATH returns the path to the media directory
      
      
      p = fullfile(this, this.MediaFolder);
      
    end
    
    
    function f = get.HasConfig(this)
      %% GET.HASCONFIG flags if there is a config MAT file for this project
      
      
      f = 2 == exist(this.ConfigPath, 'file');
      
    end
    
    
    function f = get.HasData(this)
      %% GET.HASDATA flags if there is a data MAT file for this project
      
      
      f = 2 == exist(this.DataPath, 'file');
      
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
    
    
    function p = get.Hierarchy(this)
      %% GET.HIERARCHY hierarchy path of the project
      
      
      p = [{this.Name}, this.Project.Hierarchy];
      
    end
    
    
    function p = get.Path(this)
      %% GET.PATH creates the path for this project's session's folder name
      
      
      p = fullfile(this.Project, exps.manager.valid_name(this.Name));
      
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
    
    
    function n = get.NTrial(this)
      %% GET.NTRIAL counts the number of trials available for this session
      
      
      n = numel(this.Trial);
      
    end
    
    
    function flag = get.Exists(this)
      %% GET.EXISTS flags if the experimental session exists or not
      
      
      flag = 7 == exist(this.Path, 'dir');
      
    end
    
    
    function flag = get.IsNew(this)
      %% GET.ISNEW flags if the experimental session is new or not
      
      
      flag = ~this.Exists;
      
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
      
      % Set config
      this.Config_ = c;
      
    end
    
    
    function set.Data(this, d)
      %% SET.DATA sets the data for this object
      
      
      % Validate arguments
      try
        validateattributes(d, {'struct'}, {}, mfilename, 'Data');
      catch me
        throwAsCaller(me);
      end
      
      % Set data
      this.Data_ = d;
      
    end
    
    
    function set.Trial(this, trial)
      %% SET.TRIAL ensures each trial knows about its parent session
      
      
      % First, make sure we don't have any duplicate sessions
      
      % These will be our unique trials
      T = exps.trial.empty(1, 0);
      ii = 1;
      
      % Loop over each item of this
      while numel(trial)
        % Pop the current object off of O
        proj = trial(1);
        trial(1) = [];
        
        % Find projects with matching paths
        loMatches = proj == trial;
        
        % If there are no other matching paths, then we this project is
        % unique
        if ~any(loMatches)
          T = horzcat(T, proj);
        % There are other objects that point to the same path so we will
        % merge them
        else
          % Convert the logical values to linear indexes
          idxMatches = find(loMatches);
          
          % Get the config
          stConfig = proj.Config;
          
          % Loop over each match and merge the config
          for iMatch = 1:numel(idxMatches)
            stConfig = mergestructs(stConfig, trial(idxMatches(iMatch)).Config);
          end
          
          % Set the updated config
          proj.Config = stConfig;
          
          % Append the unique array
          T = horzcat(T, proj);
          
          % And now remove all the projects that were a match
          trial(loMatches) = [];
          
        end
        
        % Increase loop counter
        ii = ii + 1;
        
      end
      
      % Loop over each trial
      for iTrial = 1:numel(T)
        % And set this session to be the trial's parent
        T(iTrial).Session = this;
        
      end
      
      % And set the property
      this.Trial = T;
      
    end
    
  end
  
  
  
  %% OVERRIDERS
  methods
    
    function s = find(this, name)
      %% FIND session inside sessions or trial inside a session
      %
      % If THIS is a single session, then NAME is assumed a trial
      
      % THIS == 'Trial 01'
      if isa(this, 'exps.session') && numel(this) == 1
        try
          % Find matching names
          idxMatches = ismember({this.Trial.Name}, name);

          % Make sure we found any project
          assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found because it does not exist or names are too ambigious.');

          % And return the data
          s = this.Trial(idxMatches);
        catch me
          % No match, so let's suggest projects based on their string
          % distance
          pclose = exps.manager.closest(this.Trial, name);

          % Found similarly sounding trials?
          if ~isempty(pclose)
            throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found. Did you maybe mean one of the following trials?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
          else
            throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:TrialNotFound', 'Trial could not be found. Make sure there is no typo in the name and that the trial exists.'), me));
          end
        end
      % THESE == 'Session 01'
      else
        try
          % Find matching names
          idxMatches = ismember({this.Name}, name);

          % Make sure we found any project
          assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:SessionNotFound', 'Trial could not be found because it does not exist or names are too ambigious.');

          % And return the data
          s = this(idxMatches);
        catch me
          % No match, so let's suggest projects based on their string
          % distance
          pclose = exps.manager.closest(this, name);

          % Found similarly sounding trials?
          if ~isempty(pclose)
            throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:SessionNotFound', 'Trial could not be found. Did you maybe mean one of the following trials?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
          else
            throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:SESSION:FIND:SessionNotFound', 'Trial could not be found. Make sure there is no typo in the name and that the trial exists.'), me));
          end
        end
      end
      
    end
    
    
    function varargout = mkdir(this)
      %% MKDIR creates the directory for this experimental session
      
      
      [varargout{1:nargout}] = this.create();
      
    end
    
    
    function varargout = list(this, prop)
      %% LIST sessions or a property of sessions
      
      
      % Default property
      if nargin < 2 || isempty(prop)
        prop = 'Name';
      end
      
      try
        % Return output?
        if nargout > 0
          varargout{1} = {this.Trial.(prop)};
        % Directly display output
        else
          disp({this.Trial.(prop)});
        end
      catch me
        throwAsCaller(me);
      end
      
    end
    
    
    function p = path(this)
      %% PATH returns the path of this project
      
      
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

