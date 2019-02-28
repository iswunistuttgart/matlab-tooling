classdef tests < matlab.unittest.TestCase
  
  %% TEST METHODS
  methods ( Test )
    
    function single_plot(this)
      %% SINGLE_PLOT
      
      
      T = linspace(0, 1, 101);
      X = rand(10, numel(T));
      Y = rand(10, numel(T));
      
      c = animatlab.conductor( ...
        animatlab.axis( ...
          animatlab.graph.plot(X, Y) ...
        ) ...
      );
      
      start(c)
      
      wait(c)
      
      close('all');
      
    end
    
    
    function double_plot(this)
      %% DOUBLE_PLOT
      
      
      T = linspace(0, 1, 101);
      X = rand(10, numel(T));
      Y = rand(10, numel(T));
      
      c = animatlab.conductor( ...
        animatlab.axis(2, 1, 1 ...
          , animatlab.graph.plot(X, Y) ...
        ) ...
        , animatlab.axis(2, 1, 2 ...
          , animatlab.graph.plot(sort(Y, 1), X) ...
        ) ...
      );
      
      start(c)
      
      wait(c)
      
      close('all');
      
    end
    
    
    function single_plot3(this)
      %% SINGLE_PLOT3
      
      
      T = linspace(0, 1, 101);
      t = 0:pi/50:10*pi; t = t(:);
      X = sin(t) .* ones(size(T));
      Y = cos(t) .* ones(size(T));
      Z = t .* T;
      
      c = animatlab.conductor( ...
        animatlab.axis( ...
          animatlab.graph.plot3(X, Y, Z) ...
          , 'XLim', [-1, 1] ...
          , 'YLim', [-1, 1] ...
          , 'ZLim', [0, max(max(max(Z)))] ...
          , 'XLimMode', 'manual' ...
          , 'YLimMode', 'manual' ...
          , 'ZLimMode', 'manual' ...
        ) ...
      );
      
      start(c)
      
      wait(c)
      
      close('all');
      
    end
    
    
    function single_surf(this)
      %% SINGLE_SURF
      
      
      T = linspace(0, 1, 501);
      T = permute(T, [3, 1, 2]);
      [X, Y] = meshgrid(1:0.5:10,1:20);
      Z = sin(X) + cos(Y);
      X = X .* ones(size(T));
      Y = Y .* ones(size(T));
      Z = Z .* T;
      
      c = animatlab.conductor( ...
        animatlab.axis( ...
          animatlab.graph.surf(X, Y, Z) ...
          , 'XLim', [mmin(X), mmax(X)] ...
          , 'YLim', [mmin(Y), mmax(Y)] ...
          , 'ZLim', [mmin(Z), mmax(Z)] ...
          , 'XLimMode', 'manual' ...
          , 'YLimMode', 'manual' ...
          , 'ZLimMode', 'manual' ...
        ) ...
      );
      
      start(c)
      
      wait(c)
      
      close('all');
      
    end
    
  end
  
end
