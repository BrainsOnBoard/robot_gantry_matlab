function [head,minval] = ridfheadbyrow(im,imref,angleunit)
if nargin < 3
    angleunit = 2*pi;
end

diffs = NaN(size(im));

for i = 1:size(im,2)
    diffs(:,i) = sqrt(mean((im-circshift(imref,i-1,2)).^2,2));
end

[minval,I] = min(diffs,[],2);
head = (I-1)*angleunit/size(im,2);
