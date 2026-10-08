function [r,metrics] = remix(demo,hTarget,hResidual,p,cfg)
%REMIX Stage 2 demonstration, evaluated against matched clean projected references.
% Simple mono fold-down retains original HRIR colour; it is not dry-source inversion.
targetMono=mean(demo.estimates.(cfg.demoMethod),2);
residualMono=mean(demo.residual,2);
cleanTargetMono=mean(demo.target,2);
cleanInterfererMono=mean(demo.interferer,2);
r.target=e5305.render(targetMono,hTarget);
r.residual=e5305.render(residualMono,hResidual);
r.idealTarget=e5305.render(cleanTargetMono,hTarget);
r.idealResidual=e5305.render(cleanInterfererMono,hResidual);
count=max(size(r.target,1),size(r.residual,1));
names=fieldnames(r);
for k=1:numel(names)
    x=r.(names{k}); r.(names{k})=[x;zeros(count-size(x,1),2)];
end
r.combined=r.target+r.residual;
r.idealCombined=r.idealTarget+r.idealResidual;
estimates={r.target,r.residual,r.combined};
references={r.idealTarget,r.idealResidual,r.idealCombined};
components={'Target','Residual_background','Combined'};
rows=struct([]);
for k=1:3
    [T,meta]=e5305.analyse(references{k},p);
    v=e5305.evaluate(estimates{k},references{k},references{k},T, ...
        demo.evalSamples,meta,p,cfg);
    rows(k).Component=string(components{k});
    rows(k).Reference="Clean binaural mono fold-down + same new HRIR";
    rows(k).ReconstructionSNRdB=v.snr; rows(k).SISDRdB=v.siSDR;
    rows(k).ILD_RMSE_dB=v.ild; rows(k).IPD_RMSE_rad=v.ipd;
    rows(k).CueEnergyCoverage=v.coverage;
end
metrics=struct2table(rows);
end
