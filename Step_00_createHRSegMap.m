%% Create segmentation maps
%  This script maps the 116 classes of the original MIDA model to eight:
%
%  1  - Background
%  2  - Cerebrospinal fluid
%  3  - Normal-appearing white matter
%  4  - White matter hyperintensity
%  5  - Recent stroke lesion
%  6  - Cortical grey matter
%  7  - Deep grey matter
%  8  - Blood vessels
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

%% Generate high-resolution map
% Load variable containing the mapping between the original 116 labels to 8
load(MIDA_mapping_fname);

% Load MIDA model and masks
info = niftiinfo(MIDA_map_fname);
original_segmap = niftiread(MIDA_map_fname);
WMH_segmap = niftiread(MIDA_WMH_fname);
RSL_segmap = niftiread(MIDA_RSL_fname);

% Map tissues
HR_tissue_map = zeros(size(original_segmap));
for c=1:size(mapping,1)
    HR_tissue_map(original_segmap == c) = mapping(c, 2);
end

% Add pathological tissues to the segmentation mask
HR_tissue_map(WMH_segmap == 1 & HR_tissue_map ~= 2) = 4;
HR_tissue_map(RSL_segmap == 1) = 5;

HR_tissue_map = padarray(HR_tissue_map(:, 141:end, :), [0, 70, 65], 1, 'both');
HR_tissue_map = permute(HR_tissue_map, [3, 1, 2]);
HR_tissue_map = flip(HR_tissue_map, 2);

% Save HR tissue map
info.ImageSize = NTrue;
info.PixelDimensions = HRes_mm;
info.Transform = affine3d(eye(4));
niftiwrite(uint16(HR_tissue_map), ['input', filesep, 'HR_tissue_map'], info);