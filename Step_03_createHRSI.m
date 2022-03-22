%% Create HR SI maps
%  This script creates HR SI maps for simulation
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

% loading images
info = niftiinfo(MIDA_tissue_map_fname);
tissue_map = niftiread(MIDA_tissue_map_fname);
pat_tissue_map = niftiread(MIDA_tissue_map_ageing_fname);

% define ROI: dGM, NAWM, WMH
included_roi = (tissue_map == NAWM_class_idx | tissue_map == dGM_class_idx);

info.Datatype = 'double';

for iCase = 1:length(lengths)
    parfor rep = 1:NRep
        % set input and output filenames
        input_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(HR_SI_output_pattern, num2str(iCase), num2str(rep));

        PVS_map = niftiread(input_fname);
        PVS_map = PVS_map > 0;
        
        if exist([output_fname, '.nii.gz'], 'file')
            continue;
        end

        if ~use_MIDA_ageing_mask
            smoothness = [1, 1, 1, 0, 0, 1, 0, 1, 0];
            HR_tissue_prob = zeros([NTrue, NumRegions]);
            for iRegion=1:NumRegions
                if smoothness(iRegion) == 0
                    HR_tissue_prob(:, :, :, iRegion) = tissue_map == iRegion;
                else
                    HR_tissue_prob(:, :, :, iRegion) = ...
                        imgaussfilt3(double(tissue_map == iRegion), smoothness(iRegion));
                end
            end

            dGM_mask = tissue_map == dGM_class_idx;
            dGM_dist = (tissue_map == NAWM_class_idx) .* (bwdist(dGM_mask) <= 1);
            dGM_dist = dGM_mask .* bwdist(dGM_dist);
            dGM_dist = dGM_dist / max(dGM_dist, [], 'all');
            dGM_dist = imgaussfilt3(dGM_dist, 1);

            HR_tissue_prob(:, :, :, dGM_class_idx) = dGM_dist .* (2-sum(HR_tissue_prob, 4));

            HR_tissue_prob(:, :, :, NAWM_class_idx) = ...
                HR_tissue_prob(:, :, :, NAWM_class_idx) + dGM_mask .* (1-sum(HR_tissue_prob, 4));

            HR_tissue_prob = HR_tissue_prob ./ sum(HR_tissue_prob, 4);

            HR_SI = zeros(NTrue);
            for iRegion=1:NumRegions
                HR_SI = HR_SI + HR_tissue_prob(:, :, :, iRegion) .* SI(iRegion);
            end

            PVS_inner_dist = PVS_map;

            HR_SI = HR_SI .* (1-PVS_inner_dist) + SI(NumRegions) .* PVS_inner_dist;
        else
            smoothness = [1, 1, 1, 1, 0, 1, 0, 1, 0];
            HR_tissue_prob = zeros([NTrue, NumRegions]);
            for iRegion=1:NumRegions
                if smoothness(iRegion) == 0
                    HR_tissue_prob(:, :, :, iRegion) = pat_tissue_map == iRegion;
                else
                    HR_tissue_prob(:, :, :, iRegion) = ...
                        imgaussfilt3(double(pat_tissue_map == iRegion), smoothness(iRegion));
                end
            end

            dGM_mask = pat_tissue_map == dGM_class_idx;
            dGM_dist = (pat_tissue_map == NAWM_class_idx) .* (bwdist(dGM_mask) <= 1);
            dGM_dist = dGM_mask .* bwdist(dGM_dist);
            dGM_dist = dGM_dist / max(dGM_dist, [], 'all');
            dGM_dist = imgaussfilt3(dGM_dist, 1);

            HR_tissue_prob(:, :, :, dGM_class_idx) = dGM_dist .* (2-sum(HR_tissue_prob, 4));

            HR_tissue_prob(:, :, :, NAWM_class_idx) = ...
                HR_tissue_prob(:, :, :, NAWM_class_idx) + dGM_mask .* (1-sum(HR_tissue_prob, 4));

            HR_tissue_prob = HR_tissue_prob ./ sum(HR_tissue_prob, 4);

            HR_SI = zeros(NTrue);
            for iRegion=1:NumRegions
                HR_SI = HR_SI + HR_tissue_prob(:, :, :, iRegion) .* SI(iRegion);
            end

            PVS_inner_dist = PVS_map;

            HR_SI = HR_SI .* (1-PVS_inner_dist) + SI(NumRegions) .* PVS_inner_dist;
        end

        % save HR SI
        niftiwrite(double(HR_SI), output_fname, info, 'Compressed', 1);
    end
end