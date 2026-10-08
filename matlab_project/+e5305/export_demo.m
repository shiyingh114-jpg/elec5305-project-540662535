function export_demo(demo,p,cfg)
%EXPORT_DEMO One common scalar for every WAV; never separate per-ear normalisation.
if ~cfg.saveAudio, return; end
dirName=fullfile(cfg.outputDir,'audio'); if ~isfolder(dirName), mkdir(dirName); end
signals.mixture=demo.mixture; signals.clean_target=demo.target;
signals.clean_interferer=demo.interferer;
methods=fieldnames(demo.estimates);
for j=1:numel(methods), signals.(['estimate_' methods{j}])=demo.estimates.(methods{j}); end
signals.residual_background=demo.residual;
names=fieldnames(demo.remix);
for j=1:numel(names), signals.(['remix_' names{j}])=demo.remix.(names{j}); end
peak=0; names=fieldnames(signals);
for j=1:numel(names), peak=max(peak,max(abs(signals.(names{j})),[],'all')); end
gain=0.98/max(peak,1);
rows=struct([]);
for j=1:numel(names)
    file=[names{j} '.wav']; x=signals.(names{j});
    audiowrite(fullfile(dirName,file),gain*x,p.fs,'BitsPerSample',24);
    rows(j).File=string(file); rows(j).CommonGain=gain;
    rows(j).DurationSeconds=size(x,1)/p.fs;
end
writetable(struct2table(rows),fullfile(dirName,'playback_gain.csv'));
end
