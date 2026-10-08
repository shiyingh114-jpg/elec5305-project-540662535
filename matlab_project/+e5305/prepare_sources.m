function [s,n,nCal] = prepare_sources(targetFile,interfererFile,fs,cfg)
%PREPARE_SOURCES Real supplied speech, anti-alias resampling and target-silent prefix.
s=readmono(targetFile,fs); n=readmono(interfererFile,fs);
nCal=round(cfg.calibrationDuration*fs);
count=min([numel(s),numel(n)-nCal,floor(cfg.maxSpeechDuration*fs)]);
assert(count>fs, 'Speech files are too short for calibration plus evaluation.');
s=s(1:count); n=n(1:count+nCal);
s=s/max(sqrt(mean(s.^2)),realmin); n=n/max(sqrt(mean(n.^2)),realmin);
s=[zeros(nCal,1);s];
end

function x=readmono(file,fs)
assert(isfile(file),'ELEC5305:AudioMissing','Missing audio: %s',file);
[x,originalFs]=audioread(file);
assert(size(x,2)==1,'ELEC5305:MonoRequired', ...
    'Use a clean mono source, not an existing stereo/binaural mix: %s',file);
x=double(x); x=x-mean(x);
assert(sum(x.^2)>0,'Source is silent.');
if originalFs~=fs
    [a,b]=rat(fs/originalFs,1e-12); x=resample(x,a,b);
end
end
