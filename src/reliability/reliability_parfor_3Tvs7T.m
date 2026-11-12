function reliability_parfor_3Tvs7T()
%% Test-Retest Reliability of rs-FC  —  PARFOR VERSION, 3T vs 7T
%
% Copy of reliability_parfor.m. The only changes are:
%   - a scanner switch ('7T' / '3T') in the USER INPUTS block that selects
%     subject, atlas, and TR
%   - the input file is found by <subject>_<scanner>_<atlas>_avgROIts
%     (matches prepare_BOLDdata_3Tvs7T.m)
%   - the output is saved as
%     reliability_truehalf<truehalf_time>min_<scanner>_d<density>.mat
% The reliability logic below is unchanged.
%
% Run once with scanner = '7T' and once with scanner = '3T'.
%
% Changes vs. original (functionality is IDENTICAL):
%
%  1. Two arrays of random starting indices (count_starts, set_starts) are
%     pre-generated BEFORE the parfor loop with a fixed seed so that:
%       (a) every parfor worker receives deterministic inputs,
%       (b) the serial and parallel versions can be compared exactly in tests.
%
%  2. parfor replaces the inner  for p = 1:iterations  loop.
%     - All variables that were indexed as {p, sub} or {p, t} inside the
%       original loop are now PURELY LOCAL temporaries within each worker.
%       This eliminates every transparency violation.
%     - Results are collected in single-indexed cell arrays  out_*{p}
%       (each cell holds a 1-x-n_times row of results for that iteration).
%     - After parfor, a short reconstruction loop rebuilds the original
%       two-dimensional  sub_*_corr{p,j}  layout, so the code that follows
%       (allsubs_* assignment, save, plotting) is 100% unchanged.
%
%  3. The  times  variable does not need to be stored per-iteration because
%     it is constant (see comment below).  times_all{sub} is set once after
%     parfor from any worker's result.
%

mainpath = '/projects/illinois/las/psych/cgratton/networks-pm/';

addpath(genpath(sprintf('%s/software/GrattonLab-General-Repo/', mainpath)))
addpath(genpath(sprintf('%s/software/BrainConn_Toolbox/', mainpath)))
addpath(genpath(sprintf('%s/7t/7t_protocol/', mainpath)))

%%%%%%%%%%%%%%%%%%%%%%%%%%% USER INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_path = sprintf('%s/7t/7t_protocol/data/ROIts/', mainpath);
savepath = sprintf('%s/7t/7t_protocol/results/', mainpath);
atlas_dir = '/projects/illinois/las/psych/cgratton/Atlases/';
truehalf_time = 30;   % minutes for "true half"
step_time = 2;  % minutes added per step
iterations = 100; % bootstrap iterations
density = 0.05;
scanner = '7T';   % '7T' or '3T'

switch scanner
    case '7T'
        subject = {'sub-01'}; % Who to include?
        atlas = 'Seitzman300-res1';
        TR = 2;  % fMRI TR in seconds
    case '3T'
        subject = {'sub-HUBS03'}; % Who to include?
        atlas = 'Seitzman300-res2';
        TR = 1;  % fMRI TR in seconds
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Derived constants (same as original)
truehalf_datapts = round((60 * truehalf_time) / TR);
step_datapts = round((60 * step_time) / TR);

% Load atlas and colours (same as original)
atlas_params = atlas_parameters_GrattonLab(atlas, atlas_dir);

% Pre-allocate allsubs_* containers (same as original)
[allsubs_fc] = deal(cell(1, length(subject)));

