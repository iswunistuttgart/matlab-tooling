classdef session < handle & matlab.mixin.Heterogeneous
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
        
        % Config of the project
        Config
        
        % Path to the config file
        ConfigPath
        
        % Flag if there is a config file of this project
        HasConfig
        
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
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new session
            
            
            try
                % If this session folder does not exist, create it
                if ~this.Exists
                    % Create this sessions's folder
                    mkdir(this.Path);
                end
                
                % Create each trial
                for iTrial = 1:this.NTrial
                    this.Trial(iTrial).create();
                end
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
        
        
        function p = get.ConfigPath(this)
            %% GET.CONFIGPATH gets the path to the config file of this project
            
            
            p = fullfile(this.Path, 'config.mat');
            
        end
        
        
        function f = get.HasConfig(this)
            %% GET.HASCONFIG flags if there is a config MAT file for this project
            
            
            f = 2 == exist(this.ConfigPath, 'file');
            
        end
        
        
        function p = get.Path(this)
            %% GET.PATH creates the path for this project's session's folder name
            
            
            p = fullfile(this.Project, exps.manager.valid_name(this.Name));
            
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
            
            % And save the config
            save(this.ConfigPath, '-struct', 'c'); %#ok<MCSUP>
            
        end
        
        
        function set.Trial(this, trial)
            %% SET.TRIAL ensures each trial knows about its parent session
            
            
            % First, make sure we don't have any duplicate sessions
            
            % These will be our unique projects
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
        
    end
    
end

