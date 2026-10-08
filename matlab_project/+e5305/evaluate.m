function out = evaluate(estimate,reference,mixture,referenceSTFT,evalSamples,meta,p,cfg)
%EVALUATE Distortion-aware SNR, mean per-ear SI-SDR, reference-weighted binaural errors.
% SNR = ||clean||^2 / ||estimate-clean||^2. No gain fitting or time realignment.
assert(isequal(size(estimate),size(reference),size(mixture)),'Metric inputs must align.');
s=reference(evalSamples,:); y=estimate(evalSamples,:);
refEnergy=sum(s.^2,'all'); errEnergy=sum((y-s).^2,'all');
out.snr=10*log10(refEnergy/max(errEnergy,refEnergy*1e-12));
earScores=nan(1,2);
for ear=1:2
    r=s(:,ear)-mean(s(:,ear)); z=y(:,ear)-mean(y(:,ear));
    energy=sum(r.^2);
    if energy<=realmin || sum(z.^2)<=energy*1e-16, continue; end
    aligned=(r'*z/energy)*r;
    projectionEnergy=sum(aligned.^2);
    distortionEnergy=sum((z-aligned).^2);
    earScores(ear)=10*log10(max(projectionEnergy,energy*1e-12)/ ...
        max(distortionEnergy,energy*1e-12));
end
out.siSDR=mean(earScores,'omitnan');
[Y,~]=e5305.analyse(estimate,p);
[out.ild,out.ipd,out.coverage]=e5305.cue_errors(Y,referenceSTFT,meta,evalSamples,p,cfg);
out.stoi=NaN;
if cfg.computeSTOI
    assert(~isempty(which('stoi')), 'ELEC5305:STOIDependency','STOI requires its MATLAB implementation.');
    % MathWorks stoi(processed,reference,fs), evaluated per ear on identical samples.
    out.stoi=mean([stoi(y(:,1),s(:,1),p.fs),stoi(y(:,2),s(:,2),p.fs)]);
end
end
