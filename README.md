# Analysis scripts for multimodal cell–microvasculature analysis in the human superior colliculus

This repository contains five scripts accompanying a study of neuron–glia–microvasculature organization in the human superior colliculus using histology and synchrotron-radiation phase-contrast micro-CT (SR PhC-µCT).

## Contents

| File | Purpose | Software |
|---|---|---|
| `01_vessel_segmentation.ijm` | 3D vessel segmentation using median filtering, edge filtering, hysteresis thresholding, OR combination, size filtering and morphological closing | Fiji/ImageJ |
| `02_vessel_segmentation_validation.m` | Nearest-neighbour comparison of manual vessel branch-point landmarks with automatic skeleton points; localization error and branch-point recall | MATLAB |
| `03_cell_classification_validation.groovy` | Comparison of manual neuron/glia markers with QuPath detections; precision, recall and F1 score | QuPath |
| `04_descriptor_registration_distance_analysis.m` | Descriptor extraction/matching, common-plane estimation by SVD, cell projection into 3D and cell-to-vessel distance sampling | MATLAB |
| `05_plane_validation_bootstrap_sensitivity.m` | Plane residuals, bootstrap estimates of plane offset/orientation and ±10 µm sensitivity analysis | MATLAB |

## Software requirements

- **Fiji/ImageJ:** 3D ImageJ Suite commands used by the macro (3D Median, 3D Edge and Symmetry Filter, 3D Hysteresis Thresholding, 3D Simple Segmentation) and MorphoLibJ.
- **MATLAB:** Statistics and Machine Learning Toolbox for `KDTreeSearcher`, `knnsearch` and `randsample`. Other toolbox requirements may depend on local image handling.
- **QuPath:** Groovy scripting support and project classes named `Neuron or Glia Ground Truth` and `Neuron or Glia detections`.

## Input data

The scripts expect user-supplied CSV and TIFF files, including `Skeleton_Points.csv`, `Manual_Landmark.csv`, `Branching_points.csv`, `Glial_centroid.csv`, `Neuron_centroid.csv`, `3D Vessel distance map.tif`, `2D Glia distance map.tif` and `2D Neuron distance map.tif`. Update paths and filenames for your local environment. Input datasets are not included.

## Reproducibility notes

Confirm that coordinates and distance-map values are calibrated in micrometres before interpreting outputs as µm. Coordinate tables are represented as `[x,y,z]`, whereas MATLAB image indexing uses `[row,column,slice] = [y,x,z]`. Verify this mapping and voxel calibration for each input. Inspect intermediate masks, landmark matches, fitted planes and distance maps before accepting quantitative outputs.

