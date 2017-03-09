function drawobjverts(objverts,arenascale,linestyle)
if nargin < 3
    linestyle = 'b';
end
if nargin < 2 || isempty(arenascale)
    arenascale = 1000;
end

if ischar(objverts)
    load(objverts,'objverts');
end
if ~iscell(objverts) && ~isempty(objverts)
    objverts = {objverts};
end

load('arenadim.mat','lim')
lim = lim*arenascale/1000;

hold on
for i = 1:length(objverts)
    cv = reshape(objverts{i},2,length(objverts{i})/2)'*arenascale/1000;
    plot([cv(:,1);cv(1,1)],[cv(:,2);cv(1,2)],linestyle)
end

axis equal
xlim([0 lim(1)])
ylim([0 lim(2)])