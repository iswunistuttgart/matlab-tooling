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
            
            
            % Loop over each trial
            for iTrial = 1:numel(trial)
                % And set this session to be the trial's parent
                trial(iTrial).Session = this;
            end
            
            % And set the property
            this.Trial = trial;
            
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
        
%         function t = search_trials(this)
%             %% SEARCH_TRIALS searches for all trials inside the current session folder path
%             
%             
%             % Get all directories inside the sessions's path
%             vTrialDirs = alldirs(this.Path);
%             % Homogenous mixing of session objects
%             esTrials = exps.trial.empty(0, 1);
%             % Loop over each session folder and make a session object for it
%             for iTrial = 1:numel(vTrialDirs)
%                 esTrials(iTrial) = exps.trial(vTrialDirs(iTrial).name, 'Session', this);
%             end
%             
%             % And assign output quantitiy
%             t = esTrials;
%             
%         end
        
    end
    
end

