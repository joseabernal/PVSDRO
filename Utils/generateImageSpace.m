%% Compute 3D Fourier transform
%  This function computes the 3D discrete Fourier transform to an input
%  image
%  
%  Inputs:
%  - k_space: 3D resolution kspace
%
%  Outputs:
%   - SI: image space for each 3D frame
%
% (c) Jose Bernal and Michael J. Thrippleton 2019

function SI = generateImageSpace(k_space)
    SI=fftshift(fftn(ifftshift(k_space)));
end