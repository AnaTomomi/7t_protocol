function run_fdcalc(sub)

restoredefaultpath;  % Reset to default MATLAB path
rehash toolbox;      % Refresh the function cache

%Define and add paths
software_path = '/projects/illinois/las/psych/cgratton/networks-pm/software';
addpath(sprintf('%s/GrattonLab-General-Repo-master/motion_calc_utilities', software_path));
addpath(sprintf('%s/bids-matlab', software_path));

base_path = '/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_sms/derivatives/datalists/beforeqc/';
fmriprep = 'fmriprep-24.1.1'; %which version of fmriprep are you using?

% Check if sub is provided
if nargin < 1
    error('Subject ID must be provided as input.');
end

%run FD calc
datalist = fullfile(base_path, [sub, '_datalist_' fmriprep '.txt']);
if ~isfile(datalist)
    error('Error: Subject file does not exist: %s', datalist);
end
FDcalc_FMRIPREP(datalist);

end