for sub = 1:numel(subject)
    
    % Load and mask data (same as original)
    FC_fname = fullfile(data_path, dir(fullfile(data_path, [subject{sub} '_' scanner '_' atlas '_avgROIts*'])).name);
    load(FC_fname)
    cat_data = roi_timeseries_concat(:, logical(tmask_concat));
    total_datapts = size(cat_data, 2);

    fprintf('Begin Processing for subject %s : Total sample points = %d...\n', subject{sub}, total_datapts)
    clear tmask_concat roi_timeseries_concat

    % Build index table (same as original) 
    num_sets = floor(total_datapts / step_datapts); % how many steps can we fit into this subject's data?
    indices = 1 : num_sets * step_datapts;
    indices_for_data = reshape(indices, step_datapts, num_sets)';
    clear indices

    % PRE-GENERATE random starting points for all iterations 
    % Using a fixed seed makes the run reproducible and lets the
    % test script compare serial vs. parfor results exactly.
    rng(42, 'twister');
    count_starts = datasample(1:num_sets, iterations, 'Replace', true);
    set_starts = datasample(1:num_sets, iterations, 'Replace', true);

    % Pre-allocate parfor OUTPUT containers (indexed by {p} only)
    % Each cell will hold a  1 x n_times  row of per-time-step results.
    [out_fc_corr, out_times] = deal(cell(iterations, 1));

    % Broadcast-variable copies (parfor workers receive read-only copies)
    % Naming them separately avoids any risk of MATLAB misclassifying them.
    bcast_cat_data = cat_data;         
    bcast_indices = indices_for_data;
    bcast_num_sets = num_sets;
    bcast_truehalf_pts = truehalf_datapts;
    bcast_step_time = step_time;
    bcast_atlas = atlas_params;

    fprintf('starting iterations \n');

    % Init parfor to speed things up
    parfor p = 1:iterations
    %  Every variable created inside this block is a LOCAL TEMPORARY
    %  on the worker.  The only assignments to "outer" variables use
    %  single-index slicing  out_*{p}  which MATLAB classifies as
    %  valid SLICED OUTPUT variables — no transparency violation.

        % TRUE HALF sampling
        count = count_starts(p);   % pre-generated, no datasample()
        th_inds = [];
        n_th_sets = 0;

        while length(th_inds) < bcast_truehalf_pts
            if count > bcast_num_sets
                count = 1;
            end
            th_inds = [th_inds; bcast_indices(count, :)']; 
            count = count + 1;
            n_th_sets = n_th_sets + 1;
        end

        % Corrmat + graph metrics for true half 
        truehalf = bcast_cat_data(:, th_inds);
        corrmat_th = paircorr_mod(truehalf');
        [A_th, Ab_th] = prep_matrix(corrmat_th, density, 'proportional');

        th_fc = A_th(triu(true(size(A_th)),1));

        % Build rest-of-data index table 
        rest_data = bcast_cat_data;
        rest_data(:, th_inds) = [];

        idx_rest = bcast_indices;
        idx_rest(end - (n_th_sets - 1) : end, :) = [];   % drop used sets
        times_local = bcast_step_time : bcast_step_time : size(idx_rest, 1) * bcast_step_time;
        n_times = numel(times_local);

        % Local result containers for this iteration 
        [loc_fc_corr] = deal(cell(1, n_times));

        % Subsample loop (same logic as original inner for-t loop)
        inds_chunk = [];
        set = set_starts(p);    % pre-generated, no datasample()

        for t = 1:n_times 
            if set > size(idx_rest, 1)
                set = 1; %come back to the first index (circular fashion)
            end
            inds_chunk = [inds_chunk; idx_rest(set, :)']; 
            sampled_data = rest_data(:, inds_chunk);
            corrmat_s = paircorr_mod(sampled_data');
            [A_s, Ab_s] = prep_matrix(corrmat_s, density, 'proportional');

            s_fc = A_s(triu(true(size(A_s)),1));

            set = set + 1;

            % Correlations / differences (same formulas as original)
            loc_fc_corr{t} = corr(th_fc, s_fc);
        end

        % Collect results into single-indexed outputs
        out_fc_corr{p} = loc_fc_corr;
        out_times{p} = times_local;
    end  % parfor p

    fprintf('\n');

    % Reconstruct 2-D cell arrays matching original {p, j} layout times 
    % is constant across iterations (n_th_sets is always the same
    % because ceil(truehalf_datapts / step_datapts) is fixed), so we read 
    % n_times from the first worker's output.

    n_times = numel(out_times{1});

    [sub_fc_corr] = deal(cell(iterations, n_times));

    for p = 1:iterations
        nt = numel(out_times{p});
        for j = 1:nt
            sub_fc_corr{p,j} = out_fc_corr{p}{j};
        end
    end

    % Store times (same as original)
    times_all{sub} = out_times{1}; % constant across iterations

    % Assign to allsubs_* (IDENTICAL to original)
    allsubs_fc{sub} = sub_fc_corr;

    clear cat_data num_sets indices_for_data out_fc_corr out_times

    fprintf('Finished Processing for sub-%s\n', subject{sub})
end

% Save (IDENTICAL to original) 
save([savepath 'reliability_truehalf' num2str(truehalf_time) 'min_' scanner '_d' num2str(density) '.mat'], ...
    'times_all', 'allsubs_fc', '-v7.3')
end