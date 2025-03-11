% Define the list of subjects
subs = {'01';};

addpath '/projects/illinois/las/psych/cgratton/networks-pm/software/GrattonLab-General-Repo-master/motion_calc_utilities';
addpath '/projects/illinois/las/psych/cgratton/networks-pm/software/bids-matlab'

% Base path for the subject files
base_path = '/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_cups/derivatives/datalists/beforeqc/';

% Loop through each subject and call FDcalc_FMRIPREP_2020
disp('Starting processing of subjects...');
for i = 1:length(subs)
    sub = subs{i};
    subject_file = fullfile(base_path, [sub, '_datalist_fmriprep-24.1.1.txt']);
    disp(['Processing subject: ', sub]);
    FDcalc_FMRIPREP_2024(subject_file);
end
disp('Finished processing of subjects.');

