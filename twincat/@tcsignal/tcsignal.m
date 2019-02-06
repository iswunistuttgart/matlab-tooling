classdef ( CaseInsensitiveProperties = true ) tcsignal < timeseries
  %% TCSIGNAL is an empty twincat signal TwinCat signal time series object
  
  
  
  %% PUBLIC PROPERTIES
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
  
  
  
  %% GENERAL METHODS
  methods
    
    function this = tcsignal(varargin)
      %% TCSIGNAL creates a new TwinCat signal object
      
      
      % Call parent constructor
      this = this@timeseries(varargin{:});
      
    end
    
  end
  
  
  
  %% CONVERSION
  methods
    
    function y = fft(this, varargin)
      %% FFT Wrap FFT on this TCSIGNAL object
      
      
      % Simple as that
      y = fft(this.Data, varargin{:});
      
    end
    
    
    function y = fftshift(this, varargin)
      %% FFTSHIFT Wrap FFTSHIFT on this TCSIGNAL object
      
      
      % Pass along
      y = fftshift(this.Data, varargin{:});
      
    end
    
  end
  
  
  
  %% GETTERS
  methods
    
    function st = get.SampleTime(this)
      %% GET.SAMPLETIME gets the sample time in milliseconds
      
      
      st = this.TimeInfo.Increment*1000;
      
    end
    
    
    function ni = get.NetId(this)
      %% GET.NETID returns the NetID of the signal
      
      
      ni = getUserDataProp(this, 'NetId');
      
    end
    
    
    function p = get.Port(this)
      %% GET.NETID returns the NetID of the signal
      
      
      p = getUserDataProp(this, 'Port');
      
    end
    
    
    function p = get.SymbolBased(this)
      %% GET.SYMBOLBASED


      p = getUserDataProp(this, 'SymbolBased');

    end


    function p = get.SymbolName(this)
      %% GET.SYMBOLNAME


      p = getUserDataProp(this, 'SymbolName');

    end


    function p = get.SymbolComment(this)
      %% GET.SYMBOLCOMMENT


      p = getUserDataProp(this, 'SymbolComment');

    end


    function p = get.IndexGroup(this)
      %% GET.INDEXGROUP


      p = getUserDataProp(this, 'IndexGroup');

    end


    function p = get.IndexOffset(this)
      %% GET.INDEXOFFSET


      p = getUserDataProp(this, 'IndexOffset');

    end


    function p = get.DataType(this)
      %% GET.DATATYPE


      p = getUserDataProp(this, 'DataType');

    end


    function p = get.VariableSize(this)
      %% GET.VARIABLESIZE


      p = getUserDataProp(this, 'VariableSize');

    end


    function p = get.Offset(this)
      %% GET.OFFSET


      p = getUserDataProp(this, 'Offset');

    end


    function p = get.ScaleFactor(this)
      %% GET.SCALEFACTOR


      p = getUserDataProp(this, 'ScaleFactor');

    end


    function p = get.BitMask(this)
      %% GET.BITMASK


      p = getUserDataProp(this, 'BitMask');

    end


    function p = get.File(this)
      %% GET.FILE


      p = getUserDataProp(this, 'File');

    end


    function p = get.StartRecord(this)
      %% GET.STARTRECORD


      p = getUserDataProp(this, 'StartRecord');

    end


    function p = get.EndRecord(this)
      %% GET.ENDRECORD


      p = getUserDataProp(this, 'EndRecord');

    end
    
  end
  
  
  
  %% SETTERS
  methods
    
    function this = set.SampleTime(this, SampleTime)
      %% SET.SAMPLETIME set the sample time in milli seconds
      
      this = setuniformtime(this, 'StartTime', this.TimeInfo.Start, 'Interval', SampleTime / 1000);
      
    end
    
    
    function this = set.NetId(this, NetId)
      %% SET.NETID


      this = setUserDataProp(this, 'NetId', NetId);

    end
    
    
    function this = set.Port(this, Port)
      %% SET.PORT


      this = setUserDataProp(this, 'Port', Port);

    end
    
    
    function this = set.SymbolBased(this, SymbolBased)
      %% SET.SYMBOLBASED


      this = setUserDataProp(this, 'SymbolBased', SymbolBased);

    end


    function this = set.SymbolName(this, SymbolName)
      %% SET.SYMBOLNAME


      this = setUserDataProp(this, 'SymbolName', SymbolName);

    end


    function this = set.SymbolComment(this, SymbolComment)
      %% SET.SYMBOLCOMMENT


      this = setUserDataProp(this, 'SymbolComment', SymbolComment);

    end


    function this = set.IndexGroup(this, IndexGroup)
      %% SET.INDEXGROUP


      this = setUserDataProp(this, 'IndexGroup', IndexGroup);

    end


    function this = set.IndexOffset(this, IndexOffset)
      %% SET.INDEXOFFSET


      this = setUserDataProp(this, 'IndexOffset', IndexOffset);

    end


    function this = set.DataType(this, DataType)
      %% SET.DATATYPE


      this = setUserDataProp(this, 'DataType', DataType);

    end


    function this = set.VariableSize(this, VariableSize)
      %% SET.VARIABLESIZE


      this = setUserDataProp(this, 'VariableSize', VariableSize);

    end


    function this = set.Offset(this, Offset)
      %% SET.OFFSET


      this = setUserDataProp(this, 'Offset', Offset);

    end


    function this = set.ScaleFactor(this, ScaleFactor)
      %% SET.SCALEFACTOR


      this = setUserDataProp(this, 'ScaleFactor', ScaleFactor);

    end


    function this = set.BitMask(this, BitMask)
      %% SET.BITMASK


      this = setUserDataProp(this, 'BitMask', BitMask);

    end


    function this = set.File(this, File)
      %% SET.FILE


      this = setUserDataProp(this, 'File', File);

    end


    function this = set.StartRecord(this, StartRecord)
      %% SET.STARTRECORD


      this = setUserDataProp(this, 'StartRecord', StartRecord);

    end


    function this = set.EndRecord(this, EndRecord)
      %% SET.ENDRECORD


      this = setUserDataProp(this, 'EndRecord', EndRecord);

    end
    
  end
  
  
  
  %% PROTECTED METHODS
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
