classdef manager < handle
    % MANAGER is the manager of experimental projects/sessions/trials
    
    
    %% PUBLIC PROPERTIES
    properties
        
        Projects@exps.project = exps.project.empty(1, 0)
        
    end
    
    
    %% WRITE-PROTECTED PROPERTIES
    properties ( SetAccess = protected )
        
    end
    
    
    %% DEPENDENT PUBLIC PROPERTIES
    properties ( Dependent )
        
    end
    
    
    
    %% STATIC METHODS
    methods ( Static )
        
        function f = filename()
            %% FILENAME returns the computer aware filename of the projects file
            
            
            % @see https://undocumentedmatlab.com/blog/unique-computer-id
%             sid = '';
%             ni = java.net.NetworkInterface.getNetworkInterfaces;
%             while ni.hasMoreElements
%                 addr = ni.nextElement.getHardwareAddress;
%                 if ~isempty(addr)
%                     sid = [sid, '.', sprintf('%.2X', typecast(addr, 'uint8'))];
%                 end
%             end
            sid = sprintf('%.2X', typecast(java.net.NetworkInterface.getByInetAddress(java.net.InetAddress.getLocalHost()).getHardwareAddress, 'uint8'));
            
            % Check userpath is not empty
            if isempty(userpath)
                userpath('reset');
            end

            % Build the filename
            f = fullfile(userpath, sprintf('experiments_%s.mat', matlab.lang.makeValidName(sid)));
            
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
        
        
%         function o = makehere(type)
%             %% MAKEHERE makes this folder a new experiments PROEJCT, SESSION, or TRIAL
%             
%             
%             try
%                 % EXPS.MANAGER.MAKEHERE(TYPE)
%                 narginchk(1, Inf);
%                 
%                 % EXPS.MANAGER.MAKEHERE(TYPE)
%                 % O = EXPS.MANAGER.MAKEHERE(TYPE)
%                 nargoutchk(0, 1);
%                 
%                 validatestring(lower(type), {'project', 'session', 'trial'}, mfilename, 'type');
%             catch me
%                 throwAsCaller(me);
%             end
%             
%             % Make a new object of the given type
%             switch lower(type)
%                 % Make new project
%                 case 'project'
%                     o = exps.project(pwd);
%                 % Make new session
%                 case 'session'
%                     % Get this folder's parent folder
%                     chParent = fullfile(pwd, '..');
%                     
%                     % Find project in the parent's folder
%                     try
%                         this = exps.manager;
%                         epParent = strcmp({this.Projects.Path}, chParent);
%                     end
%                     
%                     % Create new object
%                     o = exps.session('[unnamed]');
%                     
%                     % Assign the parent if it exists
%                     if 1 == exist('epParent', 'var') && ~isempty(epParent)
%                         o.Project = epParent;
%                     end
%                     
%                     % And done
%                 % Make new trial
%                 case 'trial'
%                     o = exps.trial(pwd);
%             end
%             
%         end
        
    end
    
    
    
    %% STATIC PROTECTED METHODS
    methods ( Static )
        
        function d = strdist(r, b, krk, cas)
            %% STRDIST computes distances between strings
            %
            % d=strdist(r,b,krk,cas) computes Levenshtein and editor distance 
            % between strings r and b with use of Vagner-Fisher algorithm.
            %    Levenshtein distance is the minimal quantity of character
            % substitutions, deletions and insertions for transformation
            % of string r into string b. An editor distance is computed as 
            % Levenshtein distance with substitutions weight of 2.
            % d=strdist(r) computes numel(r);
            % d=strdist(r,b) computes Levenshtein distance between r and b.
            % If b is empty string then d=numel(r);
            % d=strdist(r,b,krk)computes both Levenshtein and an editor distance
            % when krk=2. d=strdist(r,b,krk,cas) computes a distance accordingly 
            % with krk and cas. If cas>0 then case is ignored.
            % 
            % Example.
            %  disp(strdist('matlab'))
            %     6
            %  disp(strdist('matlab','Mathworks'))
            %     7
            %  disp(strdist('matlab','Mathworks',2))
            %     7    11
            %  disp(strdist('matlab','Mathworks',2,1))
            %     6     9

            switch nargin
               case 1
                  d = numel(r);
                  return
               case 2
                  krk = 1;
                  bb = b;
                  rr = r;
               case 3
                   bb = b;
                   rr = r;
               case 4
                  bb = b;
                  rr = r;
                  if cas > 0
                     bb = upper(b);
                     rr = upper(r);
                  end
            end

            if krk ~= 2
               krk = 1;
            end

            d = zeros(1, 0);
            luma = numel(bb);
            lima = numel(rr);
            lu1 = luma + 1;
            li1 = lima + 1;
            dl = zeros([lu1, li1]);
            dl(1,:) = 0:lima;
            dl(:,1) = 0:luma;
            % Distance
            for krk1 = 1:krk
                for ii = 2:lu1
                    bbi = bb(ii-1);
                    for ij = 2:li1
                        kr = krk1;
                        if strcmp(rr(ij-1),bbi)
                            kr = 0;
                        end
                        dl(ii,ij) = min([dl(ii-1,ij-1) + kr, dl(ii-1,ij) + 1, dl(ii,ij-1) + 1]);
                    end
                end
                d = horzcat(d, dl(end,end));
            end
            
        end
        
        
        function clo = closest(haystack, needle)
            %% CLOSEST finds the objects inside HAYSTACK that are closest to a NEEDLE
            
            
            % Get the distance between the needle and all other trials' names
            dists = cellfun(@(n) exps.manager.strdist(needle, n), {haystack.Name});
            % Sort the distances from shortest to longest
            [dists, sortidx] = sort(dists);
            
            % Now get all sessions whose name distance is smaller than 10 (some
            % random/arbitrary value)
            sortidx = sortidx(dists < 10);
            
            % And return these trials
            clo = haystack(sortidx);
        end
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = manager()
            %% MANAGER creates a new manager instance
            
            
            % Load the projects
            this.load_projects_();
            
            
        end
        
        
        function varargout = reset(this)
          %% RESET this object i.e., load a new one
          
          
          % Create new object instance
          this = exps.manager();
          
          % Assign output?
          if nargout
              varargout{1} = this;
          end
          
        end
        
        
        function p = find(this, name)
            %% FIND a single project by name
            
            
            try
                % Find matching names
                idxMatches = ismember({this.Projects.Name}, name);
                
                % Make sure we found any project
                assert(any(idxMatches), 'PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:MANAGER:FIND:ProjectNotFound', 'Project could not be found because it does not exist or names are too ambigious');
                
                % And return the data
                p = this.Projects(idxMatches);
            catch me
                % No match, so let's suggest projects based on their string
                % distance
                pclose = this.closest_projects(name);
                
                % Found similarly sounding projects?
                if ~isempty(pclose)
                    throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:MANAGER:FIND:ProjectNotFound', 'Project could not be found. Did you maybe mean one of the following projects?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
                else
                    throwAsCaller(addCause(MException('PHILIPPTEMPEL:MATLAB_TOOLING:EXPERIMENTS:EXPS:MANAGER:FIND:ProjectNotFound', 'Project could not be found. Make sure there is no typo in the name and that the project exists.'), me));
                end
            end
            
        end
        
        
        function varargout = list(this, prop)
            %% LIST projects or a property of projects
            
            
            % Default property
            if nargin < 2 || isempty(prop)
                prop = 'Name';
            end
            
            try
                % Return output?
                if nargout > 0
                    varargout{1} = {this.Projects.(prop)};
                % Directly display output
                else
                    disp({this.Projects.(prop)});
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function go(this, name)
            %% GO to a project's folder
            
            
            try
                % Find project
                p = this.find(name);
                
                % Go to project
                p.go();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function p = path(this, name)
            %% PATH gets the path of the given project
            
            
            try
                % Find project and get path of it
                p = path(this.find(name));
            catch me
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function save(this)
            %% SAVE this experiments manager instance
            
            
            % Save the experiment projects to a file
            try
                % Get the projects
                p = this.Projects;
                
                % Save above variable into the file
                save(exps.manager.filename, 'p');
                
                % Free some memory
                clear('p');
            catch me
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
    end
    
    
    
    %% SETTERS
    methods
        
        function set.Projects(this, ps)
            %% SET.PROJECTS validates the projects
            
            
            % These will be our unique projects
            P = exps.project.empty(1, 0);
            ii = 1;
            
            % Loop over each item of this
            while numel(ps)
                % Pop the current object off of O
                proj = ps(1);
                ps(1) = [];
                
                % Find projects with matching paths
                loMatches = proj == ps;
                
                % If there are no other matching paths, then we this project is
                % unique
                if ~any(loMatches)
                    P = horzcat(P, proj);
                % There are other objects that point to the same path so we will
                % merge them
                else
                    % Convert the logical values to linear indexes
                    idxMatches = find(loMatches);
                    
                    % Get the config
                    stConfig = proj.Config;
                    
                    % We will also merge the sessions
                    vSessions = proj.Session;
                    
                    % Loop over each match...
                    for iMatch = 1:numel(idxMatches)
                        % Merge configs
                        stConfig = mergestructs(stConfig, ps(idxMatches(iMatch)).Config);
                        % Merge sessions
                        vSessions = horzcat(vSessions, ps(idxMatches(iMatch)).Session);
                    end
                    
                    % Set the updated config
                    proj.Config = stConfig;
                    % And set the updated session (this will automatically be
                    % cleaned by exps.session.set.Session)
                    proj.Session = vSessions;
                    
                    % Append the unique array
                    P = horzcat(P, proj);
                    
                    % And now remove all the projects that were a match
                    ps(loMatches) = [];
                end
                
                % Increase loop counter
                ii = ii + 1;
            end
            
            % Set the cleaned array of projects
            this.Projects = P;
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function load_projects_(this)
            %% LOAD_PROJECTS_ loads the projects for this computer
            
            
            % Load the projects
            try
                % Create a matfile object
                moFile = matfile(exps.manager.filename());
                
                % Get the variables inside the matfile
                stVariables = whos(moFile);
                
                % If there are variables, we will get them
                if numel(stVariables)
                    % Find the first variable being of type 'exps.project'
                    [~, idx] = find(strcmp({stVariables.class}, 'exps.project'), 1, 'first');
                    
                    % Get the projects and assign them
                    this.Projects = moFile.(stVariables(idx).name);
                end
            catch me
                % Init empty projects array
                this.Projects = exps.project.empty(1, 0);
            end
            
        end
        
        
        function ps = closest_projects(this, name)
            %% CLOSEST_PROJECTS finds the projects with a name closest to the needle
            
            
            % Get the distance between the needle and all other projects' names
            dists = cellfun(@(n) exps.manager.strdist(name, n), {this.Projects.Name});
            % Sort the distances from shortest to longest
            [dists, sortidx] = sort(dists);
            
            % Now get all projects whose name distance is smaller than 10 (some
            % random/arbitrary value)
            sortidx = sortidx(dists < 10);
            
            % And return these projects
            ps = this.Projects(sortidx);
            
        end
        
    end
    
end
