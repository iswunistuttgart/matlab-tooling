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
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new project
            
            
            try
                % If this project folder does not exist, create it
                if ~this.Exists
                    % Create this project's folder
                    mkdir(this.Path);
                end
                
                % Create each session
                for iSess = 1:this.NSession
                    this.Session(iSess).create();
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
            
            % Set config
            this.Config = c;
            
        end
        
        
        function save_config(this)
            %% SAVE_CONFIG saves the project's config to a file
            
            
            % Continue only if the config really is a struct
            if isa(this.Config, 'struct')
                % Get the config
                c = this.Config;
                
                % Save the structure as separate variables
                save(this.ConfigPath, '-struct', 'c');
                
                % Clear memory
                clear('c');
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
            
            % And save the config
            save(this.ConfigPath, '-struct', 'c'); %#ok<MCSUP>
            
        end
        
        
        function set.Session(this, sess)
            %% SET.SESSION ensures each session knows about its parent project
            
            
            % Loop over each session
            for iSess = 1:numel(sess)
                % And set this project to be the session's parent
                sess(iSess).Project = this;
            end
            
            % And set the property
            this.Session = sess;
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function p = path(this)
            %% PATH returns the path of this project
            
            
            p = this.Path;
            
        end
        
        
        function ff = fullfile(this, varargin)
            %% FULLFILE returns the full filepath of this trial
            
            
            ff = fullfile(this.Path, varargin{:});
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function n = infer_name(this)
            %% INFER_NAME infers the name of the project from the path
            
            
            % Get the folder name
            [~, n, ~] = fileparts(this.Path);
            
            % And now make it a valid 'experimental manager' folder name
            n = exps.manager.valid_name(n);
            
        end
        
    end
    
end

