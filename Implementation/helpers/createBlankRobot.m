function [Robot, varargout] = createBlankRobot(NumberOfWires)


%% Create the robot structure
%%% Main object
Robot = struct();

%%% Descriptive information
Description = struct();
Description.Name = 'Example Robot';
Description.MotionPattern = '3R3T';
Description.NumberOfWires = NumberOfWires;
Description.DegreesOfFreedom = 6;


%%% Meta information
Meta = struct();
Meta.FormatVersion = '1.0';

%%% For the winches
Drive = struct();

Drum = struct();
Drum.Diameter = Inf(NumberOfWires, 1);
Drum.Groove = zeros(NumberOfWires, 1);
Drum.Inertia = NaN(NumberOfWires, 1);
Drum.Mass = Inf(NumberOfWires, 1);
Drum.MaxLength = Inf(NumberOfWires, 1);
Drive.Drum = orderfields(Drum);

%%% For the pulleys
Pulley = struct();
Pulley.Inertia = zeros(NumberOfWires, 1);
Pulley.Mass = zeros(NumberOfWires, 1);
Pulley.Position = zeros(3, NumberOfWires);
Pulley.Radius = zeros(NumberOfWires, 1);
Pulley.Rotation = zeros(3, NumberOfWires);

%%% For the cables
Cable = struct();
Cable.BreakingLoad = Inf(NumberOfWires, 1);
Cable.DampingCoefficient = Inf(NumberOfWires, 1);
Cable.Diameter = zeros(NumberOfWires, 1);
Cable.LengthOffset = zeros(NumberOfWires, 1);
Cable.SpringCoefficient = Inf(NumberOfWires, 1);
Cable.UnitWeight = zeros(NumberOfWires, 1);

%%% For the environment
Environment = struct();
Environment.ForceFieldDirection = [0; ...
                                    0; ...
                                    -1];
Environment.GravitationalConstant = 9.81;

%%% For the platform
Platform = struct();
Platform.Inertia = Inf(3);
Platform.Initial = struct();
Platform.Initial.Position = zeros(3, 1);
Platform.Initial.Rotation = eye(3);
Platform.Mass = Inf;
Anchor = struct();
Anchor.Position = zeros(3, NumberOfWires);
Anchor.Rotation = zeros(3, NumberOfWires);
Platform.Anchor = orderfields(Anchor);



% Finally assign the robot parts to the struct
Robot.Cable = orderfields(Cable);
Robot.Drive = orderfields(Drive);
Robot.Environment = orderfields(Environment);
Robot.Platform = orderfields(Platform);
Robot.Pulley = orderfields(Pulley);
Robot.Description = orderfields(Description);

Robot = orderfields(Robot);
Robot.Meta = Meta;


%% Assign output quantities

end