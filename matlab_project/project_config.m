function cfg = project_config()
%PROJECT_CONFIG Reproducible preliminary experiment for the revised proposal.
root = fileparts(mfilename('fullpath'));
cfg.root = root;
cfg.outputDir = fullfile(root, 'results');
cfg.hrirFile = fullfile(root, 'data', 'hrir', ...
    'H10_48K_24bit_256tap_FIR_SOFA.sofa');
% SOFA is the main experiment. An optional adapter supports supplied course MATs.
cfg.courseHrirFs = 48000; % Only used if a course MAT lacks sample-rate metadata.
cfg.courseAnglesInRadians = true; % sourceSphCoord uses radians in course toolbox.
cfg.hrirSelection = 'nearest'; % Measured nearest direction; actual angles are logged.
cfg.maxDirectionErrorDeg = 8;
cfg.targetAzimuth = 0; % SOFA: positive azimuth = left; negative = right.
cfg.elevation = 0;
cfg.angularSeparations = [15 30 60 90];
cfg.inputSNRs = 0; % Both-ear target/interferer power ratio on evaluation samples.
cfg.maxSpeechDuration = 8; % seconds, truncated if files are shorter; never looped.
cfg.calibrationDuration = 0.6; % Target silent; interferer-only noise initialisation.
sounds = fullfile(root, 'data', 'speech');

cfg.targetFiles = { ...
    fullfile(sounds,'target1.flac'), ...
    fullfile(sounds,'target2.flac'), ...
    fullfile(sounds,'target3.flac')};

cfg.interfererFiles = { ...
    fullfile(sounds,'interferer1.flac'), ...
    fullfile(sounds,'interferer2.flac'), ...
    fullfile(sounds,'interferer3.flac')};
cfg.windowDuration = 0.032; % 32 ms; sqrt(periodic Hann), 50% overlap.
cfg.sigmaILDdB = 4;
cfg.sigmaIPDrad = 0.5;
cfg.cueBandHz = [100 8000];
cfg.hrtfFloorDb = -60;
cfg.silentBinFloorDb = -80;
cfg.maskFloor = 0; % Zero follows the proposal's equations exactly.
cfg.powerTimeConstant = 0.05; % Mixture-power smoothing (seconds).
cfg.noiseTimeConstant = 0.3;
cfg.noiseUpdateThreshold = 1.5; % Simple energy gate, not a target-speech classifier.
cfg.metricBandHz = [100 8000];
cfg.metricReferenceFloorDb = -40;
cfg.metricEstimateFloorDb = -80;
cfg.remixTargetAzimuth = -30;
cfg.remixResidualAzimuth = 60;
cfg.demoPair = 1;
cfg.demoSeparation = 60;
cfg.demoSNR = 0;
cfg.demoMethod = 'Wiener_ILD_IPD';
cfg.saveFigures = true;
cfg.saveAudio = true;
cfg.computeSTOI = false; % Optional Audio Toolbox metric, off in current installation.
cfg.randomSeed = 5305;
end
