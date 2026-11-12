%% Plot test-retest reliability of rs-FC: 3T vs 7T (same participant)
% Loads the outputs of reliability_parfor_3Tvs7T.m (one per scanner) and
% plots the mean correlation with the true half (across iterations) as a
% function of minutes of data. A dotted vertical line marks the first
% measured time point at which each scanner's mean r reaches the threshold.
% The figure is only shown, not saved.

clear all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mainpath = '/projects/illinois/las/psych/cgratton/networks-pm/';
results_path = sprintf('%s/7t/7t_protocol/results/', mainpath);
truehalf_time = 30;  % minutes, must match reliability_parfor_3Tvs7T.m
density = 0.05;      % must match reliability_parfor_3Tvs7T.m
r_threshold = 0.8;   % reliability level to mark

scanners = {'3T', '7T'};
labels   = {'3T (sub-HUBS03, TR = 1 s)', '7T (sub-01, TR = 2 s)'};
colors   = {[42 120 214]/255, [235 104 52]/255};  % blue, orange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Color', 'w'); hold on

for s = 1:numel(scanners)
    fname = sprintf('%sreliability_truehalf%dmin_%s_d%s.mat', results_path, ...
        truehalf_time, scanners{s}, num2str(density));
    res = load(fname, 'times_all', 'allsubs_fc');

    times = res.times_all{1};               % minutes of data added
    r_all = cell2mat(res.allsubs_fc{1});    % iterations x time points
    r_mean = mean(r_all, 1);

    % first measured time point where mean r >= threshold
    idx = find(r_mean >= r_threshold, 1, 'first');
    if isempty(idx)
        leg_txt = sprintf('%s: r < %.1f at %g min', labels{s}, r_threshold, times(end));
    else
        leg_txt = sprintf('%s: r \\geq %.1f at %g min', labels{s}, r_threshold, times(idx));
        xline(times(idx), ':', sprintf('%g min', times(idx)), ...
            'Color', colors{s}, 'LineWidth', 1.5, ...
            'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
    end

    plot(times, r_mean, '-', 'Color', colors{s}, 'LineWidth', 2, 'DisplayName', leg_txt);
end

xlabel('Time (min)')
ylabel(sprintf('Correlation with %d-min true half (r)', truehalf_time))
title(sprintf('rs-FC reliability: 3T vs 7T (density = %s)', num2str(density)))
ylim([0 1])
legend('Location', 'southeast', 'Box', 'off')
grid on
set(gca, 'GridColor', [0.85 0.85 0.85], 'GridAlpha', 1, 'Box', 'off', ...
    'TickDir', 'out', 'FontSize', 12)
hold off
