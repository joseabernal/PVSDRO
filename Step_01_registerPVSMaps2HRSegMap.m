%% Register PVS Maps to MIDA model
%  This script registers PVS maps to the MIDA model
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

% define input and output files
output = 'input/PVSMaps/MIDA_to_HR_';

% registration of moving to fixed
system(sprintf(antsRegistrationCommand, MIDA_T2_fname, PVS_reference_T2_fname, output, MIDA_brain_mask_fname));

% Apply transformations to PVS location map
PVS_map_output = sprintf(PVS_map_output_pattern, 'location');
system(sprintf(antsApplyTransformCommand, PVS_location_map_fname, MIDA_T2_fname, PVS_location_map_output, [output, '0GenericAffine.mat']));
system(sprintf(antsApplyTransformCommand, PVS_location_map_output, MIDA_T2_fname, PVS_location_map_output, [output, '1Warp.nii.gz']));

% Apply transformations to PVS orientation maps
maps = {'r', 'g', 'b'};
for i = 1:length(maps)
    PVS_map_fname = sprintf(PVS_orientation_map_pattern, maps{i});
    PVS_map_output = sprintf(PVS_map_output_pattern, maps{i});

    system(sprintf(antsApplyTransformCommand, PVS_map_fname, MIDA_T2_fname, PVS_map_output, [output, '0GenericAffine.mat']));
    system(sprintf(antsApplyTransformCommand, PVS_map_output, MIDA_T2_fname, PVS_map_output, [output, '1Warp.nii.gz']));
end