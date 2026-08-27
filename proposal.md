# ELEC5305 Project Proposal

## 1. Project Title

**Perceptually Guided Speech Enhancement and Spatial Re-Mixing for Complex Stereo Audio Scenes**

## 2. Student Information

**Full Name:** Shiying Hong  
**Student ID (SID):** 540662535  
**GitHub Username:** shiyingh114-jpg  
**GitHub Project Link:**  
https://shiyingh114-jpg.github.io/elec5305-project-540662535/

## 3. Project Overview

The sounds recorded in real environments are often affected by background noise, interference from speakers, and reverberation. Traditional speech enhancement methods can improve signal quality, but they cannot fully utilize the spatial information in stereo recordings. This project aims to develop a MATLAB-based speech enhancement and spatial re-mixing system. This system will analyze the left and right channels in the time-frequency domain, enhance the target speech using spatial cues and speech activity information, and use soft time-frequency masking to suppress interference. Then, HRIR-based binaural processing will be used to re-mix the enhanced speech and background spatially. The main goal is to improve the target speech clarity while maintaining a meaningful spatial listening experience.

## 4. Background and Motivation

Stereo and binaural recordings contain rich spatial information, which can be used to help distinguish sound sources at different positions. Existing studies have shown that spatial features such as interaural level difference (ILD), interaural phase difference (IPD), and Mixing Vector can reflect the differences between the left and right channels and can be further used to estimate time-frequency masks, thereby improving the effect of stereo speech separation [1], [2].

In addition to noise suppression, speech enhancement systems also need to consider the spatial perception after processing. Van den Bogaert et al. studied a binaural speech enhancement method based on multichannel Wiener filter, and the results showed that this method could reduce background interference while preserving important binaural spatial cues of the target speech [3]. Li et al. also proposed a binaural speech enhancement method combining interference estimation and Wiener filter, and proved that speech enhancement and binaural cue preservation can be considered simultaneously [4].

Furthermore, HRIR can re-render the sound to different spatial directions through convolution, thereby generating binaural audio with a sense of direction [5]. Therefore, this project hopes to integrate stereo spatial cue analysis, speech enhancement, and HRIR-based spatial re-mixing into the same MATLAB system. Compared with only performing traditional noise suppression, this project not only focuses on improving the clarity of the target speech but also pays attention to the spatial auditory effect of the processed audio.

## 5. Proposed Methodology

### 5.1 Tools and Platform

This project will primarily be implemented using **MATLAB R2025a**, including audio reading, STFT analysis, speech enhancement, HRIR convolution, and results visualization. MATLAB will also be used to generate spectrograms, calculate SNR improvement, and compare the performance of different processing methods.

### 5.2 Data Sources

The project will construct controlled stereo mixtures using clean speech combined with environmental noise and background speech as interfering signals. The original clean speech will be preserved as a reference signal for subsequent objective performance evaluation. When necessary, a publicly available HRIR dataset will be used to simulate target speech and interfering sounds originating from different spatial directions.

### 5.3 Time-Frequency Analysis

The left and right channels are first converted to the time-frequency domain through STFT:

$$
X_L(k,m), \qquad X_R(k,m)
$$

where \(k\) denotes the frequency bin and \(m\) denotes the time frame. The STFT enables observation of the distribution of speech and interference across different times and frequencies, providing a foundation for subsequent time-frequency masking.

### 5.4 Stereo Spatial Cue Analysis

The system extracts ILD and IPD from the left and right audio channels:

$$
ILD(k,m)=20\log_{10}\left|\frac{X_L(k,m)}{X_R(k,m)}\right|
$$

$$
IPD(k,m)=\angle\left(\frac{X_L(k,m)}{X_R(k,m)}\right)
$$

These features reflect the amplitude and phase differences between the left and right channels, and can be used to assist in determining whether different time-frequency regions are consistent with the spatial orientation of the target speech [1], [2].

### 5.5 Speech Enhancement

First, a simple **Voice Activity Detection (VAD)** is used to distinguish between speech-active and noise-dominant regions, and the background noise power is estimated. Then, a Wiener-style soft mask is established:

$$
M_W(k,m)=\frac{P_S(k,m)}{P_S(k,m)+P_N(k,m)}
$$

Here, \(P_S\) and \(P_N\) respectively represent the estimated speech power and noise power.

On this basis, stereo spatial weighting is added:

$$
M(k,m)=M_W(k,m)M_{\text{spatial}}(k,m)
$$

Regions that better match the target speech spatial characteristics are given higher weights, thereby enhancing the target speech and suppressing interference [3], [4].

### 5.6 Reconstruction and Spatial Re-Mixing

The processed speech is reconstructed through inverse STFT, and the approximate background components are obtained using complementary masks. Finally, the target speech and the background are repositioned in specified spatial directions through HRIR convolution:

$$
y_L[n]=s[n]\ast h_L[n], \qquad y_R[n]=s[n]\ast h_R[n]
$$

This results in a stereo/binaural output with spatial orientation [5].

### 5.7 Performance Evaluation

The system will mainly evaluate the effect through SNR improvement and spectrogram comparison:

$$
\Delta SNR = SNR_{out} - SNR_{in}
$$

If time permits, SDR or simple perceptual evaluation will also be considered.

## 6. Expected Outcomes

The expected outcome is a functional MATLAB prototype for enhancing target speech in complex stereo audio and generating spatially re-mixed stereo or binaural output. The system should be able to improve the clarity of the target speech while controlling the spatial positions of the speech and background sounds.

The project will generate the enhanced audio, time-frequency masks, spectrograms, and related evaluation results. The system performance will be mainly evaluated by SNR improvement, and SDR or PESQ may be included if conditions permit. The final outcome will also include MATLAB source code, example audio, evaluation charts, final report, and complete GitHub documentation.

## 7. Timeline

| Weeks | Planned Work |
|---|---|
| 1–2 | Define project scope and complete initial research |
| 3–5 | Literature review, dataset selection and preliminary STFT experiments |
| 6–7 | Implement VAD and baseline Wiener speech enhancement |
| 8–9 | Implement stereo cue analysis and stereo-guided masking |
| 10 | Integrate stereo processing and time-frequency masking |
| 11 | Implement HRIR-based spatial re-mixing |
| 12 | Evaluation, optimisation and optional extensions |
| 13 | Final report, demonstration and GitHub documentation |

## 8. References

[1] A. Alinaghi, P. J. B. Jackson, Q. Liu, and W. Wang, “Joint Mixing Vector and Binaural Model Based Stereo Source Separation,” *IEEE/ACM Transactions on Audio, Speech, and Language Processing*, 2014.

[2] Y. Yu, W. Wang, and P. Han, “Localization Based Stereo Speech Source Separation Using Probabilistic Time-Frequency Masking and Deep Neural Networks,” *EURASIP Journal on Audio, Speech, and Music Processing*, 2016.

[3] T. Van den Bogaert, S. Doclo, J. Wouters, and M. Moonen, “Speech Enhancement with Multichannel Wiener Filter Techniques in Multimicrophone Binaural Hearing Aids,” *The Journal of the Acoustical Society of America*, 2009.

[4] J. Li, S. Sakamoto, S. Hongo, M. Akagi, and Y. Suzuki, “Two-Stage Binaural Speech Enhancement with Wiener Filter for High-Quality Speech Communication,” *Speech Communication*, 2011.

[5] M. Cuevas-Rodríguez et al., “3D Tune-In Toolkit: An Open-Source Library for Real-Time Binaural Spatialisation,” *PLOS ONE*, 2019.
