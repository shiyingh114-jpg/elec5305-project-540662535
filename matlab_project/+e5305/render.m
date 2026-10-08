function y = render(x,h)
%RENDER Full linear convolution preserves HRIR delays and complete filter tail.
assert(size(h,2)==2 && isvector(x),'Need mono source and left/right HRIR pair.');
y=[conv(x(:),h(:,1),'full'),conv(x(:),h(:,2),'full')];
% Never normalise the ears independently: that would destroy measured ILD.
end
