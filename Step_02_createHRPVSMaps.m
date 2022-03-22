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

% change datatype to uint8
info.Datatype = 'uint8';

% Construct HR brain mask
roi = tissue_map == 3 | tissue_map == 4 | tissue_map == 7;
roi = bwdist(~roi)>=4;
niftiwrite(uint8(roi), HR_ROI_mask_fname, info, 'Compressed', 1);

parfor iCase = 1:length(lengths)
    for rep = 1:NRep
        pvs_creator = create_PVS_creator(lengths(iCase), widths(iCase), PVS_vol_space);
        % choose PVS locations at random
        feasible_locations = roi .* (rand(size(roi)) >= 0.5);
        feasible_locations = blockproc3(...
            feasible_locations, ...
            ceil(PVS_vol_space * 0.7), ...
            @(input) summariseNeighbourhood(input), [0, 0, 0]);
        feasible_voxels = find(feasible_locations == 1);

        [x, y, z] = ind2sub(size(roi), feasible_voxels);

        % generate mask of PVS
        mask = zeros(size(roi));
        for idx = 1:length(x)
            % generate PVS
            display([idx, length(x)])

            half_pvs_size = floor(PVS_vol_space / 2);
            xmin = x(idx) - half_pvs_size(1);
            xmax = x(idx) + half_pvs_size(1);
            ymin = y(idx) - half_pvs_size(2);
            ymax = y(idx) + half_pvs_size(2);
            zmin = z(idx) - half_pvs_size(3);
            zmax = z(idx) + half_pvs_size(3);

            % based on https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
            a = [0, 0, 1]'; % vector in the superior-inferior direction
            b = [240, 240, 240]' - [x(idx), y(idx), z(idx)]';
            b = b / norm(b);

            GG = @(A,B) [ dot(A,B) -norm(cross(A,B)) 0; ...
                norm(cross(A,B)) dot(A,B)  0; ...
                0              0           1];
            FFi = @(A,B) [ A (B-dot(A,B)*A)/norm(B-dot(A,B)*A) cross(B,A) ];
            UU = @(Fi,G) Fi*G*inv(Fi);
            U = UU(FFi(b,a), GG(b,a));

            pvs = pvs_creator(U);
            total_voxels = sum(pvs, 'all');

            % ensure there is no intersection with other PVS
            check_intersection = sum(pvs .* mask(xmin:xmax, ymin:ymax, zmin:zmax), 'all');

            % ensure PVS fits completely within the ROI
            check_within_ROI = sum(pvs .* roi(xmin:xmax, ymin:ymax, zmin:zmax), 'all');

            if check_intersection == 0 && check_within_ROI == total_voxels
                % add it to the mask
                mask(xmin:xmax, ymin:ymax, zmin:zmax) = mask(xmin:xmax, ymin:ymax, zmin:zmax) | pvs;
            end
        end

        mask(~roi) = 0;

        cc = bwconncomp(logical(mask), 26); 
        stats = regionprops3(cc,'Volume'); 
        idx = find([stats.Volume] >= lengths(iCase)*(widths(iCase)/2).^2*pi); 
        mask_corrected = ismember(labelmatrix(cc), idx);

        % output filename
        output_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));

        % save PVS
        niftiwrite(uint8(mask_corrected), output_fname, info, 'Compressed', 1);
    end
end