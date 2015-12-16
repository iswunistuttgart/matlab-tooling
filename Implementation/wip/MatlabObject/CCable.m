classdef CCable
    properties (Access = public)
        LengthOffset = 0
        SpringCoefficient = 100000
        DampingCoefficient = 2000
        UnitWeight = 0
        BreakingLoad = Inf
        Diameter = 0
    end
    
    properties (Dependent)
        CrossSection
    end
    
    methods
        %% Constructor
        function obj = CCable()
            
        end
        
        
        %% Helper methods
        
        % Convert to format that can be used by Simulink
        function sCable = ForSimulink(obj)
            sCable = struct();
            sCable.LengthOffset = obj.LengthOffset;
            sCable.SpringCoefficient = obj.SpringCoefficient;
            sCable.DampingCoefficient = obj.DampingCoefficient;
            sCable.UnitWeight = obj.UnitWeight;
            sCable.BreakingLoad = obj.BreakingLoad;
            sCable.Diameter = obj.Diameter;
            sCable.CrossSection = obj.CrossSection;
            
            sCable = orderfields(sCable);
        end
        
        %% Get methods
        % Cross section
        function CrossSection = get.CrossSection(obj)
            CrossSection = pi*(obj.Diameter/2)^2;
        end
        
        %% Set methods
        
        % Length offset
        function obj = set.LengthOffset(obj, LengthOffset)
            try
                validateattributes(LengthOffset, {'numeric'}, {'nonnegative'}, 'set.LengthOffset', 'LengthOffset');
            catch ME
                error(ME.message);
            end
            
            obj.LengthOffset = LengthOffset;
        end
        
        % Spring coefficient
        function obj = set.SpringCoefficient(obj, SpringCoefficient)
            try
                validateattributes(SpringCoefficient, {'numeric'}, {'nonnegative'}, 'set.SpringCoefficient', 'SpringCoefficient');
            catch ME
                error(ME.message);
            end
            
            obj.SpringCoefficient = SpringCoefficient;
        end
        
        % Damping coefficient
        function obj = set.DampingCoefficient(obj, DampingCoefficient)
            try
                validateattributes(DampingCoefficient, {'numeric'}, {'nonnegative'}, 'set.DampingCoefficient', 'DampingCoefficient');
            catch ME
                error(ME.message);
            end
            
            obj.DampingCoefficient = DampingCoefficient;
        end
        
        % Unit weight
        function obj = set.UnitWeight(obj, UnitWeight)
            try
                validateattributes(UnitWeight, {'numeric'}, {'nonnegative'}, 'set.UnitWeight', 'UnitWeight');
            catch ME
                error(ME.message);
            end
            
            obj.UnitWeight = UnitWeight;
        end
        
        % Breaking load
        function obj = set.BreakingLoad(obj, BreakingLoad)
            try
                validateattributes(BreakingLoad, {'numeric'}, {'nonnegative'}, 'set.BreakingLoad', 'BreakingLoad');
            catch ME
                error(ME.message);
            end
            
            obj.BreakingLoad = BreakingLoad;
        end
        
        % Diameter
        function obj = set.Diameter(obj, Diameter)
            try
                validateattributes(Diameter, {'numeric'}, {'nonnegative'}, 'set.Diameter', 'Diameter');
            catch ME
                error(ME.message);
            end
            
            obj.Diameter = Diameter;
        end
        
    end
end