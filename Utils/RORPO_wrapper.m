function PVS_likelihood = RORPO_wrapper(SI, ROI_mask, SI_base_fname, RORPO_command)
    T2W_no_header_fname = [SI_base_fname, '-no_header'];
    mask_no_header_fname = [SI_base_fname, '_brainmask-no_header'];

    niftiwrite(uint16(SI), T2W_no_header_fname, 'Compressed', 1);
    niftiwrite(uint8(ROI_mask), mask_no_header_fname, 'Compressed', 1);
    
    T2W_output_no_header_fname = [SI_base_fname, '_out-no_header'];
    
    system(sprintf(RORPO_command, ...
        [T2W_no_header_fname, '.nii.gz'], ...
        [T2W_output_no_header_fname, '.nii.gz'], ...
        [mask_no_header_fname, '.nii.gz']));
    
    PVS_likelihood = niftiread(T2W_output_no_header_fname); 
end