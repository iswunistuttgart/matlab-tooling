classdef leapfrog < matlab.unittest.TestCase
    % LEAPFROG tests the leapfrog integration algorithm
    
    
    properties ( TestParameter )
      
    end
    
    
    methods ( Test )
      
        function drivenHarmonicOscillator(this)
          
          m = 1;
          D = 0.00;
          omega0 = 6/(2*pi);
          x0 = 0.0;
          v0 = 1.0;
          f0 = 5.0;
          T = 10.0;
          w = 0.8*omega0;
          
          function F = frc(t, x, v)
            F = f0.*cos(w.*(t - 20)).*exp(-(t./T).^2);
          end
          
          function f = ode_rhs(t, x, v)
            f = -omega0^2*x - 2*D*omega0*v + frc(t, x, v)/m;
          end
          
          [t, x, v] = leapfrog(@ode_rhs, 0:1e-2:60, x0, v0);
          
          figure;
          subplot(2, 1, 1);
          plot(t, x, t, frc(t, x, v));
          subplot(2, 1, 2);
          plot(t, v);
          
          
        end
        
%         function onVanDerPol1(this)
%             %% ONVANDERPOL tests the BDF on van-der-Pols ODE
%             %
%             %   MU in van-der-Pol's ODE is set to 1. Everything else is
%             %   unchanged.
%             %   Results are compared against ODE15S.
%             
%             
%             % Time vector
%             tspan = 0:1e-3:2;
%             % Initial state
%             y0 = [2; 0];
%             
%             % Solve with MATLAB's built-in ODE15S
%             [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
%             % Compare aginst our result
%             [tb, yb] = leapfrog(@(t, x, v) vdp1(t, [x(:); v(:)]), tspan, y0(1:end/2), y0(end/2+1:end));
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1), 'leapfrog');
%             % First subplot is result
%             hax(1) = subplot(2, 1, 1, 'Parent', hf);
%             % Plot data
%             hp = plot( ...
%                 hax(1) ...
%                 , tf, yf(:,1) ...
%                 , tb, yb(:,1) ...
%             );
%             % Adjust plotted lines
%             hp(1).Color = [0, 1, 0];
%             hp(1).LineStyle = '-';
%             hp(2).Color = [1, 0, 0];
%             hp(2).LineStyle = '-';
%             ylabel(hax(1), 'Solution');
%             % Second axis is error
%             hax(2) = subplot(2, 1, 2, 'Parent', hf);
%             % Plot data
%             plot( ...
%                 hax(2) ...
%                 , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
%             );
%             ylabel(hax(2), 'Relative error');
%             
%             % Update figure
%             drawnow();
%             
%         end
        
        
%         function onVanDerPol1_WithMassStateIndependent(this)
%             %% ONVANDERPOL_WITHMASSSTATEINDEPENDENT tests the BDF on van-der-Pols ODE
%             %
%             %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
%             %   artifically set to 4. Mass matrix's state dependence is set to
%             %   none.
%             %   Results are compared against ODE15S.
%             
%             
%             % Time vector
%             tspan = 0:1e-3:2;
%             % Initial state
%             y0 = [2; 0];
%             
%             % Solve with MATLAB's built-in ODE15S
%             [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
%             % Compare aginst our result
%             [tb, yb] = leapfrog(@vdp1_s, tspan, y0(1:end/2), y0(end/2+1:end), odeset('MaxOrder', 'Mass', @(t) 4.*eye([2, 2]), 'MStateDependence', 'none'));
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1), 'leapfrog');
%             % First subplot is result
%             hax(1) = subplot(2, 1, 1, 'Parent', hf);
%             % Plot data
%             hp = plot( ...
%                 hax(1) ...
%                 , tf, yf(:,1) ...
%                 , tb, yb(:,1) ...
%             );
%             % Adjust plotted lines
%             hp(1).Color = [0, 1, 0];
%             hp(1).LineStyle = '-';
%             hp(2).Color = [1, 0, 0];
%             hp(2).LineStyle = '-';
%             ylabel(hax(1), 'Solution');
%             % Second axis is error
%             hax(2) = subplot(2, 1, 2, 'Parent', hf);
%             % Plot data
%             plot( ...
%                 hax(2) ...
%                 , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
%             );
%             ylabel(hax(2), 'Relative error');
%             
%             % Update figure
%             drawnow();
%             
%         end
        
        
%         function onVanDerPol1_WithMassStateDepencent(this)
%             %% ONVANDERPOL_WITHMASSSTATEDEPENDENT tests the BDF on van-der-Pols ODE
%             %
%             %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
%             %   artifically set to 4. Mass matrix's state dependence is set to
%             %   none.
%             %   Results are compared against ODE15S.
%             
%             
%             % Time vector
%             tspan = 0:1e-3:2;
%             % Initial state
%             y0 = [2; 0];
%             
%             % Solve with MATLAB's built-in ODE15S
%             [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
%             % Compare aginst our result
%             [tb, yb] = leapfrog(@vdp1_s, tspan, y0(1:end/2), y0(end/2+1:end), odeset('MaxOrder', 'Mass', @(t, y) 4.*eye([2, 2]), 'MStateDependence', 'strong'));
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1), 'leapfrog');
%             % First subplot is result
%             hax(1) = subplot(2, 1, 1, 'Parent', hf);
%             % Plot data
%             hp = plot( ...
%                 hax(1) ...
%                 , tf, yf(:,1) ...
%                 , tb, yb(:,1) ...
%             );
%             % Adjust plotted lines
%             hp(1).Color = [0, 1, 0];
%             hp(1).LineStyle = '-';
%             hp(2).Color = [1, 0, 0];
%             hp(2).LineStyle = '-';
%             ylabel(hax(1), 'Solution');
%             % Second axis is error
%             hax(2) = subplot(2, 1, 2, 'Parent', hf);
%             % Plot data
%             plot( ...
%                 hax(2) ...
%                 , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
%             );
%             ylabel(hax(2), 'Relative error');
%             
%             % Update figure
%             drawnow();
%             
%         end
        
        
%         function onVanDerPol1000(this, odefun)
%             
%             
%             % Time vector
%             tspan = 0:1e-3:10;
%             % Initial state
%             y0 = [2; 0];
%             
%             % Solve with MATLAB's built-on ODE15s
%             [tf, yf] = ode15s(@vdp1000, tspan, y0);
%             % Compare aginst our result
%             [tb, yb] = odefun(@vdp1000, tspan, y0, odeset('MaxOrder'));
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1000), sprintf('bdf%g'));
%             % First subplot is result
%             hax(1) = subplot(2, 1, 1, 'Parent', hf);
%             % Plot data
%             hp = plot( ...
%                 hax ...
%                 , tf, yf(:,1) ...
%                 , tb, yb(:,1) ...
%             );
%             % Adjust plotted lines
%             hp(1).Color = [0, 1, 0];
%             hp(1).LineStyle = '-';
%             hp(2).Color = [1, 0, 0];
%             hp(2).LineStyle = '-';
%             ylabel(hax(1), 'Solution');
%             % Second axis is error
%             hax(2) = subplot(2, 1, 2, 'Parent', hf);
%             % Plot data
%             plot( ...
%                 hax ...
%                 , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
%             );
%             ylabel(hax(2), 'Relative error');
%             
%         end
        
    end
    
    
end

