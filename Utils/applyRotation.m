%% Apply gross motion to sMRI acquisition
%  This function applies the gross motion to a given 
%  in the input sMRI acquisition.
%  
%  Inputs:
%  - SI: 3D sMRI signal
%  - theta: rotation angle
%  - dimensions: 3x1 boolean vector
%
%  Outputs:
%   - SI: 3D sMRI signal
%
% (c) Jose Bernal 2022

function SI = applyRotation(SI, theta, dimensions)
    SI = imrotate3(SI, theta, dimensions, 'crop');
end