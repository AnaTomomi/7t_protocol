function run_fcproc(sub)

%add paths
main_path = '/projects/illinois/las/psych/cgratton/networks-pm';
addpath(sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess',main_path));
addpath(sprintf('%s/software/nifti/',main_path));
addpath(sprintf('%s/software/bids-matlab/',main_path));
addpath(sprintf('%s/software/hline_vline/',main_path));

% Change cd into repo
outputDir = sprintf('%s/7t/pilot_3t_bids/derivatives/FCPreproc-24.1.1/', main_path);
params= sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess/make_fs_masks_params_UIUC.m', main_path);
base_path= sprintf('%s/7t/pilot_bids_cups/derivatives/datalists/beforeqc/',main_path);
fmriprep = 'fmriprep-24.1.1';

% Check if sub is provided
if nargin < 1
    error('Subject ID must be provided as input.');
end

%start the preprocessing
datafile = fullfile(base_path, [sub, '_datalist_' fmriprep '.txt']);
disp(['Processing subject: ', sub]);
    
FCPROCESS_GrattonLab_old_erode_CSF(datafile,outputDir,params,'defaults2');

end