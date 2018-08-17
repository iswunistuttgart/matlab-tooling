classdef test_odeXb < matlab.unittest.TestCase
    % TEST_ODEXB ODE solvers with an implicit Euler BDF implementatiomn
    
    properties ( TestParameter )
        
        odefun = {@ode1b, @ode2b, @ode3b, @ode4b, @ode5b, @ode6b};
        
    end
    
    
    methods ( Test )
        
        function onVanDerPol1(this, odefun)
            
            
            % Time vector
            tspan = 0:1e-3:10;
            % Initial state
            y0 = [2; 0];
            
            % Solve with MATLAB's built-on ODE15s
            [tf, yf] = ode15s(@vdp1, tspan, y0);
            % Compare aginst our result
            [tb, yb] = odefun(@vdp1, tspan, y0);
            
            % New figure
            hf = figure;
            % Set figure name
            hf.Name = sprintf('%s with %s', func2str(@vdp1), func2str(odefun));
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
%             [tb, yb] = odefun(@vdp1000, tspan, y0);
%             
%             % New figure
%             hf = figure;
%             % Set figure name
%             hf.Name = sprintf('%s with %s', func2str(@vdp1000), func2str(odefun));
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

