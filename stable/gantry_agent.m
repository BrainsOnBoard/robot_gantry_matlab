classdef gantry_agent < handle
    properties (GetAccess=private, SetAccess=private)
        stepsize;
        x = 0;
        y = 0;
        z;
    end
    
    properties (GetAccess=private, SetAccess=private)
        gantry_obj;
    end
    
    methods
        function g = gantry_agent(stepsize_in_mm, z)
            g.stepsize = stepsize_in_mm;
            g.z = z;
            
            g.gantry_obj = gantry_default;
        end
        
        function im = get_image(g)
            im = flipud(g.gantry_obj.getFrame);
        end
        
        function stepforward(g, heading)
            [xoff,yoff] = pol2cart(heading * pi/180, g.stepsize);
            g.move_to_point(g.x + xoff, g.y + yoff);
        end
        
        function move_to_point(g, x, y)
            g.x = x;
            g.y = y;
            g.gantry_obj.moveToPoint([x, y, g.z]);
        end
        
        function delete(g)
            delete(g.gantry_obj);
        end
    end
end
