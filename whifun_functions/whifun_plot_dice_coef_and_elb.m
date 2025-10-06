function whifun_plot_dice_coef_and_elb(Dice_coefficient_folds_all,elb,K_range_l,K_range_h)
%WHIFUN_PLOT_DICE_COEF_AND_ELB Plots the Dice Coefficient and Distortion (ELBO proxy) over a range of K-values.
%
%   WHIFUN_PLOT_DICE_COEF_AND_ELB(DICE_COEFFICIENT_FOLDS_ALL, ELB, K_RANGE_L, K_RANGE_H)
%   generates a plot showing the trend of the Dice Coefficient and a proxy
%   for the Evidence Lower Bound (ELB/Distortion) across different K-values
%   (e.g., number of clusters).
%
%   Input Arguments:
%   DICE_COEFFICIENT_FOLDS_ALL - A vector containing the mean Dice Coefficients
%                                for each K-value.
%   ELB                        - A vector containing the corresponding Distortion
%                                (or ELBO proxy) values for each K-value.
%   K_RANGE_L                  - The lowest K-value used in the analysis (for x-axis limit).
%   K_RANGE_H                  - The highest K-value used in the analysis (for x-axis limit).
%
%   The function uses a dual y-axis plot:
%   - Left y-axis: Dice Coefficients (marked with '*')
%   - Right y-axis: Distortion (marked with '+')
%
%   Example:
%      % Assuming 'dice_results' and 'elb_results' are computed for K=2 to K=10
%      whifun_plot_dice_coef_and_elb(dice_results, elb_results, 2, 10);
%
%   Author: Pratik Jain

figure; % Create a new figure window
% Plot Dice Coefficients on the left y-axis
plot(Dice_coefficient_folds_all,'Marker','*','LineWidth',2)
xlim([K_range_l K_range_h]) % Set x-axis limits based on K range
xlabel('K-values') % Label the x-axis
ylabel('Dice Coefficients') % Label the left y-axis

yyaxis right % Switch to the right y-axis
% Plot Distortion (ELB) on the right y-axis
plot(elb,'Marker','+','LineWidth',2)
ylabel('Distortion') % Label the right y-axis

set(gca,'FontSize',15); % Set the font size for the current axes
end