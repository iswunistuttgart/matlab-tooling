classdef bdf < matlab.unittest.TestCase
    % BDF tests implicit BDF
    
    
    properties ( TestParameter )
      
      % Order of BDF
      ordr = struct('o1', 1, 'o2', 2, 'o3', 3, 'o4', 4, 'o5', 5, 'o6', 6);
      
    end
    
    
    methods ( Test )
        
        function onVanDerPol1(this, ordr)
            %% ONVANDERPOL tests the BDF on van-der-Pols ODE
            %
            %   MU in van-der-Pol's ODE is set to 1. Everything else is
            %   unchanged.%
            %   Results are compared against ODE15S.
            
            
            % Time vector
            tspan = 0:1e-3:2;
            % Initial state
            y0 = [2; 0];
            
            % Solve with MATLAB's built-in ODE15S
            [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
            % Compare aginst our result
            [tb, yb] = bdf(@vdp1, tspan, y0, odeset('MaxOrder', ordr));
            
            % New figure
            hf = figure;
            % Set figure name
            hf.Name = sprintf('%s with %s', func2str(@vdp1), sprintf('bdf%g', ordr));
            % First subplot is result
            hax(1) = subplot(2, 1, 1, 'Parent', hf);
            % Plot data
            hp = plot( ...
                hax(1) ...
                , tf, yf(:,1) ...
                , tb, yb(:,1) ...
            );
            % Adjust plotted lines
            hp(1).Color = [0, 1, 0];
            hp(1).LineStyle = '-';
            hp(2).Color = [1, 0, 0];
            hp(2).LineStyle = '-';
            ylabel(hax(1), 'Solution');
            % Second axis is error
            hax(2) = subplot(2, 1, 2, 'Parent', hf);
            % Plot data
            plot( ...
                hax(2) ...
                , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
            );
            ylabel(hax(2), 'Relative error');
            
            % Update figure
            drawnow();
            
        end
        
        
        function onVanDerPol1_WithMassStateIndependent(this, ordr)
            %% ONVANDERPOL_WITHMASSSTATEINDEPENDENT tests the BDF on van-der-Pols ODE
            %
            %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
            %   artifically set to 4. Mass matrix's state dependence is set to
            %   none.
            %   Results are compared against ODE15S.
            
            
            % Time vector
            tspan = 0:1e-3:2;
            % Initial state
            y0 = [2; 0];
            
            % Solve with MATLAB's built-in ODE15S
            [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
            % Compare aginst our result
            [tb, yb] = bdf(@vdp1_s, tspan, y0, odeset('MaxOrder', ordr, 'Mass', @(t) 4.*eye([2, 2]), 'MStateDependence', 'none'));
            
            % New figure
            hf = figure;
            % Set figure name
            hf.Name = sprintf('%s with %s', func2str(@vdp1), sprintf('bdf%g', ordr));
            % First subplot is result
            hax(1) = subplot(2, 1, 1, 'Parent', hf);
            % Plot data
            hp = plot( ...
                hax(1) ...
                , tf, yf(:,1) ...
                , tb, yb(:,1) ...
            );
            % Adjust plotted lines
            hp(1).Color = [0, 1, 0];
            hp(1).LineStyle = '-';
            hp(2).Color = [1, 0, 0];
            hp(2).LineStyle = '-';
            ylabel(hax(1), 'Solution');
            % Second axis is error
            hax(2) = subplot(2, 1, 2, 'Parent', hf);
            % Plot data
            plot( ...
                hax(2) ...
                , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
            );
            ylabel(hax(2), 'Relative error');
            
            % Update figure
            drawnow();
            
        end
        
        
        function onVanDerPol1_WithMassStateDepencent(this, ordr)
            %% ONVANDERPOL_WITHMASSSTATEDEPENDENT tests the BDF on van-der-Pols ODE
            %
            %   MU in van-der-Pols ODE is set to 1. The ODE's mass matrix is
            %   artifically set to 4. Mass matrix's state dependence is set to
            %   none.
            %   Results are compared against ODE15S.
            
            
            % Time vector
            tspan = 0:1e-3:2;
            % Initial state
            y0 = [2; 0];
            
            % Solve with MATLAB's built-in ODE15S
            [tf, yf] = ode15s(@vdp1, tspan, y0, odeset());
            % Compare aginst our result
            [tb, yb] = bdf(@vdp1_s, tspan, y0, odeset('MaxOrder', ordr, 'Mass', @(t, y) 4.*eye([2, 2]), 'MStateDependence', 'strong'));
            
            % New figure
            hf = figure;
            % Set figure name
            hf.Name = sprintf('%s with %s', func2str(@vdp1), sprintf('bdf%g', ordr));
            % First subplot is result
            hax(1) = subplot(2, 1, 1, 'Parent', hf);
            % Plot data
            hp = plot( ...
                hax(1) ...
                , tf, yf(:,1) ...
                , tb, yb(:,1) ...
            );
            % Adjust plotted lines
            hp(1).Color = [0, 1, 0];
            hp(1).LineStyle = '-';
            hp(2).Color = [1, 0, 0];
            hp(2).LineStyle = '-';
            ylabel(hax(1), 'Solution');
            % Second axis is error
            hax(2) = subplot(2, 1, 2, 'Parent', hf);
            % Plot data
            plot( ...
                hax(2) ...
                , tf, abs(yf - yb)./((abs(yf) + abs(yb))/2) ...
            );
            ylabel(hax(2), 'Relative error');
            
            % Update figure
            drawnow();
            
        end
        
        
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
%             [tb, yb] = odefun(@vdp1000, tspan, y0, odeset('MaxOrder', ordr));
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1000), sprintf('bdf%g', ordr));
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

