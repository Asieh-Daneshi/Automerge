# Automerge

MATLAB tools that remove the visible borders in montages of adaptive-optics scanning laser ophthalmoscope (AOSLO) images.

"Automontaging" places the summed, normalised frames (sumNorms) from different AOSLO videos at the right position, but the borders between them stay visible. Automerging gives a smooth montage on top of that result.

## Usage

1. Run Automontaging as usual (if you have already done so, you do not need to run it again).
2. Optional but recommended when brightness differs a lot between sumNorms: run `FieldCorrection_SingleFrames.m`. It is a histogram correction and must run after Automontaging and before Automerging.
3. Run `Automerging.m` and follow the instructions in the MATLAB workspace. When asked, give the path to the folder with the Automontaging results (or with the corrected sumNorms from step 2).

## Fixing problem spots interactively

After the automatic merge you can improve parts of the image that are not good enough:

1. Click one point whose surroundings look poor.
2. All frames that contribute to that point are shown. Enter the number written above a frame (not the frame number), or keep the current merge. A yellow rectangle marks the candidate frame when only its corner overlaps the point.
3. Use the whole candidate frame, or zoom in and select a sub-region as a polygon of any shape.
4. Repeat for as many points as you like. Each run takes a few seconds.

## Why the histogram correction

When the intensity differs strongly between single sumNorms, or between spots within one sumNorm, the merge looks poor. Several histogram-correction algorithms were tested; `FieldCorrection_SingleFrames.m` gave the best result.

## Contents

- `2020-09-09_Automerging/`: the MATLAB code (`Automerging.m`, `MergeIm_Intensity.m`, `Panorama.m`, `FieldCorrection_SingleFrames.m`, `FinalCorrection.m` and helpers)
- `Examples/`: example montages (see `Examples/ReadMe.txt`)
- `Progress reports related to automerging/`: development reports and intermediate results
- `2020-09-09_Readme.docx`: the original documentation with figures

## Note

The documentation with all figures is the `.docx` file in this repository; this README is a text summary of it.
