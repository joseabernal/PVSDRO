%% "Acquire" scanning resolution signal
%  Truncate high resolution sMRI signal to produce the "acquired" scanning
%  resolution sMRI signal. The signal is affected by noise, determined
%  by the signal-to-noise ratio.
%  
%  Inputs:
%  - HR_SI: 3D high resolution image
%  - FOV_mm_True: Default FOV in mm
%  - NTrue: Dimension of image that defines the "true" object
%  - SDnoise: Standard deviation of noise
%  - FOV_mm_Acq: Acquired FOV in mm
%  - NDes: Spatial dimensions of desired FOV region
%  - NAcq: Spatial dimensions of acquired images
%  - apply_noise: flag indicating whether to add noise or not
%  - apply_motion_artefacts: flag indicating whether to induce motion artefacts

%  Outputs:
%   - LR_SI: "Acquired" 3D (scanning resolution) sMRI signal
%
% (c) Jose Bernal and Michael J. Thrippleton 2020

function LR_SI = generateLRData(HR_SI, FOV_mm_True, NTrue, SDnoise, FOV_mm_Acq, NAcq, apply_noise, apply_motion_artefacts)
    if apply_motion_artefacts
        %% Adjust FOV and acquisition matrices
        LR_k_space = cat(4, ...
            resample(HR_SI(:, :, :, 1), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq),...
            resample(HR_SI(:, :, :, 2), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq),...
            resample(HR_SI(:, :, :, 3), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq));
    else
        %% Adjust FOV and acquisition matrices
        LR_k_space = resample(HR_SI(:, :, :, 1), FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);
    end
    
    %% Induce motion artefacts
    % Combine k-spaces to produce motion artifacts
    LR_k_space_motion = add_motion_artifacts_rotation_kspace(LR_k_space, NAcq);
    
    %% Add noise
    if apply_noise
        LR_k_space_acquired = add_noise(LR_k_space_motion, SDnoise, NAcq);
    else
        LR_k_space_acquired = LR_k_space_motion;
    end

    %% Transform to image space
    LR_SI = abs(generateImageSpace(LR_k_space_acquired));
end