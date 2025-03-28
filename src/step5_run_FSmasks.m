% Define the list of subjects
subs = {'1'}; %; separated

main_path = '/projects/illinois/las/psych/cgratton/networks-pm';
addpath(sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess', main_path));

% Base path for the subject files
fmriprepTopDir = sprintf('%s/7t/pilot_bids_sms/derivatives/fmriprep-24.1.1/', main_path);
params= sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess/make_fs_masks_params_UIUC.m', main_path);

% Loop through each subject and call make_fs_masks
disp('Starting processing of subjects...');
for i = 1:length(subs)
    sub = subs{i};
  
    disp(['Processing subject: ', sub]);

    make_fs_masks_erodeCSF(sub, fmriprepTopDir, params);

end
disp('Finished processing of subjects.');

