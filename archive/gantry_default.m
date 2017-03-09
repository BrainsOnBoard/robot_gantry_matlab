function g=gantry_default()
p.maxV = [240;240;151];
p.maxA = [20;20;20];

% function g = g_control_object(debug, home_gantry, disableZ, acuity, maxV, maxA, showvidpreview, simulate)
g = g_control_object(false,true,false,1,p.maxV,p.maxA,false,false);

