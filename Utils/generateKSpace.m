%% Compute 3D inverse Fourier transform
%  This function computes the 3D inverse discrete Fourier transform of an
%  input image
%  
%  Inputs:
%  - SI: 3D resolution scan
%
%  Outputs:
%   - HR_k_space: k-space for each 3D frame
%
% (c) Jose Bernal and Michael J. Thrippleton 2019

function k_space = generateKSpace(SI)
    k_space=fftshift(ifftn(ifftshift(SI)));
end