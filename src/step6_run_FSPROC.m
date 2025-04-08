
% Define the list of subjects
subs = {'1'};

main_path = '/projects/illinois/las/psych/cgratton/networks-pm';
addpath(sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess',main_path));
addpath(sprintf('%s/software/nifti/',main_path));

% Change cd into repo
fcprocDir = sprintf('%s/7t/pilot_bids_sms/derivatives/FCPreproc-24.1.1/', main_path);
params= sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess/make_fs_masks_params_UIUC.m', main_path);
base_path= sprintf('%s/7t/pilot_bids_sms/derivatives/datalists/beforeqc/',main_path);
fmriprep = 'fmriprep-24.1.1';

% Loop through each subject and call FDcalc_FMRIPREP_2020
disp('Starting processing of subjects...');
for i = 1:length(subs)
    sub = subs{i};
    subject_file = fullfile(base_path, [sub, '_datalist_' fmriprep '.txt']);
    disp(['Processing subject: ', sub]);
    FCPROCESS_GrattonLab_old_erode_CSF(subject_file,fcprocDir,params,'defaults2');
end
disp('Finished processing of subjects.');

