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
LR_ROI_mask_output_fname = sprintf(LR_ROI_mask_fname, num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));
ROI = niftiread(LR_ROI_mask_output_fname) == 1;
% ROI = bwdist(~ROI)>=2;

figure;
hold on;
xlabel('Recall')
ylabel('Precision')
xlim([0, 1])
ylim([0, 1])

rep=1;
for filter_idx = [FRANGI_FILTER, JERMAN_FILTER, RORPO_FILTER]
    sensitivity_values = cell(length(lengths), NRep);
    precision_values = cell(length(lengths), NRep);
    auc_values = nan(length(lengths), NRep);
    for iCase = 1:length(lengths)
        parfor rep=1:NRep
            % load signal and ground truth
            SI_fname = sprintf(LR_SI_output_pattern, num2str(iCase), num2str(rep), num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));
            GT_fname = sprintf(LR_PVS_map_output_pattern, num2str(iCase), num2str(rep), num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));
            LR_likelihood_fname = sprintf(LR_likelihood_pattern, filter_names{filter_idx}, num2str(iCase), num2str(rep), num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3)));

            GT = niftiread(GT_fname);

            if sum(GT(ROI) == 1) == 0
                continue
            end

            if ~exist([LR_likelihood_fname, '.nii.gz'], 'file')
                info = niftiinfo(SI_fname);
                SI = double(niftiread(SI_fname));    

                % run filters
                switch filter_idx
                    case FRANGI_FILTER
                        PVS_likelihood = FrangiFilter3D(SI, LBC_res_mm, options);
                    case JERMAN_FILTER
                        PVS_likelihood = vesselness3D(SI, scales, LBC_res_mm, tau, isbrightondark);
                    case RORPO_FILTER
                        PVS_likelihood = RORPO_wrapper(SI, ROI, SI_fname, RORPO_command);
                end

                % mask segmentations outside of the region of interest
                PVS_likelihood = double(PVS_likelihood);
                PVS_likelihood = PVS_likelihood .* double(ROI);

                info.Datatype = 'double';
                niftiwrite(PVS_likelihood, LR_likelihood_fname, info, 'Compressed', 1);
            else
                PVS_likelihood = niftiread(LR_likelihood_fname);
            end
            
            [X, Y, T] = perfcurve(GT(ROI), PVS_likelihood(ROI), 1, 'XCrit', 'reca', 'YCrit', 'prec');
            Y(isnan(Y)) = 1;

            sensitivity_values{iCase, rep} = X;
            precision_values{iCase, rep} = Y;
            auc_values(iCase, rep) = trapz(X, Y);

            plot(sensitivity_values{iCase, rep}, precision_values{iCase, rep})
            display([iCase, lengths(iCase), widths(iCase), auc_values(iCase, rep)])
            drawnow;
        end
    end
    hold off;

    save(sprintf(performance_fname, filter_names{filter_idx}, num2str(LBC_res_mm(1)), num2str(LBC_res_mm(2)), num2str(LBC_res_mm(3))), ...
        'sensitivity_values', 'precision_values', 'auc_values');
end