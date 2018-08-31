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
    
    
    function dydt = rob1_rhs(t, y)
      %% ROB1_RHS is the right-hand side of the Robertson problem
      
      dydt = [ ...
        -0.04*y(1,:) + 1e4*y(2,:).*y(3,:) ; ...
        0.04*y(1,:) - 1e4*y(2,:).*y(3,:) - 3e7*y(2,:).^2 ; ...
        y(1,:) + y(2,:) + y(3,:) - 1 ; ...
      ];
 
    end
    
    
    function M = rob1_mass(t, y)
      %% ROB1_MASS is the mass matrix of the Robertson problem
      
      
      M = [ ...
        1, 0, 0 ; ...
        0, 1, 0 ; ...
        0, 0, 0 ; ...
      ];
    
    end
    
    
    function M = transamp_mass(t, y)
      %% TRANSAMP_MASS is the massa matrix of the one-transistor amplifier DAE
      
      
      c = 1e-6 * (1:3);
      M = zeros(5,5);
      M(1,1) = -c(1);
      M(1,2) =  c(1);
      M(2,1) =  c(1);
      M(2,2) = -c(1);
      M(3,3) = -c(2);
      M(4,4) = -c(3);
      M(4,5) =  c(3);
      M(5,4) =  c(3);
      M(5,5) = -c(3);
      
    end
    
    
    function dydt = transamp_rhs(t, y)
      %% TRANSAMP_RHS is the right-hand side of the one-transistor amplifier DAE
      
      
      % Define voltages and constant parameters
      Ue = @(t) 0.4*sin(200*pi*t);
      Ub = 6;
      R0 = 1000;
      R15 = 9000;
      alpha = 0.99;
      beta = 1e-6;
      Uf = 0.026;

      f23 = beta*(exp((y(2) - y(3))/Uf) - 1);
      
      dydt = [ ...
        -(Ue(t) - y(1))/R0 ; ...
        -(Ub/R15 - y(2)*2/R15 - (1-alpha)*f23) ; ...
        -(f23 - y(3)/R15) ; ...
        -((Ub - y(4))/R15 - alpha*f23) ; ...
        (y(5)/R15) ; ...
      ];
      
    end
    
    
    function M = simplependulum_mass(t, y)
      %% SIMPLEPENDULUM_MASS
      
      
      % Integrator chain of 2x2, mass of 2x2, holonomic constraint of 1x1
      M = blkdiag(eye(2, 2), eye(2, 2), 0);
      
    end
    
    
    function dydt = simplependulum_rhs(t, y)
      %% SIMPLEPENDULUM_RHS
      
      
      dydt = zeros(5, 1);
      dydt(1) = y(3);
      dydt(2) = y(4);
      dydt(3) = -y(1);
      dydt(4) = 9.81*y(2);
      dydt(5) = y(1)^2 + y(2)^2 - 1;
      
    end
    
  end
  
  
  %% TESTCLASSSETUP
  methods ( TestClassSetup )
    
    function clearFigureTiffs(this)
      %% CLEARFIGURETIFFS removes all tiffs from previous test runs
      
      
      % Get all files
      vFiles = allfiles(fileparts(mfilename('fullpath')), '*', 'Prefix', class(this));
      
      % If got files
      if numel(vFiles)
        % Delete every files
        for iFile = 1:numel(vFiles)
          % Skip files not ending in '.tif(f)' (just in case)
          if ~( endsWith(vFiles(iFile).name, 'tif') || endsWith(vFiles(iFile).name, 'tiff') )
            continue
          end
          
          try
            delete(fullfile(vFiles(iFile).folder, vFiles(iFile).name));
          catch me
            warning(me.identifier, '%s', me.message);
          end
        end
      end
      
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
      
      
      % Skip tests that failed
      if isempty(this.testname)
        return
      end
      
      % Select figure
