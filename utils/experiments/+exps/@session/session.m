classdef session < handle & matlab.mixin.Heterogeneous
    % SESSION an experimental session object containing many trials
    
    properties
        
        % Human readable name of the session
        Name
        
        % All trials of this session
        Trial@exps.trial = exps.trial.empty(0, 1)
        
    end
    
    
    properties ( Dependent )
        
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
    
    
    properties ( SetAccess = immutable )
        
        % Corresponding parent project of this session
        Project@exps.project
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = session(name, proj)
            
            
            % Validate arguments
            try
                narginchk(2, 2);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'Name');
                validateattributes(proj, {'exps.project'}, {'nonempty'}, mfilename, 'Proj');
            catch me
                throwAsCaller(me);
            end
            
            % Set name
            this.Name = name;
            
            % Set project
            this.Project = proj;
            
            % And find all trial
            this.Trial = this.search_trials();
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new project
            
            
            try
                assert(this.IsNew, 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:MATLAB:SESSION:SessionNotNew', 'Cannot create session folder: session is not new.');
            catch me
                throwAsCaller(me);
            end
            
            
            try
                % Create this sessions's folder
                mkdir(this.Path);
                
                % Create each trial
                for iTrial = 1:this.NTrial
                    this.Trial(iTrial).create();
                end
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
            
            
            p = fullfile(this.Project.Path, exps.manager.valid_name(this.Name));
            
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
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function t = search_trials(this)
            %% SEARCH_TRIALS searches for all trials inside the current session folder path
            
            
            % Get all directories inside the sessions's path
            vTrialDirs = alldirs(this.Path);
            % Homogenous mixing of session objects
%             esTrials = zeros(0, 1, 'like', @trial);
            esTrials = exps.trial.empty(0, 1);
            % Loop over each session folder and make a session object for it
            for iTrial = 1:numel(vTrialDirs)
                esTrials(iTrial) = exps.trial(vTrialDirs(iTrial).name, this);
            end
            
            % And assign output quantitiy
            t = esTrials;
            
        end
        
    end
    
end

