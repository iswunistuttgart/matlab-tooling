plotRobotAnchors(cfg_gears_a, 'PlotStyle', '3d', 'BoundingBox', 'on')

plotRobotAnchors(cfg_platform_b, 'PlotStyle', '3d', 'BoundingBox', 'on', 'BoundingBoxSpec', {'FaceColor', 'black', 'FaceAlpha', 0.33});

plotRobotWorkspace(DAT(1:3,:), DAT(4:6,:), DAT(7:9,:), 'HullSpec', {'FaceColor', 'g', 'FaceAlpha', 0.2});

plotRobotGround(cfg_gears_a);

grid minor
box on
axis equal

ax = gca;
ax.BoxStyle = 'full';
