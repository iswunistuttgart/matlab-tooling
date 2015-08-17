function oneDimWaveEquation()

% Speed of wave
C = 1;
% Step size in space
dx = 0.01;
% Length of beam
Length = 2;
% Number of nodes in space
nx = Length/dx+1;
% Step size in time
dt = 0.01;
% End of simulation
Time = 10;
% Number of nodes in time
nt = Time/dt+1;

% Create linspace of position and time
x = 0:dx:Length;
t = 0:dt:Time;

% Keep the solution of the wave equation in this variable as (time, space)
U = zeros(numel(t), numel(x));


r = C*dt/dx;


%% Conditions
%%% Initial conditions
% Initial shape is a sine wave
% U_initPosition = sin(2*pi*x);
% U_initPosition(ceil(end/2):end) = 0;
U_startPos = @(x) sin(2*pi*x);
U_startPos = @(x) exp(-400.*(x - 0.3).^2);
% Initial velocity be set to zero
U_startVel = @(x) x.*0; % cos(2*pi*x);
% U_startVel = @(x) x(2:end-1).*0; % cos(2*pi*x);

%%% Boundary conditions (left side)
% Left side: fix to zero
% U_left = zeros(numel(t), 1);
U_left = @(t) 0*t;

% Right side: a sine wave for the first half, then fixed
U_right = @(t) 0; % iif(t < Time/2, @() sin(2*pi*t), true, 0);


% Construct leapfrog matrix
B = diag(2*(1-r^2)*ones(nx,1),0) + diag(r^2*ones(nx-1,1),1) + diag(r^2*ones(nx-1,1),-1);
% B = diag(2*(1-r^2)*ones(nx-2,1),0) + diag(r^2*ones(nx-3,1),1) + diag(r^2*ones(nx-3,1),-1);

b = @(t) r^2.*[U_left(t), zeros(1, nx-2), U_right(t)];
% b = @(x) r^2.*[U_left(x), zeros(1, nx-4), U_right(x)];

U(1,:) = U_startPos(x);
% Get the simulation started for t = t1
% b0 = r^2.*[U_left(0), ...
%             zeros(1,nx-2), ...
%             U_right(0)];
U(2,:) = 1/2.*transpose(B*transpose(U(1,:))) + dt*U_startVel(x) + 1/2.*b(0);
% U(2,1) = U_left(0+dt);
% U(2,2:end-1) = 1/2.*transpose(B*transpose(U(1,2:end-1))) + dt*U_startVel(x) + 1/2.*b(0);
% U(2,end) = U_left(0+dt);


%% Run the approxmiation
for iTime = 2:numel(t)
%     b = r^2.*[U_left(t(iTime)), ...
%                 zeros(1,nx-2), ...
%                 U_right(t(iTime))];
    U(iTime+1,:) = transpose(B*transpose(U(iTime,:))) - U(iTime-1,:) + b(t(iTime));
%     U(iTime+1,1) = U_left(t(iTime));
%     U(iTime+1,2:end-1) = transpose(B*transpose(U(iTime,2:end-1))) - U(iTime-1,2:end-1) + b(t(iTime));
%     U(iTime+1,end) = U_right(t(iTime));
end

hFig = figure;
hPlot = plot(NaN, NaN);
hTitle = title('');
ylim([min(min(U)), max(max(U))]);

% for iX = 1:numel(x)
%     set(hPlot, 'XData', t, 'YData', U(1:end-1,iX));
%     set(hTitle, 'String', ['Pose X = ' , num2str(x(iX))]);
%     drawnow;
%     pause(0.25);
% end

nFramesPerSecond = 24;
dTimePlot = round(1/(nFramesPerSecond*dt));

for iTime = 1:dTimePlot:numel(t)
    set(hPlot, 'XData', x, 'YData', U(iTime,:));
    set(hTitle, 'String', ['Time t = ' , num2str(t(iTime))]);
    drawnow
    pause(1/nFramesPerSecond);
end

end
