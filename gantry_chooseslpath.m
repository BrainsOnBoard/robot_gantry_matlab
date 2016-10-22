function gantry_chooseslpath(arenafn)
if nargin < 1
    arenafn = 'arena1_boxes.mat';
end

[clx,cly,cli] = gantry_chooseroute(arenafn,2);
if isempty(clx)
    return
end

fi = 1;
% if isempty(arenafn)
%     fpre = 'sl_';
% else
    fpre = ['sl_' matfileremext(arenafn) '_'];
% end
while true
    fn = sprintf(fullfile(mfiledir,'sl_dat','paths',sprintf('%s%03d.mat',fpre,fi)));
    if ~exist(fn,'file')
        break
    end
    fi = fi+1;
end

savemeta(fn,'arenafn','clx','cly','cli')