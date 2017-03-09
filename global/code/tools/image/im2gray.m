function im2=im2gray(im)
switch size(im,3)
    case 1
        im2 = im;
    case 3
        im2 = rgb2gray(im);
    otherwise
        error('bad image size')
end