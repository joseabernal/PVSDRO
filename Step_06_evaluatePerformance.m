%% Analyse performance of segmentation filter
% This script examines precision and recall of PVS segmentation filters.
% The filter is indicated with the parameter "filter_idx" (See
% setParameters.m file). 
%
% (c) Jose Bernal 2021

clc;
clear all;
close all;

% set configuration (paths)
setConfig;

% set parameters
setParameters;

% load brain and ROI masks
tissue_map = niftiread(LR_brain_mask_fname);
tissue_map = bwdist(~tissue_map)>2;

ROI = niftiread(LR_ROI_mask_fname);
ROI = ROI > 0.95;

sensitivity_values = nan(9, 103);
specificity_values = nan(9, 103);
precision_values = nan(9, 103);
for iCase = 1:length(lengths)
    GT_list = zeros([numel(ROI), NRep]);
    likelihood_list = zeros([numel(ROI), NRep]);
    for rep=1:NRep
        % load signal and ground truth
        SI_fname = sprintf(LR_SI_output_pattern, num2str(iCase), num2str(rep));
        GT_fname = sprintf(LR_PVS_map_output_pattern, num2str(iCase), num2str(rep));
        
        info = niftiinfo(SI_fname);
        SI = double(niftiread(SI_fname));
        GT = niftiread(GT_fname);
        GT = GT >= 0.5;
        GT = GT .* tissue_map;
        
        % run filters
        if filter_idx == FRANFI_FILTER
            PVS_likelihood = FrangiFilter3D(SI, MSSIII_res_mm, options);
        end
        
        if filter_idx == JERMAN_FILTER
            PVS_likelihood = vesselness3D(SI, scales, MSSIII_res_mm, tau, isbrightondark);
        end
        
        if filter_idx == RORPO_FILTER
            PVS_likelihood = RORPO_wrapper(SI, ROI.*tissue_map, SI_fname, RORPO_command);
        end
        
        % mask segmentations outside of the region of interest
        PVS_likelihood = PVS_likelihood .* ROI;
        PVS_likelihood = PVS_likelihood .* tissue_map;
        
        GT_list(:, rep) = GT(:);
        likelihood_list(:, rep) = PVS_likelihood(:);
    end
    
    GT_list = GT_list(ROI, :);
    likelihood_list = likelihood_list(ROI, :);
    
    threshold_list = [-Inf, 10.^(prctile(log10(likelihood_list(likelihood_list>0)), 0:100)), 1];
    
    % compute sensitivity, specificity, precision for multiple thresholds
    parfor iThreshold=1:length(threshold_list)
        display(iThreshold)
        seg = likelihood_list > threshold_list(iThreshold);
        
        tp = sum(GT_list & seg, 1);
        fn = sum(GT_list & ~seg, 1);
        fp = sum(~GT_list & seg, 1);
        tn = sum(~(GT_list | seg), 1);
        
        sensitivity = tp ./ (tp+fn);
        specificity = tn ./ (tn+fp);
        precision = tp ./ (tp+fp);
        
        sensitivity_values(iCase, iThreshold) = mean(sensitivity);
        specificity_values(iCase, iThreshold) = mean(specificity);
        precision_values(iCase, iThreshold) = mean(precision);
    end
end

%% Plot receiver-operating and precision-recall curves
colours = distinguishable_colors(length(lengths));

figure;
hold on;
xlabel('1-Specificity')
ylabel('Sensitivity')
plot([0, 1], [0, 1], 'Color', [17 17 17]/255)
for iOpt=1:length(lengths)
    plot(1-specificity_values(iOpt, :), sensitivity_values(iOpt, :), 'Color', colours(iOpt, :))
end
hold off;

figure;
hold on;
xlabel('Recall')
ylabel('Precision')
for iOpt=1:length(lengths)
    tmp = precision_values(iOpt, :);
    tmp(isnan(tmp)) = 1;
    plot(sensitivity_values(iOpt, :), tmp, 'Color', colours(iOpt, :))
    display([iOpt, lengths(iOpt), widths(iOpt), trapz(tmp, sensitivity_values(iOpt, :))])
end
hold off;

tmp = precision_values;
tmp(isnan(tmp)) = 1;
summary.sensitivity = sensitivity_values;
summary.precision = tmp;
summary.specificity = specificity_values;