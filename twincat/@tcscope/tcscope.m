classdef ( CaseInsensitiveProperties = true ) tcscope < tscollection
  %% TCSCOPE creates an empty TwinCat scope signal collection
  
  
  
  %% PUBLIC PROPERTIES
  properties
    
    UserData = struct();
    
  end
  
  
  %% DEPENDENT PUBLIC PROPERTIES
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
  
  
  
  %% STATIC METHODS
  methods ( Static )
    
    function this = from_csv(varargin)
      %% FROM_CSV Read a TwinCat CSV file and convert it to a TCSCOPE object
      
      
      % Wrapper for this function
      % @TODO Maybe consider moving the function here and making `csv2tcscope()`
      % an actual wrapper for `tcscope.from_csv()`...
      this = csv2tcscope(varargin{:});
      
    end
    
  end
  
  
  
  %% GENERAL METHODS
  methods
    
    function this = tcscope(varargin)
      %% TCSCOPE creates a new TwinCat scope time series collection
      
      
      this = this@tscollection(varargin{:});
      
    end
    
  end
  
  
  
  %% DATA FILTERING METHODS
  methods
    
    function that = extract(this, cb)
      %% EXTRACT Extract data wherever the callback is true
      %
      %   EXTRACT(TCSCOPE, CB) extracts signal data from the scope wherever the
      %   callback CB evaluates to true. Callback CB must be of the form
      %   `@(scope, signal)` and return 1 at the time indices to extract, 0 on
      %   time indices to discard.
      
      
      try
        validateattributes(cb, {'function_handle'}, {'nonempty'}, mfilename, 'cb');
      catch me
        throwAsCaller(me);
      end
      
      % Init return
      that = tcscope();
      
      % Loop over each member and get its corresponding property
      for k = 1:length(this.Members_)
        % Evaluate what data to keep
        idx = cb(this.Members_(k), this);
        idx(find(idx, 1, 'first')) = 0;
        
        % Create a new signal object
        ts = tcsignal();
        ts = init(ts, this.Members_(k).Data(idx,:), this.Time(idx), this.Members_(k).Quality, 'IsTimeFirst', this.Members_(k).IsTimeFirst);
%         ts.TimeInfo = this.TimeInfo;
        ts.DataInfo = this.Members_(k).DataInfo;
        ts.QualityInfo = this.Members_(k).QualityInfo;
        ts.Name = sprintf('%s', this.Members_(k).Name);
        ts.Events = this.Members_(k).Events;
        if isfield(this.Members_(k), 'TreatNaNasMissing') % UserData may not exist for <=12a saved tscollections
           ts.TreatNaNasMissing = this.Members_(k).TreatNaNasMissing;
        end
        if isfield(this.Members_(k), 'UserData') % UserData may not exist for <=11b saved tscollections
           ts.UserData = this.Members_(k).UserData;
        end
        % Add back extra fields for proper @timeseries subclass
        if isfield(this.Members_(k), 'ExtraProps') && ~isempty(this.Members_(k).ExtraProps)
          extraFields = setdiff( ...
            fields(this.Members_(k).ExtraProps) ...
            , {'Time','Data','Quality', 'DataInfo','QualityInfo','Name','IsTimeFirst','Events','Class','Length','TimeInfo','TreatNaNasMissing'} ...
          );
        
          for j = 1:numel(extraFields)
            ts = set(ts, extraFields{j}, this.Members_(k).ExtraProps.(extraFields{j}));
          end
          
        end
        
        % Append filtered TCsignal to the TCscope object
        that = addts(that, setuniformtime(ts, 'StartTime', 0, 'Interval', this.TimeInfo.Increment));
        
      end
      
    end
    
  end
  
  
  
  %% FOURIER METHODS
  methods
    
    function y = fft(this, varargin)
      %% FFT Wraps FFT on all signals in this object
      %
      %   See also:
      %   FFT
      
      
      % Wrap FFT on every TCSIGNAL object
      y = cell2mat(arrayfun(@(d) fft(d.Data, varargin{:}), this.Members_, 'UniformOutput', false).');
      
    end
    
    
    function y = fftshift(this, varargin)
      %% FFTSHIFT Wraps FFTSHIFT on all signals in this object
      %
      %   See also:
      %   FFTSHIFT
      
      
      % Wrap FFTSHIFT on every TCSIGNAL object
      y = cell2mat(arrayfun(@(d) fftshift(d.Data, varargin{:}), this.Members_, 'UniformOutput', false).');
      
    end
    
  end
  
  
  
  %% SETTERS
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
  
  
  
  %% GETTERS
  methods
    
    function file = get.File(this)
      %% SET.FILE sets the scope filename
      
      
      file = getSignalProperty(this, 'File');
      
    end
    
    
    function sr = get.StartRecord(this)
      %% SET.STARTRECORD sets the start record property
      
      
      sr = getSignalProperty(this, 'StartRecord');
      
    end
    
    
    function er = get.EndRecord(this)
      %% SET.ENDRECORD sets the end record property
      
      
      er = getSignalProperty(this, 'EndRecord');
      
    end
    
    
    function v = get.NetId(this)
      %% GET.NETID


      v = getSignalProperty(this, 'NetId');

    end


    function v = get.Port(this)
      %% GET.PORT


      v = getSignalProperty(this, 'Port');

    end


    function v = get.SampleTime(this)
      %% GET.SAMPLETIME


      v = getSignalProperty(this, 'SampleTime');

    end


    function v = get.SymbolBased(this)
      %% GET.SYMBOLBASED


      v = getSignalProperty(this, 'SymbolBased');

    end


    function v = get.SymbolName(this)
      %% GET.SYMBOLNAME


      v = getSignalProperty(this, 'SymbolName');

    end


    function v = get.SymbolComment(this)
      %% GET.SYMBOLCOMMENT


      v = getSignalProperty(this, 'get.');

    end


    function v = get.IndexGroup(this)
      %% GET.INDEXGROUP


      v = getSignalProperty(this, 'IndexGroup');

    end


    function v = get.IndexOffset(this)
      %% GET.INDEXOFFSET


      v = getSignalProperty(this, 'IndexOffset');

    end


    function v = get.DataType(this)
      %% GET.DATATYPE


      v = getSignalProperty(this, 'DataType');

    end


    function v = get.VariableSize(this)
      %% GET.VARIABLESIZE


      v = getSignalProperty(this, 'VariableSize');

    end


    function v = get.Offset(this)
      %% GET.OFFSET


      v = getSignalProperty(this, 'Offset');

    end


    function v = get.ScaleFactor(this)
      %% GET.SCALEFACTOR


      v = getSignalProperty(this, 'ScaleFactor');

    end


    function v = get.BitMask(this)
      %% GET.BITMASK


      v = getSignalProperty(this, 'BitMask');

    end
    
  end
  
  
  
  %% PROTECTED METHODS
  methods ( Access = protected )
    
    function val = getSignalProperty(this, prop)
      %% GETSIGNALPROPERTY gets a property for each signal
      
      
      % Init return
      val = cell(length(this.Members_), 1);
      
      % Loop over each member and get its corresponding property
      for iMember = 1:length(this.Members_)
        % If the signal has this data property...
        if isfield(this.Members_(iMember).UserData, prop)
          % Get it
          val{iMember} = this.Members_(iMember).UserData.(prop);
        end
        
      end
      
    end
    
    
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
