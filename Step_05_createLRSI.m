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

parfor iCase = 1:length(lengths)
    for rep=1:NRep
        % define input and output filenames
        input_fname = sprintf(HR_SI_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(LR_SI_output_pattern, num2str(iCase), num2str(rep));

        info = niftiinfo(input_fname);
        info.Datatype = 'double';
        info.ImageSize = NAcq;
        info.PixelDimensions = MSSIII_res_mm;
        
        HR_SI = double(niftiread(input_fname));
        
        % Downsample to create PVE
        LR_SI = resample(HR_SI, FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);

        % save LR PVS map
        niftiwrite(double(LR_SI), output_fname, info, 'Compressed', 1);
    end
end

input_fname = sprintf(HR_SI_output_pattern, num2str(1), num2str(1));
info = niftiinfo(input_fname);
tissue_map = niftiread(MIDA_tissue_map_fname);

info.Datatype = 'uint16';
info.ImageSize = NAcq;
info.PixelDimensions = MSSIII_res_mm;

% Construct LR brain mask
ROI = tissue_map == 3 | tissue_map == 4 | tissue_map == 5 | tissue_map == 6 | tissue_map == 7 | tissue_map == 8;
LR_brain_mask = resample(double(ROI), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);
niftiwrite(uint16(LR_brain_mask>0.95), LR_brain_mask_fname, info, 'Compressed', 1);

% Construct LR ROI mask
ROI = tissue_map == 3 | tissue_map == 4 | tissue_map == 7;
LR_ROI_mask = resample(double(ROI), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);
niftiwrite(uint16(LR_ROI_mask>0.95), LR_ROI_mask_fname, info, 'Compressed', 1);