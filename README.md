# ELEC5305 Audio Signal Processing Project

## Project Title

**Binaural Spatial-Cue Guided Speech Separation and Spatial Re-Mixing in MATLAB**

## Project Overview

This project investigates whether binaural spatial cues can improve speech separation in controlled two-source audio scenes. Clean target speech and an interfering signal will be spatialised using measured HRIRs to create binaural mixtures with known source directions.

ILD and IPD cues will be extracted from the binaural signals and used to construct soft time-frequency masks. The project will compare conventional spectral masking with ILD-based, IPD-based, and combined spatial masking under different source angular separations.

HRIR-based spatial re-mixing will be used as a final listening demonstration after the main speech-separation experiments.

## Main Research Question

How much do binaural ILD and IPD cues improve soft-mask speech separation beyond conventional spectral masking, and how does the benefit depend on the angular separation between the target and interfering source?

## Proposed Methods

- Short-Time Fourier Transform (STFT)
- Controlled binaural mixtures using measured HRIRs
- SADIE II / SOFA spatial audio data
- ILD-based spatial masking
- IPD-based spatial masking
- Combined ILD + IPD masking
- Spectral/Wiener masking baseline
- Ablation experiments across different source angular separations
- SNR and SI-SDR/SDR evaluation
- ILD/IPD spatial-cue evaluation
- HRIR-based spatial re-mixing and listening demonstration

## Platform

MATLAB R2025a

Existing MATLAB SOFA/HRTF processing tools will be used for reading and processing measured HRIR data.

## Expected Outcome

The project is expected to produce a MATLAB prototype for generating controlled binaural mixtures, extracting ILD and IPD cues, applying soft time-frequency masks, and reconstructing the target speech. The main outcome will be a comparison of spectral, ILD-based, IPD-based, and combined masking methods under different source angular separations.

## Project Status

Current work focuses on literature review, HRIR/SOFA dataset preparation, and implementation of the controlled binaural separation experiment.

## Proposal

The full revised project proposal is available in [`proposal.md`](proposal.md).
