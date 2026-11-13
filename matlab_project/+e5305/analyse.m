function [X,meta] = analyse(x,p)
%ANALYSE Standard MATLAB STFT with explicit boundary and hop padding.
validateattributes(x,{'double'},{'2d','real','finite','nonempty'});
meta.length=size(x,1); meta.prefix=p.windowLength;
overlap=p.windowLength-p.hop;
total=ceil((meta.length+2*meta.prefix-overlap)/p.hop)*p.hop+overlap;
xp=[zeros(meta.prefix,size(x,2));x;zeros(total-meta.prefix-meta.length,size(x,2))];
[X,meta.frequency,meta.time]=stft(xp,p.fs,'Window',p.window, ...
    'OverlapLength',overlap,'FFTLength',p.nfft,'FrequencyRange','onesided');
meta.frequency=meta.frequency(:);
meta.time=meta.time(:).'-meta.prefix/p.fs; % Explicit row: frequency-by-time broadcasting.
end
