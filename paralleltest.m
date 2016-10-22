cth = 0;
lastth = pi/2;

p.startoffs = [-1.5 -.5 0:2];

dth = circ_dist(cth,lastth);
fprintf('dth: %g\n',(180/pi)*dth);
%                 roffs = -p.startoffs*(tan(pi/2-dth)+1/sin(dth));
grad = 1; %dy/dx;
roffs = -sign(dth)*(p.startoffs/grad)*(1-sqrt(1+grad^2));
[rxoff,ryoff] = rotatexy(roffs,p.startoffs,lastth); % -(dth>0)*pi/2,+(dth>0)*pi/2
% rclx(end+1,:) = rxoff+stx;
% rcly(end+1,:) = ryoff+sty;

figure(2);clf
plot([zeros(1,5);roffs],[p.startoffs;p.startoffs],'b',rxoff,ryoff,'g+')