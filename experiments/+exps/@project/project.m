classdef project < handle & matlab.mixin.Heterogeneous
    % PROJECT is an experimental project object
    
    properties
        
        % Name of the project
        Name
        
        % Path to project's root
        Path
        
        % All sessions found for the project
        Session@exps.session = exps.session.empty(0, 1)
        
    end
    
    
    properties ( Dependent )
        
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
            
            % Find all sessions
            this.Session = this.search_sessions();
            
        end
        
        
        function create(this)
            %% CREATE creates the folder structure for a new project
            
            
            try
                assert(this.IsNew, 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:MATLAB:PROJECT:ProjectNotNew', 'Cannot create project folder: project is not new.');
            catch me
                throwAsCaller(me);
            end
            
            
            try
                % Create this project's folder
                mkdir(this.Path);
                
                % Create each session
                for iSess = 1:this.NSession
                    this.Session(iSess).create();
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
        
        function n = get.NSession(this)
            %% GET.NSESSION counts the number of sessions
            
            
            n = numel(this.Session);
            
        end
        
        
        function t = get.Trial(this)
            %% GET.TRIAL gets all the project's trials
            
            
            t = horzcat(this.Session.Trial);
            
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
    methods
        
        function s = search_sessions(this)
            
            % Get all directories inside the project's path
            vSessionDirs = alldirs(this.Path);
            % Homogenous mixing of session objects
%             esSessions = zeros(0, 1, 'like', @session);
            esSessions = exps.session.empty(0, 1);
            % Loop over each session folder and make a session object for it
            for iSession = 1:numel(vSessionDirs)
                esSessions(iSession) = exps.session(vSessionDirs(iSession).name, 'Project', this);
            end
            
            % And assign output quantitiy
            s = esSessions;
            
        end
        
        
        function n = infer_name(this)
            %% INFER_NAME infers the name of the project from the path
            
            
            % Get the folder name
            [~, n, ~] = fileparts(this.Path);
            
            % And now make it a valid 'experimental manager' folder name
            n = exps.manager.valid_name(n);
            
        end
        
    end
    
end

