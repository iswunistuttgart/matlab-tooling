function animOneDimWaveDamped_OneCable(MovieFilename, PlotInhomogeneous, varargin)

%% Function initialization
% This keeps our previously opened figure;
persistent hLastFigure;

% If the function previoulsy created a figure, we will close that one
if ~isempty(hLastFigure) && ishandle(hLastFigure)
    close(hLastFigure)
end

% Cleanup function
% finishup = onCleanup(@() iif(ishandle(hLastFigure), close(hLastFigure), true, true));



%% Function defaults
bSaveMovie = false;
bPlotInhomogeneous = false;
bMovieFileOpen = false;
chMovieFilename = '';



%% Assertion
assert(nargin < 1 || isempty(MovieFilename) || ( ~isempty(MovieFilename) && ischar(MovieFilename) ));
assert(nargin < 2 || ( ~isempty(PlotInhomogeneous) && islogical(PlotInhomogeneous)));

% Assign the first argument
if nargin > 0 && ~isempty(MovieFilename)
    bSaveMovie = true;
    chMovieFilename = MovieFilename;
end
if nargin > 1
    bPlotInhomogeneous = PlotInhomogeneous;
end



%% Simulate the wave equation
[U, Axes, U_inh] = oneDimWaveDamped_OneCable(varargin{:});



%% Plot the result
% The vector of indices to take
vFrames = 0:1/(25*Axes.DeltaT):(numel(Axes.DimT)-1);

% Initialize the figure handle
hLastFigure = figure();

% Save a movie?
if bSaveMovie
    % Create a new video writer
    writerObj = VideoWriter(sprintf('%s.mp4', chMovieFilename), 'MPEG-4');
    % Set the framerate to 25fps
    writerObj.FrameRate = 25;
    % Try opening the file, if it fails we will not save the video but display
    % an message
    try
        open(writerObj);
        bMovieFileOpen = true;
    catch me
        display(me.message);
        bMovieFileOpen = false;
    end
end

% Initialize the plot handle (two plots, first is the initial condition, second
% the solution)
if bPlotInhomogeneous
    hPlot = plot(NaN, NaN, NaN, NaN, NaN, NaN);
else
    hPlot = plot(NaN, NaN, NaN, NaN);
end
% And set its x-values right away
vColors = distinguishableColors(3);
set(hPlot(1), 'XData', Axes.DimX, 'LineStyle', '--', 'Color', vColors(1,:));
set(hPlot(2), 'XData', Axes.DimX, 'Color', vColors(2,:));
if bPlotInhomogeneous
    set(hPlot(3), 'XData', Axes.DimX, 'Color', vColors(3,:));
end
% Set the labels
hXLabel = xlabel('String coordinate $x_{\rm{nom}} \left[ \mathrm{m}/L \right]$');
hYLabel = ylabel('Deflection $u \left[ \mathrm{m} \right]$');
% Initialize the plot's title
hTitle = title('');
% Create a legend
if bPlotInhomogeneous
    hLegend = legend('initial', 'homogeneous', 'inhomogeneous', 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
else
    hLegend = legend('initial', 'solution', 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
end
% Set the y-limits of the figure automagically to the min and max of U
if bPlotInhomogeneous
    if min(min(U)) < max(max(U)) && min(min(U_inh)) < max(max(U_inh))
        autosetlims('y', min(min(min(U)), min(min(U_inh))), max(max(max(U)), max(max(U_inh))));
    end
else
    if min(min(U)) < max(max(U))
        autosetlims('y', min(min(U)), max(max(U)));
    end
end

if bMovieFileOpen
    % Set the font size to 16 for all
    set(gca, 'FontSize', 16, 'LineWidth', 0.66);
    set(hLastFigure, 'Color', 'w');
end

% Plot the initial condition
set(hPlot(1), 'YData', U(1,:));

% Set the figure to a ratio of 4:3 for normal viewing mode or to 16:9 for video
% mode
if bSaveMovie
    setfigureratio('16:9');
else
    setfigureratio('4:3');
end

% Animate the movement
for iT = 1:numel(vFrames)
    % What is the actual index of the time that we are plotting?
    iEvalTime = vFrames(iT)+1;
    % Update Y-data of our plot
    set(hPlot(2), 'YData', U(iEvalTime,:));
    % Plot the markers of the cable
    if bPlotInhomogeneous
        set(hPlot(3), 'YData', U_inh(iEvalTime,:));
    end
    % Update the title to display the time
    set(hTitle, 'String', sprintf('Time $t = %0.3f$', Axes.DimT(iEvalTime)));
    
    % Update figure handle
    drawnow();
    
    % If the video file was successfully opened, we can save the video
    if bMovieFileOpen
        frame = getframe(hLastFigure);
        writeVideo(writerObj, frame);
    end
end

% Movie done, so we can close the video object
if bMovieFileOpen
    close(writerObj);
end

end