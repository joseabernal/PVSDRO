%% Apply gross motion to sMRI acquisition
%  This function applies the gross motion to a given 
%  in the input sMRI acquisition.
%  
%  Inputs:
%  - SI: 3D sMRI signal
%  - trans_matrix: Transformation matrix
%  - Dim: Dimension
%
%  Outputs:
%   - SI: 3D sMRI signal
%
% (c) Jose Bernal 2021

function SI = applyGrossMotion(SI, trans_matrix, Dim)
    SI = imwarp(SI, trans_matrix, 'cubic', 'OutputView', imref3d(Dim));
end