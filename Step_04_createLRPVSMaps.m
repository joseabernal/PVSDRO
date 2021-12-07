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

parfor iCase = 1:length(lengths)
    for rep=1:NRep
        % define input and output filenames
        input_fname = sprintf(HR_PVS_map_output_pattern, num2str(iCase), num2str(rep));
        output_fname = sprintf(LR_PVS_map_output_pattern, num2str(iCase), num2str(rep));

        info = niftiinfo(input_fname);
        info.Datatype = 'double';
        info.ImageSize = NAcq;
        info.PixelDimensions = MSSIII_res_mm;
        
        HR_Map = double(niftiread(input_fname)>0);
        
        LR_Map = resample(HR_Map, FOV_mm_True, NTrue, FOV_mm_Acq, NAcq);

        % save LR PVS map
        niftiwrite(double(LR_Map), output_fname, info, 'Compressed', 1);
    end
end