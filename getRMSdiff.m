function rmsval = getRMSdiff(v1,v2)
rmsval = sqrt(sum(sum(bsxfun(@minus,v1,v2).^2,1),2)./numel(v1(:,:,1)));
