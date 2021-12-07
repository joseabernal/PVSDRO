%% Induce motion artefacts by creating composite k-space
%  Induce motion artefacts by creating a composite k-space in which some
%  lines are taken from when the person was in position A and the rest from
%  when it moved to position B.
%  
%  Inputs:
%  - k_space_after_motion: K-space of the object after gross motion
%  - k_space_before_motion: K-space of the object before gross motion
%  - NTrue: Dimension of image that defines the "true" object
%  Outputs:
%   - composite_k_space: Composite k-space
%
% (c) Jose Bernal 2021

function composite_k_space = add_motion_artifacts_rotation_kspace(k_space_after_motion, k_space_before_motion, NTrue, k_space_mix_threshold)
    % number of lines in k-space
    n_k_space_lines = NTrue(3) * NTrue(1);
    
    % how many lines to take from kspace before motion
    if nargin < 4
        k_space_mix_threshold = randi([n_k_space_lines/2, n_k_space_lines]);
    end
    
    display(k_space_mix_threshold)
    
    line_count = 0;
    composite_k_space = zeros(size(k_space_before_motion));
    for iLine=1:NTrue(1)
        for iSlice=1:NTrue(3)
            % take only k_space_mix_threshold lines from kspace before
            % motion, and rest from after motion
            if line_count < k_space_mix_threshold
                composite_k_space(iLine, :, iSlice) = k_space_before_motion(iLine, :, iSlice);
            else
                composite_k_space(iLine, :, iSlice) = k_space_after_motion(iLine, :, iSlice);
            end
            line_count = line_count + 1;
        end
    end
end