function result = summarise(metrics)
%SUMMARISE Means and sample SD across speech pairs, not repeated random draws.
keys=unique(metrics(:,{'RequestedSeparationDeg','InputSNRdB','Method'}),'rows','stable');
names={'ActualSeparationDeg','SNRImprovementdB','SISDRImprovementdB', ...
    'SIRImprovementdB','ILD_RMSE_dB','IPD_RMSE_rad','CueEnergyCoverage'};
result=keys; result.NumPairs=zeros(height(keys),1);
for j=1:numel(names)
    result.([names{j} '_Mean'])=nan(height(keys),1);
    result.([names{j} '_SD'])=nan(height(keys),1);
    result.([names{j} '_ValidN'])=zeros(height(keys),1);
end
for k=1:height(keys)
    selected=metrics.RequestedSeparationDeg==keys.RequestedSeparationDeg(k) & ...
        metrics.InputSNRdB==keys.InputSNRdB(k) & metrics.Method==keys.Method(k);
    result.NumPairs(k)=nnz(selected);
    for j=1:numel(names)
        values=metrics.(names{j})(selected); values=values(isfinite(values));
        result.([names{j} '_ValidN'])(k)=numel(values);
        if ~isempty(values), result.([names{j} '_Mean'])(k)=mean(values); end
        if numel(values)>=2, result.([names{j} '_SD'])(k)=std(values); end
    end
end
end
