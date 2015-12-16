classdef Meta
    properties
        Name = ''
        MotionPattern = ''
        DegressOfFreedom = 0
        NumberOfWires = 0
    end
    
    methods
        function obj = Meta(Name, NumberOfWires, DegeesOfFreedom, MotionPattern)
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
        
        function obj = set.Name(obj, Name)
            try
                validateattributes(Name, {'char'}, {'nonempty'}, 'set.Name', 'Name');
            catch ME
                error(ME.message);
            end
            
            obj.Name = Name;
        end
        
        function obj = set.MotionPattern(obj, MotionPattern)
            try
                validatestring(MotionPattern, {'1T', '2T', '3T', '1R3T', '2R3T', '3R3T'}, 'set.MotionPattern', 'MotionPattern');
            catch ME
                error(ME.message);
            end
            
            obj.MotionPattern = MotionPattern;
        end
        
        function obj = set.DegressOfFreedom(obj, DegressOfFreedom)
            try
                validateattributes(DegressOfFreedom, {'numeric'}, {'scalar', '>=', 0}, 'set.DegreesOfFreedom', 'DegressOfFreedom');
            catch ME
                error(ME.message);
            end
            
            obj.DegressOfFreedom = DegressOfFreedom;
        end
        
        function obj = set.NumberOfWires(obj, NumberOfWires)
            try
                validateattributes(NumberOfWires, {'numeric'}, {'scalar', '>=', 0}, 'set.NumberOfWires', 'NumberOfWires');
            catch ME
                error(ME.message);
            end
            
            obj.NumberOfWires = NumberOfWires;
        end
    end
end