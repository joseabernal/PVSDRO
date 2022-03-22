%% Downsampling PVS maps
%  This script downsamples HR maps for simulation
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

for iCase = 1:length(lengths)
    parfor rep=1:NRep
        % define input and output filenames
        input_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(LR_PVS_map_output_pattern, num2str(iCase), num2str(rep), num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));

        info = niftiinfo(input_fname);
        info.Datatype = 'uint8';
        info.ImageSize = NAcq;
        info.PixelDimensions = LBC_res_mm;

        HR_Map = bwdist(niftiread(input_fname)==0);

        LR_Map = generateLRData(...
            HR_Map, FOV_mm_True, NTrue, SDnoise, FOV_mm_Acq, NAcq, 0, 0);

        % save LR PVS map
        niftiwrite(uint8(LR_Map>0.5), output_fname, info, 'Compressed', 1);
    end
end