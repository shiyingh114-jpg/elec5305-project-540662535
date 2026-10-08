# ELEC5305 Audio Signal Processing Project

## Project Title

**Binaural Spatial-Cue Guided Speech Separation and Spatial Re-Mixing in MATLAB**

## Project Overview

This project investigates whether binaural spatial cues can improve speech separation in controlled two-source audio scenes.

Clean target speech and an interfering speech signal are spatialised using measured HRIRs to generate binaural mixtures with known source directions. Interaural Level Difference (ILD) and Interaural Phase Difference (IPD) cues are extracted from the binaural mixture and used to construct soft time-frequency masks.

The main experiment compares conventional spectral masking with ILD-based, IPD-based, and combined spatial masking under different angular separations between the target and interfering source.

HRIR-based spatial re-mixing is included as a secondary listening demonstration.

## Main Research Question

How much do binaural ILD and IPD cues improve soft-mask speech separation beyond conventional spectral masking, and how does the benefit depend on the angular separation between the target and interfering source?

## Methods

The implemented system includes:

- Controlled binaural mixture generation using measured HRIRs
- Short-Time Fourier Transform (STFT)
- ILD cue extraction
- IPD cue extraction
- ILD-based soft masking
- IPD-based soft masking
- Combined ILD + IPD masking
- Wiener spectral masking baseline
- Spectral + spatial masking
- Angular-separation ablation experiments
- SNR and SI-SDR evaluation
- ILD/IPD spatial-cue evaluation
- HRIR-based spatial re-mixing

## Experimental Setup

The target source is fixed at 0° azimuth.

The interfering source is tested at different angular separations:

- 15°
- 30°
- 60°
- 90°

The default input SNR is 0 dB.

Three target/interferer speech pairs are used in the main experiment.

## Data and Resources

- **Speech data:** LibriSpeech `dev-clean`
- **HRIR data:** SADIE II H10, SOFA format

Source and licence information are included in the corresponding folders under `matlab_project/data/`.
