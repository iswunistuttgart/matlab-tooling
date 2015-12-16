classdef CRobot
    properties (Access = private)
        m_Meta
        m_Cables = zeros(0, 1)clc
    end
    
    properties (Dependent)
        DegreesOfFreedom
        Meta
        MotionPattern
        Name
        NumberOfWires
%         Cables
    end
    
    methods
        %% Constructor
        function obj = CRobot()
            obj.m_Meta = CMeta();
%             obj.m_Cables = zeros(1,0);
        end
        
        
        %% Helper methods
        
        % Convert to format that can be used by Simulink
        function sRobot = ForSimulink(obj)
            sRobot = struct();
            sRobot.Meta = obj.Meta.ForSimulink();
            
            sRobot = orderfields(sRobot);
        end
        
        %% Get methods
        % Degrees of freedom
        function DegreesOfFreedom = get.DegreesOfFreedom(obj)
            DegreesOfFreedom = obj.Meta.DegreesOfFreedom;
        end
        
        % Meta
        function Meta = get.Meta(obj)
            Meta = obj.m_Meta;
        end
        
        % Motion pattern
        function MotionPattern = get.MotionPattern(obj)
            MotionPattern = obj.Meta.MotionPattern;
        end
        
        % Name
        function Name = get.Name(obj)
            Name = obj.Meta.Name;
        end
        
        % Number of wires
        function NumberOfWires = get.NumberOfWires(obj)
            NumberOfWires = obj.Meta.NumberOfWires;
        end
        
        %% Set methods
        
        % Degrees of freedom
        function obj = set.DegreesOfFreedom(obj, DegreesOfFreedom)
            try
                obj.Meta.DegreesOfFreedom = DegreesOfFreedom;
            catch ME
                error(ME.message);
            end
        end
        
        % Meta
        function obj = set.Meta(obj, Meta)
            try
                validateattributes(Meta, {'CMeta'}, {}, 'set.Meta', 'Meta');
            catch ME
                error(ME.message);
            end
            
            obj.m_Meta = Meta;
        end
        
        % Name
        function obj = set.MotionPattern(obj, MotionPattern)
            try
                obj.Meta.MotionPattern = MotionPattern;
            catch ME
                error(ME.message);
            end
        end
        
        % Name
        function obj = set.Name(obj, Name)
            try
                obj.Meta.Name = Name;
            catch ME
                error(ME.message);
            end
        end
        
        % Number of wires
        function obj = set.NumberOfWires(obj, NumberOfWires)
            try
                obj.Meta.NumberOfWires = NumberOfWires;
            catch ME
                error(ME.message);
            end
        end
        
        
        function obj = AddCable(obj, Cable)
            try
                validateattributes(Cable, {'CCable'}, {}, 'set.Cable', 'Cable');
            catch ME
                error(ME.message);
            end
            
            obj.m_Cables(end+1) = Cable;
        end
        
    end
end