%       figure(this.HFig);
      this.HFig.Visible = 'off';
      
      % Get test name: remove the class name from the testname
      this.testname = last(strsplit(this.testname, '.'));
      
      % Set name of figure
      this.HFig.Name = this.testname;
      
      if contains(this.testname, 'onOneTransistorAmplifier')
        % Solutions
        hax(1) = subplot(2, 1, 1 ...
          , 'Parent', this.HFig ...
        );
        hp(1) = plot(hax(1) ...
          , this.Tode15s, this.Yode15s(:,5) ...
        );
        hold(hax(1), 'on');
        hp(2) = plot(hax(1) ...
          , this.Tbdf, this.Ybdf(:,5) ...
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
      else
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
      end
      
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
      saveas(this.HFig, fullfile(fileparts(mfilename('fullpath')), sprintf('%s.%s.tiff', class(this), this.testname)), 'tiff');
      
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
      T0 = 0;
      Tf = 2;
      tsp = tspan(T0, Tf, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@vdp1, tsp, y0, odeset('MaxOrder', ordr));
      
      this.assertNotEmpty(this.Tbdf);
      this.assertNotEmpty(this.Ybdf);
      this.assertSize(this.Ybdf, [numel(this.Tbdf), 2]);
      this.assertEqual(this.Tode15s, this.Tbdf, 'AbsTol', 1000*eps);
      this.assertEqual(this.Tbdf(end), Tf, 'AbsTol', 1000*eps);
      
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
      T0 = 0;
      Tf = 2;
      tsp = tspan(T0, Tf, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.vdp1_s, tsp, y0, odeset('MaxOrder', ordr, 'Mass', @(t) 4.*eye([2, 2]), 'MStateDependence', 'none'));
      
      this.assertNotEmpty(this.Tbdf);
      this.assertNotEmpty(this.Ybdf);
      this.assertSize(this.Ybdf, [numel(this.Tbdf), 2]);
      this.assertEqual(this.Tode15s, this.Tbdf, 'AbsTol', 1000*eps);
      this.assertEqual(this.Tbdf(end), Tf, 'AbsTol', 1000*eps);
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
    
%     function onSimplePendulum(this, ordr)
%       %% ONSIMPLEPENDULUM
%       
%       
%       % Time vector
%       T0 = 0;
%       Tf = 5;
%       tsp = tspan(T0, Tf, 1e-3);
%       % Initial state
%       y0 = [sqrt(2)/2; sqrt(2)/2; 0; 0; 0];
%       
%       % Set options for both solvers
%       stOdeOpts = odeset( ...
%           'Mass', mltests.ode.bdf.simplependulum_mass...
%         , 'MStateDependence', 'strong' ...
%       );
%       
%       % Solve with MATLAB's built-in ODE15S
%       [this.Tode15s, this.Yode15s] = ode23t(@mltests.ode.bdf.simplependulum_rhs, tsp, y0, stOdeOpts);
%       % Compare aginst our result
%       [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.simplependulum_rhs, tsp, y0, odeset(stOdeOpts, 'MaxOrder', ordr));
%       
%       this.assertNotEmpty(this.Tbdf);
%       this.assertNotEmpty(this.Ybdf);
%       this.assertSize(this.Ybdf, [numel(this.Tbdf), 2]);
%       this.assertEqual(this.Tode15s, this.Tbdf, 'AbsTol', 1000*eps);
%       this.assertEqual(this.Tbdf(end), Tf, 'AbsTol', 1000*eps);
%       
%       % Set name of this test case
%       this.testname = sprintf('%s_order%g', funcname(), ordr);
%       
%     end
    
    
    function onVanDerPol1_WithMassStateDepencent(this, ordr)
      %% ONVANDERPOL_WITHMASSSTATEDEPENDENT tests the BDF on van-der-Pols ODE
      %
      %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
      %   artifically set to 4. Mass matrix's state dependence is set to
      %   none.
      %   Results are compared against ODE15S.
      
      
      % Time vector
      T0 = 0;
      Tf = 2;
      tsp = tspan(T0, Tf, 1e-3);
      % Initial state
      y0 = [2; 0];
      
      % Solve with MATLAB's built-in ODE15S
      [this.Tode15s, this.Yode15s] = ode15s(@vdp1, tsp, y0, odeset());
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.vdp1_s, tsp, y0, odeset('MaxOrder', ordr, 'Mass', @(t, y) 4.*eye([2, 2]), 'MStateDependence', 'strong'));
      
      this.assertNotEmpty(this.Tbdf);
      this.assertNotEmpty(this.Ybdf);
      this.assertSize(this.Ybdf, [numel(this.Tbdf), 2]);
      this.assertEqual(this.Tode15s, this.Tbdf, 'AbsTol', 1000*eps);
      this.assertEqual(this.Tbdf(end), Tf, 'AbsTol', 1000*eps);
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
    
    function onOneTransistorAmplifier(this, ordr)
      %% ONONETRANSISTORAMPLIFIER tests BDF on the one transistor amplifier
      %
      %   
      
      
      % Time vector
      T0 = 0;
      Tf = 0.05;
      tsp = tspan(T0, Tf, 1e-5);
      % Initial state
      y0 = zeros(5, 1);
      Ub = 6;
      y0(1) = 0;
      y0(2) = Ub/2;
      y0(3) = Ub/2;
      y0(4) = Ub;
      y0(5) = 0;
      
      % Set options for both solvers
      stOdeOpts = odeset( ...
          'Mass', mltests.ode.bdf.transamp_mass ...
        , 'MStateDependence', 'strong' ...
        ... , 'RelTol', 1e-4 ...
        ... , 'AbsTol', [1e-6, 1e-10, 1e-6] ...
      );
      
      % Solve with MATLAB's built-in ODE23T
      [this.Tode15s, this.Yode15s] = ode23t(@mltests.ode.bdf.transamp_rhs, tsp, y0, stOdeOpts);
      % Compare aginst our result
      [this.Tbdf, this.Ybdf] = bdf(@mltests.ode.bdf.transamp_rhs, tsp, y0, odeset(stOdeOpts, 'MaxOrder', ordr));
      
      this.assertNotEmpty(this.Tbdf);
      this.assertNotEmpty(this.Ybdf);
      this.assertSize(this.Ybdf, [numel(this.Tbdf), 5]);
      this.assertEqual(this.Tode15s, this.Tbdf, 'AbsTol', 1000*eps);
      this.assertEqual(this.Tbdf(end), Tf, 'AbsTol', 1000*eps);
      
      % Set name of this test case
      this.testname = sprintf('%s_order%g', funcname(), ordr);
      
    end
    
  end
  
  
end

