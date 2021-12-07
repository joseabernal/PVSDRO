%% Parameter file
%  This configuration file allows setting up imaging and tissue
%  characteristics.
%  
% (c) Jose Bernal 2021

%% Imaging parameters - dimensions are LR (Phase encoding), AP (Freq Encoding), SI (Slice encoding)
FOV_mm_True=[240, 240, 240]; %Acquired FoV
HRes_mm = [0.5, 0.5, 0.5];%MSS3 resolution
NTrue = floor(FOV_mm_True./HRes_mm);%number of points acquired

FOV_mm_Acq=[240, 240, 240]; %Acquired FoV
MSSIII_res_mm = [0.9375, 0.9375, 0.90];%MSS3 resolution
NAcq = floor(FOV_mm_Acq./MSSIII_res_mm);%number of points acquired

%% Experiment parameters
apply_gross_motion = 1; %flag indicating whether to apply gross motion
apply_motion_artefacts = 1; %flag indicating whether to induce motion artefacts.
apply_noise = 1; %flag indicating whether to add noise or not
low_contrast = 1; %flag indicating whether to simulate PVS of lower contrast than that in real data

% Noise extent
% We represent the signal-to-noise ratio (SNR) as the quotient
% between the mean signal value and the standard deviation of the
% background noise. The SNR=79.2249 of the real scans should be similar to that of
% our simulations, i.e. SNR_real = SNR_sim or mu_real/SD_real =
% mu_sim/SD_sim. Thus, the standard deviation of the noise in
% our simulations should be equal to (mu_sim*SD_real)/mu_real.
SDnoise = 0.9467; %Estimated noise SD 0.9467 value for MSSIII

%% Tissue parameters per class
%  1 - Background
%  2 - Cerebrospinal fluid
%  3 - Normal-appearing white matter
%  4 - White matter hyperintensity
%  5 - Recent stroke lesion
%  6 - Cortical grey matter
%  7 - Deep grey matter
%  8 - Blood vessels
%  9 - PVS
NumRegions = 9;
NAWM_class_idx = 3;
WMH_class_idx = 4;
dGM_class_idx = 7;

if ~low_contrast
    SI = [0 425 75 130 180 85 85 0 200];
else
    SI = [0 425 75 130 180 85 85 0 150];
end

%% PVS generation parameters
NRep = 1; % number of repetitions
cmedian = 251; % number of PVS per case
wstats = 2 + 0.5 * [-1, 0, 1]; % widths
% wstats = wstats * 0.75; % adjust widths for partial volumes
vstats = 13.76 + 4.85 * [-1, 0, 1]; % volumes
PVS_vol_space=[8, 8, 8]; %mm
PVS_vol_voxels=PVS_vol_space./HRes_mm;
PVS_res=[50, 50, 50];

%% PVS characteristics
% here we only consider three cases per characteristic
[volumes, widths] = meshgrid(vstats, wstats);
count = floor(cmedian);
volumes = volumes(:);
widths = widths(:);
lengths = volumes ./ widths.^2 * 6/pi;

%% Filter parameters
FRANFI_FILTER = 1;
JERMAN_FILTER = 2;
RORPO_FILTER = 3;
filter_idx = 1;

% Frangi filter parameters
options = struct('FrangiScaleRange', [0.4 0.8], 'FrangiScaleRatio', 0.2, 'FrangiAlpha', 0.5, ...
          'FrangiBeta', 0.5, 'FrangiC', 500, 'verbose',false,'BlackWhite',false);   
      
% Jerman filter parameters
tau = 0.5;
scales = 0.4:0.2:0.8;
isbrightondark = true;