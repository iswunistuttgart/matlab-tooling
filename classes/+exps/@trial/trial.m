classdef trial < handle & matlab.mixin.Heterogeneous
    % TRIAL An experimental trial object containing information on all files
    
    properties
        
        % Name of the trial
        Name
        
    end
    
    
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
    
    
    properties ( SetAccess = immutable )
        
        % Corresponding parent session object for the trial
        Session@exps.session
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = trial(name, sess)
            
            
            % Validate arguments
            try
                narginchk(2, 2);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
                validateattributes(sess, {'exps.session'}, {'nonempty'}, mfilename, 'sess');
            catch me
                throwAsCaller(me);
            end
            
            % Assign the name
            this.Name = name;
            
            % Assign the parent session
            this.Session = sess;
            
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
            
            
            p = fullfile(this.Session.Path, exps.manager.valid_name(this.Name));
            
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
    
end

