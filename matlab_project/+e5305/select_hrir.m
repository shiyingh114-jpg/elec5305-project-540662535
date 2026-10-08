function [h,direction] = select_hrir(db,azimuth,elevation,cfg)
%SELECT_HRIR Choose measured nearest direction or existing Audio Toolbox interpolation.
requested=unit_vector(azimuth,elevation);
allVectors=unit_vector(db.positions(:,1),db.positions(:,2));
[similarity,idx]=max(allVectors*requested');
errorDeg=acosd(max(-1,min(1,similarity)));
assert(errorDeg<=cfg.maxDirectionErrorDeg,'ELEC5305:DirectionCoverage', ...
    'Nearest measurement to [%g,%g] is %g degrees away; choose another dataset/direction.', ...
    azimuth,elevation,errorDeg);
if strcmpi(cfg.hrirSelection,'interpolate') && errorDeg>1e-6
    assert(isfield(db,'sofaObject') && ~isempty(which('interpolateHRTF')), ...
        'ELEC5305:InterpolationDependency','Interpolation requires Audio Toolbox sofaread/interpolateHRTF.');
    assert(all(db.delay==0,'all'),'Interpolation with additional SOFA delays is unsupported.');
    result=interpolateHRTF(db.sofaObject,[azimuth elevation]);
    h=squeeze(result(1,:,:)).';
    direction.azimuth=mod(azimuth+180,360)-180; direction.elevation=elevation;
    direction.selection='Audio Toolbox interpolation'; direction.errorDeg=0;
elseif strcmpi(cfg.hrirSelection,'nearest') || errorDeg<=1e-6
    a=db.ir(:,:,idx); delays=db.delay(idx,:);
    h=zeros(size(a,1)+max(delays),2);
    for ear=1:2, h(delays(ear)+(1:size(a,1)),ear)=a(:,ear); end
    direction.azimuth=db.positions(idx,1); direction.elevation=db.positions(idx,2);
    direction.selection='Measured nearest direction'; direction.errorDeg=errorDeg;
else
    error('ELEC5305:Selection','cfg.hrirSelection must be nearest or interpolate.');
end
direction.requestedAzimuth=azimuth; direction.requestedElevation=elevation;
direction.measurementIndex=idx;
direction.unitVector=unit_vector(direction.azimuth,direction.elevation);
end

function u=unit_vector(a,e)
u=[cosd(e).*cosd(a),cosd(e).*sind(a),sind(e)];
end
