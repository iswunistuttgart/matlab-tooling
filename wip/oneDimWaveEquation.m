function oneDimWaveEquation()

% Speed of wave
C = 1;
% C = sqrt(285714285.714286);
% C = 2;
% Step size in space
dx = 1e-2;
% Length of beam
Length = 5;
% Number of nodes in space
nx = Length/dx+1;
% Step size in time
dt = 1e-3;
% End of simulation
Time = 50;
% Number of nodes in time
nt = Time/dt+1;

% Create linspace of position and time
x = 0:dx:Length;
t = 0:dt:Time;

% Keep the solution of the wave equation in this variable as (time, space)
U_num = zeros(numel(t), numel(x));


r = C*dt/dx;


%% Conditions
%%% Initial conditions
% Initial shape is a sine wave
U_startPos = @(x) x.*0;
% U_startPos = @(x) sin(2*pi*x);
% U_startPos = @(x) exp(-400.*(x - 0.3).^2);
% Initial velocity be set to zero
U_startVel = @(x) x.*0; % cos(2*pi*x);
% U_startVel = @(x) x(2:end-1).*0; % cos(2*pi*x);

%%% Boundary conditions (left side)
% Left side: fix to zero
% U_left = zeros(numel(t), 1);
U_left = @(t, x) 0*t;

% Right side: fixed
U_right = @(t, x) 0; % iif(t < Time/2, @() sin(2*pi*t), true, 0);
% Right side: a sine wave for the first half, then fixed
U_right = @(t, x) iif(t <= (2*pi*3)/Time, @() 1/2*sin(2*pi*t), true, 0);
U_right = @(t, x) iif(t <= 4, @() 0.1.*sin(2*pi*t/4), true, 0);


% Construct leapfrog matrix
B = diag(2*(1-r^2)*ones(nx,1),0) + diag(r^2*ones(nx-1,1),1) + diag(r^2*ones(nx-1,1),-1);
% B = diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-3,1),1) + diag(r^2*ones(nx-3,1),-1);

b = @(t, x) r^2.*[U_left(t), zeros(1, nx-2), U_right(t, x)];
% b = @(x) r^2.*[U_left(x), zeros(1, nx-4), U_right(x)];

U_num(1,:) = U_startPos(x);
% Get the simulation started for t = t1
% b0 = r^2.*[U_left(0), ...
%             zeros(1,nx-2), ...
%             U_right(0)];
U_num(2,:) = 1/2.*transpose(B*transpose(U_num(1,:))) + dt*U_startVel(x) + 1/2.*b(0, U_num(1,:));
% U(2,1) = U_left(0+dt);
% U(2,2:end-1) = 1/2.*transpose(B*transpose(U(1,2:end-1))) + dt*U_startVel(x) + 1/2.*b(0);
% U(2,end) = U_left(0+dt);



%% Run the approxmiation
for iTime = 2:numel(t)
%     b = r^2.*[U_left(t(iTime)), ...
%                 zeros(1,nx-2), ...
%                 U_right(t(iTime))];
    U_num(iTime+1,:) = transpose(B*transpose(U_num(iTime,:))) - U_num(iTime-1,:) + b(t(iTime), x(:));
%     U(iTime+1,1) = U_left(t(iTime));
%     U(iTime+1,2:end-1) = transpose(B*transpose(U(iTime,2:end-1))) - U(iTime-1,2:end-1) + b(t(iTime));
%     U(iTime+1,end) = U_right(t(iTime));
end



%% And with d'Alembert
U_dal = zeros(numel(t), numel(x));
% U_dal(1,:) = 1/2.*(U_startPos(x - C*t(1)) + U_startPos(x + C*t(1)));
% for iTime = 2:numel(t)
%     for iX = 1:numel(x)
%         trapzEval = x(iX)-C*t(iTime):dt:x(iX)+C*t(iTime);
%         U_dal(iTime,iX) = 1/2.*(U_startPos(x(iX) - C*t(iTime)) + U_startPos(x(iX) + C*t(iTime))) + 1/(2*C)*trapz(trapzEval, U_startVel(trapzEval));
%     end
% %     U_dal(iTime,:) = 1/2.*(U_startPos(x - C*t(iTime)) + U_startPos(x + C*t(iTime)));
% %     U_dal(iTime,:) = 1/2.*(U_startPos(x - C*t(iTime)) + U_startPos(x + C*t(iTime)));
% end



%% Plot the results
hFig = figure;
hPlot = plot(NaN, NaN, NaN, NaN);
hTitle = title('');
% ylim([min(min(U_num)), max(max(U_num))]);
autosetlims('y', min(min(U_num)), max(max(U_num)));
hLegend = legend('numeric', 'd''Alembert');

% for iX = 1:numel(x)
%     set(hPlot, 'XData', t, 'YData', U(1:end-1,iX));
%     set(hTitle, 'String', ['Pose X = ' , num2str(x(iX))]);
%     drawnow;
%     pause(0.25);
% end

nFramesPerSecond = 24;
dTimePlot = round(1/(nFramesPerSecond*dt));

for iTime = 1:dTimePlot:numel(t)
% for iTime = 1:numel(t)
    set(hPlot(1), 'XData', x, 'YData', U_num(iTime,:));
%     set(hPlot(2), 'XData', x, 'YData', U_dal(iTime,:));
    set(hTitle, 'String', ['Time t = ' , num2str(t(iTime))]);
    drawnow
    pause(1/nFramesPerSecond);
end

end
