classdef conductor < handle
  %% CONDUCTOR Main animation conductor object
  %
  %   CONDUCTOR is the main animation object, the one that conducts all
  %   operations on each artists it is composed of. In its basic concept, a
  %   CONDUCTOR is a figure that encloses one or multiple ARTISTS, which would
  %   generally be AXES. Using the CONDUCTOR, we can conduct our animation by
  %   stepping forward or backward in time.
  
  
  
  %% READ-ONLY PROPRETIES
  properties ( SetAccess = protected )
    
    % Child objects of the conductor
    Children@animatlab.axis
    
    % Figure
    Figure@matlab.ui.Figure
    
    % Properties of figure
    Properties = {}
    
    % Timer object
    Timer@timer = timer.empty(1, 0)
    
    % Frames per second
    FPS = 25
    
    % Time vector
    Time
    
    % Index vector
    FrameIndex
    
    % Current time index
    Index = 1
    
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
    
  end
  
  
  %% DEPENDENT PUBLIC, READ-ONLY PROPERTIES
  properties ( Dependent, SetAccess = protected )
    
  end
  
  
  
  %% GENERAL METHODS
  methods
    
    function this = conductor(varargin)
      %% CONDUCTOR Create a new conductor object from a set of artists
      
      
      % Got arguments?
      if nargin > 0
        % Check if there are any axes objects
        idxAx = cellfun(@(o) isa(o, 'animatlab.axis'), varargin);
        idxAx = find(idxAx);
        
        % No axes objects found, so push all graph objects into a new axis
        % object
        if isempty(idxAx)
          % Find all graph objects
          idxGraph = cellfun(@(o) isa(o, 'animatlab.graph'), varargin);
          idxGraph = find(idxGraph);
          
          % Create an axes object from all the graph objects
          ax = { ...
            animatlab.axis( ...
              varargin{idxGraph} ...
            ) ...
          };
          
          % Remove the graph objects from the list of arguments
          varargin(idxGraph) = [];
        else
          % Get axes
          ax = [varargin{idxAx}];
          % Remove all axes from arguments
          varargin(idxAx) = [];
        end
        
        % Set axis objects
        this.Children = ax;
        
      end
      
      
      % Additional arguments parsed using an input parser
      ip = inputParser();
      
      % FPS
      addParameter(ip, 'FPS', 25, @(x) validateattributes(x, {'numeric'}, {'scalar', 'finite', 'nonempty', 'positive', 'nonnan', 'nonsparse', 'integer'}, mfilename, 'FPS'));
      
      % Time vector
      addParameter(ip, 'Time', [], @(x) validateattributes(x, {'numeric'}, {'vector', 'finite', 'nonempty', 'increasing', 'nonnan', 'nonsparse'}, mfilename, 'Time'));

      % StartFcn
      addParameter(ip, 'StartFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StartFcn'));

      % UpdateFcn
      addParameter(ip, 'UpdateFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'UpdateFcn'));

      % StopFcn
      addParameter(ip, 'StopFcn', {}, @(x) validateattributes(x, {'cell', 'function_handle'}, {'nonempty'}, mfilename, 'StopFcn'));
      
      % Configure input parser
      ip.FunctionName = funcname();
      ip.KeepUnmatched = true;
      
      % Parse all additional arguments
      try
        ip.parse(varargin{:});
      catch me
        throwAsCaller(me);
      end
      
      % Set FPS
      this.FPS = ip.Results.FPS;
      % Time vector
      if ~isempty(ip.Results.Time)
        this.Time = ip.Results.Time;
      else
        % Build a time vector that just spans over all data
        this.Time = ((1:1:last(size(this.Children(1).Children(1).XData))) - 1) ./ this.FPS;
      end
      this.Time = this.Time(:);
      
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
      
      % Convert the vector of time values and of frame time values to an index
      % vector of the data arrays
      [~, this.FrameIndex] = min(abs(this.Time - (this.Time(1):1/this.FPS:this.Time(end))));
      
      % Convert unmatched arguments to a cell
      this.Properties = unmatchedcell(ip.Unmatched);
      
    end
    
    
    function delete(this)
      %% DELETE Delete the conductor object
      
      
      % Got a valid timer object?
      if ~isempty(this.Timer) && isvalid(this.Timer)
        % Stop timer
        stop(this);
        
        % Delete this
        delete(this.Timer);
        
      end
      
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
  
  
  
  %% GETTERS
  methods
    
  end
  
  
  
  %% TIMER METHODS
  methods
    
    function varargout = timer(this, varargin)
      %% TIMER Turn the conductor into a timer object
      
      
      % Create a figure object
      this.Figure = figure();
      
      % Create a temporary timer object
      this.Timer = timer( ...
          'ExecutionMode', 'fixedDelay' ...
        , 'StartDelay', 3 ...
        , 'StartFcn', @(o, e) timer_start(this, o, e) ...
        , 'StopFcn', @(o, e) timer_stop(this, o, e) ...
        , 'TimerFcn', @(o, e) timer_update(this, o, e) ...
        , 'ErrorFcn', @(o, e) timer_error(this, o, e) ...
        , 'TasksToExecute', numel(this.FrameIndex) ...
        , 'Period', max([0.0001, round(1000/this.FPS)/1000]) ... % Make sure that Period is no smaller than 1ms
        , 'BusyMode', 'queue' ...
        , varargin{:} ...
      );
      
      % Return timer object if requested
      if nargout > 0
        varargout = {this.Timer};
      end
      
    end
    
    
    function start(this)
      %% START Start animation
      
      
      % If there is no timer object, we will create one
      if isempty(this.Timer) || ~isa(this.Timer, 'timer')
        timer(this);
      end
      
      % Start timer
      start(this.Timer);
      
    end
    
    
    function stop(this)
      %% STOP Stop running timer
      
      
      % If the timer object is valid, stop it
      if ishandle(this.Timer)
        stop(this.Timer);
      end
      
    end
    
    
    function wait(this)
      %% WAIT Wait for timer to stop before returning to command
      
      
      % Wait only on valid timers
%       if ~isempty(this.Timer) && isvalid(this.Timer)
        wait(this.Timer);
%       end
      
    end
    
    
    function timer_start(this, tmr, evt)
      %% TIMER_START
      
      
      % Start every child
      arrayfun(@(c) start(c, tmr, evt), this.Children);
      
      % Call start function
      start_fcn(this, this);
      
      % Make sure everything is draw
      drawnow();
      
    end
    
    
    function timer_update(this, tmr, evt)
      %% TIMER_UPDATE
      
      
      % Bail out if figure is invalid
      if ~ishandle(this.Figure)
        return
      end
      
      % Update every child
      arrayfun(@(c) update(c, tmr, evt), this.Children);
      
      % Call update functions
      update_fcn(this, this);
      
      % Advance local frame index counter
      this.Index = this.FrameIndex(tmr.TasksExecuted);
      
    end
    
    
    function timer_stop(this, tmr, evt)
      %% TIMER_STOP
      
      
      % Stop every child
      arrayfun(@(c) stop(c, tmr, evt), this.Children);
      
      % Call stop functions
      stop_fcn(this, this);
      
      % Advance local frame index counter
      this.Index = this.FrameIndex(tmr.TasksExecuted);
      
    end
    
    
    function timer_error(this, tmr, evt)
      %% TIMER_ERROR
      
      
      
      
    end
    
  end
  
  
  
  %% OVERRRIDERS
  methods
    
    function close(this)
      %% CLOSE Close this conductor
      
      
      % Stop this timer
      stop(this);
      
      % Close the figure
      if ishandle(this.Figure) && isvalid(this.Figure)
        close(this.Figure);
      end
      
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
