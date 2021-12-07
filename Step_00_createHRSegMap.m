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
HR_orig_segmap = niftiread(MIDA_map_fname);
WMH_segmap = niftiread(MIDA_WMH_fname);
RSL_segmap = niftiread(MIDA_RSL_fname);

% Map tissues
HR_tissue_map_clean = zeros(size(HR_orig_segmap));
for c=1:size(mapping, 1)
    HR_tissue_map_clean(HR_orig_segmap == c) = mapping(c, 2);
end

% Add pathological tissues to the segmentation mask
HR_tissue_map_ageing = HR_tissue_map_clean;
HR_tissue_map_ageing(WMH_segmap == 1 & HR_tissue_map_ageing ~= 2) = 4;
HR_tissue_map_ageing(RSL_segmap == 1) = 5;

HR_tissue_map_clean = padarray(HR_tissue_map_clean(:, 141:end, :), [0, 70, 65], 1, 'both');
HR_tissue_map_clean = permute(HR_tissue_map_clean, [3, 1, 2]);
HR_tissue_map_clean = flip(HR_tissue_map_clean, 2);

HR_tissue_map_ageing = padarray(HR_tissue_map_ageing(:, 141:end, :), [0, 70, 65], 1, 'both');
HR_tissue_map_ageing = permute(HR_tissue_map_ageing, [3, 1, 2]);
HR_tissue_map_ageing = flip(HR_tissue_map_ageing, 2);

% Save HR tissue maps
info.ImageSize = NTrue;
info.PixelDimensions = HRes_mm;
info.Transform = affine3d(eye(4));
niftiwrite(uint16(HR_tissue_map_clean), MIDA_tissue_map_fname, info, 'Compressed', 1);
niftiwrite(uint16(HR_tissue_map_ageing), MIDA_tissue_map_ageing_fname, info, 'Compressed', 1);

HR_SI = SI(HR_tissue_map_clean);

% save HR T2-like image
niftiwrite(uint16(HR_SI), MIDA_T2_fname, info, 'Compressed', 1);
niftiwrite(uint16(HR_SI>0), MIDA_brain_mask_fname, info, 'Compressed', 1);