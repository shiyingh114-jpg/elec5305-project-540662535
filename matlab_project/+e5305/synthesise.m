function x = synthesise(X,meta,p)
%SYNTHESISE Use the same standard ISTFT parameters and remove only known padding.
xp=istft(X,p.fs,'Window',p.window,'OverlapLength',p.windowLength-p.hop, ...
    'FFTLength',p.nfft,'FrequencyRange','onesided','Method','wola','ConjugateSymmetric',true);
assert(size(xp,1)>=meta.prefix+meta.length,'ISTFT length is insufficient.');
x=real(xp(meta.prefix+(1:meta.length),:));
end
