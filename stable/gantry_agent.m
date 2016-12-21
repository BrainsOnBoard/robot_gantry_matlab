classdef gantry_agent < handle
    properties (GetAccess=public, SetAccess=private)
        limitmm;
    end

    properties (GetAccess=private, SetAccess=private)
        gantry_obj;
        unwrapparams;
    end
    
    methods
        function g = gantry_agent
            g.gantry_obj = gantry_default;
            g.limitmm = g.gantry_obj.limitmm;
            
            load('gantry_centrad.mat','unwrapparams')
            g.unwrapparams = unwrapparams;
        end
        
        function im = get_image(g)
            im = circshift(fliplr(andy_unwrap(rgb2gray(g.gantry_obj.getRawFrame),g.unwrapparams)),0.25*size(g.unwrapparams.xM,2),2);
        end
        
        function move_to_point(g, x, y, z)
            g.gantry_obj.moveToPoint([x, y, z]);
        end
        
        function delete(g)
            delete(g.gantry_obj);
        end
    end
end