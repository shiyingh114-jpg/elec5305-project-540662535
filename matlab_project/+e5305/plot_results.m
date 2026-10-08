function plot_results(metrics,demo,p,cfg)
%PLOT_RESULTS Export standalone figures suitable for the preliminary GitHub report.
out=fullfile(cfg.outputDir,'figures'); if ~isfolder(out), mkdir(out); end
summary=e5305.summarise(metrics);
methods=unique(summary.Method,'stable'); methods(methods=="Mixture")=[];
colours=lines(numel(methods));
columns={'SNRImprovementdB','SISDRImprovementdB','ILD_RMSE_dB','IPD_RMSE_rad'};
labels={'Reconstruction SNR improvement (dB)','SI-SDR improvement (dB)', ...
    'Reference-weighted ILD RMSE (dB)','Reference-weighted IPD RMSE (rad)'};
for snr=unique(summary.InputSNRdB)'
    fig=figure('Visible','off','Color','w','Position',[100 100 1200 780]);
    tiledlayout(2,2,'TileSpacing','compact');
    for k=1:4
        nexttile; hold on;
        for j=1:numel(methods)
            select=summary.InputSNRdB==snr & summary.Method==methods(j);
            a=summary(select,:); a=sortrows(a,'RequestedSeparationDeg');
            style='-'; if methods(j)=="OraclePowerRatio", style='--'; end
            errorbar(a.ActualSeparationDeg_Mean,a.([columns{k} '_Mean']), ...
                a.([columns{k} '_SD']),'LineStyle',style,'Marker','o', ...
                'Color',colours(j,:),'LineWidth',1.2,'DisplayName',strrep(methods(j),'_','+'));
        end
        grid on; xlabel('Actual source angular separation (degrees)'); ylabel(labels{k});
        if k<=2, yline(0,':','HandleVisibility','off'); end
        if k==1, legend('Location','best','Interpreter','none'); end
    end
    sgtitle(sprintf('Input SNR %g dB; mean +/- sample SD across speech pairs',snr));
    exportgraphics(fig,fullfile(out,sprintf('performance_snr_%g.png',snr)),'Resolution',160);
    close(fig);
end
if ~isfield(demo,'selectedMask'), return; end
time=demo.meta.time; freq=demo.meta.frequency;
fig=figure('Visible','off','Color','w','Position',[100 100 1200 720]);
tiledlayout(2,3,'TileSpacing','compact');
methods=fieldnames(demo.masks);
for j=1:numel(methods)
    nexttile; imagesc(time,freq,demo.masks.(methods{j}),[0 1]); axis xy;
    ylim([0 cfg.cueBandHz(2)]); xlim([0 demo.meta.length/p.fs]);
    title(strrep(methods{j},'_','+')); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
end
sgtitle(sprintf('Masks: pair %d, requested separation %g degrees',cfg.demoPair,cfg.demoSeparation));
exportgraphics(fig,fullfile(out,'mask_comparison.png'),'Resolution',160); close(fig);
fig=figure('Visible','off','Color','w','Position',[100 100 1200 760]);
tiledlayout(2,2,'TileSpacing','compact');
signals={demo.target,demo.mixture,demo.estimates.(cfg.demoMethod), ...
    demo.estimates.OraclePowerRatio};
titles={'Clean target (left ear)','Mixture (left ear)', ...
    ['Estimated target: ' strrep(cfg.demoMethod,'_','+')],'Oracle power-ratio estimate (left ear)'};
peak=max(abs(demo.T(:,:,1)),[],'all');
for j=1:4
    [S,m]=e5305.analyse(signals{j},p);
    nexttile; imagesc(m.time,m.frequency,20*log10(max(abs(S(:,:,1))/peak,1e-5)),[-80 10]);
    axis xy; ylim([0 cfg.metricBandHz(2)]); xlim([0 m.length/p.fs]);
    xlabel('Time (s)'); ylabel('Frequency (Hz)'); title(titles{j}); colorbar;
end
sgtitle('Common magnitude scale: dB relative to peak clean-target STFT');
exportgraphics(fig,fullfile(out,'spectrogram_comparison.png'),'Resolution',160); close(fig);
fig=figure('Visible','off','Color','w','Position',[100 100 1150 600]);
tiledlayout(2,2,'TileSpacing','compact');
maps={demo.diagnostic.ild,demo.diagnostic.ipd, ...
    demo.diagnostic.deltaILD,demo.diagnostic.deltaIPD};
titles={'Mixture ILD (dB, L/R)','Mixture IPD (radians, L/R)', ...
    'ILD difference from target template (dB)','Wrapped IPD difference from target (radians)'};
ranges={[-20 20],[-pi pi],[-20 20],[-pi pi]};
for j=1:4
    nexttile; imagesc(time,freq,maps{j},ranges{j}); axis xy;
    ylim(cfg.cueBandHz); xlim([0 demo.meta.length/p.fs]);
    title(titles{j}); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
end
exportgraphics(fig,fullfile(out,'binaural_cues.png'),'Resolution',160); close(fig);
end
