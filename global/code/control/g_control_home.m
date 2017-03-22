function g_control_home
%G_CONTROL_HOME   Returns the gantry to its home position.
% The gantry is raised before homing.

p.maxV = [240;240;151];
p.maxA = [20;20;20];
acuity = 1;
% Gantry(debug, home_gantry, disableZ, acuity, maxV, maxA, showvidpreview)
g = g_control_object(false,true,false,acuity,p.maxV,p.maxA,false,false);

delete(g)