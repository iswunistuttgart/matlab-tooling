classdef ( CaseInsensitiveProperties = true ) tcscope < tscollection
    % TCSCOPE creates an empty TwinCat scope signal collection
    
    
    
    %%     PROPERTIES    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        
        UserData = struct();
        
    end
    
    
    properties ( Dependent = true )
        
        NetId
        
        Port
        
        SymbolBased
        
        SymbolName
        
        SymbolComment
        
        IndexGroup
        
        IndexOffset
        
        DataType
        
        VariableSize
        
        Offset
        
        ScaleFactor
        
        BitMask
        
        SampleTime
        
        File
        
        StartRecord
        
        EndRecord
        
    end
    
    
    
    %%     PUBLIC METHODS     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function this = tcscope(varargin)
            %% TCSCOPE creates a new TwinCat scope time series collection
            
            
            this = this@tscollection(varargin{:});
        end
        
    end
    
    
    
    %%    SETTERS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function set.File(this, File)
            %% SET.FILE sets the scope filename
            
            
            this.UserData.File = File;
        end
        
        
        function set.StartRecord(this, StartRecord)
            %% SET.STARTRECORD sets the start record property
            
            
            this.UserData.StartRecord = StartRecord;
        end
        
        
        function set.EndRecord(this, EndRecord)
            %% SET.ENDRECORD sets the end record property
            
            
            this.UserData.EndRecord = EndRecord;
        end
        
    end
    
    
    
    %%    GETTERS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function file = get.File(this)
            %% SET.FILE sets the scope filename
            
            
            file = this.UserData.File;
        end
        
        
        function sr = get.StartRecord(this)
            %% SET.STARTRECORD sets the start record property
            
            
            sr = this.UserData.StartRecord;
        end
        
        
        function er = get.EndRecord(this)
            %% SET.ENDRECORD sets the end record property
            
            
            er = this.UserData.EndRecord;
        end
        
        
        function v = get.NetId(this)
            %% GET.NETID


            v = this.getSignalProperty('NetId');

        end


        function v = get.Port(this)
            %% GET.PORT


            v = this.getSignalProperty('Port');

        end


        function v = get.SampleTime(this)
            %% GET.SAMPLETIME


            v = this.getSignalProperty('SampleTime');

        end


        function v = get.SymbolBased(this)
            %% GET.SYMBOLBASED


            v = this.getSignalProperty('SymbolBased');

        end


        function v = get.SymbolName(this)
            %% GET.SYMBOLNAME


            v = this.getSignalProperty('SymbolName');

        end


        function v = get.SymbolComment(this)
            %% GET.SYMBOLCOMMENT


            v = this.getSignalProperty('get.');

        end


        function v = get.IndexGroup(this)
            %% GET.INDEXGROUP


            v = this.getSignalProperty('IndexGroup');

        end


        function v = get.IndexOffset(this)
            %% GET.INDEXOFFSET


            v = this.getSignalProperty('IndexOffset');

        end


        function v = get.DataType(this)
            %% GET.DATATYPE


            v = this.getSignalProperty('DataType');

        end


        function v = get.VariableSize(this)
            %% GET.VARIABLESIZE


            v = this.getSignalProperty('VariableSize');

        end


        function v = get.Offset(this)
            %% GET.OFFSET


            v = this.getSignalProperty('Offset');

        end


        function v = get.ScaleFactor(this)
            %% GET.SCALEFACTOR


            v = this.getSignalProperty('ScaleFactor');

        end


        function v = get.BitMask(this)
            %% GET.BITMASK


            v = this.getSignalProperty('BitMask');

        end
        
    end
    
    
    
    %%    PROTECTED METHODS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods ( Access = protected )
        
        function val = getSignalProperty(this, prop)
            %% GETSIGNALPROPERTY gets a property for each signal
            
            
            % Init return
            val = cell(1, length(this.Members_));
            
            % Loop over each member and get its corresponding property
            for iMember = 1:length(this.Members_)
                % If the signal has this data property...
                if isfield(this.Members_(iMember).UserData, prop)
                    % Get it
                    val{iMember} = this.Members_(iMember).UserData.(prop);
                end
            end
            
        end
        
    end
    
end
