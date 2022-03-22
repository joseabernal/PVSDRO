%% Run RORPO from Matlab
%  Wrapper function to run RORPO from Matlab
%  
%  Inputs:
%  - SI: 3D image
%  - ROI_mask: 3D binary mask
%  - SI_base_fname: filename
%  - RORPO_command: RORPO command
%
%  Outputs:
%   - PVS_likelihood: filter response map
%
% (c) Jose Bernal 2022

function PVS_likelihood = RORPO_wrapper(SI, ROI_mask, SI_base_fname, RORPO_command)
    T2W_no_header_fname = [SI_base_fname, '-no_header'];
    T2W_no_header_fname = replace_parenthesis(T2W_no_header_fname);
    mask_no_header_fname = [SI_base_fname, '_brainmask-no_header'];
    mask_no_header_fname = replace_parenthesis(mask_no_header_fname);
    
    [partition, ~] = lloyds(SI(ROI_mask==1), 2^8, 1e-2);
    SI_uint8 = imquantize(SI, partition, 0:2^8-1);
    
    niftiwrite(uint8(SI_uint8), T2W_no_header_fname, 'Compressed', 1);
    niftiwrite(uint8(ROI_mask), mask_no_header_fname, 'Compressed', 1);
    
    T2W_output_no_header_fname = [SI_base_fname, '_out-no_header'];
    T2W_output_no_header_fname = replace_parenthesis(T2W_output_no_header_fname);
    
    system(sprintf(RORPO_command, ...
        [T2W_no_header_fname, '.nii.gz'], ...
        [T2W_output_no_header_fname, '.nii.gz'], ...
        [mask_no_header_fname, '.nii.gz']));
    
    PVS_likelihood = niftiread(T2W_output_no_header_fname); 
end

function out_fname = replace_parenthesis(in_fname)
    out_fname = in_fname;
    out_fname = replace(out_fname, '(', '');
    out_fname = replace(out_fname, ')', '');
end