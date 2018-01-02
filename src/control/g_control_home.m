function g_control_home
%G_CONTROL_HOME   Returns the gantry to its home position.
% The gantry is raised before homing.

% creates a gantry object, which performs homing then is destroyed
g_control_object('home',true);