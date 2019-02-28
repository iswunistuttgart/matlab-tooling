classdef graph < animatlab.artist
  %% GRAPH
  
  
  %% GRAPH PROPERTIES
  properties
    
    % Data index corresponding to the current time
    Index = 1
    
    XData
    
    YData
    
    ZData
    
    UData
    
    VData
    
    WData
    
    CData
    
    % Graph object
    Graph
    
    % Plot function
    GraphFcnStr
    
    % Parent object of the graph: axis
    Parent@animatlab.axis
    
  end
  
  
  %% DEPENDENT PROPERTIES
  properties ( Dependent )
    
    % Plot function callback
    GraphFcn
    
  end
  
  
  %% STATIC GENERATOR METEHODS
  methods ( Static )
    
    function o = plot(x, y, varargin)
      %% PLOT
      
      o = animatlab.graph(@plot, 'XData', x, 'YData', y, varargin{:});
      
    end
    
    
    function o = stairs(x, y, varargin)
      %% STAIRS
      
      
      o = animatlab.graph(@stairs, 'XData', x, 'YData', y, varargin{:});
      
    end
    
    
    function o = plot3(x, y, z, varargin)
      %% PLOT3
      
      
      o = animatlab.graph(@plot3, 'XData', x, 'YData', y, 'ZData', z, varargin{:});
      
    end
    
    
    function o = surf(x, y, z, varargin)
      %% SURF
      
      
      % SURF(X, Y, Z, C, ...)
      if nargin > 3 && isnumeric(varargin{1})
        c = varargin{1};
        varargin(1) = [];
      % SURF(X, Y, Z, ...)
      else
        c = z;
      end
      
      o = animatlab.graph(@surf, 'XData', x, 'YData', y, 'ZData', z, 'CData', c, varargin{:});
      
    end
    
    
    function o = patch(x, y, z, varargin)
      %% PATCH
      
      
      % PATCH(X, Y, Z, C, ...)
      if nargin > 3 && isnumeric(varargin{1})
        c = varargin{1};
        varargin(1) = [];
      % PATCH(X, Y, Z, ...)
      else
        c = z;
      end
      
      o = animatlab.graph(@patch, 'XData', x, 'YData', y, 'ZData', z, 'CData', c, varargin{:});
      
    end
    
    
    function o = fill3(x, y, z, varargin)
      %% FILL3
      
      
      % FILL3(X, Y, Z, C, ...)
      if nargin > 3 && isnumeric(varargin{1})
        c = varargin{1};
        varargin(1) = [];
      % FILL3(X, Y, Z, ...)
      else
        c = z;
      end
      
      o = animatlab.graph(@fill3, 'XData', x, 'YData', y, 'ZData', z, 'CData', c, varargin{:});
      
    end
    
  end
  
  
  
  %% GENERAL METHOD
  methods
    
    function this = graph(varargin)
      %% GRAPH
      
      
      ip = inputParser();
      
      addRequired(ip, 'GraphFcn', @(x) validateattributes(x, {'function_handle'}, {'nonempty'}, mfilename, 'GraphFcn'));
      
      addParameter(ip, 'XData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'XData'));
      
      addParameter(ip, 'YData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'YData'));
      
      addParameter(ip, 'ZData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'ZData'));
      
      addParameter(ip, 'UData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'UData'));
      
      addParameter(ip, 'VData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'VData'));
      
      addParameter(ip, 'WData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'WData'));
      
      addParameter(ip, 'CData', [], @(x) validateattributes(x, {'numeric'}, {'nonempty'}, mfilename, 'CData'));
      
      ip.FunctionName = funcname();
      ip.KeepUnmatched = true;
      
      try
        parse(ip, varargin{:});
      catch me
        throwAsCaller(me);
      end
      
      
      this.XData = ip.Results.XData;
      this.YData = ip.Results.YData;
      this.ZData = ip.Results.ZData;
      this.UData = ip.Results.UData;
      this.VData = ip.Results.VData;
      this.WData = ip.Results.WData;
      this.CData = ip.Results.CData;
      this.GraphFcn = ip.Results.GraphFcn;
      this.Properties = unmatchedcell(ip.Unmatched);
      
    end
    
  end
  
  
  %% SETTERS
  methods
    
    function set.GraphFcn(this, gf)
      %% SET.GRAPHFCN
      
      
      this.GraphFcnStr = func2str(gf);
      
    end
    
  end
  
  
  %% GETTERS
  methods
    
    function gf = get.GraphFcn(this)
      %% GET.GRAPHFCN
      
      
      gf = str2func(this.GraphFcnStr);
      
    end
    
  end
  
  
  
  %% ANIMATION METHODS
  methods
    
    function start(this, tmr, evt)
      %% START
      
      
      switch this.GraphFcnStr
        case 'plot'
          initData = {NaN, NaN};
          
        case 'stairs'
          initData = {NaN, NaN};
          
        case 'plot3'
          initData = {NaN, NaN, NaN};
          
        case 'surf'
          initData = {NaN, NaN, NaN, NaN};
          
        case 'patch'
          initData = {NaN, NaN, NaN, NaN};
          
        case 'fill3'
          initData = {NaN, NaN, NaN, NaN};
        
      end
      
      % Create a graph object
      this.Graph = this.GraphFcn(initData{:}, this.Properties{:});
      
      % Get the name/value pairs
      pv = make_pvpairs(this);
      
      % Set the graph data which actually plots stuff 
      set(this.Graph ...
        , pv{:} ...
      );
      
      % Execute start functions
      start_fcn(this, this.Graph);
      
    end
    
    
    function update(this, tmr, evt)
      %% UPDATE
      
      
      % Convert the stored data into a name/value pair
      pv = make_pvpairs(this);
      
      % Update graph data
      set(this.Graph ...
        , pv{:} ...
      );
      
      % Execute update functions
      update_fcn(this, this.Graph);
    
    end
    
    
    function stop(this)
      %% STOP
      
      
      % Execute stop functions
      stop_fcn(this, this.Graph);
      
    end
    
    
    function pv = make_pvpairs(this)
      %% MAKE_PVPAIRS
      
      
      idx = this.Parent.Parent.Index;
      
      switch this.GraphFcnStr
        case 'plot'
          pv = {'XData', this.XData(:,idx), 'YData', this.YData(:,idx)};
          
        case 'stairs'
          pv = {'XData', this.XData(:,idx), 'YData', this.YData(:,idx)};
          
        case 'plot3'
          pv = {'XData', this.XData(:,idx), 'YData', this.YData(:,idx), 'ZData', this.ZData(:,idx)};
          
        case 'surf'
          pv = {'XData', this.XData(:,:,idx), 'YData', this.YData(:,:,idx), 'ZData', this.ZData(:,:,idx), 'CData', this.CData(:,:,idx)};
          
        case 'patch'
          pv = {'XData', this.XData(:,:,idx), 'YData', this.YData(:,:,idx), 'ZData', this.ZData(:,:,idx), 'CData', this.CData(:,:,idx)};
          
        case 'fill3'
          pv = {'XData', this.XData(:,:,idx), 'YData', this.YData(:,:,idx), 'ZData', this.ZData(:,:,idx), 'CData', this.CData(:,:,idx)};
          
      end
      
    end
    
  end
  
end
