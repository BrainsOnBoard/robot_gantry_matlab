function cnt=g_fig_save(ofname,sz,ext,type,dpi,addprefix)
%function cnt=g_fig_save(ofname,sz,ext,type,r,addprefix)

global LASTFIGS

if nargin < 6
    addprefix = true;
end
if nargin < 5 || isempty(dpi)
    dpi = 300;
end
if nargin < 3 || isempty(ext)
    type = 'pdf';
end
if nargin == 3 || isempty(type)
    type = ext;
end
ext = ['.' ext];
if nargin < 2
    sz = [16 7];
end
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperSize',sz);
set(gcf,'PaperPosition',[0 0 sz]);

if addprefix
    % directory, based on global g_dir_figures and current subdir
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

    % prepend number for filename
    cnt = 1;
    while true
        fname = fullfile(dname,sprintf('%04d_%s%s',cnt,ofname,ext));
        if ~exist(fname,'file')
            break;
        end
        cnt = cnt+1;
    end
else
    % no prefix, put in g_dir_figures
    fname = fullfile(g_dir_figures,ofname);
end

fprintf('Saving figure to %s...\n',fname);
print(['-d' type],sprintf('-r%d',dpi),fname);

if isempty(LASTFIGS)
    LASTFIGS = { fname };
else
    LASTFIGS = [ LASTFIGS; {fname} ];
end

if ~nargout
    clear cnt
end
