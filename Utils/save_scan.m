%% Save 3D and 4D scans
%  This function saves all input scans.
%
%  Inputs:
%  - scans: a cell containing all scans
%  - filenames: a cell containing all filenames
%  - dim: dimension of the scans
%  - output_folder: folder where all scans are stored
%  - Res_mm: voxel resolution in millimeters
%
%  Outputs:
%   - finished_successfully: boolean indicating whether the execution was
%                            successful
%
% (c) Jose Bernal and Michael J. Thrippleton 2019

function finished_successfully = save_scan(scans, filenames, dim, output_folder, Res_mm)
    try
        info.fname=[output_folder '/output'];
        info.dim=dim;
        info.dt=[16 0];
        info.mat=[Res_mm(1) 0 0 0; 0 Res_mm(2) 0 0;0 0 Res_mm(3) 0; 0 0 0 1];
        dataToWrite = scans;
        NFiles=size(dataToWrite, 2);
        for iFile=1:NFiles
            SPMWrite4D(info, dataToWrite{iFile}, output_folder, filenames{iFile}, 16);
        end

        finished_successfully = true;
    catch 
        warning('Problem saving image');
        finished_successfully = false;
    end
end