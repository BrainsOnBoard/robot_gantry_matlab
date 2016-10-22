function imout=imbwdrawline(im,x,y)
if isrow(x)
    x = x(:);
    y = y(:);
end
imout = im2uint8(im);
for i = 1:size(x,2)
    cx = x(:,i);
    cy = y(:,i);
    if length(cx)==2 && cx(1)==cx(2) && cy(1)==cy(2)
        imout(round(cy(1)),round(cx(1)),:) = 255;
    else
        verts = [cx'; cy'];
        imout = insertShape(imout,'Line',verts(:)','Color','white','Opacity',1,'SmoothEdges',false);
    end
%     figure(2);clf
%     imshow(imout)
%     keyboard
end

imout = im2bw(imout);