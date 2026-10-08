function db = load_hrir(cfg)
%LOAD_HRIR Measured SOFA data via sofaread, or built-in NetCDF if Audio is absent.
% No synthetic HRTF model and no custom HRTF interpolator.
assert(isfile(cfg.hrirFile),'ELEC5305:HRIRMissing', ...
    'Missing measured HRIR file. Run download_sadie or edit cfg.hrirFile.');
db.file=cfg.hrirFile;
[~,~,ext]=fileparts(db.file);
if strcmpi(ext,'.mat')
    a=load(db.file); assert(isfield(a,'hrir'),'Expected course HRIR structure named hrir.');
    a=a.hrir;
    db.ir=double(a.impulseResponses); pos=double(a.sourceSphCoord);
    db.positions=pos(:,1:2);
    if cfg.courseAnglesInRadians, db.positions=rad2deg(db.positions); end
    if isfield(a,'sampFreq'), db.fs=double(a.sampFreq); else, db.fs=cfg.courseHrirFs; end
    db.delay=zeros(size(db.positions,1),2);
    db.backend='Course measured MAT (explicit coordinate units)';
    db.database='Course HRIR'; db.subject=string(a.subjectName);
elseif strcmpi(ext,'.sofa')
    convention=string(ncreadatt(db.file,'/','SOFAConventions'));
    assert(convention=="SimpleFreeFieldHRIR", 'ELEC5305:SOFAConvention', ...
        'Use measured SimpleFreeFieldHRIR; other conventions need their own renderer.');
    if ~isempty(which('sofaread'))
        obj=sofaread(db.file);
        db.ir=permute(double(obj.Numerator),[3 2 1]);
        db.fs=double(obj.SamplingRate);
        db.positions=positions_to_angles(double(obj.SourcePosition),obj.SourcePositionType);
        db.delay=double(obj.Delay); db.sofaObject=obj;
        db.backend='Audio Toolbox sofaread';
    else
        db.ir=read_ordered(db.file,'Data.IR',{'N','R','M'});
        db.fs=double(ncread(db.file,'Data.SamplingRate')); db.fs=db.fs(1);
        pos=read_ordered(db.file,'SourcePosition',{'M','C'});
        db.positions=positions_to_angles(pos,ncreadatt(db.file,'SourcePosition','Type'));
        db.delay=read_ordered(db.file,'Data.Delay',{'I','R'});
        db.backend='MATLAB built-in ncread (measured directions, no interpolation)';
    end
    % Explicitly verify listener frame and receiver order instead of swapping ears by guess.
    view=read_ordered(db.file,'ListenerView',{'I','C'});
    up=read_ordered(db.file,'ListenerUp',{'I','C'});
    listener=read_ordered(db.file,'ListenerPosition',{'I','C'});
    assert(norm(view(1,:)-[1 0 0])<1e-6 && norm(up(1,:)-[0 0 1])<1e-6 && ...
        norm(listener(1,:))<1e-6,'ELEC5305:ListenerFrame', ...
        'This prototype requires the standard origin / +x forward / +z up listener frame.');
    receivers=read_ordered(db.file,'ReceiverPosition',{'R','C','I'});
    assert(strcmpi(ncreadatt(db.file,'ReceiverPosition','Type'),'cartesian'), ...
        'ReceiverPosition must be Cartesian.');
    assert(receivers(1,2,1)>receivers(2,2,1),'ELEC5305:EarOrder', ...
        'Expected receiver 1 = left (+y), receiver 2 = right (-y).');
    db.database=string(ncreadatt(db.file,'/','DatabaseName'));
    db.subject=string(ncreadatt(db.file,'/','ListenerShortName'));
else
    error('ELEC5305:HRIRFormat','Use measured .sofa or supplied course .mat data.');
end
assert(size(db.ir,2)==2 && size(db.ir,3)==size(db.positions,1),'Inconsistent HRIR dimensions.');
assert(all(isfinite(db.ir),'all') && all(isfinite(db.positions),'all'),'Invalid HRIR values.');
assert(isscalar(db.fs) && db.fs>0,'Invalid HRIR sample rate.');
db.positions(:,1)=mod(db.positions(:,1)+180,360)-180;
if size(db.delay,1)==1, db.delay=repmat(db.delay,size(db.positions,1),1); end
assert(isequal(size(db.delay),[size(db.positions,1) 2]),'Unsupported per-measurement delay dimensions.');
% Retain every FIR's own delay. Refuse fractional-delay data instead of rounding ITD.
assert(all(db.delay>=0 & abs(db.delay-round(db.delay))<1e-8,'all'), ...
    'ELEC5305:FractionalDelay','Fractional/negative SOFA delays require a supported fractional-delay renderer.');
db.delay=round(db.delay);
end

function a=read_ordered(file,name,desired)
info=ncinfo(file,name); dims={info.Dimensions.Name};
assert(all(ismember(dims,desired)) && all(ismember(desired,dims)), ...
    'ELEC5305:SOFADimensions','Unexpected dimensions in %s.',name);
[~,order]=ismember(desired,dims);
raw=double(ncread(file,name));
raw=reshape(raw,[info.Dimensions.Length]);
a=permute(raw,order); % Dimension names, not dimension sizes, determine orientation.
end

function angles=positions_to_angles(pos,type)
if strcmpi(type,'spherical')
    angles=pos(:,1:2); % SOFA spherical coordinates are degrees, degrees, metres.
elseif strcmpi(type,'cartesian')
    angles=[atan2d(pos(:,2),pos(:,1)),atan2d(pos(:,3),hypot(pos(:,1),pos(:,2)))];
else
    error('ELEC5305:Coordinates','Unsupported SOFA source coordinate type.');
end
end
