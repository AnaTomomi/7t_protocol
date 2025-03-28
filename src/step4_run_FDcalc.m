%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the list of subjects
subs = {'1';};

software_path = '/projects/illinois/las/psych/cgratton/networks-pm/software';

addpath(sprintf('%s/GrattonLab-General-Repo-master/motion_calc_utilities', software_path));
addpath(sprintf('%s/bids-matlab', software_path));

% Base path for the subject files
base_path = '/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_sms/derivatives/datalists/beforeqc/';

%which version of fmriprep are you using?
fmriprep = 'fmriprep-24.1.1';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through each subject and call FDcalc_FMRIPREP_2020
disp('Starting processing of subjects...');
for i = 1:length(subs)
    sub = subs{i};
    subject_file = fullfile(base_path, [sub, '_datalist_' fmriprep '.txt']);
    disp(['Processing subject: ', sub]);
    FDcalc_FMRIPREP(subject_file);
end
disp('Finished processing of subjects.');

