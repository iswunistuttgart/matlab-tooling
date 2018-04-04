classdef manager
    % MANAGER is the experimental project/session/trial manager
    
    properties
    end
    
    methods ( Static )
        
        function p = project(name)
            %% PROJECT finds the given project and returns it as an EXPS.EPROJECT object
            
            
            try
                narginchk(1, 1);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
            catch me
                throwAsCaller(me);
            end
            
            % Find folder and create object from it
            try
                % Check project exists
                assert(exps.manager.project_exist(name), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:PROJECT:InvalidProjectName', 'Invalid project name given. Does the project exixst?');
                
                % Return the instantiated project
                p = exps.project(name);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function s = session(name, proj)
            %% SESSION finds the given session and returns it as an EXPS.ESESSION object
            
            
            try
                narginchk(2, 2);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
                validateattributes(proj, {'char'}, {'nonempty'}, mfilename, 'proj');
            catch me
                throwAsCaller(me);
            end
            
            % Check and instantiate
            try
                % Check project exists
                assert(exps.manager.project_exist(proj), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:SESSION:InvalidProjectName', 'Invalid project name given. Does the project exixst?');
                % Check session exists
                assert(exps.manager.session_exist(name, proj), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:SESSION:InvalidSessionName', 'Invalid session name given. There does not seem to be any project containing this session.');
                
                % Create a session object
                s = exps.session(name, exps.project(proj));
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function t = trial(name, sess, proj)
            %% TRIAL finds the given trial and returns it as an EXPS.ETRIAL object
            
            
            try
                narginchk(3, 3);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
                validateattributes(sess, {'char'}, {'nonempty'}, mfilename, 'sess');
                validateattributes(proj, {'char'}, {'nonempty'}, mfilename, 'proj');
            catch me
                throwAsCaller(me);
            end
            
            % Check and instantiate
            try
                % Check project exists
                assert(exps.manager.project_exist(proj), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:TRIAL:InvalidProjectName', 'Invalid project name given. Does the project exixst?');
                % Check session exists
                assert(exps.manager.session_exist(sess, proj), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:TRIAL:InvalidSessionName', 'Invalid session name given. There does not seem to be any project containing this session.');
                % Check trial exists
                assert(exps.manager.trial_exist(name, sess, proj), 'PHILIPPTEMPEL:SIMTECH_SEILMODELLIERUNG:EXPERIMENTS:EXPS:MANAGER:TRIAL:InvalidTrialName', 'Invalid trial name given. There does not seem to be any project or project session containing this trial.');
                
                % Create a trial object
                t = exps.trial(name, exps.session(sess, exps.project(proj)));
            catch me
                throwAsCaller(me);
            end
            
            
        end
        
        
        function name = valid_name(name)
            %% VALID_NAME turns the given name to a valid experimental folder name
            
            
            persistent ceInvalidChars
            if isempty(ceInvalidChars)
                ceInvalidChars = '[^a-zA-Z_0-9\-\ ]';
            end
            
            % Delete all invalid characters
            name = regexprep(name, ceInvalidChars, '');
            
            % Replace whitespace by hyphen
            name = strrep(name, ' ', '-');
            
            % Lastly, lowercase everything
            name = lower(name);
            
        end
        
        
        function f = project_exist(proj)
            %% PROJECT_EXIST checks if the given project exists
            
            
            f = 7 == exist(fullfile(exppath(), exps.manager.valid_name(proj)), 'dir');
            
        end
        
        
        function f = session_exist(sess, proj)
            %% SESSION_EXIST checks if the given project session exists
            
            
            f = 7 == exist(fullfile(exppath(), exps.manager.valid_name(proj), exps.manager.valid_name(sess)), 'dir');
            
        end
        
        
        function f = trial_exist(trial, sess, proj)
            %% TRIAL_EXIST checks if the given project session trial exists
            
            
            f = 7 == exist(fullfile(exppath(), exps.manager.valid_name(proj), exps.manager.valid_name(sess), exps.manager.valid_name(trial)), 'dir');
            
        end
        
    end
    
end

