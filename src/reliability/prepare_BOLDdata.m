%% organize data
% This script concatenates the BOLD data and computes the ROI-averaged time
% series. 
%
% User inputs:
% - subject_list: csv file with list of subjects with good data (specified per run)
% - atlas: name of the atlas to use for computing the averaged ROI-ts
% - FCdir: path to where the preprocessed data in volumetric is
% - savepath: where all the concatenated parts will go


clear all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main_path = '/projects/illinois/las/psych/cgratton';
atlas = 'Seitzman300-res1';
sequence = 'SMS_OG';
FCdir = [main_path '/networks-pm/7t/pilots/' sequence '/derivatives/FCPreproc-24.1.1'];
fmriprepdir = [main_path '/networks-pm/7t/pilots/' sequence '/derivatives/fmriprep-24.1.1'];
atlas_dir = sprintf('%s/networks-pm/Atlases',main_path); %Where are the atlases?
savepath = '/projects/illinois/las/psych/cgratton/networks-pm/7t/7t_protocol/data/ROIts';
TR = 1.945;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1: add all toolboxes needed
addpath(genpath(sprintf('%s/networks-pm/software/nifti', main_path))); % Where is the nifti-read toolbox?
addpath(genpath(sprintf('%s/networks-pm/software/bids-matlab', main_path))); % Where is the bids-matlab toolbox?
addpath(genpath(sprintf('%s/networks-pm/software/hline_vline', main_path))); % Where is the hline_vline toolbox?
addpath(genpath(sprintf('%s/networks-pm/software/GrattonLab-General-Repo', main_path))); % Where is the General-Lab Repo toolbox?

% Step 2: prepare all info and paths
atlas_params = atlas_parameters_GrattonLab(atlas,atlas_dir);
roi_data = load_nii_wrapper(atlas_params.MNI_nii_file); %vox by 1

subj = {'sub-1'};

for i = 1:numel(subj)
    thisSub = subj{i};
    thisSub_runs = dir(fullfile(FCdir, thisSub, '**', '*zmdt.nii.gz'));
    
    roi_timeseries_concat = [];
    tmask_concat = [];

    for j = 1:size(thisSub_runs,1) %read each file for this suject
        file_data = load_nii_wrapper(fullfile(thisSub_runs(j).folder, thisSub_runs(j).name)); 
        file_roi_timeseries{j} = roi_average_timecourse(file_data,roi_data);
        roi_timeseries_concat = [roi_timeseries_concat file_roi_timeseries{j}];

        [f1, ~, ~] = fileparts(thisSub_runs(j).folder);
        [~, f1, ~] = fileparts(f1);
        f2 = split(thisSub_runs(j).name, '_');
    
        % tmask file:
        tmask{j} = table2array(readtable([fmriprepdir '/' thisSub '/' f1 '/func/FD_outputs/' thisSub '_' f1 '_task-rest_' f2{4} '_desc-tmask_fFD.txt']));
        tmask_concat = [tmask_concat; tmask{j}];
    end

    save(sprintf('%s/%s_%s_%s_avgROIts', savepath,thisSub,sequence,atlas), 'roi_timeseries_concat', 'tmask_concat');
    fprintf('%s: %s \n', thisSub, num2str((sum(tmask_concat)*TR)/60))

end

% Functions needed 
function roi_ts_avg = roi_average_timecourse(bold_data,roi_data)

nrois = unique(roi_data);
nrois = nrois(nrois>0); % assume 0 is not an ROI

for nr = 1:length(nrois)
    roi_vox = bold_data(roi_data==nrois(nr),:);
    roi_ts_avg(nr,:) = nanmean(roi_vox,1);
    num_nans = sum(isnan(roi_vox(:)));
    if num_nans>0
        warning(sprintf('ROI %03d contains nans',nrois));
    end
end

end

function [r p] = paircorr_mod(a,b)
%PAIRCORR Computes pairwise Pearson's linear correlation coefficient with
% optional significance. Returns r, a p1-by-p2 matrix containing the
% pairwise correlation coefficient between each pair of columns in the
% n-by-p1 and n-by-p2 matrices a and b. r is calculated as the dot
% product between two vectors divided by the product of their magnitudes.
% If a second output argument is provided, like so:
% [r p] = paircorr(a,b)
% then p is the two-tailed significance.
% TOL 03/01/11.
% Added single input functionality TOL, 04/01/12.

if nargin<2
    b = a;
end

a = bsxfun(@minus, a, mean(a));
b = bsxfun(@minus, b, mean(b));

mag_a = sqrt(sum(a.^2, 1));
mag_b = sqrt(sum(b.^2, 1));

r = (a' * b) ./ (mag_a' * mag_b);

if nargout > 1
    [n p1] = size(a);
    
    % calculate t-statistic
    t = r ./ sqrt((1 - r.^2)/(n - 2));
    % calculate significance, two-tailed
    p = 2 * tcdf(-abs(t), n - 2);
end
end