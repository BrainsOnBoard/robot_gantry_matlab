function im2 = gantry_processim_green(im,unwrapparams,crop)
if nargin<2
    load('gantry_centrad.mat')
end
im2 = circshift(fliplr(andy_unwrap(im(:,:,2),unwrapparams)),0.25*size(unwrapparams.xM,2),2);
if nargin<1
    crop = load('gantry_cropparams.mat');
end
if exist('crop','var')
    im2 = im2(crop.y1:crop.y2,:);
end
