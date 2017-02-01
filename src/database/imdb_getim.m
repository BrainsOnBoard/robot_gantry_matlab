function fr=imdb_getim(whd,y,x,crop)
load(fullfile(whd,sprintf('im_%03d_%03d.mat',y,x)))

if nargin==4
    fr = fr(crop.y1:crop.y2,:);
end