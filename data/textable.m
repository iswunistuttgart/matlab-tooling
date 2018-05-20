classdef textable < handle ...
        & dynamicprops
    % TEXTABLE is a MATLAB table object that supports export to TeX files
    
    
    %% PUBLIC PROPERTIES
    properties
        
    end
    
    
    %% DEPENDENT PROPERTIES
    properties ( Dependent )
        
        % Whether to use siunitx 
        SIUnitX = 'off'
        
        % File to save to
        Filename = ''
        
        % Wrap tabular in table environment
        TableEnv = 'off'
        
        % Whether to use rulers
        Rulers = 'on'
        
        % Whether to use booktabs to set rulers or not
        Booktabs = 'on'
        
        % Caption of the tabular table
        Caption = ''
        
        % Label of the tabular table
        Label = ''
        
        % Center the cable
        Centering = 'on'
        
    end
    
    
    %% PROTECTED PROPERTIES
    properties ( Access = protected )
        
        Table_@table
        
    end
    
    
    %% GENERAL METHODS
    methods
        
        function this = textable(tbl, varargin)
            %% TEXTABLE creates a new TeX table object
            %
            %   T = TEXTABLE(TABLE) creates a new TEXTABLE object from the table
            %   object TABLE.
            %
            %   T = TEXTABLE(TABLE, 'Name', 'Value', ...) allows setting
            %   optional inputs using name/value pairs.
            %
            %   Inputs:
            %
            %   TABLE               A nonempty TABLE object
            %
            %   Optional Inputs -- specified as parameter value pairs
            %
            %   Outputs:
            %
            %   T                   New TEXTABLE objec that can be written to
            %                       file
            
            
            % Validate arguments
            try
                % TEXTABLE(TBL)
                % TEXTABLE(TBL, 'Name', 'Value', ...)
                narginchk(1, Inf);
                
                % TEXTABLE(TBL)
                % T = TEXTABLE(TBL)
                nargoutchk(0, 1);
                
                % Check TBL is a TABLE object
                validateattributes(tbl, {'table'}, {'nonempty'}, mfilename, 'Table');
                
                % Make sure we have an even count of variable arguments
                assert(iseven(numel(varargin)), 'Invalid number of variable arguments list. Must be even');
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated properties
            this.Table_ = tbl;
            
            % Assign list of variable arguments
            for iArg = 1:2:numel(varargin)
                this.(varargin{iArg}) = varargin{iArg + 1};
            end
            
        end
        
    end
    
    
    
    %% SETTERS
    methods
        
        function set.SIUnitX(this, six)
            %% SET.SIUNITX ensures the SIUNITX property is valid
            
            
            % Validate argument
            try
                six = parseswitcharg(validatestring(lower(six), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'SIUnitX'));
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.SIUnitX = six;
            
        end
        
        
        function set.Filename(this, f)
            %% SET.FILENAME ensures the filename is valid
            
            
            % Validate argument
            try
                validateattributes(f, {'char'}, {}, mfilename, 'Filename');
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Filename = f;
            
        end
        
        
        function set.TableEnv(this, te)
            %% SET.TABLEENV ensures the TABLEENV property is valid
            
            
            % Validate argument
            try
                te = parseswitcharg(validatestring(lower(te), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'TableEnv'));
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.TableEnv = te;
            
        end
        
        
        function set.Rulers(this, rls)
            %% SET.RULERS ensures the RULERS property is valid
            
            
            % Validate argument
            try
                rls = parseswitcharg(validatestring(lower(rls), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Rulers'));
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Rulers = rls;
            
        end
        
        
        function set.Booktabs(this, bkt)
            %% SET.BOOKTABS ensures the BOOKTABS property is valid
            
            
            % Validate argument
            try
                bkt = parseswitcharg(validatestring(lower(bkt), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Booktabs'));
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Booktabs = bkt;
            
        end
        
        
        function set.Caption(this, c)
            %% SET.CAPTION ensures the caption is set correctly
            
            
            % Validate argument
            try
                validateattributes(c, {'char'}, {}, mfilename, 'Caption');
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Caption = c;
            
        end
        
        
        function set.Label(this, l)
            %% SET.LABEL ensures the label is set correctly
            
            
            % Validate argument
            try
                validateattributes(l, {'char'}, {}, mfilename, 'Label');
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Label = l;
            
        end
        
        
        function set.Centering(this, ce)
            %% SET.CENTERING ensures the CENTERING property is valid
            
            
            % Validate argument
            try
                ce = parseswitcharg(validatestring(lower(ce), {'on', 'off', 'yes', 'no', 'please'}, mfilename, 'Centering'));
            catch me
                throwAsCaller(me);
            end
            
            % Assign validated argument
            this.Table_.Properties.UserData.Centering = ce;
            
        end
        
%         function set.Table_(this, tbl)
%             %% SET.TABLE_
%             
%             
%             % Set the property
%             this.Table_ = tbl;
%             
%             % Now add dynamic properties to this class that reflect the table
%             % object
%             ceVars = tbl.Properties.VariableNames;
%             
% %             function set_dynprop(this, prop, val)
% %                 this.Table_.(prop) = val;
% %             end
% %             function v = get_dynprop(this, prop)
% %                 v = this.Table_.(prop);
% %             end
%             function q = a(this, varargin)
%                 q = this.Weight;
%             end
%             
%             % Loop over each property
%             for iVar = 1:numel(ceVars)
%                 % Add the dynamic property
%                 p = this.addprop(ceVars{iVar});
%                 % Add a get method callback to the property
% %                 p.GetMethod = @(varargin) return disp('foo');
%                 p.GetMethod = @(o) deal(o.get_tableprop(ceVars{iVar}));
%                 % Add a set method callback to the property
%                 p.SetMethod = @(o, v) o.set_tableprop(ceVars{iVar}, v);
% %                 % Add add its value
% %                 this.(ceProps{iProp}) = tbl.(ceProps{iProp});
%             end
%             
%         end
        
    end
    
    
    %% GETTERS
    methods
        
        function flag = get.SIUnitX(this)
            %% GET.SIUNITX returns flag if siunitx package should be used
            
            
            flag = this.table_userdata('SIUnitX', 'off');
            
        end
        
        
        function f = get.Filename(this)
            %% GET.FILENAME returns the filename stored on this table
            
            
            f = this.table_userdata('Filename');
            
        end
        
        
        function flag = get.TableEnv(this)
            %% GET.TABLEENV returns flag if the `tabular` should be wrapped in a `table` env
            
            
            flag = this.table_userdata('TableEnv', 'off');
            
        end
        
        
        function flag = get.Rulers(this)
            %% GET.RULERS returns flag if rulers should be typeset or not
            
            
            flag = this.table_userdata('Rulers', 'off');
            
        end
        
        
        function flag = get.Booktabs(this)
            %% GET.BOOKTABS returns flag if booktabs should be used for rules
            
            
            flag = this.table_userdata('Booktabs', 'off');
            
        end
        
        
        function f = get.Caption(this)
            %% GET.CAPTION returns the table's caption
            
            
            f = this.table_userdata('Caption');
            
        end
        
        
        function l = get.Label(this)
            %% GET.LABEL returns the table's label
            
            
            l = this.table_userdata('Label');
            
        end
        
        
        function flag = get.Centering(this)
            %% GET.CENTERING returns flag if tabular should be centered or not
            
            
            flag = this.table_userdata('Centering', 'off');
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function writetable(this, varargin)
            %% WRITETABLE writes this TEXTABLE to a TeX file
            
            
            % Combine all args
            args = [{this}, varargin];
            % Find the first TEXTABLE object
            this = args{find(cellfun(@(x) isa(x, 'textable'), args), 1, 'first')};
            varargin = args(~cellfun(@(x) isa(x, 'textable'), args));
            
            % Get the filename that is passed as an argument (or not, we'll
            % never know
            if numel(varargin) > 0
                chFilename = varargin{1};
            else
                % Check this object for a filename
                if ~isempty(this.Filename)
                    chFilename = this.Filename;
                else
                    % Check table's user data for a 'Name'
                    if ~isempty(this.table_userdata('Name'))
                        chFilename = this.table_userdata('Name');
                    % No filename found, so we will fallback to a filename based
                    % on the variable's name
                    else
                        if ~isempty(inputname(1))
                            chFilename = inputname(1);
                        else
                            chFilename = 'table.tex';
                        end
                    end
                end
            end
            
            % Split the filename
            [chFile_Path, chFile_Name, ~] = fileparts(chFilename);
            % Set the default extension
            chFile_Ext = '.tex';
            % Build the final filename
            chFile = fullfile(chFile_Path, [chFile_Name, chFile_Ext]);
            
            % Now write the file
            try
                % Open file
                hFid = fopen(chFile, 'w');
                
                % Cleanup object
                coCleaner = onCleanup(@() fclose(hFid));
                
                % Table header
                if strcmp('on', this.TableEnv)
                    % Open the table
                    textable.open_env(hFid, 'table');
                    fprintf(hFid, '\n');
                    
                    % Center table?
                    if strcmp('on', this.Centering)
                        textable.write_macro(hFid, 'centering');
                        fprintf(hFid, '\n');
                    end
                    
                    % Write a caption?
                    if ~isempty(this.Caption)
                        textable.write_macro(hFid, 'caption', this.Caption);
                        fprintf(hFid, '\n');
                    end
                    
                    % Write a label?
                    if ~isempty(this.Label)
                        textable.write_macro(hFid, 'label', this.Label);
                        fprintf(hFid, '\n');
                    end
                end
                
                % Some information about the table
                nColumns = size(this.Table_, 2);
                nRows = size(this.Table_, 1);
                
                % Whether table has a first column or not
                loFirstColumn = ~isempty(this.Table_.Properties.RowNames);
                
                % We need to know the data type of every columun
                ceDatatypes = cell(1, nColumns);
                for iData = 1:nColumns
                    % Any numeric values must be formatted as numbers in LaTeX
                    if isa(this.Table_.(iData), 'numeric')
                        ceDatatypes{iData} = 'numeric';
                    % Logical values are going to be signed integers
                    elseif isa(this.Table_.(iData), 'logical')
                        ceDatatypes{iData} = 'logical';
                    % Cell array for the column => string for each row
                    elseif isa(this.Table_.(iData), 'cell')
                        ceDatatypes{iData} = 'char';
                    % No matching data type
                    else
                        ceDatatypes{iData} = '';
                    end
                end
                
                % Build the row formatting for the data
                ceFormat = cell(1, nColumns);
                
                % Loop over each column and inspect its type so that we can
                % infer its formatting from that
                for iData = 1:nColumns
                    switch ceDatatypes{iData}
                        case 'numeric'
                            % With the siunitx package enabled, the column is
                            % parsed as an 'S'-alignment thus no math env is
                            % required
                            if strcmp('on', this.SIUnitX)
                                ceFormat{iData} = '%.12f';
                            % No SIUnitX => regular math number
                            else
                                ceFormat{iData} = '$%.6f$';
                            end
                        case 'logical'
                            % With the siunitx package enabled, the column is
                            % parsed as an 'S'-alignment thus no math env is
                            % required
                            if strcmp('on', this.SIUnitX)
                                ceFormat{iData} = '%d';
                            % No SIUnitX => regular math number
                            else
                                ceFormat{iData} = '$%d$';
                            end
                        case 'char'
                            ceFormat{iData} = '%s';
                        otherwise
                            ceFormat{iData} = 'n/a';
                    end
                end
                
                % Find the alignment of the columns
                if isfield(this.Table_.Properties, 'Alignment')
                    ceAlignment = this.Table_.Properties.Alignment;
                else
                    % With siunitx package, we have numeric columns aligned as
                    % 'S' and other data types aligned as 'l'
                    if strcmp('on', this.SIUnitX)
                        ceAlignment = cell(1, nColumns);
                        [ceAlignment{strcmp(ceDatatypes, 'numeric')}] = deal('S');
                        [ceAlignment{strcmp(ceDatatypes, 'logical')}] = deal('S');
                        [ceAlignment{strcmp(ceDatatypes, 'char')}] = deal('l');
                    % No specific formatting, so everything is left-aligned as
                    % per good scientific standards
                    else
                        ceAlignment = repmat({'l'}, 1, nColumns);
                    end
                end
                
                % Add an alignment for the first column
                if loFirstColumn
                    ceAlignment = [{'l'}, ceAlignment];
                end
                
                % Open the tabular
                textable.open_env(hFid, 'tabular');
                fprintf(hFid, '{ %s }', strjoin(ceAlignment, ' '));
                
                % Do we have a header?
                ceHeader = this.Table_.Properties.VariableNames;
                if ~isempty(ceHeader)
                    % Top rule or not
                    if strcmp('on', this.Rulers)
                        if strcmp('on', this.Booktabs)
                            fprintf(hFid, '\\toprule');
                        else
                            fprintf(hFid, '\\hline');
                        end
                    end
                    % Break line
                    fprintf(hFid, '\n');
                    % Add additional spacing for the first column?
                    if loFirstColumn
                        fprintf(hFid, ' & ');
                    end
                    
                    % Fix headers for siunitx package where column type is 'S'
                    ceHeader(contains(ceDatatypes, {'numeric', 'logical'})) = cellfun(@(h) sprintf('{%s}', h), ceHeader(contains(ceDatatypes, {'numeric', 'logical'})), 'UniformOutput', false);
                    
                    % Set all headers
                    fprintf(hFid, '%s ', strjoin(ceHeader, ' & '));
                    % Add a tabular newline
                    fprintf(hFid, '\\\\');
                    
                    % Mid rule or not
                    if strcmp('on', this.Rulers)
                        if strcmp('on', this.Booktabs)
                            fprintf(hFid, ' \\midrule');
                        else
                            fprintf(hFid, ' \\hline');
                        end
                    end
                end
                
                % New line
                fprintf(hFid, '\n');
                
                % Now we can add the data
                for iData = 1:nRows
                    % Add the RowNames?
                    if loFirstColumn
                        fprintf(hFid, '%s', this.Table_.Properties.RowNames{iData});
                        fprintf(hFid, ' & ');
                    end
                    
                    % Loop over each column
                    for iColumn = 1:nColumns
                        % Get the table's entry
                        mxEntry = this.Table_{iData,iColumn};
                        
                        % Strip down from a cell to a char
                        if isa(mxEntry, 'cell')
                            mxEntry = char(mxEntry);
                        end
                        
                        % And write to file
                        fprintf(hFid, ceFormat{iColumn}, mxEntry);
                        
                        % Column separator
                        if iColumn ~= nColumns
                            fprintf(hFid, ' & ');
                        end
                    end
                    
                    % End the row
                    fprintf(hFid, ' \\\\');
                    
                    % Switch to new line
                    if iData ~= nRows
                        % And newline
                        fprintf(hFid, '\n');
                    end
                end
                
                % Bottom rule
                if strcmp('on', this.Rulers)
                    if strcmp('on', this.Booktabs)
                        fprintf(hFid, ' \\bottomrule');
                    else
                        fprintf(hFid, ' \\hline');
                    end
                end
                
                % And newline
                fprintf(hFid, '\n');
                
                % Close the tabular
                textable.close_env(hFid, 'tabular');
                fprintf(hFid, '\n');
                
                % Close the table
                if strcmp('on', this.TableEnv)
                    textable.close_env(hFid, 'table');
                    fprintf(hFid, '\n');
                end
                
            catch me
                throwAsCaller(me);
            end
            
        end
        
%         function varargout = subsref(this, s)
%             %% SUBSREF
%             
%             
%             switch s(1).type
%                 case '.'
%                     if length(s) == 1
%                         % Implement obj.PropertyName
%                         % Check if the requested property is one of this object
%                         if ~isprop(this, s(1).subs)
%                             varargout{1} = this.Table_.(s(1).subs);
%                         else
%                             varargout{1} = this.(s(1).subs);
%                         end
%                     elseif length(s) == 2 && strcmp(s(2).type,'()')
%                         % Implement obj.PropertyName(indices)
%                         % If the property cannot be found on this object, we
%                         % will pass it down to the table
%                         if ~isprop(this, s(1).subs)
%                             varargout{1} = this.Table_.(s(1).subs)(s(2).subs{:});
%                         % Property exists on this object, so get that one
%                         else
%                             varargout{1} = this.(s(1).subs)(s(2).subs{:});
%                         end
%                     else
%                         [varargout{1:nargout}] = builtin('subsref', this, s);
%                     end
%                 case '()'
% %                     if length(s) == 1
% %                         % Implement obj(indices)
% %                         ...
% %                     elseif length(s) == 2 && strcmp(s(2).type, '.')
% %                         % Implement obj(ind).PropertyName
% %                         ...
% %                     elseif length(s) == 3 && strcmp(s(2).type, '.') && strcmp(s(3).type, '()')
% %                         % Implement obj(indices).PropertyName(indices)
% %                         ...
% %                     else
%                         % Use built-in for any other expression
%                         [varargout{1:nargout}] = builtin('subsref', this, s);
% %                     end
%                 case '{}'
% %                     if length(s) == 1
% %                         % Implement obj{indices}
% %                         ...
% %                     elseif length(s) == 2 && strcmp(s(2).type, '.')
% %                         % Implement obj{indices}.PropertyName
% %                         ...
% %                     else
%                         % Use built-in for any other expression
%                         [varargout{1:nargout}] = builtin('subsref', this, s);
% %                     end
%                 otherwise
%                     error('Not a valid indexing expression')
%             end
%         end
        
        
%         function this = subsasgn(this, s, varargin)
%             %% SUBSASGN 
%             
%             
%             switch s(1).type
%                 case '.'
%                     if length(s) == 1
%                         % Implement obj.PropertyName = varargin{:};
%                         ...
%                     elseif length(s) == 2 && strcmp(s(2).type, '()')
%                         % Implement obj.PropertyName(indices) = varargin{:};
%                         ...
%                     else
%                         % Call built-in for any other case
%                         this = builtin('subsasgn', this, s,varargin);
%                     end
%                 case '()'
%                     if length(s) == 1
%                         % Implement obj(indices) = varargin{:};
%                     elseif length(s) == 2 && strcmp(s(2).type, '.')
%                         % Implement obj(indices).PropertyName = varargin{:};
%                         ...
%                     elseif length(s) == 3 && strcmp(s(2).type, '.') && strcmp(s(3).type, '()')
%                         % Implement obj(indices).PropertyName(indices) = varargin{:};
%                         ...
%                     else
%                         % Use built-in for any other expression
%                         this = builtin('subsasgn', this, s, varargin);
%                     end         
%                 case '{}'
%                     if length(s) == 1
%                         % Implement obj{indices} = varargin{:}
%                         ...
%                     elseif length(s) == 2 && strcmp(s(2).type, '.')
%                         % Implement obj{indices}.PropertyName = varargin{:}
%                         ...
%                         % Use built-in for any other expression
%                         this = builtin('subsasgn', this, s, varargin);
%                     end
%                 otherwise
%                     error('Not a valid indexing expression')
%             end
%         end
        
    end
    
    
    
    %% PROTECTED STATIC METHODS
    methods ( Static, Access = protected )
        
        function open_env(hFid, env, varargin)
            %% OPEN_ENV opens a LaTeX environment
            %
            %   OPEN_ENV(HFID, ENV) writes the opener for environment ENV to the
            %   file identified by handle HFID.
            
            
            try
                % TEXTABLE.OPEN_ENV(HFID, ENV)
                % TEXTABLE.OPEN_ENV(HFID, ENV, OPTIONAL)
                narginchk(2, 3);
                % TEXTABLE.OPEN_ENV(HFID, ENV)
                nargoutchk(0, 0);
                % Validate file handle
                validateattributes(hFid, {'numeric'}, {'nonempty', 'positive'}, mfilename, 'hFid');
                % Validate environment
                validateattributes(env, {'char'}, {'nonempty'}, mfilename, 'env');
            catch me
                throwAsCaller(me);
            end
            
            % Write env begin
            fprintf(hFid, '\\begin');
            % Write optional arguments?
            if nargin > 2
                fprintf(hFid, '[%s]', varargin{1});
            end
            % Environment name
            fprintf(hFid, '{%s}', env);
            
        end
        
        
        function close_env(hFid, env)
            %% CLOSE_ENV closes a LaTeX environment
            %
            %   CLOSE_ENV(HFID, ENV) writes the closer for environment ENV to
            %   the file identified by handle HFID.
            
            
            try
                % TEXTABLE.CLOSE_ENV(HFID, ENV)
                narginchk(2, 2);
                % TEXTABLE.CLOSE_ENV(HFID, ENV)
                nargoutchk(0, 0);
                % Validate file handle
                validateattributes(hFid, {'numeric'}, {'nonempty', 'positive'}, mfilename, 'hFid');
                % Validate environment
                validateattributes(env, {'char'}, {'nonempty'}, mfilename, 'env');
            catch me
                throwAsCaller(me);
            end
            
            % Write env end
            fprintf(hFid, '\\end{%s}', env);
            
        end
        
        
        function write_macro(hFid, macro, varargin)
            %% WRITE_MACRO writes a macro with arguments to the file
            %
            %   WRITE_MACRO(HFID, MACRO) writes a macro call to the macro MACRO
            %   to the file identified by handle HFID.
            %
            %   WRITE_MACRO(HFID, MACRO, REQUIRED) writes the additional
            %   required argument string REQUIRED to the macro call.
            %
            %   WRITE_MACRO(HFID, MACRO, REQUIRED, OPTIONAL) writes the
            %   additional optional argument sring OPTIONAL to the macro call.
            
            
            try
                % TEXTABLE.WRITE_MACRO(HFID, MACRO)
                % TEXTABLE.WRITE_MACRO(HFID, MACRO, REQUIRED)
                % TEXTABLE.WRITE_MACRO(HFID, MACRO, REQUIRED, OPTIONAL)
                narginchk(2, 4);
                % TEXTABLE.WRITE_MACRO(HFID, MACRO)
                nargoutchk(0, 0);
                % Validate file handle
                validateattributes(hFid, {'numeric'}, {'nonempty', 'positive'}, mfilename, 'hFid');
                % Validate macro
                validateattributes(macro, {'char'}, {'nonempty'}, mfilename, 'macro');
            catch me
                throwAsCaller(me);
            end
            
            % Macro call
            fprintf(hFid, '\\%s', macro);
            
            % Optional argument
            if nargin > 3
                fprintf(hFid, '[%s]', varargin{2});
            end
            
            % Required argument
            if nargin > 2
                fprintf(hFid, '{%s}', varargin{1});
            end
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function this = set_tableprop(this, p, v)
            %% SET_TABLEPROP sets a property on the table
            
            
            this.Table_.(p) = v;
            
        end
        
        
        function v = get_tableprop(this, p)
            %% GET_TABLEPROP gets a property from the table
            
            
            v = this.Table_.(p);
            
        end
        
        
        function v = table_userdata(this, f, d)
            %% TABLE_USERDATA returns data from the table's UserData structure
            %
            %   V = TABLE_USERDATA(FIELD) returns the value for field FIELD. If
            %   field FIELD does not exist, it returns [].
            %
            %   V = TABLE_USERDATA(FIELD, DEFAULT) returns default value DEFAULT
            %   if the field FIELD does not exist
            
            
            
            try
                % TABLE_USERDATA(TEXTABLE, FIELD)
                % TABLE_USERDATA(TEXTABLE, FIELD, DEFAULT)
                narginchk(2, 3);
                
                % TABLE_USERDATA(TEXTABLE, FIELD, ...)
                % V = TABLE_USERDATA(TEXTABLE, FIELD, ...)
                nargoutchk(0, 1);
                
                % FIELD must be char
                validateattributes(f, {'char'}, {'nonempty'}, mfilename, 'Field');
                
                % Default `default` value
                if nargin < 3
                    d = [];
                end
            catch me
                throwAsCaller(me);
            end
            
            % Check field exists
            if isfield(this.Table_.Properties, 'UserData') && isfield(this.Table_.Properties.UserData, f)
                % Get value
                v = this.Table_.Properties.UserData.(f);
            % Field does not exist
            else
                v = d;
            end
            
        end
        
    end
    
end
