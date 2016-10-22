clear; clc

set(0,'DefaultFigureWindowStyle','docked') 
warning('off','images:imshow:magnificationMustBeFitForDockedFigure')

maxV = [151;151;151];
maxA = [20;20;20];
acuity = 0.5
g = Gantry(1,1,0,acuity,maxV,maxA);

g.moveToPoint([1500;1500;500])
% g.moveToPoint([0;0;0])

% pause(4)

% timer is set, simulation directory is created as a subdirectory of the one given
g.startSimulation('C:\Users\gantry\Desktop\chris\simulation_data')

%% circle parameters
linear = 100
radius = 500
smoothness = 15

plane = 1 % Plane selection: 1 = XY, 2 = XZ, 3 = YZ
direction = 1 % Travel direction: 1 = CCW, 2 = CW

%% calculate velocity components for circular motion
if plane == 1
    % calculate velocities for XY circle
    [x y] = circlePoints(radius,smoothness,direction);
    deltaT = setInterval(x,y,linear) % calculate deltaT
    velocities = [diff(x); diff(y); zeros(1,size(x,2)-1)] / deltaT; % vel = deltaX over deltaT
        
elseif plane == 2
    % calculate velocities for XZ circle
    [x z] = circlePoints(radius,smoothness,direction);
    deltaT = setInterval(x,z,linear) % calculate deltaT
    velocities = [diff(x); zeros(1,size(x,2)-1); diff(z)] / deltaT; % vel = deltaX over deltaT

elseif plane == 3
    % calculate velocities for YZ circle
    [y z] = circlePoints(radius,smoothness,direction);
    deltaT = setInterval(y,z,linear) % calculate deltaT
    velocities = [zeros(1,size(y,2)-1); diff(y); diff(z)] / deltaT; % vel = deltaX over deltaT

else
    error('incorrect plane specifier')
end
    
% velocities = velocities / 5
% deltaT = deltaT * 5
    
%% calculate velocities for ramps
accel = 10

if direction == 2
    accel = -1
    linear = -linear
end

velos = 0:accel:linear;

ramp_l = sum(velos)*deltaT

%% begin interpolation

steps = size(velos,2)
steps1 = steps
vel = [0 0 0]'
% lastVel = vel

t = 1;

%% ramp onto circle
for u = 1:steps
   
    delTic = tic;
    
    % specify velocity
    if plane == 1
        vel = vel + [0 accel 0]'; % this is for XY circles!
    elseif plane == 2
        vel = vel + [0 0 accel]'; % this is for XZ circles
    elseif plane == 3
        vel = vel + [0 0 accel]'; % this is for YZ circles!
    else
        error('incorrect plane specification')
    end
    
    % move at velocity
    [p(t,:), r(t,:), times(t)] = g.contMove(vel);

    t = t + 1;
    
    while(toc(delTic) < deltaT)
        % wait
    end
end

%% interpolate circle
steps = size(velocities,2)

for u = 1:steps
   
    delTic = tic;
        
    % specify velocity
    vel = velocities(:,u);
    % move at velocity
    [p(t,:), r(t,:), times(t)] = g.contMove(vel);
        
    f = g.getFrame();
    figure(100)
    imshow(f)
    
    t = t + 1;
    
    while(toc(delTic) < deltaT)
        % wait
    end
end

%% wind motors down

[posHist, speedHist, time] = g.windDown

posHist = [p' posHist];
speedHist = [r' speedHist];
time = [times time'];

figure(10)
plot3(posHist(1,:),posHist(2,:),posHist(3,:))
title('Trajectory')
xlabel('X')
ylabel('Y')
zlabel('Z')

figure(2)
plot(r(steps1+1:end,:))
title('Actual velocity for circle')
legend('X','Y','Z')

figure(3)
plot(velocities')
title('Theoretical velocity for circle')
legend('X','Y','Z')

figure(4)
plot(r(steps1+1:end,:)-velocities')
title('Velocity error for circle')
legend('X','Y','Z')

figure(5)
plot(time,speedHist')
title('Velocity over time for all of path')
xlabel('Time (s)')
ylabel('Velocity (mm/s)')
legend('X','Y','Z')

x_width = max(posHist(1,:))-min(posHist(1,:))
y_width = max(posHist(2,:))-min(posHist(2,:))
z_width = max(posHist(3,:))-min(posHist(3,:))

