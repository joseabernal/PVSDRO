%% Register case to segmentation map
%  Register input case to segmentation map using ants
%
%  Inputs:
%  - fname: filename
%
% (c) Jose Bernal 2021

function registerCase2SegmentationMap(fname)
    % find transformation matrix
    system(['sh Software/ants/antsRegistrationSyNQuick.sh -d 3 -t r', ...
        ' -f input/LR_t2w.nii.gz', ...,
        ' -m  ', fname, '.nii.gz', ...
        ' -o ', fname, '_']);
    system(['mv ', fname, '_Warped.nii.gz ', fname, '.nii.gz'])
end