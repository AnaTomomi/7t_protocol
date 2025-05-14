function run_makefsmasks(sub)

main_path = '/projects/illinois/las/psych/cgratton/networks-pm';
addpath(sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess', main_path));
addpath(sprintf('%s/software/nifti/',main_path));

% Check if sub is provided
if nargin < 1 || isempty(sub)
    error('Error: Subject ID must be provided as input.');
end

% Base path for the subject files
fmriprepTopDir = sprintf('%s/7t/pilot_bids_sms/derivatives/fmriprep-24.1.1/', main_path);
params= sprintf('%s/software/GrattonLab-General-Repo-master/FCProcess/make_fs_masks_params_UIUC.m', main_path);

% Check if params file exists
if ~isfile(params)
    error('Error: Parameters file not found - %s', params);
end

% Run processing function
try
    make_fs_masks_erodeCSF(sub, fmriprepTopDir, params);
    disp(['Finished processing for subject: ', sub]);
catch ME
    disp(['Error processing subject ', sub, ': ', ME.message]);
end

end

