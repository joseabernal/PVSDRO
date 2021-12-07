%% Generate a PVS
%  Generate a PVS with certain characteristics
%  
%  Inputs:
%  - length: PVS length
%  - width: PVS width
%  - orientation: PVS orientation
%  - FOV_mm_True: FOV in mm
%  - NTrue: Spatial dimensions of true FOV region 
%  - NAcq: Spatial dimensions of acquired FOV region
%
%  Outputs:
%   - LR_capsule: 3D low resolution version of capsule
%
% (c) Jose Bernal 2021

function LR_PVS=create_PVS(length, width, orientation, FOV_mm, NTrue, NAcq)
    FOV_mm_Acq = FOV_mm;
    res_mm_True = FOV_mm./NTrue;
    res_mm_Acq = FOV_mm_Acq./NAcq;
    
    rotm = eul2rotm(deg2rad([orientation(2), orientation(1), orientation(3)]), 'XYZ'); % cor, sag, axial
   
    [x_mm_HR, y_mm_HR, z_mm_HR] = meshgrid(...
        (-FOV_mm(2)/2):res_mm_True(2):(FOV_mm(2)/2-res_mm_True(2)),...    
        (-FOV_mm(1)/2):res_mm_True(1):(FOV_mm(1)/2-res_mm_True(1)),...
        (-FOV_mm(3)/2):res_mm_True(3):(FOV_mm(3)/2-res_mm_True(3))); %HR position values in image

    a = 0.5 * width;
    b = 0.5 * width;
    c = 0.5 * length;
    
    HR_PVS = ((x_mm_HR/a).^2 + (y_mm_HR/b).^2 + (z_mm_HR/c).^2) <= 1;
    HR_PVS = double(HR_PVS);

    [x_mm_LR, y_mm_LR, z_mm_LR] = meshgrid(...
        (-FOV_mm_Acq(2)/2):res_mm_Acq(2):(FOV_mm_Acq(2)/2-res_mm_Acq(2)),...    
        (-FOV_mm_Acq(1)/2):res_mm_Acq(1):(FOV_mm_Acq(1)/2-res_mm_Acq(1)),...
        (-FOV_mm_Acq(3)/2):res_mm_Acq(3):(FOV_mm_Acq(3)/2-res_mm_Acq(3))); %LR position values in image
    
    sampling_points = rotm*[x_mm_LR(:), y_mm_LR(:), z_mm_LR(:)]';

    x_mm_LR = reshape(sampling_points(1, :), size(x_mm_LR));
    y_mm_LR = reshape(sampling_points(2, :), size(y_mm_LR));
    z_mm_LR = reshape(sampling_points(3, :), size(z_mm_LR));
    
    LR_PVS = interp3(x_mm_HR, y_mm_HR, z_mm_HR, HR_PVS, ...
        x_mm_LR, y_mm_LR, z_mm_LR, 'linear', 0);

    LR_PVS = LR_PVS>0;
end