function [ildError,ipdError,coverage] = cue_errors(Y,T,meta,evalSamples,p,cfg)
%CUE_ERRORS Do not invent phase for silent outputs. Report covered reference energy.
refPower=mean(abs(T).^2,3); refPeak=max(refPower,[],'all');
inTime=meta.time>=(evalSamples(1)-1)/p.fs & meta.time<=(evalSamples(end)-1)/p.fs;
inFreq=meta.frequency>=cfg.metricBandHz(1) & meta.frequency<=cfg.metricBandHz(2);
valid=inFreq & inTime & min(abs(T).^2,[],3)>refPeak*10^(cfg.metricReferenceFloorDb/10);
weights=refPower.*valid;
denom=sum(weights,'all');
present=min(abs(Y).^2,[],3)>refPeak*10^(cfg.metricEstimateFloorDb/10);
used=valid & present;
covered=sum(refPower.*used,'all');
if denom<=realmin, ildError=NaN; ipdError=NaN; coverage=NaN; return; end
coverage=covered/denom;
if covered<=realmin, ildError=NaN; ipdError=NaN; return; end
floorValue=max(refPeak*1e-14,realmin);
ildT=10*log10((abs(T(:,:,1)).^2+floorValue)./(abs(T(:,:,2)).^2+floorValue));
ildY=10*log10((abs(Y(:,:,1)).^2+floorValue)./(abs(Y(:,:,2)).^2+floorValue));
ipdT=angle(T(:,:,1).*conj(T(:,:,2))); ipdY=angle(Y(:,:,1).*conj(Y(:,:,2)));
deltaPhase=angle(exp(1i*(ipdY-ipdT)));
ildError=sqrt(sum(refPower.*used.*(ildY-ildT).^2,'all')/covered);
ipdError=sqrt(sum(refPower.*used.*deltaPhase.^2,'all')/covered);
end
