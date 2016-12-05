classdef gantry_agent < handle
    properties (GetAccess=private, SetAccess=private)
        stepsize;
        x = 0;
        y = 0;
        z;
    end
    
    properties (GetAccess=private, SetAccess=private)
        gantry_obj = gantry_default;
    end
    
    methods
        function g = gantry_agent(stepsize_in_mm, z)
            g.stepsize = stepsize_in_mm;
            g.z = z;
        end
        
        function im = get_image(g)
            im = g.gantry_obj.getFrame;
        end
        
        function stepforward(g, heading)
            [xoff,yoff] = pol2cart(heading * pi/180, g.stepsize);
            g.moveToPoint([g.x + xoff, g.y + yoff, g.z]);
        end
    end
end
