# ELEC5305 Project Proposal

## 1. Project Title

**Binaural Spatial-Cue Guided Speech Separation and Spatial Re-Mixing in MATLAB**

## 2. Student Information

**Full Name:** Shiying Hong  
**Student ID (SID):** 540662535  
**GitHub Username:** shiyingh114-jpg  
**GitHub Project Link:**  
https://shiyingh114-jpg.github.io/elec5305-project-540662535/

## 3. Project Overview

This project investigates whether binaural spatial cues can improve speech separation in controlled two-source audio scenes. Clean target speech and an interfering signal will be spatialised using measured HRIRs to create binaural mixtures with known source directions. Interaural level difference (ILD) and interaural phase difference (IPD) will be extracted from the left and right channels and used to construct soft time-frequency masks, which will be compared with a conventional spectral masking baseline under different source angular separations. The main aim is to determine how much binaural spatial information improves target-speech separation and how this benefit changes as the angular separation between the target and interfering source increases. After separation, HRIR-based spatial re-mixing will be used as a final listening demonstration.

## 4. Background and Motivation

Binaural signals contain spatial information that can help distinguish sound sources arriving from different directions. Two important cues are ILD and IPD. Previous studies have shown that these cues can be used to estimate probabilistic or soft time-frequency masks for source separation [1], [2], [6]. MESSL is an established example that uses interaural phase and level cues for probabilistic source separation and will be used as a reference for the simpler spatial masks developed in this project.

Measured HRIRs provide a practical way to create controlled binaural mixtures with known source directions. Public HRIR datasets such as SADIE II can be accessed and processed using the SOFA format, allowing realistic binaural cues to be generated without developing a new HRTF model [7], [8]. Previous binaural enhancement work has also shown that interference reduction should be considered together with preservation of spatial cues [3], [4], [9].

Recent neural methods can achieve strong binaural separation performance, but this project will focus on a classical and interpretable ILD/IPD-based approach so that the contribution of spatial cues can be examined directly [10].

## 5. Proposed Methodology

### 5.1 Tools and Platform

The project will be implemented in MATLAB R2025a. MATLAB will be used for audio loading, STFT analysis, HRIR convolution, binaural cue extraction, soft-mask processing, inverse STFT reconstruction, visualisation, and objective evaluation. A publicly available measured HRIR dataset, such as SADIE II, will be used in SOFA format. Existing MATLAB SOFA/HRTF processing tools will be used to read and process the spatial data, rather than developing a new HRTF model or recreating standard processing infrastructure.

### 5.2 Controlled Binaural Mixtures

A clean target speech signal and an interfering speech or noise signal will be used to construct controlled binaural mixtures. Each source will first be convolved with the left- and right-ear HRIRs corresponding to a known source azimuth. The binaural target and interfering signals will then be summed to produce the final mixture.

The target direction will remain fixed during the main experiment, while the interfering source will be placed at several angular separations, for example 15°, 30°, 60°, and 90°. The original clean target and interference signals will be retained as references for objective evaluation.

### 5.3 Time-Frequency Analysis

The left and right mixture channels will be transformed into the time-frequency domain using the STFT:

```math
X_L(k,m), \qquad X_R(k,m)
```

where k represents the frequency bin and m represents the time frame.

The STFT representation allows binaural cues and soft masks to be estimated separately for individual time-frequency regions.

### 5.4 Binaural Spatial Cue Analysis

ILD and IPD will be calculated from the binaural mixture as

```math
\mathrm{ILD}(k,m)
=
20\log_{10}
\left(
\frac{|X_L(k,m)|}{|X_R(k,m)|}
\right)
```

and

```math
\mathrm{IPD}(k,m)
=
\angle
\left(
\frac{X_L(k,m)}{X_R(k,m)}
\right)
```

The target direction will be assumed to be known. Reference ILD and IPD patterns will be obtained from the HRIR pair corresponding to that direction. For each time-frequency bin, the observed cues will be compared with the expected target cues. The IPD difference will be wrapped to the [-π, π] range to avoid phase discontinuities.

