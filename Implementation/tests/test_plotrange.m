%% Initialize
t = linspace(0, 2*pi, 500);
x = sin(t);
y = cos(t);
hFig = figure;



%% Simple x-y plot
hPlot = plot(t, x);
[minplotvalue(), maxplotvalue()]
clf(hFig)



%% Two x-y plots in one
hPlot = plot(t, x, t, y);
[minplotvalue(), maxplotvalue()]
clf(hFig)



%% Simple 3D plot x-y-z
hPlot = plot3(t, x, y);
[minplotvalue(); maxplotvalue()]
clf(hFig)



%% Two 3D plots x-y-z in one
hPlot = plot3(t, x, y, y, x, t);
[minplotvalue(); maxplotvalue()]
clf(hFig)



%% Plot with empty data than overridden
plot(NaN, NaN);
hold on;
hPlot = plot(t, x, t, y);
[minplotvalue(), maxplotvalue()]
clf(hFig)
