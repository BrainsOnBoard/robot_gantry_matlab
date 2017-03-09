function gantry_home

p.maxV = [240;240;151];
p.maxA = [20;20;20];
acuity = 1;
% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA, showvidpreview)
g = alexGantry(false,true,false,acuity,p.maxV,p.maxA,false,false);

delete(g)