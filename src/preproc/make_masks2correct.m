main_path = '/projects/illinois/las/psych/cgratton/';
addpath(sprintf('%s/networks-pm/software/nifti/',main_path));

%% Load the canonical 1 mm template just to steal its header
template = sprintf('%s/Atlases/templateflow/tpl-MNI152NLin6Asym/tpl-MNI152NLin6Asym_res-01_T1w.nii.gz',main_path);
nii = load_untouch_nii(template);
volSize  = nii.hdr.dime.dim(2:4);

%% Create three masks full of 0s
brainstem  = ones(volSize);
ventricles = zeros(volSize);

% ---------- 1) Brainstem ----------
brainstem(56:129, 81:161, 1:103) = 0;

nii.img = brainstem;
save_untouch_nii(nii, sprintf('%s/networks-pm/masks/brainstem_res-1_mask.nii',main_path));

% ---------- 2) Ventricles ----------
ventricles(58:126, 71:161, 1:111) = 1;

nii.img = ventricles;
save_untouch_nii(nii, sprintf('%s/networks-pm/masks/ventricles_res-1_mask.nii',main_path));
