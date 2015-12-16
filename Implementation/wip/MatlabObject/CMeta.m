classdef CMeta
    properties
        DegressOfFreedom = 0
        MotionPattern = ''
        Name = ''
        NumberOfWires = 0
    end
    
    methods
        %% Constructor
        function obj = CMeta(Name, NumberOfWires, DegeesOfFreedom, MotionPattern)
            if exist('Name', 'var')
                obj.Name = Name;
            end
            
            if exist('NumberOfWires', 'var')
                obj.NumberOfWires = NumberOfWires;
            end
            
            if exist('DegeesOfFreedom', 'var')
                obj.DegressOfFreedom = DegeesOfFreedom;
            end
            
            if exist('MotionPattern', 'var')
                obj.MotionPattern = MotionPattern;
            end
        end
        
        
        %% Helpers
        
        % Convert to format that can be used by Simulink
        function sMeta = ForSimulink(obj)
            sMeta = struct();
            sMeta.Name = obj.Name;
            sMeta.MotionPattern = obj.MotionPattern;
            sMeta.DegressOfFreedom = obj.DegressOfFreedom;
            sMeta.NumberOfWires = obj.NumberOfWires;
            sMeta = orderfields(sMeta);
        end
        
        %% Set methods
        
        % Degrees of Freedom
        function obj = set.DegressOfFreedom(obj, DegressOfFreedom)
            try
                validateattributes(DegressOfFreedom, {'numeric'}, {'scalar', '>=', 0}, 'set.DegreesOfFreedom', 'DegressOfFreedom');
            catch ME
                error(ME.message);
            end
            
            obj.DegressOfFreedom = DegressOfFreedom;
        end
        
        % Motion Pattern
        function obj = set.MotionPattern(obj, MotionPattern)
            try
                validatestring(MotionPattern, {'1T', '2T', '3T', '1R3T', '2R3T', '3R3T'}, 'set.MotionPattern', 'MotionPattern');
            catch ME
                error(ME.message);
            end
            
            obj.MotionPattern = MotionPattern;
        end
        
        % Name
        function obj = set.Name(obj, Name)
            try
                validateattributes(Name, {'char'}, {'nonempty'}, 'set.Name', 'Name');
            catch ME
                error(ME.message);
            end
            
            obj.Name = Name;
        end
        
        % Number of Wires
        function obj = set.NumberOfWires(obj, NumberOfWires)
            try
                validateattributes(NumberOfWires, {'numeric'}, {'scalar', '>=', 0}, 'set.NumberOfWires', 'NumberOfWires');
            catch ME
                error(ME.message);
            end
            
            obj.NumberOfWires = NumberOfWires;
        end
        
        
        %% Get methods
        % Degrees of Freedom
        function DegressOfFreedom = get.DegressOfFreedom(obj)
            DegressOfFreedom = obj.DegressOfFreedom;
        end
        
        % Motion Pattern
        function MotionPattern = get.MotionPattern(obj)
            MotionPattern = obj.MotionPattern;
        end
        
        % Name
        function Name = get.Name(obj)
            Name = obj.Name;
        end
        
        % Number of Wires
        function NumberOfWires = get.NumberOfWires(obj)
            NumberOfWires = obj.NumberOfWires;
        end
    end
end