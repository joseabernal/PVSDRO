%% Summarise neighbourhood
%  Select a single voxel within a neighbourhood as center of the PVS
%  
%  Inputs:
%  - patch: 3D patch
%
%  Outputs:
%   - new_patch: 3D patch
%
% (c) Jose Bernal 2022

function new_patch = summariseNeighbourhood(patch)
    new_patch = zeros(size(patch));
    
    feasible_locations = find(patch == 1);
    
    if ~isempty(feasible_locations)
        rand_position = randi([1, length(feasible_locations)]);
        new_patch(feasible_locations(rand_position)) = 1;
    end
end