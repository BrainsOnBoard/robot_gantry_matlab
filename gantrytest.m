disp('== running gantrytest')

maxV = [151;151;151];
maxA = [20;20;20];
acuity = 1;

% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA)
g = alexGantry(false,true,false,acuity,maxV,maxA);

disp('== moving gantry')
g.moveToPoint([600;0;500])

disp('== getting frame')
fr = g.getRawFrame;

g.moveToPoint([300;0;500])

disp('== homing gantry')
g.homeGantry(false);

disp('== deleting gantry object')
delete(g)

figure(1);clf
imshow(fr)