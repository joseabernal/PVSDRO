%% Create HR SI maps
%  This script creates HR SI maps for simulation
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

% loading images
info = niftiinfo(MIDA_tissue_map_fname);
tissue_map = niftiread(MIDA_tissue_map_fname);

% define ROI: dGM, NAWM, WMH
included_roi = (tissue_map == NAWM_class_idx | tissue_map == dGM_class_idx | tissue_map == WMH_class_idx);

info.Datatype = 'int16';

parfor iCase = 1:length(lengths)
    for rep=1:NRep
        % set input and output filenames
        input_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(HR_SI_output_pattern, num2str(iCase), num2str(rep));

        PVS_map = niftiread(input_fname);
        PVS_map = PVS_map > 0;
        
        HR_SI = SI(tissue_map) .* (1-PVS_map) + SI(NumRegions) .* PVS_map;

        % save HR SI
        niftiwrite(int16(HR_SI), output_fname, info, 'Compressed', 1);
    end
end