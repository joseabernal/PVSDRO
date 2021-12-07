%% Create HR PVS maps
%  This script creates HR PVS maps for simulation
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
PVS_loc_map = niftiread(sprintf(PVS_map_output_pattern, 'location'));
PVS_r_map = niftiread(sprintf(PVS_map_output_pattern, 'r'));
PVS_g_map = niftiread(sprintf(PVS_map_output_pattern, 'g'));
PVS_b_map = niftiread(sprintf(PVS_map_output_pattern, 'b'));

PVS_rgb_map = [PVS_r_map(:), PVS_g_map(:), PVS_b_map(:)];

% define ROI: dGM, NAWM, WMH
included_roi = (tissue_map == NAWM_class_idx | tissue_map == dGM_class_idx | tissue_map == WMH_class_idx);

PVS_loc_map(~included_roi) = 0;

thmax = prctile(PVS_loc_map(PVS_loc_map>0), 90);

info.Datatype = 'int16';

s = RandStream('mlfg6331_64');
parfor iCase = 1:length(lengths)
    for rep=1:NRep
        % choose PVS locations at random
        R = randsample(s, 1:numel(PVS_loc_map), count, true, min(PVS_loc_map(:)/thmax, 1));

        [x, y, z] = ind2sub(size(PVS_loc_map), R);

        angles = PVS_rgb_map(R, :);
        angles = reshape(angles, [], 3);

        % generate mask of PVS
        mask = zeros(size(PVS_loc_map));
        characteristics = cell(length(x), 1);
        for idx = 1:length(x)           
            rot_angles = angles(idx, :);
            if x(idx) <= 240
                rot_angles(1) = -rot_angles(1);
            end

            % generate PVS
            pvs = create_PVS(volumes(iCase), widths(iCase), rot_angles, PVS_vol_space, PVS_res, PVS_vol_voxels);
            
            % check whether PVS is valid
            xmin = x(idx);
            xmax = x(idx) + PVS_vol_voxels(1)-1;
            ymin = y(idx);
            ymax = y(idx) + PVS_vol_voxels(2)-1;
            zmin = z(idx);
            zmax = z(idx) + PVS_vol_voxels(3)-1;
            
            % check if PVS is within included_roi
            valid_section = pvs .* included_roi(xmin:xmax, ymin:ymax, zmin:zmax);
            
            if sum(valid_section, 'all') < 0.95 * sum(pvs, 'all')
                continue;
            end
            
            % check if there are not any PVS occupying the same region
            % already            
            if sum(mask(xmin:xmax, ymin:ymax, zmin:zmax), 'all') > 0.5 * prod(PVS_vol_voxels)
                continue;
            end
            
            % add it to the mask
            mask(xmin:xmax, ymin:ymax, zmin:zmax) = idx * pvs;
        end

        mask(~included_roi) = 0;
        
        % output filename
        output_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));

        % save PVS
        niftiwrite(int16(mask), output_fname, info, 'Compressed', 1);
    end
end