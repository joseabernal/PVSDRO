%% Generate a PVS
%  Generate a PVS with certain characteristics
%  
%  Inputs:
%  - length: PVS length
%  - width: PVS width
%  - FOV_mm_True: FOV in mm
%  - NPoints: Spatial dimensions of true FOV region 
%
%  Outputs:
%   - LR_capsule: 3D low resolution version of capsule
%
% (c) Jose Bernal 2022

function PVS_creator=create_PVS_creator(length, width, NVox)
    half_size = floor(NVox / 2);
    [x_vox, y_vox, z_vox] = ndgrid(...
        -half_size(2):half_size(2), ...
        -half_size(1):half_size(1), ...
        -half_size(3):half_size(3));

    PVS = x_vox.^2 + y_vox.^2 <= (width/2).^2;
    PVS = PVS .* (abs(z_vox) <= length/2);
    PVS = double(PVS);
    
    interpolant = griddedInterpolant(x_vox, y_vox, z_vox, PVS, 'linear', 'none');

    sampling_points = cat(2, x_vox(:), y_vox(:), z_vox(:));

    PVS_creator = @(orientation) reshape(create_PVS_aux(interpolant, orientation, sampling_points), size(x_vox));
end

function PVS = create_PVS_aux(interpolant, rotm, sampling_points)    
    sampling_points = rotm*sampling_points';

    PVS = interpolant(sampling_points(1, :), sampling_points(2, :), sampling_points(3, :));
    PVS = PVS>=0.5;
end