function [head,minval] = ridfhead(im,imref,angleunit)
if nargin < 3
    angleunit = 2*pi;
end

if ~isa(im,'double') || ~isa(imref,'double')
    error('images should be doubles for ridfs')
end

diffs = NaN(1,size(im,2));

for i = 1:size(im,2)
    diffs(i) = getRMSdiff(im,circshift(imref,i-1,2));
end

[minval,I] = min(diffs);
head = (I-1)*angleunit/size(im,2);