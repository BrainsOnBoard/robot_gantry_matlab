function [objim,badzone,oxs,oys,goxs,goys]=gantry_getbadzoneim(arenafn,objgridac,headclear,zht)
if nargin < 4
    zht = 0;
end
objmap = gantry_getobjmatrix_3d(arenafn,objgridac);
pts = objmap>0 & objmap >= zht;
goodzone = conv2(single(pts),ones(ceil(headclear/objgridac),'single'),'same')==0;
objim = repmat(~pts,1,1,3);
objim(:,:,2) = goodzone;
objim(:,:,3) = goodzone;
objim = im2uint8(objim);
badzone = ~goodzone;

oxs = objgridac*(0.5+(0:size(badzone,2)-1));
oys = objgridac*(0.5+(0:size(badzone,1)-1));
[goxs,goys] = meshgrid(oxs,oys);