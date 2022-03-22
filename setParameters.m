%% Parameter file
%  This configuration file allows setting up imaging and tissue
%  characteristics.
%  
% (c) Jose Bernal 2021

%% Reference masks
use_MIDA_ageing_mask = 1; %flag indicating whether to use the MIDA model with pathological regions

%% Imaging parameters - dimensions are LR (Phase encoding), AP (Freq Encoding), SI (Slice encoding)
FOV_mm_True=[240, 240, 240]; %Acquired FoV
HRes_mm = [0.5, 0.5, 0.5];%MSS3 resolution
NTrue = floor(FOV_mm_True./HRes_mm);%number of points acquired

FOV_mm_Acq=[240, 240, 240]; %Acquired FoV
LBC_res_mm = [1, 1, 1];%LBC resolution
NAcq = floor(FOV_mm_Acq./LBC_res_mm);%number of points acquired

%% Experiment parameters
apply_motion_artefacts = 0; %flag indicating whether to induce motion artefacts.
apply_noise = 1; %flag indicating whether to add noise or not

% Noise extent
% We represent the signal-to-noise ratio (SNR) as the quotient
% between the mean signal value and the standard deviation of the
% background noise. The SNR of the real scans should be similar to that of
% our simulations, i.e. SNR_real = SNR_sim or mu_real/SD_real =
% mu_sim/SD_sim. Thus, the standard deviation of the noise in
% our simulations should be equal to (mu_sim*SD_real)/mu_real.
SDnoise = 7.1423; % 7.1423 [IQR 5.9272    8.4299];

%% Tissue parameters per class
%  1 - Background
%  2 - Cerebrospinal fluid
%  3 - Normal-appearing white matter
%  4 - White matter hyperintensity
%  6 - Cortical grey matter
%  7 - Deep grey matter
%  8 - Blood vessels
%  9 - PVS
NumRegions = 9;
CSF_class_idx = 2;
NAWM_class_idx = 3;
WMH_class_idx = 4;
dGM_class_idx = 7;
RSL_class_idx = 5;

SI = [0 1152 395 657 0 450 395 0 547];

%% PVS generation parameters
NRep = 10; % number of repetitions
wstats = 1:1:6; % width between 0 and 3 mm
lstats = 1:1:20; % length between 0 and 10 mm
PVS_vol_space=[21, 21, 21]; %vox

%% PVS characteristics
[lengths, widths] = meshgrid(lstats, wstats);

% 1st constrain - lengths > widths
valid_options = lengths > widths & lengths ~= 0 & widths ~= 0;
lengths = lengths(valid_options);
widths = widths(valid_options);

% 2st constrain - eccentricity > 0.8
eccentricity = sqrt((lengths/2).^2 - (widths/2).^2)./(lengths/2);
valid_options = eccentricity > 0.8;
lengths = lengths(valid_options);
widths = widths(valid_options);

%% Filter parameters
FRANGI_FILTER = 1;
JERMAN_FILTER = 2;
RORPO_FILTER = 3;
filter_names = {'Frangi', 'Jerman', 'RORPO'};
filter_idx = 3;

% Frangi filter parameters
options = struct('FrangiScaleRange', [0.4 0.8], 'FrangiScaleRatio', 0.2, 'FrangiAlpha', 0.5, ...
          'FrangiBeta', 0.5, 'FrangiC', 500, 'verbose',false,'BlackWhite',false);   
      
% Jerman filter parameters
tau = 0.5;
scales = 0.4:0.2:0.8;
isbrightondark = true;