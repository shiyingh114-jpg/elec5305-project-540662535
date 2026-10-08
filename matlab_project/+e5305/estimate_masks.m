function [masks,d] = estimate_masks(X,hTarget,meta,p,nCal,cfg)
%ESTIMATE_MASKS Proposal 5.4/5.5: target-template Gaussian cue weights.
% Inputs deliberately exclude clean target/interferer STFTs and interferer direction.
L=X(:,:,1); R=X(:,:,2);
power=mean(abs(X).^2,3);
tiny=max(max(power,[],'all')*1e-12,realmin);
d.ild=10*log10((abs(L).^2+tiny)./(abs(R).^2+tiny));
d.ipd=angle(L.*conj(R));
H=fft(hTarget,p.nfft,1); H=H(1:size(X,1),:);
htiny=max(max(abs(H),[],'all')*1e-12,realmin);
d.targetILD=20*log10((abs(H(:,1))+htiny)./(abs(H(:,2))+htiny));
d.targetIPD=angle(H(:,1).*conj(H(:,2)));
d.deltaILD=d.ild-d.targetILD;
d.deltaIPD=angle(exp(1i*(d.ipd-d.targetIPD))); % Circular difference [-pi,pi].
ildWeight=exp(-0.5*(d.deltaILD/cfg.sigmaILDdB).^2);
ipdWeight=exp(-0.5*(d.deltaIPD/cfg.sigmaIPDrad).^2);
validFrequency=meta.frequency>=cfg.cueBandHz(1) & meta.frequency<=cfg.cueBandHz(2) & ...
    min(abs(H),[],2)>max(abs(H),[],'all')*10^(cfg.hrtfFloorDb/20);
% Unreliable frequencies are neutral (1); silent bins below are suppressed (0).
ildWeight(~validFrequency,:)=1; ipdWeight(~validFrequency,:)=1;
calibration=meta.time>=p.windowLength/(2*p.fs) & ...
    meta.time<=(nCal-size(hTarget,1)-p.windowLength/2)/p.fs;
assert(nnz(calibration)>=3,'Calibration too short for uncontaminated frames.');
noisePSD=mean(power(:,calibration),2);
assert(sum(noisePSD)>tiny,'Interferer-only calibration is silent; change its offset/file.');
noisePSD=max(noisePSD,tiny);
alpha=exp(-p.hop/(p.fs*cfg.powerTimeConstant));
beta=exp(-p.hop/(p.fs*cfg.noiseTimeConstant));
smoothPower=noisePSD;
W=zeros(size(power)); d.noiseUpdate=false(1,size(X,2));
for m=1:size(X,2)
    smoothPower=alpha*smoothPower+(1-alpha)*power(:,m);
    afterCalibration=meta.time(m)>nCal/p.fs;
    if afterCalibration && sum(smoothPower)<cfg.noiseUpdateThreshold*sum(noisePSD)
        noisePSD=beta*noisePSD+(1-beta)*smoothPower;
        noisePSD=max(noisePSD,tiny); d.noiseUpdate(m)=true;
    end
    speechPSD=max(smoothPower-noisePSD,0);
    W(:,m)=speechPSD./max(speechPSD+noisePSD,tiny);
end
masks.Wiener=W;
masks.ILD=ildWeight;
masks.IPD=ipdWeight;
masks.ILD_IPD=ildWeight.*ipdWeight;
masks.Wiener_ILD_IPD=W.*ildWeight.*ipdWeight;
silent=power<max(power,[],'all')*10^(cfg.silentBinFloorDb/10);
names=fieldnames(masks);
for j=1:numel(names)
    M=masks.(names{j}); M=max(cfg.maskFloor,min(1,M)); M(silent)=0;
    assert(all(isfinite(M),'all') && all(M>=0 & M<=1,'all'),'Invalid mask.');
    masks.(names{j})=M;
end
d.validFrequency=validFrequency; d.calibrationFrames=calibration;
d.finalNoisePSD=noisePSD;
end