Spatial weights will then be defined as

```math
M_{\mathrm{ILD}}(k,m)
=
\exp
\left(
-\frac{
\left[\Delta \mathrm{ILD}(k,m)\right]^2
}{
2\sigma_{\mathrm{ILD}}^2
}
\right)
```

and

```math
M_{\mathrm{IPD}}(k,m)
=
\exp
\left(
-\frac{
\left[\Delta \mathrm{IPD}(k,m)\right]^2
}{
2\sigma_{\mathrm{IPD}}^2
}
\right)
```

A combined mask may be formed as

```math
M_{\mathrm{spatial}}(k,m)
=
M_{\mathrm{ILD}}(k,m)
M_{\mathrm{IPD}}(k,m)
```

ILD-only, IPD-only and combined ILD+IPD masks will be evaluated separately so that the contribution of each binaural cue can be examined directly.

### 5.5 Baseline and Mask Comparison

A conventional spectral or Wiener-style soft mask will be implemented as a non-spatial baseline:

```math
M_W(k,m)
=
\frac{
P_S(k,m)
}{
P_S(k,m)+P_N(k,m)
}
```

where P_S and P_N represent estimated speech and interference power.

A simple activity or noise-power estimator may be used where required, but VAD and noise estimation will not be treated as major research components.

The main ablation experiment will compare:

1. spectral/Wiener baseline;
2. ILD-only spatial mask;
3. IPD-only spatial mask;
4. combined ILD and IPD mask;
5. spectral + binaural spatial masking.

For the combined system, for example,

```math
M(k,m)
=
M_W(k,m)
M_{\mathrm{spatial}}(k,m)
```

If time permits, an Ideal Ratio Mask will also be calculated from the known clean source signals as an approximate upper-bound reference.

### 5.6 Reconstruction and Spatial Re-Mixing

The selected mask will be applied to both binaural channels:

```math
\hat{S}_L(k,m)
=
M(k,m)X_L(k,m)
```

and

```math
\hat{S}_R(k,m)
=
M(k,m)X_R(k,m)
```

The target estimate will then be reconstructed using inverse STFT. A complementary mask,

```math
M_R(k,m)
=
1-M(k,m)
```

may be used to obtain a residual/background estimate. This signal will not be treated as a clean reconstruction of the interferer because masking errors, overlapping speech energy and reverberation may remain.

After the separation stage is complete, a monophonic estimate of each recovered component may be spatially re-rendered to a new direction using HRIR convolution:

```math
y_L[n]
=
s[n] * h_L[n]
```

```math
y_R[n]
=
s[n] * h_R[n]
```

The spatial re-mixing stage will be treated mainly as an application and listening demonstration, while the main research focus remains the effect of binaural spatial cues on speech separation.

### 5.7 Performance Evaluation

The main evaluation will examine both mask type and source angular separation.

Speech-separation performance will be assessed using:

1. SNR improvement;
2. SI-SDR or SDR;
3. spectrogram comparisons; and
4. listening examples.

For binaural outputs, ILD and IPD errors will also be examined relative to the clean target binaural reference. This will make it possible to evaluate whether improved speech separation is accompanied by preservation or distortion of the original spatial cues.

Performance will be plotted against angular separation so that the benefit of binaural spatial information can be quantified directly.

## 6. Expected Outcomes

The project is expected to produce a MATLAB prototype for generating controlled binaural mixtures, extracting ILD and IPD cues, applying soft time-frequency masks, and reconstructing the target speech. The main outcome will be a comparison of spectral, ILD-based, IPD-based, and combined masking methods under different source angular separations. HRIR-based spatial re-mixing will also be included as a final listening demonstration.

## 7. Timeline

