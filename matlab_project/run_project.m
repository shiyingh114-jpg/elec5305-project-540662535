function [metrics, summary] = run_project(cfg)
%RUN_PROJECT Complete controlled experiment; no clean-source input to estimated masks.
% Usage: run_project; or cfg=project_config; cfg.inputSNRs=[-5 0 5]; run_project(cfg).
if nargin == 0, cfg = project_config(); end
root = fileparts(mfilename('fullpath'));
addpath(root); % Do not genpath the old toolbox: it can shadow stft/istft.
assert(~isempty(which('stft')) && ~isempty(which('resample')), ...
    'ELEC5305:Toolbox', 'Signal Processing Toolbox is required.');
assert(numel(cfg.targetFiles) == numel(cfg.interfererFiles), 'File pairs must match.');
assert(cfg.sigmaILDdB>0 && cfg.sigmaIPDrad>0, 'Cue tolerances must be positive.');
assert(cfg.maskFloor>=0 && cfg.maskFloor<1, 'Mask floor must be in [0,1).');
rng(cfg.randomSeed);
if ~isfolder(cfg.outputDir), mkdir(cfg.outputDir); end
db = e5305.load_hrir(cfg);
fs = db.fs;
p.fs = fs;
p.windowLength = 2*round(cfg.windowDuration*fs/2);
p.hop = p.windowLength/2;
p.window = sqrt(hann(p.windowLength,'periodic'));
p.nfft = 2^nextpow2(max(p.windowLength,size(db.ir,1)+max(db.delay,[],'all')));
assert(iscola(p.window,p.windowLength-p.hop,'wola'), 'Window must satisfy WOLA.');
[hTarget, targetDirection] = e5305.select_hrir(db, cfg.targetAzimuth, cfg.elevation, cfg);
[hNewTarget, newTargetDirection] = e5305.select_hrir(db,cfg.remixTargetAzimuth,cfg.elevation,cfg);
[hNewResidual, newResidualDirection] = e5305.select_hrir(db,cfg.remixResidualAzimuth,cfg.elevation,cfg);
rows = struct([]); directions = struct([]); demo = struct(); row = 0; sceneIndex = 0;
fprintf('HRIR: %s\nBackend: %s; fs=%g Hz\n',db.file,db.backend,fs);
for pair = 1:numel(cfg.targetFiles)
    [s,n,nCal] = e5305.prepare_sources(cfg.targetFiles{pair},cfg.interfererFiles{pair},fs,cfg);
    cleanTarget = e5305.render(s,hTarget);
    for separation = cfg.angularSeparations
        [hInterferer, intDirection] = e5305.select_hrir(db, ...
            cfg.targetAzimuth+separation,cfg.elevation,cfg);
        rawInterferer = e5305.render(n,hInterferer);
        count = max(size(cleanTarget,1),size(rawInterferer,1));
        target = [cleanTarget;zeros(count-size(cleanTarget,1),2)];
        rawNoise = [rawInterferer;zeros(count-size(rawInterferer,1),2)];
        evalSamples = (nCal+size(hTarget,1)+p.windowLength:count)';
        assert(numel(evalSamples)>fs/2, 'At least 0.5 s of evaluated speech is required.');
        for inputSNR = cfg.inputSNRs
            noiseGain = sqrt(sum(target(evalSamples,:).^2,'all') / ...
                max(sum(rawNoise(evalSamples,:).^2,'all'),realmin) / 10^(inputSNR/10));
            noise = noiseGain*rawNoise;
            mixture = target+noise;
            [X,meta] = e5305.analyse(mixture,p);
            [T,~] = e5305.analyse(target,p);
            [N,~] = e5305.analyse(noise,p);
            reconstruction = e5305.synthesise(X,meta,p);
            reconstructionError = max(abs(reconstruction-mixture),[],'all');
            assert(reconstructionError<1e-9*max(1,max(abs(mixture),[],'all')), ...
                'ELEC5305:Reconstruction','STFT reconstruction/alignment failed.');
            % These five masks only see mixture, target HRIR and calibration schedule.
            [masks,diagnostic] = e5305.estimate_masks(X,hTarget,meta,p,nCal, cfg);
            % Oracle is computed separately, never passed into estimate_masks.
            targetPower = mean(abs(T).^2,3); noisePower = mean(abs(N).^2,3);
            masks.OraclePowerRatio = targetPower ./ max(targetPower+noisePower,realmin);
            names = [{'Mixture'};fieldnames(masks)];
            sceneIndex = sceneIndex+1;
            actualSeparation = acosd(max(-1,min(1,dot(targetDirection.unitVector,intDirection.unitVector))));
            directions(sceneIndex).Pair = pair;
            directions(sceneIndex).RequestedSeparationDeg = separation;
            directions(sceneIndex).ActualSeparationDeg = actualSeparation;
            directions(sceneIndex).RequestedSNRdB = inputSNR;
            directions(sceneIndex).TargetAzimuthDeg = targetDirection.azimuth;
            directions(sceneIndex).TargetElevationDeg = targetDirection.elevation;
            directions(sceneIndex).InterfererAzimuthDeg = intDirection.azimuth;
            directions(sceneIndex).InterfererElevationDeg = intDirection.elevation;
            inputMetric = e5305.evaluate(mixture,target,mixture,T,evalSamples,meta,p,cfg);
            for j = 1:numel(names)
                name = names{j};
                if strcmp(name,'Mixture'), M=ones(size(X,1),size(X,2)); else, M=masks.(name); end
                estimate = e5305.synthesise(X.*M,meta,p);
                residual = e5305.synthesise(X.*(1-M),meta,p);
                complementError = max(abs(estimate+residual-mixture),[],'all');
                assert(complementError<1e-9*max(1,max(abs(mixture),[],'all')), 'Complement failed.');
                values = e5305.evaluate(estimate,target,mixture,T,evalSamples,meta,p,cfg);
                % Freeze the mixture-derived mask when measuring component suppression.
                targetPassed = e5305.synthesise(T.*M,meta,p);
                noisePassed = e5305.synthesise(N.*M,meta,p);
                outputSIR = 10*log10(max(sum(targetPassed(evalSamples,:).^2,'all'),realmin)/ ...
                    max(sum(noisePassed(evalSamples,:).^2,'all'),realmin));
                row=row+1;
                rows(row).Pair=pair;
                rows(row).RequestedSeparationDeg=separation;
                rows(row).ActualSeparationDeg=actualSeparation;
                rows(row).InputSNRdB=inputSNR;
                rows(row).Method=string(name);
                rows(row).ReconstructionSNRdB=values.snr;
                rows(row).SNRImprovementdB=values.snr-inputMetric.snr;
                rows(row).SISDRdB=values.siSDR;
                rows(row).SISDRImprovementdB=values.siSDR-inputMetric.siSDR;
                rows(row).OutputSIRdB=outputSIR;
                rows(row).SIRImprovementdB=outputSIR-inputSNR;
                rows(row).ILD_RMSE_dB=values.ild;
                rows(row).IPD_RMSE_rad=values.ipd;
                rows(row).CueEnergyCoverage=values.coverage;
                rows(row).STOI=values.stoi;
                rows(row).ComplementMaxError=complementError;
                fprintf('pair %d, %g deg (%g actual), %g dB, %-18s SI-SDRi=%+.2f dB\n', ...
                    pair,separation,actualSeparation,inputSNR,name,rows(row).SISDRImprovementdB);
                if pair==cfg.demoPair && separation==cfg.demoSeparation && inputSNR==cfg.demoSNR
                    demo.estimates.(name)=estimate;
                    if strcmp(name,cfg.demoMethod), demo.selectedMask=M; demo.residual=residual; end
                end
            end
            if pair==cfg.demoPair && separation==cfg.demoSeparation && inputSNR==cfg.demoSNR
                demo.mixture=mixture; demo.target=target; demo.interferer=noise;
                demo.X=X; demo.T=T; demo.masks=masks; demo.diagnostic=diagnostic;
                demo.meta=meta; demo.evalSamples=evalSamples;
                demo.direction=struct('target',targetDirection,'interferer',intDirection);
                demo.noiseGain=noiseGain;
            end
        end
    end
end
metrics=struct2table(rows);
summary=e5305.summarise(metrics);
directionTable=struct2table(directions);
writetable(metrics,fullfile(cfg.outputDir,'metrics_per_condition.csv'));
writetable(summary,fullfile(cfg.outputDir,'metrics_summary.csv'));
writetable(directionTable,fullfile(cfg.outputDir,'directions.csv'));
remixMetrics=table();
if isfield(demo,'selectedMask')
    [demo.remix,remixMetrics] = e5305.remix(demo,hNewTarget,hNewResidual,p,cfg);
    demo.newDirections=struct('target',newTargetDirection,'residual',newResidualDirection);
    writetable(remixMetrics,fullfile(cfg.outputDir,'remix_metrics.csv'));
    e5305.export_demo(demo,p,cfg);
end
if cfg.saveFigures, e5305.plot_results(metrics,demo,p,cfg); end
dataset=rmfield(db,intersect(fieldnames(db),{'ir','sofaObject'}));
save(fullfile(cfg.outputDir,'experiment.mat'),'cfg','p','dataset','metrics', ...
    'summary','directionTable','remixMetrics','demo','-v7.3');
e5305.write_report(summary,dataset,cfg);
fprintf('\nSaved results to %s\n',cfg.outputDir);
end
