function imfun = gantry_getimfun(improc)
switch improc
    case 'histeq'
        imfun = @histeq;
    case 'bin'
        thresh = gantry_imthresh;
        imfun = @(x) x > thresh;
    case ''
        imfun = @deal;
end