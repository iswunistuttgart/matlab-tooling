classdef bdf < matlab.unittest.TestCase
  % BDF tests implicit BDF
  
  
  
  %% PROPERTIES
  properties
    
    % Figure for visualization
    HFig;
    
    % Time and solution vector of ODE15S solver
    Tode15s
    Yode15s
    
    % Time and solution vector of BDF solver
    Tbdf
    Ybdf
    
    % Name of last run test
    testname
    
  end
  
  
  %% TESTPARAMETERS
  properties ( TestParameter )
    
    % Order of BDF
    ordr = struct('o1', 1, 'o2', 2, 'o3', 3, 'o4', 4, 'o5', 5, 'o6', 6);
    
  end
  
  
  
  %% STATIC METHODS
  methods ( Static )
    
    function dydt = vdp1_s(t, y)
      %% VDP1_S is a scaled VDP1
      
      
      dydt = 4.*[y(2); (1-y(1)^2)*y(2)-y(1)];
      
    end
    
  end
  
  
  
  %% TESTMETHODSETUP
  methods ( TestMethodSetup )
    
    function createFigure(this)
      %% CREATEFIGURE creates the target figure
      
      % Create an invisible figure
      this.HFig = figure('Visible', 'off');
      
    end
    
  end
  
  
  
  %% TESTMETHODTEARDOWN
  methods ( TestMethodTeardown )
    
    function fillFigure(this)
      %% FILLFIGURE with simulation results
      
      
      % Select figure
      figure(this.HFig);
      this.HFig.Visible = 'off';
      
      % Get test name: remove the class name from the testname
      this.testname = last(strsplit(this.testname, '.'));
      
      % Set name of figure
      this.HFig.Name = this.testname;
      
      % Solutions
      hax(1) = subplot(2, 1, 1 ...
        , 'Parent', this.HFig ...
      );
      hp(1) = plot(hax(1) ...
        , this.Tode15s, this.Yode15s(:,1:end/2) ...
      );
      hold(hax(1), 'on');
      hp(2) = plot(hax(1) ...
        , this.Tbdf, this.Ybdf(:,1:end/2) ...
      );
      xlabel(hax(1) ...
        , 'Time $t / \mathrm{s}$' ...
        , 'Interpreter', 'latex' ...
      );
      ylabel(hax(1) ...
        , 'Concentration $y$' ...
        , 'Interpreter', 'latex' ...
      );
      %%% Adjust line styles and colors
      % ODE15s
      hp(1).LineStyle = '-';
      % BDF
      hp(2).LineStyle = '-';
      legend(hax(1) ...
        , {'ode15s', 'bdf'} ...
      );
      
      % Errors on states
      hax(2) = subplot(2, 1, 2 ...
        , 'Parent', this.HFig ...
      );
      plot(hax(2) ...
        , this.Tbdf, abs(this.Yode15s - this.Ybdf)./((abs(this.Yode15s) + abs(this.Ybdf))/2).*100 ...
      );
      legend(hax(2) ...
        , arrayfun(@(ii) sprintf('$e_{y_{%g}}$', ii), 1:size(this.Yode15s, 2), 'UniformOutput', false) ...
        , 'Location', 'North' ...
        , 'Interpreter', 'latex' ...
      );
      xlabel(hax(2) ...
        , 'Time $t / \mathrm{s}$' ...
        , 'Interpreter', 'latex' ...
      );
      ylabel(hax(2) ...
        , 'Relative error $\%$' ...
        , 'Interpreter', 'latex' ...
      );
      
      % Update drawing
      drawnow();
      
      % Save figure to file
      saveas(this.HFig, fullfile(pwd, this.testname), 'tiff');
      
      % Close figure
      close(this.HFig);
      
    end
    
  end
  
  
  
  %% TESTS
  methods ( Test )
    
    function onVanDerPol1(this, ordr)
      %% ONVANDERPOL tests the BDF on van-der-Pols ODE
      %
      %   MU in van-der-Pol's ODE is set to 1. Everything else is
      %   unchanged.%
      %   Results are compared against ODE15S.
      
      
      % Time vector
      tsp = tspan(0, 2, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@vdp1, tsp, y0, odeset('MaxOrder', ordr));
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
    
    function onVanDerPol1_WithMassTimeDependent(this, ordr)
      %% ONVANDERPOL_WITHMASSTIMEDEPENDENT tests the BDF on van-der-Pols ODE
      %
      %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
      %   artifically set to 4. Mass matrix's state dependence is set to none.
      %   Results are compared against ODE15S.
      
      
      % Time vector
      tsp = tspan(0, 2, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.vdp1_s, tsp, y0, odeset('MaxOrder', ordr, 'Mass', @(t) 4.*eye([2, 2]), 'MStateDependence', 'none'));
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
    
    function onVanDerPol1_WithMassStateDepencent(this, ordr)
      %% ONVANDERPOL_WITHMASSSTATEDEPENDENT tests the BDF on van-der-Pols ODE
      %
      %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
      %   artifically set to 4. Mass matrix's state dependence is set to
      %   none.
      %   Results are compared against ODE15S.
      
      
      % Time vector
      tsp = tspan(0, 2, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.vdp1_s, tsp, y0, odeset('MaxOrder', ordr, 'Mass', @(t, y) 4.*eye([2, 2]), 'MStateDependence', 'strong'));
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
  end
  
  
end

