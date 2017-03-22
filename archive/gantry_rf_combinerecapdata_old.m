function g_live_combinerecapdata

arenafn = [];
whroute = 5;

whtrial = 1;
whoffs = 1;

maindatadir = fullfile(mfiledir,'routedat','data');
datadir = fullfile(maindatadir,sprintf('route_%s_%03d',arenafn,whroute));
load(fullfile(datadir,'params.mat'));

outdatafn = fullfile(maindatadir,sprintf('route_%s_%03d_trial_%04d_offs_%04d.mat',arenafn,whroute,whtrial,whoffs));

vars = {'curx','cury','curth','head','minval','whsn','bear','goalx','goaly', ...
        'goalxi','goalyi','shortestdisttoroute','whnearest','bad_collision', ...
        'bad_distfromroute','bad_outofarena','isbad'};
    
outd = struct;
for i = 1:length(vars)
    outd.(vars{i}) = [];
end

cstep = 1;
while true
    cfn = fullfile(datadir,sprintf('trial%04d_offs%04d_step%04d.mat',whtrial,whoffs,cstep));
    if ~exist(cfn,'file')
        break;
    end
    load(cfn);
    for i = 1:length(vars)
        outd.(vars{i})(end+1) = d.(vars{i});
    end
    cstep = cstep+1;
end

savemeta(outdatafn,'pr','outd');