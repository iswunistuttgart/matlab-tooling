classdef ( Abstract ) artist < handle & matlab.mixin.Heterogeneous
  %% ARTIST The main component of an animation, something that knows how to draw itself
  
  
  %% PROPERTIES
  properties
    
    % Start function callbacks
    % @(OBJ, IND)
    %   OBJ             Graphics object the update is being executed on
    %   IND             Counter indeex of execution
    StartFcn = {}
    
    % Update function callbacks
    % @(OBJ, IND)
    %   OBJ             Graphics object the update is being executed on
    %   IND             Counter indeex of execution
    UpdateFcn = {}
    
    % Stop function callbacks
    % @(OBJ, IND)
    %   OBJ             Graphics object the update is being executed on
    %   IND             Counter indeex of execution
    StopFcn = {}
    
    % Artist's properties
    Properties = {}
    
  end
  
  
  
  %% ABSTRACT METHODS
  methods ( Abstract )
    
    start(this)
    %% START
    
    
    update(this)
    %% UPDATE
    
    
    stop(this)
    %% STOP
    
  end
  
  
  
  %% GENERAL METHODS
  methods
    
    function this = artist(varargin)
      %% ARTIST
      
      
      % Input parser
      persistent ip
      if isempty(ip)
        ip = inputParser();
        
        % StartFcn
        addParameter(ip, 'StartFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StartFcn'));
        
        % UpdateFcn
        addParameter(ip, 'UpdateFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'UpdateFcn'));
        
        % StopFcn
        addParameter(ip, 'StopFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StopFcn'));
        
        % Further configuration of IP
        ip.FunctionName = mfilename();
        ip.KeepUnmatched = true;
        
      end
      
      % Parse arguments
      try
        parse(ip, varargin{:});
      catch me
        throwAsCaller(me);
      end
      
      % Assign valid parsed arguments
      if isa(ip.Results.StartFcn, 'function_handle')
        this.StartFcn = {ip.Results.StartFcn};
      else
        this.StartFcn = ip.Results.StartFcn;
      end
      if isa(ip.Results.UpdateFcn, 'function_handle')
        this.UpdateFcn = {ip.Results.UpdateFcn};
      else
        this.UpdateFcn = ip.Results.UpdateFcn;
      end
      if isa(ip.Results.StopFcn, 'function_handle')
        this.StopFcn = {ip.Results.StopFcn};
      else
        this.StopFcn= ip.Results.StopFcn;
      end
      
      % Store unmatched properties
      this.Properties = unmatchedcell(ip.Unmatched);
      
    end
    
  end
  
  
  
  %% FUNCTION CALLBACK METHODS
  methods
    
    function start_fcn(this, varargin)
      %% START_FCN
      
      
      cellfun(@(f) feval(f, varargin{:}), this.StartFcn);
      
    end
    
    
    function update_fcn(this, varargin)
      %% UPDATE_FCN
      
      
      cellfun(@(f) feval(f, varargin{:}), this.UpdateFcn);
      
    end
    
    
    function stop_fcn(this, varargin)
      %% STOP_FCN
      
      
      cellfun(@(f) feval(f, varargin{:}), this.StopFcn);
      
    end
    
  end
  
end
