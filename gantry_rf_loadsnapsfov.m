function rd=gantry_rf_loadsnapsfov(arenafn,whroute,fov)
% function rd=gantry_rf_loadsnapsfov(arenafn,whroute,fov)

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),whroute);
rd = load(fullfile(mfiledir,'routedat',routefn));
if fov==360
    rd.snths = atan2(diff(rd.cly),diff(rd.clx));
    rd.snths(end+1) = rd.snths(end);
else
    load(fullfile(mfiledir,'routedat',sprintf('snaps_%s_fov%03d',routefn,fov)),'fovsnaps')
    rd.snaps = fovsnaps;
%     clear fovsnaps
    rd.snths = [];
end