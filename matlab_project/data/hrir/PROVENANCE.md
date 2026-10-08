# Measured HRIR provenance

- Dataset: **SADIE II**, University of York AudioLab; Cal Armstrong, Lewis Thresh and Gavin Kearney.
- Fixed source record: [Zenodo version 2-1, published 27 March 2024](https://zenodo.org/records/10886409).
- Downloaded archive: `H10_HRIR_SOFA.zip` (record MD5 `501542240c1e2688a00a7f4267a11c5e`).
- Extracted, unmodified file: `H10_HRIR_SOFA/H10_48K_24bit_256tap_FIR_SOFA.sofa`.
- Included file SHA-256: `b48cf93b1b3919fa61a787242c75763fad2a4b0ee3464e53e165ba12a9720fde`.
- Original dataset license text downloaded from the same record is retained as `SADIE_II_LICENSE.txt`.
- Directions: positive azimuth to the listener's left; 0° is frontal. SOFA receiver positions are checked for left/right order.

Associated paper: C. Armstrong, L. Thresh, D. T. Murphy and G. C. Kearney, “A Perceptual Evaluation of Individual and Non-Individual HRTFs: A Case Study of the SADIE II Database,” *Applied Sciences*, 8(11), 2029, 2018. [DOI](https://doi.org/10.3390/app8112029).

The code reuses MATLAB's [SOFA reading](https://www.mathworks.com/help/audio/ref/sofaread.html) and optional [HRTF interpolation](https://www.mathworks.com/help/audio/ref/interpolatehrtf.html) when Audio Toolbox is available. In the supplied installation Audio Toolbox is absent; built-in NetCDF reading extracts the measured FIRs and existing nearest measurement directions. It does not fit a head model or synthesise an HRTF.

The supplied course speech WAVs remain in the parent `toolbox/` folder and are not duplicated into this project. Their source redistribution terms are not established here; reviewers can configure their own clean mono speech files.