| Weeks | Planned Work |
|---|---|
| 1–2 | Refine project scope and research question |
| 3–4 | Expand literature review and select HRIR/SOFA dataset |
| 5–6 | Generate controlled binaural mixtures with known source directions |
| 7 | Implement STFT processing and spectral/Wiener baseline |
| 8 | Implement ILD-based spatial masking |
| 9 | Implement IPD-based and combined ILD+IPD masking |
| 10 | Conduct ablation and angular-separation experiments |
| 11 | Evaluate SNR/SI-SDR and binaural cue errors |
| 12 | Implement HRIR-based spatial re-mixing and listening demonstration |
| 13 | Final evaluation, report, demonstration, and GitHub documentation |

## 8. References

[1] A. Alinaghi, P. J. B. Jackson, Q. Liu, and W. Wang, “Joint Mixing Vector and Binaural Model Based Stereo Source Separation,” *IEEE/ACM Transactions on Audio, Speech, and Language Processing*, vol. 22, no. 9, pp. 1434–1448, 2014, doi: 10.1109/TASLP.2014.2320637.

[2] Y. Yu, W. Wang, and P. Han, “Localization Based Stereo Speech Source Separation Using Probabilistic Time-Frequency Masking and Deep Neural Networks,” *EURASIP Journal on Audio, Speech, and Music Processing*, vol. 2016, Art. no. 7, 2016, doi: 10.1186/s13636-016-0085-x.

[3] T. Van den Bogaert, S. Doclo, J. Wouters, and M. Moonen, “Speech Enhancement with Multichannel Wiener Filter Techniques in Multimicrophone Binaural Hearing Aids,” *The Journal of the Acoustical Society of America*, vol. 125, no. 1, pp. 360–371, 2009, doi: 10.1121/1.3023069.

[4] J. Li, S. Sakamoto, S. Hongo, M. Akagi, and Y. Suzuki, “Two-Stage Binaural Speech Enhancement with Wiener Filter for High-Quality Speech Communication,” *Speech Communication*, vol. 53, no. 5, pp. 677–689, 2011, doi: 10.1016/j.specom.2010.04.009.

[5] M. Cuevas-Rodríguez, L. Picinali, D. González-Toledo, C. Garre, E. de la Rubia-Cuestas, L. Molina-Tanco, and A. Reyes-Lecuona, “3D Tune-In Toolkit: An Open-Source Library for Real-Time Binaural Spatialisation,” *PLOS ONE*, vol. 14, no. 3, Art. no. e0211899, 2019, doi: 10.1371/journal.pone.0211899.

[6] M. I. Mandel, R. J. Weiss, and D. P. W. Ellis, “Model-Based Expectation-Maximization Source Separation and Localization,” *IEEE Transactions on Audio, Speech, and Language Processing*, vol. 18, no. 2, pp. 382–394, 2010, doi: 10.1109/TASL.2009.2029711.

[7] C. Armstrong, L. Thresh, D. T. Murphy, and G. C. Kearney, “A Perceptual Evaluation of Individual and Non-Individual HRTFs: A Case Study of the SADIE II Database,” *Applied Sciences*, vol. 8, no. 11, Art. no. 2029, 2018, doi: 10.3390/app8112029.

[8] P. Majdak, F. Zotter, F. Brinkmann, J. De Muynke, M. Mihocic, and M. Noisternig, “Spatially Oriented Format for Acoustics 2.1: Introduction and Recent Advances,” *Journal of the Audio Engineering Society*, vol. 70, no. 7/8, pp. 565–584, 2022, doi: 10.17743/jaes.2022.0026.

[9] A. I. Koutrouvelis, J. Jensen, M. Guo, R. C. Hendriks, and R. Heusdens, “Binaural Speech Enhancement with Spatial Cue Preservation Utilising Simultaneous Masking,” in *Proc. 25th European Signal Processing Conference (EUSIPCO)*, 2017, doi: 10.23919/EUSIPCO.2017.8081277.

[10] X. Lu, Y. Ma, X. Jiang, X. Wang, and J. Sang, “A Lightweight Fourier-Based Network for Binaural Speech Enhancement with Spatial Cue Preservation,” in *Proc. IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)*, 2026, doi: 10.1109/ICASSP55912.2026.11463903.
