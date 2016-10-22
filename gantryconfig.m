
p.maxV = [240;240;151];
p.maxA = [20;20;20];
g = alexGantry(false,true,false,1,p.maxV,p.maxA);

lim = g.limitmm;

g.moveToPoint([0;0;0])
disp('moved to back left')

pause
g.moveToPoint([g.limitmm(1);0;0])
disp('moved to front left')

pause
g.moveToPoint([g.limitmm(1:2);0])
disp('moved to front right')

pause
g.moveToPoint([0;g.limitmm(2);0])
disp('moved to back right')

pause
g.homeGantry(false)