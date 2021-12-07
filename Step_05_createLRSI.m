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

%% Create LR T2-w like images with PVS
rng(0);
if apply_motion_artefacts
    % Generate random transformation to set head position
    head_position_B = cell(1, NRep);
    for rep=1:NRep
        head_position_B{rep} = generateRandomTransformation(5*[1 1 1], [0 0 0]);
    end

    % number of lines in k-space
    n_k_space_lines = NTrue(3) * NTrue(1);

    % how many lines to take from kspace before motion
    k_space_mix_thresholds = randi([n_k_space_lines/2, n_k_space_lines], NRep, 1);
end

for iCase = 1:length(lengths)
    for rep=1:NRep
        % define input and output filenames
        input_fname = sprintf(HR_SI_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(LR_SI_output_pattern, num2str(iCase), num2str(rep));

        info = niftiinfo(input_fname);
        info.Datatype = 'double';
        info.ImageSize = NAcq;
        info.PixelDimensions = MSSIII_res_mm;
        
        HR_SI = double(niftiread(input_fname));
        
        if apply_gross_motion
            % Generate random transformation to set initial head position
            head_position = generateRandomTransformation([5, 5, 5], [5, 5, 5]);
            
            % Apply random starting position
            HR_SI = applyGrossMotion(HR_SI, head_position, NTrue);
        end
        
        if apply_motion_artefacts
            % Apply random starting position
            HR_SI_B = applyGrossMotion(HR_SI, head_position_B{rep}, NTrue);
            
            k_space_A = fftshift(ifftn(ifftshift(HR_SI)));
            k_space_B = fftshift(ifftn(ifftshift(HR_SI_B)));

            % generate composite k-space
            composite_k_space = add_motion_artifacts_rotation_kspace(...
                k_space_B, k_space_A, NTrue, k_space_mix_thresholds(rep));

            HR_SI = ifftshift(fftn(fftshift(composite_k_space)));
        end
        
        if apply_noise
            k_space = fftshift(ifftn(ifftshift(HR_SI)));

            % add noise
            k_space_noisy = add_noise(k_space, SDnoise, NTrue);

            HR_SI = ifftshift(fftn(fftshift(k_space_noisy)));
        end
        
        % Downsample to create PVE
        LR_SI = resample(abs(HR_SI), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);

        % save LR PVS map
        niftiwrite(double(LR_SI), output_fname, info, 'Compressed', 1);
        
        if apply_gross_motion
            registerCase2SegmentationMap(output_fname);
        end
    end
end