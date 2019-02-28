classdef axis < animatlab.artist
  %% AXIS
  
  
  %% PROPERTIES
  properties
    
    % Axis object
    Axis%@matlab.graphics.axis.Axes
    
    % Parent object: conductor
    Parent@animatlab.conductor
    
    % All animation children
    Children@animatlab.graph
    
    % NMP
    NMP = {1, 1, 1};
    
  end
  
  
  
  %% GENERAL METHODS
  methods
    
    function this = axis(varargin)
      %% AXIS Create a new axis object
      %
      %   AXIS(G1, G2, ...) creates a new axis object with graphics objects G1,
      %   G2, etc.
      %   
      %   AXIS([N, M, P], G1, G2, ...) creates an axis object much like a
      %   subplot axis object over N rows, M columns, and pushes into the P-th
      %   subplot.
      
      
      % AXIS(NMP, G1, G2, ...)
      % AXIS(N, M, P, G1, G2, ...)
      if isnumeric(varargin{1})
        % AXIS(NMP, G1, G2, ...)
        if nargin > 1 && ~isnumeric(varargin{2}) && ~isempty(varargin{1})
          % Get that scalar value
          nmp = varargin(1);
          % And pop it off the array
          varargin(1) = [];
        % AXIS(N, M, P, G1, G2, ...)
        else
          % Get first three arguments
          nmp = varargin(1:3);
          % Pop off first three arguments
          varargin(1:3) = [];
        end
      else
      % AXIS(G1, G2, ...)
        nmp = {1, 1, 1};
      end
      
      % Assign children
      chil = [varargin{cellfun(@(o) isa(o, 'animatlab.graph'), varargin)}];
      varargin(cellfun(@(o) isa(o, 'animatlab.graph'), varargin)) = [];
      
      % Call parent constructor
      this = this@animatlab.artist(varargin{:});
      
      % Store the retrieved axis style
      this.NMP = nmp;
      
      % Store all extracted children
      this.Children = chil;
      
    end
    
  end
  
  
  
  %% SETTERS
  methods
    
    function set.Children(this, c)
      %% SET.CHILDREN
      
      
      % Assign children
      this.Children = c;
      
      % Set parent on the children objects
      [this.Children.Parent] = deal(this);
      
    end
    
  end
  
  
  
  %% ANIMATION METHODS
  methods
    
    function start(this, tmr, evt)
      %% START
      
      
      % Make the axes object
      this.Axis = subplot( ...
        this.NMP{:} ...
        , 'Parent', this.Parent.Figure ...
      );
      
      % Add to axes
      this.Axis.NextPlot = 'add';
      
      % Start all children
      arrayfun(@start, this.Children);
      
      % Set axis properties
      if ~isempty(this.Properties)
        set( ...
          this.Axis ...
          , this.Properties{:} ...
        );
      end
      
      % No more adding to axes
      this.Axis.NextPlot = 'replace';
      
      % Execute start functions
      start_fcn(this, this.Axis);
      
    end
    
    
    function update(this, tmr, evt)
      %% UPDATE
      
      
      % Update all children
      arrayfun(@update, this.Children);
      
      % Execute start functions
      update_fcn(this, this.Axis);
      
    end
    
    
    function stop(this, tmr, evt)
      %% STOP
      
      
      % Stop all children
      arrayfun(@stop, this.Children);
      
      % Execute start functions
      stop_fcn(this, this.Axis);
      
    end
    
  end
  
end
