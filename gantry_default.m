classdef gantry_default < alexGantry
    methods
        function g=gantry_default()
            p.maxV = [240;240;151];
            p.maxA = [20;20;20];
            acuity = 1;
            % Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA)
            g@alexGantry(false,false,false,acuity,p.maxV,p.maxA,true);
        end
    end
end