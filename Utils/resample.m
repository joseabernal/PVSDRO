%% Modify FOV and resample accordingly
%  Modify field of view to mimic slab-selective RF excitation
%  
%  Inputs:
%  - HR_SI: 3D high resolution image
%  - FoV_mm_True: Original FOV in mm
%  - NTrue: Dimension of image that defines the "true" object
%  - FoV_mm_Acq: Desired FOV in mm
%  - NAcq: Spatial dimensions of desired FOV region
%
%  Outputs:
%   - LR_k: k-space of the 3D low resolution version the input
%
% (c) Jose Bernal and Michael J. Thrippleton 2019

function LR_k = resample(HR_SI, FoV_mm_True, NTrue, FoV_mm_Acq, NAcq)
    res_mm_True=FoV_mm_True./NTrue; %HR resolution
    res_mm_Acq=FoV_mm_Acq./NAcq; %LR resolution

    k_FoV_perMM_HR=1./res_mm_True; %HR FoV in k-space
    k_res_perMM_HR=1./FoV_mm_True; %HR resolution in k-space
    k_FoV_perMM_LR=1./res_mm_Acq; %LR FoV in k-space
    k_res_perMM_LR=1./FoV_mm_Acq; %LR resolution in k-space

    [x_mm_HR, y_mm_HR, z_mm_HR] = meshgrid(...
        (-FoV_mm_True(2)/2):res_mm_True(2):(FoV_mm_True(2)/2-res_mm_True(2)),...    
        (-FoV_mm_True(1)/2):res_mm_True(1):(FoV_mm_True(1)/2-res_mm_True(1)),...
        (-FoV_mm_True(3)/2):res_mm_True(3):(FoV_mm_True(3)/2-res_mm_True(3))); %HR position values in image
    [kx_perMM_HR, ky_perMM_HR, kz_perMM_HR] = meshgrid(...
        (-k_FoV_perMM_HR(2)/2):k_res_perMM_HR(2):(k_FoV_perMM_HR(2)/2-k_res_perMM_HR(2)),...
        (-k_FoV_perMM_HR(1)/2):k_res_perMM_HR(1):(k_FoV_perMM_HR(1)/2-k_res_perMM_HR(1)),...
        (-k_FoV_perMM_HR(3)/2):k_res_perMM_HR(3):(k_FoV_perMM_HR(3)/2-k_res_perMM_HR(3)));  %HR position values in k-space
    x_mm_LR=[(-FoV_mm_Acq(2)/2), (FoV_mm_Acq(2)/2-res_mm_Acq(2))];
    y_mm_LR=[(-FoV_mm_Acq(1)/2), (FoV_mm_Acq(1)/2-res_mm_Acq(1))];
    z_mm_LR=[(-FoV_mm_Acq(3)/2), (FoV_mm_Acq(3)/2-res_mm_Acq(3))];
    [kx_perMM_LR, ky_perMM_LR, kz_perMM_LR] = meshgrid(...
        (-k_FoV_perMM_LR(2)/2):k_res_perMM_LR(2):(k_FoV_perMM_LR(2)/2-k_res_perMM_LR(2)),...
        (-k_FoV_perMM_LR(1)/2):k_res_perMM_LR(1):(k_FoV_perMM_LR(1)/2-k_res_perMM_LR(1)),...
        (-k_FoV_perMM_LR(3)/2):k_res_perMM_LR(3):(k_FoV_perMM_LR(3)/2-k_res_perMM_LR(3)));  %LR position values in k-space

    SF=prod(FoV_mm_True./FoV_mm_Acq); %Scaling factor

    is_within_LR_FoV=(x_mm_HR>=min(x_mm_LR)) & (x_mm_HR<=max(x_mm_LR)) & ...
        (y_mm_HR>=min(y_mm_LR)) & (y_mm_HR<=max(y_mm_LR)) & ...
        (z_mm_HR>=min(z_mm_LR)) & (z_mm_HR<=max(z_mm_LR)); %find HR voxels within LR FoV

    is_modified = FoV_mm_True>FoV_mm_Acq; %flag indicating whether to filter or not on a certain direction
    
    W = createWindow3D(FoV_mm_True, FoV_mm_Acq, res_mm_True, is_modified); %create 3D window to reduce phase warping
    
    HR_SI_windowed = (HR_SI .* W) .* is_within_LR_FoV;  %discard outlier lines and multiply by window
    
    HR_k = generateKSpace(HR_SI_windowed); %compute corresponding k-space
    
    LR_k = SF * interp3(kx_perMM_HR, ky_perMM_HR, kz_perMM_HR, HR_k, ...
            kx_perMM_LR, ky_perMM_LR, kz_perMM_LR, 'linear'); %resample
end