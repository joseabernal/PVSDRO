%% Generate random transformation matrix
%  Generate random rigid transformation matrix
%
%  Inputs:
%  - theta_max: maximum rotation angle
%  - t_max: maximum translation value
%
%  Outputs:
%   - randtransmat: random transformation matrix
%
% (c) Jose Bernal 2021

function randtransmat = generateRandomTransformation(theta_max, t_max)
    thetax = deg2rad(unifrnd(-theta_max(1), theta_max(1)));
    thetay = deg2rad(unifrnd(-theta_max(2), theta_max(2)));
    thetaz = deg2rad(unifrnd(-theta_max(3), theta_max(3)));
    tx = unifrnd(-t_max(1), t_max(1));
    ty = unifrnd(-t_max(2), t_max(2));
    tz = unifrnd(-t_max(3), t_max(3));
    
    randtransmat = eye(4, 4);
    randtransmat(1:3,1:3) = eul2rotm([thetaz, thetay, thetax]);
    randtransmat(4, 1:3) = [tx, ty, tz];
    
    randtransmat = affine3d(randtransmat);
end