function g=gantry_default()
p.maxV = [240;240;151];
p.maxA = [20;20;20];

% function g = alexGantry(debug, homeGantry, disableZ, acuity, maxV, maxA, showvidpreview, simulate)
g = alexGantry(false,true,false,1,p.maxV,p.maxA,false,false);

