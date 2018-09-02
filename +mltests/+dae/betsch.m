classdef betsch < matlab.unittest.TestCase
  % BETSCH tests Betsch's DAE integration algorithm
  
  
  %% CLASS PROPERTIES
  properties
    
    % Step size
    h = 1e-3;
    % Final time
    T = 5;
    
    % Figure window handle
    HFig
    
    % Simulation result: time
    t
    % Simulation result: position
    q
    % Simulation result: velocity
    Dq
    % Name of test just run
    testname
    
  end
  
  
  %% TESTPARAMETERS
  properties ( TestParameter )

  end
  
  
  
  %% ODE CALLBACKS
  methods
    
    function dvdt = pendulum_rhs(this, t, q, Dq)
      
      
      % Weight of the pendulum mass is 1 kg, gravity acts only in negative z
      % with 9.81 kg m s^-2
      dvdt = [ ...
        0 ; ...
        -1*9.81 ; ...
      ];
      
    end
    
    
    function M = pendulum_mass(this, t, q, Dq)
      
      
      % Mass of the pendulum is 1 [ kg ]
      M = 1.*eye([2, 2]);
      
    end
    
    
    function PhiQ = pendulum_constraintq(this, t, q)
      
      
      % Pendulum mass must be placed at 1 m from the center
      PhiQ = q(1)^2 + q(2)^2 - 1^2;
      
    end
    
    
    function PhiDQ = pendulum_constraintdq(this, t, q)
      
      
      % Derivative of PhiQ wrt Q
      PhiDQ = [2*q(1), 2*q(2)];
      
    end
    
    
    function JPhiQ = pendulum_jconstraintq(this, t, q)
      
      
      % Derivative of PhiQ wrt Q
      JPhiQ = [2*q(1), 2*q(2)];
      
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
      
      
      % Stop execution if test failed
      if isempty(this.testname)
        return
      end
      
      % Select figure
      figure(this.HFig);
      
      % Get test name: remove the class name from the testname
      this.testname = last(strsplit(this.testname, '.'));
      
      % Set name of figure
      this.HFig.Name = this.testname;
      
      % Holds the axes handles
      hax = gobjects(3);
      
      % Position/Positions
      hax(1) = subplot(2, 2, [1, 2] ...
        , 'Parent', this.HFig ...
      );
      plot(hax(1) ...
        ... , this.t, this.q ...
        , this.q(:,1), this.q(:,2) ...
      );
      xlabel(hax(1) ...
        , 'Position $x / \mathrm{m}$' ...
        , 'Interpreter', 'latex' ...
      );
      ylabel(hax(1) ...
        , 'Position $z / \mathrm{m}$' ...
        , 'Interpreter', 'latex' ...
      );
      axis(hax(1), 'equal');
      xlim(hax(1), [-1.1, 1.1]);
      ylim(hax(1), [-1.1, 1.1]);
      legend({'pos'} ...
        , 'Location', 'best' ...
        , 'Interpreter', 'latex' ...
      );
      
      % Position/Positions
      hax(2) = subplot(2, 2, 3 ...
        , 'Parent', this.HFig ...
      );
      plot(hax(2) ...
        , this.t, this.q ...
      );
      xlabel(hax(2) ...
        , 'Time $t / \mathrm{s}$' ...
        , 'Interpreter', 'latex' ...
      );
      ylabel(hax(2) ...
        , 'Positions $q / \mathrm{m}$' ...
        , 'Interpreter', 'latex' ...
      );
      xlim(hax(2), this.t([1, end]));
      legend({'$x$', '$z$'} ...
        , 'Location', 'NorthWest' ...
        , 'Interpreter', 'latex' ...
      );
      
      % Velocity/Velocities
      hax(3) = subplot(2, 2, 4 ...
        , 'Parent', this.HFig ...
      );
      plot(hax(3) ...
        , this.t, this.Dq ...
      );
      xlabel(hax(3) ...
        , 'Time $t / \mathrm{s}$' ...
        , 'Interpreter', 'latex' ...
      );
      ylabel(hax(3) ...
        , 'Velocities $\dot{q} / \mathrm{m}\mathrm{s}^{-1}$' ...
        , 'Interpreter', 'latex' ...
      );
      xlim(hax(3), this.t([1, end]));
      legend({'$\dot{x}$', '$\dot{z}$'} ...
        , 'Location', 'NorthWest' ...
        , 'Interpreter', 'latex' ...
      );
      
      % Link some axes for better scrolling
      linkaxes(hax([2,3]), 'x');
      
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
    
    function freePendulum_ZeroVelocity(this)
      %% FREEPENDULUM_ZEROVELOCITY
      
      
      % Time span vector
      tsp = tspan(0, this.T, this.h);
      % Initial positions
      q0 = [
        1*cosd(45) ; ...
        -1*sind(45) ; ...
      ];
      Dq0 = [0; 0];
      
      % DAE options
      stDaeOpts = daeset( ...
          'Mass', @this.pendulum_mass ...
        , 'ConstraintsQ', @this.pendulum_constraintq ...
        , 'ConstraintsDQ', @this.pendulum_constraintdq ...
        , 'JConstraintsQ', @this.pendulum_jconstraintq ...
      );
      
      % Simulate
      [this.t, this.q, this.Dq] = betsch(@this.pendulum_rhs, tsp, q0, Dq0, stDaeOpts);
      
      % Assertion
      this.assertNotEmpty(this.t);
      this.assertLength(this.q, length(this.t));
      this.assertLength(this.Dq, length(this.t));
      
      % Mark name of test
      this.testname = funcname();
      
    end
    
    
    function freePendulum_NonzeroVelocity(this)
      %% FREEPENDULUM_NONZEROVELOCITY
      
      
      % Time span vector
      tsp = tspan(0, this.T, this.h);
      % Initial positions
      q0 = [
        1*cosd(45) ; ...
        -1*sind(45) ; ...
      ];
      Dq0 = [
        -1*sind(45) ; ...
        -1*cosd(45) ; ...
      ];
      
      % DAE options
      stDaeOpts = daeset( ...
          'Mass', @this.pendulum_mass ...
        , 'ConstraintsQ', @this.pendulum_constraintq ...
        , 'ConstraintsDQ', @this.pendulum_constraintdq ...
        , 'JConstraintsQ', @this.pendulum_jconstraintq ...
      );
      
      % Simulate
      [this.t, this.q, this.Dq] = betsch(@this.pendulum_rhs, tsp, q0, Dq0, stDaeOpts);
      
      % Assertion
      this.assertNotEmpty(this.t);
      this.assertLength(this.q, length(this.t));
      this.assertLength(this.Dq, length(this.t));
      
      % Mark name of test
      this.testname = funcname();
      
    end
  
  end
  

end
