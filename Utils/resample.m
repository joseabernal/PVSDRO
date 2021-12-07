%% Resample signal
%  Resample signal by downsampling
%  
%  Inputs:
%  - HR_SI: 3D high resolution image
%  - FoV_mm_True: Original FOV in mm
%  - NTrue: Dimension of image that defines the "true" object
%  - FoV_mm_Acq: Desired FOV in mm
%  - NAcq: Spatial dimensions of desired FOV region
%  - interp_method: Interpolation method
%
%  Outputs:
%   - LR_SI: 3D low resolution version of input
%
% (c) Jose Bernal 2021

function LR_SI = resample(HR_SI, FOV_mm_True, NTrue, FOV_mm_Acq, NAcq, interp_method)
    if nargin < 6
        interp_method = 'cubic';
    end

    res_mm_True=FOV_mm_True./NTrue; %HR resolution
    res_mm_Acq=FOV_mm_Acq./NAcq; %LR resolution

    [x_mm_HR, y_mm_HR, z_mm_HR] = meshgrid(...
        (-FOV_mm_True(2)/2):res_mm_True(2):(FOV_mm_True(2)/2-res_mm_True(2)),...    
        (-FOV_mm_True(1)/2):res_mm_True(1):(FOV_mm_True(1)/2-res_mm_True(1)),...
        (-FOV_mm_True(3)/2):res_mm_True(3):(FOV_mm_True(3)/2-res_mm_True(3))); %HR position values in image
    [x_mm_LR, y_mm_LR, z_mm_LR] = meshgrid(...
        (-FOV_mm_Acq(2)/2):res_mm_Acq(2):(FOV_mm_Acq(2)/2-res_mm_Acq(2)),...    
        (-FOV_mm_Acq(1)/2):res_mm_Acq(1):(FOV_mm_Acq(1)/2-res_mm_Acq(1)),...
        (-FOV_mm_Acq(3)/2):res_mm_Acq(3):(FOV_mm_Acq(3)/2-res_mm_Acq(3))); %LR position values in image
    
    LR_SI = interp3(x_mm_HR, y_mm_HR, z_mm_HR, HR_SI, x_mm_LR, y_mm_LR, z_mm_LR, interp_method); %resample
end