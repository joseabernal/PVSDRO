%% Read transformation matrices
% Read transformation matrices
%  
%  Inputs:
%  - trans_matrix_pattern: pattern of trans_matrices (See Config file)
%  - patient_ID: patient identification [1-205]

%  Outputs:
%   - transformation_matrices: cell array with 21 transformation matrices,
%   one for each frame
%
% (c) Jose Bernal 2021

function transformation_matrices = read_transformation_matrices(trans_matrix_pattern, patient_ID)
    trans_matrices_fname = sprintf(trans_matrix_pattern, num2str(patient_ID));
    
    transformation_matrices = load(trans_matrices_fname);
    transformation_matrices = transformation_matrices.trans_matrices;
end