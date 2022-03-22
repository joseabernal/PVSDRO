%% Induce motion artefacts by creating composite k-space
%  Induce motion artefacts by creating a composite k-space in which some
%  lines are taken from when the person was in three different positions.
%  This code is based on
%  https://github.com/joseabernal/BrainDCEDRO/blob/master/Artefacts/add_motion_artifacts_rotation_kspace.m.
%  
%  Inputs:
%  - k_spaces: k-spaces of the object of interest
%  - NTrue: Dimension of image that defines the "true" object
%  Outputs:
%   - composite_k_space: Composite k-space
%
% (c) Jose Bernal 2022

function composite_k_space = add_motion_artifacts_rotation_kspace(k_spaces, NTrue)
    if ndims(k_spaces) <= 3
        composite_k_space = k_spaces;
    else
        % number of lines in k-space
        n_k_space_lines = NTrue(3) * NTrue(1);

        % how many lines to take from kspace before motion
        if nargin < 3
            k_space_lines_second_segment = randi([n_k_space_lines/2, n_k_space_lines]);

            remaining_lines = n_k_space_lines - k_space_lines_second_segment;
            k_space_lines_first_segment = randi([0, floor(remaining_lines/2)]);
            k_space_lines_third_segment = ...
                n_k_space_lines - k_space_lines_first_segment - k_space_lines_second_segment;
        end
        
        display(100*[k_space_lines_first_segment, k_space_lines_second_segment, k_space_lines_third_segment]/n_k_space_lines)

        line_count = 0;
        composite_k_space = zeros(NTrue);
        for iLine=1:NTrue(1)
            for iSlice=1:NTrue(3)
                % take only k_space_mix_threshold lines from kspace before
                % motion, and rest from after motion
                if line_count < k_space_lines_first_segment
                    composite_k_space(iLine, :, iSlice) = k_spaces(iLine, :, iSlice, 1);
                elseif line_count < (k_space_lines_first_segment + k_space_lines_second_segment)
                    composite_k_space(iLine, :, iSlice) = k_spaces(iLine, :, iSlice, 2);
                else
                    composite_k_space(iLine, :, iSlice) = k_spaces(iLine, :, iSlice, 3);
                end

                line_count = line_count + 1;
            end
        end
    end
end