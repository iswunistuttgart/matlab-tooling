classdef Robot
    properties (Transient)
        pMeta
    end
    
    methods
        function obj = Robot()
            obj.pMeta = Meta();
        end
        
        function oMeta = get.Meta(obj)
            oMeta = obj.pMeta
        end
        
    end
end