classdef project < handle & matlab.mixin.Heterogeneous
    % PROJECT is an experimental project object
    
    
    %% PUBLIC PROPERTIES
    properties
        
        % Name of the project
        Name
        
        % Path to project's root
        Path
        
        % All sessions found for the project
        Session@exps.session = exps.session.empty(1, 0);
        
    end
    
    
    %% PUBLIC DEPENDENT PROPERTIES
    properties ( Dependent )
        
        % Config of the project
        Config
        
        % Path to the config file
        ConfigPath
        
        % Flag if there is a config file of this project
        HasConfig
        
        % Number of project sessions
        NSession
        
        % All the project's trials
        Trial
        
        % Flag whether the project exist or not. True if the folder path does
        % exist
        Exists
        
        % Flag if project is new or not. True if the folder path does not exist
        IsNew
        
    end
    
    
    %% PROTECTED PROPERTIES
    properties ( Access = protected )
      
      % Actual loaded config
      Config_ = struct();
      
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = project(pth, varargin)
            %% PROJECT creates a new project object
            
            
            % Validate arguments
            try
                % PROJECT(PATH)
                % PROJECT(PATH, 'Name', 'Value', ...)
                narginchk(1, Inf);
                
                % PROJECT(PATH)
                % P = PROJECT(PATH)
                nargoutchk(0, 1);
                
                % Validate path
                validateattributes(pth, {'char'}, {'nonempty'}, mfilename, 'path');
            catch me
                throwAsCaller(me);
            end
            
            % Set project path
            this.Path = pth;
            
            % Assign variable list of arguments
            for iArg = 1:2:numel(varargin)
                this.(varargin{iArg}) = varargin{iArg + 1};
            end
            
            % No name set?
            if isempty(this.Name)
                % Infer the name from the path
                this.Name = this.infer_name();
            end
            
            % Load configuration
            this.Config = this.load_config();
            
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
                
                % Create this project's folder
                [loSuccess, chMessage, chMessageId] = mkdir(this.Path);
                
                % Create each session
                for iSess = 1:this.NSession
                    this.Session(iSess).create();
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
%                 % Delete the directory i.e., 'cleanup'
%                 rmdir(this.Path, 's');
                
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
        
    end
    
    
    
    %% GETTERS
    methods
        
        function c = get.Config(this)
            %% GET.CONFIG gets the config
            
            
            % Get private property
            c = this.Config_;
            
        end
        
        
        function p = get.ConfigPath(this)
            %% GET.CONFIGPATH gets the path to the config file of this project
            
            
            p = fullfile(this.Path, 'config.mat');
            
        end
        
        
        function f = get.HasConfig(this)
            %% GET.HASCONFIG flags if there is a config MAT file for this project
            
            
            f = 2 == exist(this.ConfigPath, 'file');
            
        end
        
        
        function n = get.NSession(this)
            %% GET.NSESSION counts the number of sessions
            
            
            n = numel(this.Session);
            
        end
        
        
        function t = get.Trial(this)
            %% GET.TRIAL gets all the project's trials
            
            
            t = horzcat(this.Session.Trial);
            
            if isempty(t)
                t = exps.trial.empty(1, 0);
            end
            
        end
        
        
        function flag = get.Exists(this)
            %% GET.EXISTS flags if the experimental project exists or not
            
            
            flag = 7 == exist(this.Path, 'dir');
            
        end
        
        
        function flag = get.IsNew(this)
            %% GET.ISNEW flags if the experimental project is new or not
            
            
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
            
            % Set validated property
            this.Config_ = c;
            
        end
        
        
        function set.Session(this, sess)
            %% SET.SESSION ensures each session knows about its parent project
            
            
            % First, make sure we don't have any duplicate sessions
            
            % These will be our unique projects
            S = exps.session.empty(1, 0);
            ii = 1;
            
            % Loop over each item of this
            while numel(sess)
                % Pop the current object off of O
                proj = sess(1);
                sess(1) = [];
                
                % Find projects with matching paths
                loMatches = proj == sess;
                
                % If there are no other matching paths, then we this project is
                % unique
                if ~any(loMatches)
                    S = horzcat(S, proj);
                % There are other objects that point to the same path so we will
                % merge them
                else
                    % Convert the logical values to linear indexes
                    idxMatches = find(loMatches);
                    
                    % Get the config
                    stConfig = proj.Config;
                    
                    % Store trials
                    vTrials = proj.Trial;
                    
                    % Loop over each match and merge the config
                    for iMatch = 1:numel(idxMatches)
                        stConfig = mergestructs(stConfig, sess(idxMatches(iMatch)).Config);
                        vTrials = horzcat(vTrials, sess(idxMatches(iMatch)).Trial);
                    end
                    
                    % Set the updated config
                    proj.Config = stConfig;
                    % And set concatenated trials
                    proj.Trial = vTrials;
                    
                    % Append the unique array
                    S = horzcat(S, proj);
                    
                    % And now remove all the projects that were a match
                    sess(loMatches) = [];
                end
                
                % Increase loop counter
                ii = ii + 1;
            end
            
            % Loop over each session
            for iSess = 1:numel(S)
                % And set this project to be the session's parent
                S(iSess).Project = this;
            end
            
            % And set the property
            this.Session = S;
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function s = find(this, name)
            %% FIND project inside projects or session inside a projecft
            %
            % If THIS is a single session, then NAME is assumed a trial
            
            % THIS == 'Session 01'
            if isa(this, 'exps.project') && numel(this) == 1
              try
                  % Find matching names
                  idxMatches = ismember({this.Session.Name}, name);

                  % Make sure we found any project
                  assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:SessionNotFound', 'Session could not be found because it does not exist or names are too ambigious.');

                  % And return the data
                  s = this.Session(idxMatches);
              catch me
                  % No match, so let's suggest session based on their string
                  % distance
                  pclose = exps.manager.closest(this.Sesion, name);

                  % Found similarly sounding sessions?
                  if ~isempty(pclose)
                      throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:SessionNotFound', 'Session could not be found. Did you maybe mean one of the following sessions?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
                  else
                      throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:SessionNotFound', 'Session could not be found. Make sure there is no typo in the name and that the session exists.'), me));
                  end
              end
            % THESE == 'Project 01'
            else
              try
                  % Find matching names
                  idxMatches = ismember({this.Name}, name);

                  % Make sure we found any project
                  assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:ProjecftNotFound', 'Session could not be found because it does not exist or names are too ambigious.');

                  % And return the data
                  s = this(idxMatches);
              catch me
                  % No match, so let's suggest session based on their string
                  % distance
                  pclose = exps.manager.closest(this, name);

                  % Found similarly sounding sessions?
                  if ~isempty(pclose)
                      throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:ProjecftNotFound', 'Session could not be found. Did you maybe mean one of the following sessions?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
                  else
                      throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:PROJECT:FIND:ProjecftNotFound', 'Session could not be found. Make sure there is no typo in the name and that the session exists.'), me));
                  end
              end
            end
            
        end
        
        
        function varargout = mkdir(this)
            %% MKDIR creates the directory for this experimental project
            
            
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
                    varargout{1} = {this.Session.(prop)};
                % Directly display output
                else
                    disp({this.Session.(prop)});
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
        
        function n = infer_name(this)
            %% INFER_NAME infers the name of this project from the path
            
            
            % Get the folder name
            [~, n, ~] = fileparts(this.Path);
            
            % And now make it a valid 'experimental manager' folder name
            n = exps.manager.valid_name(n);
            
        end
        
    end
    
end

