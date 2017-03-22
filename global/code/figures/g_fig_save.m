function cnt=g_fig_save(ofname,sz,ext,type,r)
%function cnt=g_fig_save(ofname,sz,ext,type,r)

global LASTFIGS
% function savefig(fname,sz,ext,type)
% global verbose
if nargin < 5
    r = 300;
end
if nargin == 3
    type = ext;
end
% issvg = false;
if nargin < 3
    type = 'pdf';
    ext = 'pdf';
% elseif strcmp(type,'svg')
%     issvg = true;
%     type = 'pdf';
%     ext = 'pdf';
end
ext = ['.' ext];
if nargin < 2
    sz = [16 7];
end
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperSize',sz);
set(gcf,'PaperPosition',[0 0 sz]);
% set(gca,'FontSize',8)
% set(gca, 'Position', get(gca, 'OuterPosition') - ...
%   get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
%set(gca,'Position',[0 0 1 1]);

% if length(fname) >= length(ext) && strcmpi(fname((end-length(ext)+1):end),ext)
%     fname = fname((end-length(ext)+1):end);
% % end
% ofname = [figdir filesep ofname];

d = dbstack;
if length(d) > 1
    mfd = d(2).name;
else
    mfd = '.';
end
dname = fullfile(g_dir_figures,mfd);
if ~exist(dname,'dir')
    mkdir(dname);
end

cnt = 1;
while true
    fname = fullfile(dname,sprintf('%04d_%s%s',cnt,ofname,ext));
    if ~exist(fname,'file')
        break;
    end
    cnt = cnt+1;
end

fprintf('Saving figure to %s...\n',fname);
print(['-d' type],sprintf('-r%d',r),fname);

if isempty(LASTFIGS)
    LASTFIGS = { fname };
else
    LASTFIGS = [ {fname}; LASTFIGS ];
end

% if strcmpi(ext,'.eps') || strcmpi(ext,'.pdf')
%     system(['okular "' fname '" &']);
% else
%     system(['ristretto "' fname '" &']);
% end

if ~nargout
    clear cnt
end
% if issvg % do conversion
%     sfname = [figdir filesep ofname];
%     cnt = 2;
%     while exist([sfname '.svg'],'file')
%         sfname = sprintf('%s (%d)',ofname,cnt);
%         cnt = cnt+1;
%     end
%     sfname = [sfname '.svg'];
%     fprintf('Converted file name: %s\n',sfname);
%     system(sprintf('inkscape -l "%s" "%s%s"',sfname,fname,ext));
% end