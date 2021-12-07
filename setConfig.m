%% Configuration file
%  This configuration file allows adding all relevant folders to the
%  project.
%  
% (c) Jose Bernal 2021

maxNumCompThreads(15);

addpath('Artefacts');
addpath('Utils');

addpath(['Software', filesep, 'ants']); % Not provided
addpath(['Software' filesep, 'FrangiFilter']); % Not provided
addpath(['Software', filesep, 'JermanFilter']); % Not provided

output_folder = 'output';

% MIDA model configuration parameters
MIDA_mapping_fname = ['input', filesep, 'mapping.mat'];
MIDA_map_fname = ['input', filesep, 'MIDA_v1.0', filesep, 'MIDA_v1_voxels', filesep, 'MIDA_v1.nii.gz'];
MIDA_WMH_fname = ['input', filesep, 'Masks', filesep, 'WMH_mask.nii.gz'];
MIDA_RSL_fname = ['input', filesep, 'Masks', filesep, 'RSL_mask.nii.gz'];
MIDA_tissue_map_fname = ['input', filesep, 'HR_tissue_map'];
MIDA_tissue_map_ageing_fname = ['input', filesep, 'HR_tissue_map_ageing'];
MIDA_T2_fname = ['input', filesep, 'HR_T2w'];
MIDA_brain_mask_fname = ['input', filesep, 'HR_brainmask'];

% PVS location map configuration parameters
PVS_reference_T2_fname = ['input', filesep, 'PVSMaps', filesep, 'ref_case.nii.gz'];
PVS_location_map_fname = ['input', filesep, 'PVSMaps', filesep, 'PVSlocation.nii.gz'];
PVS_orientation_map_pattern = ['input', filesep, 'PVSMaps', filesep, 'PVSmap_%s.nii.gz'];
PVS_map_output_pattern = ['input', filesep, 'PVSMaps', filesep, 'PVSmap_%s_to_MIDA.nii.gz'];

% HR output configuration parameters
HR_PVS_map_output_pattern = ['output', filesep, 'PVS_mask_per_case', filesep, 'HR_PVS_mask_Case_%s_Rep_%s'];
LR_PVS_map_output_pattern = ['output', filesep, 'PVS_mask_per_case', filesep, 'LR_PVS_mask_Case_%s_Rep_%s'];
HR_SI_output_pattern = ['output', filesep, 'SI', filesep, 'HR_SI_Case_%s_Rep_%s'];
LR_SI_output_pattern = ['output', filesep, 'SI', filesep, 'LR_SI_Case_%s_Rep_%s'];
LR_likelihood_pattern = ['output', filesep, 'Likelihood', filesep, 'LR_likelihood_%s_Case_%s_Rep_%s'];
LR_ROI_mask_fname = ['output', filesep, 'LR_ROI_mask'];
LR_brain_mask_fname = ['output', filesep, 'LR_brainmask'];

% commands
antsRegistrationCommand = 'sh Software/ants/antsRegistrationSyNQuick.sh -n 15 -d 3 -f %s -m %s -o %s -x %s -t s';
antsApplyTransformCommand = 'antsApplyTransforms -d 3 -i %s -r %s -o %s -t %s';

% Set library path containing c++17
if strcmp(getenv('LD_LIBRARY_PATH'),'/usr/local/lib:/usr/local/lib64:/usr/lib64')==0
    setenv('LD_LIBRARY_PATH', '/usr/local/lib:/usr/local/lib64:/usr/lib64');
end

RORPO_command = '/local2/RORPO/bin/RORPO_multiscale_usage --input=%s --output=%s --scaleMin=3 --factor=1.5 --nbScales=4 --normalize --uint8 --mask=%s --core=33';