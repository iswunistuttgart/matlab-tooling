classdef project < handle & matlab.mixin.Heterogeneous
    % PROJECT is an experimental project object
    
    properties
        
        % Name of the project
        Name
        
        % All sessions found for the project
        Session@exps.session = exps.session.empty(0, 1)
        
    end
    
    
    properties ( Dependent )
        
        % Path of the project's fodler
        Path
        
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
        
        function this = project(name)
            %% PROJECT creates a new project object
            
            
            % Validate arguments
            try
                narginchk(1, 1);
                
                nargoutchk(0, 1);
                
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
            catch me
                throwAsCaller(me);
            end
            
            % Set project name
            this.Name = name;
            
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
        
        function p = get.Path(this)
            %% GET.PATH gets the project's folder path
            
            
            % Turn the Project name to a MATLAB valid name and append this to
            % the path from `exppath()`
            p = fullfile(exppath(), exps.manager.valid_name(this.Name));
            
        end
        
        
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
        
%         function varargout = subsref(this, s)
%             %% SUBSREF overrides the subsref command
%             
%             
%             switch s(1).type
%                 case '.'
%                     [varargout{1:nargout}] = builtin('subsref', this, s);
% %                     if length(s) == 1
% %                     % Implement this.PropertyName
% %                         varargout{1} = this.(s.subs);
% %                     elseif length(s) == 2 && strcmp(s(2).type,'()')
% %                         % Implement this.PropertyName(indices)
% %                         ...
% %                     else
% %                         [varargout{1:nargout}] = builtin('subsref',this,s);
% %                     end
%                 case '()'
%                     [varargout{1:nargout}] = builtin('subsref', this.Session, s);
% %                     if length(s) == 1
% %                         % Implement this(indices)
% %                         [varargout{1:nargout}] = this.Session(s.subs{1});
% %                     elseif length(s) == 2 && strcmp(s(2).type,'.')
% %                         % Implement this(ind).PropertyName
% %                         ...
% %                     elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
% %                         % Implement this(indices).PropertyName(indices)
% %                         ...
% %                     else
% %                         % Use built-in for any other expression
% %                         [varargout{1:nargout}] = builtin('subsref',this,s);
% %                     end
%                 case '{}'
%                     [varargout{1:nargout}] = builtin('subsref', this, s);
% %                     if length(s) == 1
% %                         % Implement this{indices}
% %                     ...
% %                     elseif length(s) == 2 && strcmp(s(2).type,'.')
% %                         % Implement this{indices}.PropertyName
% %                         ...
% %                     else
% %                         % Use built-in for any other expression
% %                         [varargout{1:nargout}] = builtin('subsref',this,s);
% %                     end
%                 otherwise
%                     error('Not a valid indexing expression')
%             end
%         end
        
        
%         function this = subsasgn(this,s,varargin)
%             %% SUBSASGN
%             
%             
%             switch s(1).type
%                 case '.'
%                     this = builtin('subsasgn', this, s, varargin{:});
% %                     if length(s) == 1
% %                         % Implement this.PropertyName = varargin{:};
% %                         this.(s.subs) = varargin{:};
% %                     elseif length(s) == 2 && strcmp(s(2).type,'()')
% %                         % Implement this.PropertyName(indices) = varargin{:};
% %                         this.(s(1).subs)(s(2).subs{1}) = varargin{:};
% %                     else
% %                         % Call built-in for any other case
% %                         this = builtin('subsasgn',this,s,varargin);
% %                     end
%                 case '()'
%                     this = builtin('subsasgn', this.Session, s, varargin{:});
% %                     if length(s) == 1
% %                         % Implement this(indices) = varargin{:};
% %                     elseif length(s) == 2 && strcmp(s(2).type,'.')
% %                         % Implement this(indices).PropertyName = varargin{:};
% %                         ...
% %                     elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
% %                         % Implement this(indices).PropertyName(indices) = varargin{:};
% %                         ...
% %                     else
% %                         % Use built-in for any other expression
% %                         this = builtin('subsasgn',this,s,varargin);
% %                     end         
%                 case '{}'
%                     this = builtin('subsasgn', this, s, varargin{:});
% %                     if length(s) == 1
% %                         % Implement this{indices} = varargin{:}
% %                         ...
% %                     elseif length(s) == 2 && strcmp(s(2).type,'.')
% %                         % Implement this{indices}.PropertyName = varargin{:}
% %                         ...
% %                         % Use built-in for any other expression
% %                         this = builtin('subsasgn',this,s,varargin);
% %                     end
%                 otherwise
%                     error('Not a valid indexing expression')
%             end
%         end
        
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
                esSessions(iSession) = exps.session(vSessionDirs(iSession).name, this);
            end
            
            % And assign output quantitiy
            s = esSessions;
            
        end
        
    end
    
end

