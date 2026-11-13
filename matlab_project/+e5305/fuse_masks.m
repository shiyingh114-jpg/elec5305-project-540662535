function M = fuse_masks(spatial,W,lambda)
%FUSE_MASKS Bound the additional attenuation from an uncertain Wiener estimate.
% lambda=0 reproduces the original product; lambda=1 gives spatial-only masking.
validateattributes(lambda,{'numeric'},{'scalar','finite','>=',0,'<=',1});
assert(isequal(size(spatial),size(W)),'Masks must have matching shapes.');
assert(all(isfinite(spatial) & spatial>=0 & spatial<=1,'all') && ...
    all(isfinite(W) & W>=0 & W<=1,'all'),'Input masks must be in [0,1].');
M=spatial.*(lambda+(1-lambda)*W);
end
