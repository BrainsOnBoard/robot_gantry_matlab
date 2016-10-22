function imdb_ridferrsbyrowchunked_all(whfig,dosave)
if nargin < 2
    dosave = false;
end
if nargin < 1
    whfig = 1;
else
    whfig = 10^(whfig-1);
end

nchunk = 6;

d = dir(fullfile(mfiledir,'unwrap_imdb_*'));
d = d([1 2 6 5]);
[mehc,sehc] = deal(NaN(nchunk,length(d)));
mehc_overall = NaN(1,length(d));
labels = cell(length(d),1);
for whdi = 1:length(d)
    [fd,whd,refxi,refyi] = imdb_getfigdat_ridferrsbyrowchunked(true,fullfile(mfiledir,d(whdi).name));
    
    ehc = 1-cos(min(pi/2,abs(pi2pi(fd.headsbychunk(:,:)))));
    mehc(:,whdi) = nanmean(ehc,2);
    mehc_overall(whdi) = nanmean(1-cos(min(pi/2,abs(pi2pi(fd.heads(:))))));
    sehc(:,whdi) = nanstd(ehc,[],2);
    labels{whdi} = imdb_getlabel(whd);
end

% mehc = bsxfun(@rdivide,mehc,sum(mehc));

xtl = cell(nchunk+1,1);
for i = 1:nchunk
    xtl{i} = num2str(i);
end
xtl{end} = 'overall';

figure(1*whfig);clf
% subplot(1,2,1)
barh(1:nchunk+1,[mehc;mehc_overall])
% xlim([0 1])
set(gca,'YDir','reverse','YTickLabel',xtl)
% title(whd,'Interpreter','none')
ylabel('which vertical slice (from top)')
xlabel('mean error over arena')
legend(labels{:})

[~,rank] = sort(mehc);
mean(rank,2)

% subplot(1,2,2)
% barh(1:nchunk,sehc)
% set(gca,'YDir','reverse')
% xlim([0 1])
% set(gca,'YTick',[])
% xlabel('std')

% load('gantry_cropparams.mat');
% refim = imdb_getim(whd,refyi,refxi);
% refim = refim(y1:y2,:);
% subplot(2,2,3:4)
% imshow(refim)
% hold on
% chunkht = 10;
% for i = 1:nchunk
%     y = min(size(refim,1),chunkht*i);
%     plot(xlim,[y y],'r')
% end

if dosave
    savefig('ridferrsbyrows',[20 25])
end

dump2base(true)