classdef ( CaseInsensitiveProperties = true ) tcsignal < timeseries
    % TCSIGNAL is an empty twincat signal TwinCat signal time series object
    
    
    
    %%     PROPERTIES    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
        
        function this = tcsignal(varargin)
            %% TCSIGNAL creates a new TwinCat signal object
            
            
            % Call parent constructor
            this = this@timeseries(varargin{:});
        end
        
    end
    
    
    %%    GETTERS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function st = get.SampleTime(this)
            %% GET.SAMPLETIME gets the sample time in milliseconds
            
            
            st = this.TimeInfo.Increment*1000;
            
        end
        
        
        function ni = get.NetId(this)
            %% GET.NETID returns the NetID of the signal
            
            
            ni = this.getUserDataProp('NetId');
            
        end
        
        
        function p = get.Port(this)
            %% GET.NETID returns the NetID of the signal
            
            
            p = this.getUserDataProp('Port');
            
        end
        
        
        function p = get.SymbolBased(this)
            %% GET.SYMBOLBASED


            p = this.getUserDataProp('SymbolBased');

        end


        function p = get.SymbolName(this)
            %% GET.SYMBOLNAME


            p = this.getUserDataProp('SymbolName');

        end


        function p = get.SymbolComment(this)
            %% GET.SYMBOLCOMMENT


            p = this.getUserDataProp('SymbolComment');

        end


        function p = get.IndexGroup(this)
            %% GET.INDEXGROUP


            p = this.getUserDataProp('IndexGroup');

        end


        function p = get.IndexOffset(this)
            %% GET.INDEXOFFSET


            p = this.getUserDataProp('IndexOffset');

        end


        function p = get.DataType(this)
            %% GET.DATATYPE


            p = this.getUserDataProp('DataType');

        end


        function p = get.VariableSize(this)
            %% GET.VARIABLESIZE


            p = this.getUserDataProp('VariableSize');

        end


        function p = get.Offset(this)
            %% GET.OFFSET


            p = this.getUserDataProp('Offset');

        end


        function p = get.ScaleFactor(this)
            %% GET.SCALEFACTOR


            p = this.getUserDataProp('ScaleFactor');

        end


        function p = get.BitMask(this)
            %% GET.BITMASK


            p = this.getUserDataProp('BitMask');

        end


        function p = get.File(this)
            %% GET.FILE


            p = this.getUserDataProp('File');

        end


        function p = get.StartRecord(this)
            %% GET.STARTRECORD


            p = this.getUserDataProp('StartRecord');

        end


        function p = get.EndRecord(this)
            %% GET.ENDRECORD


            p = this.getUserDataProp('EndRecord');

        end
        
    end
    
    
    %%    SETTERS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        function this = set.SampleTime(this, SampleTime)
            %% SET.SAMPLETIME set the sample time in milli seconds
            
            this = this.setuniformtime('StartTime', this.TimeInfo.Start, 'Interval', SampleTime./1000);
            
        end
        
        
        function this = set.NetId(this, NetId)
            %% SET.NETID


            this = this.setUserDataProp('NetId', NetId);

        end
        
        
        function this = set.Port(this, Port)
            %% SET.PORT


            this = this.setUserDataProp('Port', Port);

        end
        
        
        function this = set.SymbolBased(this, SymbolBased)
            %% SET.SYMBOLBASED


            this = this.setUserDataProp('SymbolBased', SymbolBased);

        end


        function this = set.SymbolName(this, SymbolName)
            %% SET.SYMBOLNAME


            this = this.setUserDataProp('SymbolName', SymbolName);

        end


        function this = set.SymbolComment(this, SymbolComment)
            %% SET.SYMBOLCOMMENT


            this = this.setUserDataProp('SymbolComment', SymbolComment);

        end


        function this = set.IndexGroup(this, IndexGroup)
            %% SET.INDEXGROUP


            this = this.setUserDataProp('IndexGroup', IndexGroup);

        end


        function this = set.IndexOffset(this, IndexOffset)
            %% SET.INDEXOFFSET


            this = this.setUserDataProp('IndexOffset', IndexOffset);

        end


        function this = set.DataType(this, DataType)
            %% SET.DATATYPE


            this = this.setUserDataProp('DataType', DataType);

        end


        function this = set.VariableSize(this, VariableSize)
            %% SET.VARIABLESIZE


            this = this.setUserDataProp('VariableSize', VariableSize);

        end


        function this = set.Offset(this, Offset)
            %% SET.OFFSET


            this = this.setUserDataProp('Offset', Offset);

        end


        function this = set.ScaleFactor(this, ScaleFactor)
            %% SET.SCALEFACTOR


            this = this.setUserDataProp('ScaleFactor', ScaleFactor);

        end


        function this = set.BitMask(this, BitMask)
            %% SET.BITMASK


            this = this.setUserDataProp('BitMask', BitMask);

        end


        function this = set.File(this, File)
            %% SET.FILE


            this = this.setUserDataProp('File', File);

        end


        function this = set.StartRecord(this, StartRecord)
            %% SET.STARTRECORD


            this = this.setUserDataProp('StartRecord', StartRecord);

        end


        function this = set.EndRecord(this, EndRecord)
            %% SET.ENDRECORD


            this = this.setUserDataProp('EndRecord', EndRecord);

        end
        
    end
    
    
    
    %%    PROTECTED METHODS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods ( Access = protected )
        
        function val = getUserDataProp(this, prop)
            %% GETUSERDATAPROP gets a property from the UserData structure
            
            
            % If the field exists, get it
            if isfield(this.UserData, prop)
                val = this.UserData.(prop);
            % Field does not exist
            else
                val = [];
            end
            
        end
        
        
        function this = setUserDataProp(this, prop, val)
            %% SETUSERDATAPROP sets a property on the UserData structure
            
            
            % Set the property
            this.UserData.(prop) = val;
            
        end
        
    end
    
end
