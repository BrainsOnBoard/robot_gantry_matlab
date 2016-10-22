function th=infomax_gethead(im,weights)
    dec = NaN(size(im,2),1);
    for i = 1:size(im,2)
        crim = circshift(im,[0 i-1]);
        dec(i) = sum(abs(weights*crim(:)));
    end
    [cert,minI] = min(dec);

    th = 2*pi*(minI-1)/size(im,2);
end
