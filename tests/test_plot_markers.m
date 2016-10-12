function test_plot_markers()
%%
t = linspace(0, 4*pi, 100);
s = sin(t);
c = cos(t);


%%
hFig = figure;
plot(t, s, t, c);
plot_markers();



%%
hFig = figure;
plot(t, [s; c]);
plot_markers(25, 'Spacing', 'logx');



%%
hFig = figure;
plot(t, s, t, c);
plot_markers('Order', 'd', 'Spacing', 'curve');



%%
hFig = figure;
plot3(t, s, c);
plot_markers();



%%
hFig = figure;
plot3(t, s, c);
plot_markers(55, 'Spacing', 'curve');


end