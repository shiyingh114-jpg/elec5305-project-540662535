function run_validation()
%RUN_VALIDATION DSP invariants that matter for this controlled experiment.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);
cfg=project_config(); rng(cfg.randomSeed);
db=e5305.load_hrir(cfg);
p.fs=db.fs; p.windowLength=2*round(cfg.windowDuration*p.fs/2); p.hop=p.windowLength/2;
p.window=sqrt(hann(p.windowLength,'periodic'));
p.nfft=2^nextpow2(max(p.windowLength,size(db.ir,1)+max(db.delay,[],'all')));
assert(size(db.ir,2)==2 && db.fs==48000,'Expected measured 48 kHz binaural data.');
[h,d]=e5305.select_hrir(db,0,0,cfg);
assert(d.errorDeg<cfg.maxDirectionErrorDeg && all(isfinite(h),'all'));
% Non-hop-aligned sizes and both boundary impulses detect padding / sample shifts.
for count=[1,37,p.windowLength+17,3*p.fs+113]
    x=randn(count,2); x(1,:)=2; x(end,:)=-3;
    [X,meta]=e5305.analyse(x,p); recovered=e5305.synthesise(X,meta,p);
    assert(isequal(size(x),size(recovered)) && max(abs(x-recovered),[],'all')<1e-10);
    mask=rand(size(X,1),size(X,2));
    a=e5305.synthesise(X.*mask,meta,p); b=e5305.synthesise(X.*(1-mask),meta,p);
    assert(max(abs(a+b-x),[],'all')<1e-10,'Complementary mask reconstruction failed.');
    % Identical mask in each ear preserves cross-channel cues in the masked STFT.
    Y=X.*mask; active=abs(X(:,:,1).*X(:,:,2))>1e-12 & mask>1e-4;
    before=angle(X(:,:,1).*conj(X(:,:,2))); after=angle(Y(:,:,1).*conj(Y(:,:,2)));
    phaseError=angle(exp(1i*(before-after)));
    assert(all(abs(phaseError(active))<1e-10),'Shared mask altered STFT IPD.');
end
wrapped=angle(exp(1i*((-pi+0.01)-(pi-0.01))));
assert(abs(wrapped-0.02)<1e-12,'Phase wrapping is discontinuous.');
% FIR rendering must retain filter tails and exact per-ear impulse response.
rendered=e5305.render([1;zeros(10,1)],h);
assert(size(rendered,1)==size(h,1)+10 && max(abs(rendered(1:size(h,1),:)-h),[],'all')<1e-12);
% Silence gives undefined cue error, not artificial zero error.
[T,meta]=e5305.analyse(rendered,p);
[a,b,c]=e5305.cue_errors(zeros(size(T)),T,meta,(1:size(rendered,1))',p,cfg);
assert(isnan(a) && isnan(b) && c==0,'Silent estimate should have zero coverage.');
% Identity estimate and scalar gain distinguish SNR from scale-invariant SDR.
x=randn(10007,2); [T,meta]=e5305.analyse(x,p);
v=e5305.evaluate(0.5*x,x,x,T,(1:size(x,1))',meta,p,cfg);
assert(abs(v.snr-20*log10(2))<1e-10 && v.siSDR>100);
v=e5305.evaluate(x,x,x,T,(1:size(x,1))',meta,p,cfg);
assert(v.ild<1e-10 && v.ipd<1e-10 && abs(v.coverage-1)<1e-12);
% Estimated masks remain bounded when signals are identical to target rendering.
[s,n,nCal]=e5305.prepare_sources(cfg.targetFiles{1},cfg.interfererFiles{1},p.fs,cfg);
scene=e5305.render(s,h)+e5305.render(n,h);
[X,meta]=e5305.analyse(scene,p);
[masks,diagnostic]=e5305.estimate_masks(X,h,meta,p,nCal,cfg);
for name=fieldnames(masks)'
    M=masks.(name{1}); assert(all(isfinite(M),'all') && all(M>=0 & M<=1,'all'));
end
assert(nnz(diagnostic.calibrationFrames)>=3);
assert(max(abs(masks.ILD_IPD-masks.ILD.*masks.IPD),[],'all')<1e-12);
fprintf('Validation passed: measured HRIR, boundary reconstruction, complementarity, shared-ear IPD,\n');
fprintf('phase wrapping, convolution tails, silent cue handling, SNR/SI-SDR, and mask bounds.\n');
end
