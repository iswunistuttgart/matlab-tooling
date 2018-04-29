function test_plot_markers()
%% TEST_PLOT_MARKERS tests the `plot_markers` function
%%
t = linspace(0, 4*pi, 100);
s = sin(t);
c = cos(t);


%%
hFig = figure;
plot(t, s, t, c);
hold('on');
plot_markers(25);
hold('off');



%%
hFig = figure;
plot(t, [s; c]);
hold('on');
plot_markers(25, 'Spacing', 'logx');
hold('off');



%%
hFig = figure;
plot(t, s, t, c);
hold('on');
plot_markers(25, 'Order', 'd', 'Spacing', 'curve');
hold('off');



%%
hFig = figure;
plot3(t, s, c);
hold('on');
plot_markers(25);
hold('off');



%%
hFig = figure;
plot3(t, s, c);
hold('on');
plot_markers(55, 'Spacing', 'curve');
hold('off');


end
