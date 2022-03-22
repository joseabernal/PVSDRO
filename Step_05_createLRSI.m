%% Downsampling SI maps
%  This script downsamples HR SI maps for simulation
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

%% create LR brain and ROI masks
input_fname = sprintf(HR_SI_output_pattern, num2str(1), num2str(1));
info = niftiinfo(input_fname);
tissue_map = niftiread(MIDA_tissue_map_fname);

% Generate random transformation to set head position
rot_angles = unifrnd(-5, -1, NRep, 1);
rot_dimensions = randi([0 1], NRep, 3);

%% Create LR T2-w like images with PVS
for iCase = 1:length(lengths)
    parfor rep=1:NRep
        % define input and output filenames
        input_fname = sprintf(HR_SI_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(LR_SI_output_pattern, num2str(iCase), num2str(rep), num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));

        info = niftiinfo(input_fname);
        info.Datatype = 'uint16';
        info.ImageSize = NAcq;
        info.PixelDimensions = LBC_res_mm;

        HR_SI = double(niftiread(input_fname));

        if apply_motion_artefacts
            theta_prev = rot_angles(rep);
            theta_post = -theta_prev;

            HR_SI = cat(4, ...
                applyRotation(HR_SI, theta_prev, rot_dimensions(rep, :)), ...
                HR_SI, ...
                applyRotation(HR_SI, theta_post, rot_dimensions(rep, :)));
        end

        LR_SI = generateLRData(...
            HR_SI, FOV_mm_True, NTrue, SDnoise, FOV_mm_Acq, NAcq, apply_noise, apply_motion_artefacts);

        % save LR PVS map
        niftiwrite(uint16(LR_SI), output_fname, info, 'Compressed', 1);
    end
end

info.Datatype = 'uint16';

% Construct LR brain mask
ROI = tissue_map == 3 | tissue_map == 4 | tissue_map == 5 | tissue_map == 6 | tissue_map == 7;
ROI_dist = bwdist(~ROI);
LR_brain_mask = generateLRData(...
    ROI_dist, FOV_mm_True, NTrue, SDnoise, FOV_mm_Acq, NAcq, 0, 0) >= 6;
% niftiwrite(uint16(ROI_dist>=6), HR_brain_mask_fname, info, 'Compressed', 1);

% Construct LR ROI mask
ROI = tissue_map == 3 | tissue_map == 4 | tissue_map == 7;
LR_ROI_mask = generateLRData(...
    bwdist(~ROI), FOV_mm_True, NTrue, SDnoise, FOV_mm_Acq, NAcq, 0, 0) >= 1;
% niftiwrite(uint16((bwdist(~ROI)>=1) .* (ROI_dist>=6)), HR_ROI_mask_fname, info, 'Compressed', 1);

LR_ROI_mask_output_fname = sprintf(LR_ROI_mask_fname, num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));

info.ImageSize = NAcq;
info.PixelDimensions = LBC_res_mm;
niftiwrite(uint16(LR_brain_mask), LR_brain_mask_fname, info, 'Compressed', 1);
niftiwrite(uint16(LR_ROI_mask.*LR_brain_mask), LR_ROI_mask_output_fname, info, 'Compressed', 1);