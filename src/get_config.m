function cfg = get_config(sub)

% This is the config file, it has all the paths and variables needed to run
% the GrattonLab pipeline. 
% Modify this file when starting a project and check the paths.
%
% Inputs: 
%       - sub: (str), subject number
%
% Outputs: struc

cfg = {}; %initialize empty structure

%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL CONFIG        %
%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.labDir = '/projects/illinois/las/psych/cgratton'; %Lab Folder
cfg.projectDir = sprintf('%s/networks-pm/7t/pilots/SMS_OG', cfg.labDir); % Where is the dataset main folder?
cfg.derivsDir = sprintf('%s/networks-pm/7t/pilots/SMS_OG/derivatives', cfg.labDir); % Where are the derivatives stored?
cfg.fmriprep = 'fmriprep-24.1.1'; %What version of fmriprep are you using? It must match with the name of the folder where the fmriprep outputs were stored

cfg.TR = 1.945;

%%%%%%%%%%%%%%%%%%%%%%%%%
% TOOLBOX SET UP        %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.preproc_path = sprintf('%s/networks-pm/software/GrattonLab-General-Repo', cfg.labDir); % Where is the Gratton pipeline code?
cfg.niftiread_toolbox = sprintf('%s/networks-pm/software/nifti',cfg.labDir); % Where is the nifti-read toolbox?
cfg.bids_toolbox = sprintf('%s/networks-pm/software/bids-matlab', cfg.labDir); % Where is the bids-matlab toolbox?
cfg.hline_vline = sprintf('%s/networks-pm/software/hline_vline', cfg.labDir); % Where is the hline_vline toolbox?

cfg.singularity_cmd_start = ''; %previously in cfg
cfg.afni_sif = [cfg.labDir '/singularity_images/afni_make_build_latest.sif']; %previously in cfg
cfg.templateflow_dir = [cfg.labDir '/Atlases/templateflow/']; %previously in cfg
cfg.fsl_cmd_start = ''; %previously in cfg
cfg.ants_sif = [cfg.labDir '/singularity_images/ants_v2.4.0.sif']; %previously in cfg
cfg.surface_scripts = sprintf('%s/SurfacePipeline', cfg.preproc_path); %where are the executables for preprocessing fsavg2fslr? If you downloaded this git, this should be already ok

cfg.ants_dir = fullfile(cfg.labDir, 'Scripts' , 'antsbin' , 'ANTS-build' , 'Examples');
cfg.workbench_dir = fullfile(cfg.labDir, 'Scripts', 'workbench2', 'bin_linux64');
cfg.workbench_cmd = fullfile(cfg.workbench_dir, 'wb_command');
cfg.Caret5_Command = fullfile(cfg.labDir, 'Scripts', 'caret', 'bin_linux64');
cfg.c3d_dir = fullfile(cfg.labDir, 'Scripts', 'c3d-1.0.0-Linux-x86_64', 'bin');
cfg.wb_dir = fullfile(cfg.labDir, 'Scripts', 'workbench_new', 'workbench' , 'bin_linux64');
cfg.fs_bin_dir = sprintf('%s/Scripts/freesurfer/bin', cfg.labDir);
cfg.scripts_dir = fullfile(cfg.labDir, 'Scripts');

%%%%%%%%%%%%%%%%%%%%%%%%%
% MOTION CALC - FDCalc.m%
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.contig_frames = 5; % Number of continuous samples w/o high FD necessary for inclusion
cfg.headSize = 50; % assume 50 mm head radius
cfg.FDthresh = 0.2;
cfg.fFDthresh = 0.1;
cfg.run_min = 50; % minimum number of frames in a run

%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_FS_MASKS         %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.fmriprepTopDir = sprintf('%s/%s/', cfg.derivsDir, cfg.fmriprep);
cfg.space = 'MNI152NLin6Asym';
cfg.voxdim = '1'; % voxel size
cfg.GMprobseg_thresh = 0.5; % threshold for the gray matter
cfg.eroiterwm = 2; % number of erosions to perform for WM
cfg.WMprobseg_thresh = 0.9;
cfg.eroitercsf = 1; % number of erosions to perform for CSF
cfg.CSFprobseg_thresh = 0.9;
cfg.include_brainstem_ventricles_masks = 1; %toggle to include custom rectangular masks to be multiplied with the fmriprep masks
cfg.maskDir = sprintf('%s/networks-pm/masks', cfg.labDir); %

%%%%%%%%%%%%%%%%%%%%%%%%%
% FC PROCESS            %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.outputDir = sprintf('%s/FCPreproc-24.1.1', cfg.derivsDir); % Where the denoised files will be stored?
cfg.tmasktype = 'regular'; %'ones' or something else (ones = take everything except short periods at the start of each scan
cfg.space = 'MNI152NLin6Asym'; %template in use
cfg.res = sprintf('res-%s',cfg.voxdim); %'','res-2' or 'res-3' (voxel resolutions for output), res-1=1mm, res-2=2mm, res-3=0.5mm
cfg.GMthresh = 0.5; %used for nuis regressors. Check that these (esp WM/CSF look ok; GM mostly used for grayplot)
cfg.WMthresh = 0.9; %thresholded prior to FCprocess (make_fs_masks script), but keeping for QC variable
cfg.CSFthresh = 0.9;  %thresholded prior to FCprocess (make_fs_masks script), but keeping for QC variable (copied by JC because I'm using this output)
cfg.WMerode = '1'; %how many erosions did the WM mask go through?
cfg.CSFerode = '1'; %how many erosions did the CSF mask go through?
cfg.denoise_switches = 'defaults2'; %what denoising options will you apply? 'defaults2' will get the GL's usual ones (see Gratton's papers)
cfg.QCmat = 1; %toggle. Set to 1 to save the QCmat file to inspect denoising options
cfg.dropFr = 5; % number of frames to drop at the beginning
cfg.FDtype = 'fFD'; %Which motion to use? FD= fmriprep outputs, fFD=GL's motion calculation
cfg.residuals = 'None'; % to address potential residuals feild (to indicate residuals for task FC). Set to 'None' if there are no residuals

%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE ADJECENCY MATRIX $
%%%%%%%%%%%%%%%%%%%%%%%%%

cfg.FCdir = cfg.outputDir; % Where the denoised files will be stored?
cfg.atlas_dir = sprintf('%s/networks-pm/Atlases',cfg.labDir); %Where are the atlases?
cfg.atlas = 'Seitzman300'; %What atlas will be used? WARNING: only Seitzman300-res1 available for 1mm data
cfg.FDtype = 'fFD';

%%%%%%%%%%%%%%%%%%%%%%%%%
% FSAVG2FSLR            %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.freesurfer_dir = sprintf('%s/sourcedata/freesurfer',cfg.fmriprepTopDir); % Where is the subjects' freesurfer data?
cfg.fsLR_output_dir = sprintf('%s/FREESURFER_fs_LR',cfg.freesurfer_dir); % where will the high-res, native, and low-res meshes be stored?
cfg.preproc_anat_dir = cfg.fmriprepTopDir; % Where is the subjects' anatomical data (from fmriprep)
cfg.postfreesurfer_script = sprintf('%s/SurfacePipeline/PostFreeSurferPipeline_fsavg2fslr_fmriprep.sh', cfg.preproc_path); % Where is the HCP bash script? The current version is provided in this GIT (more traceable)
cfg.midres = '1'; %toggle to also output 59k

%%%%%%%%%%%%%%%%%%%%%%%%%
% postFCPREPROC         %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.fcprocessed_funcdata_dir = cfg.outputDir;
cfg.vertex_num = '164'; %number of vertex that the functional data will be projected to
cfg.res_short = '111'; %resolution for surface projection
cfg.fcprocessed_funcdata_dir_suffix = '_fmriprep_zmdt_resid_ntrpl_bpss_zmdt';
cfg.CIFTIoutfolder = sprintf('%s/postFCPreproc-24.1.1', cfg.derivsDir); % Where the final files will be stored?
cfg.medial_mask_L = sprintf('%s/Scripts/CIFTI_RELATED/Resources/cifti_masks/L.atlasroi.%sk_fs_LR.shape.gii',cfg.labDir, cfg.vertex_num); %where is the L surface atlas?
cfg.medial_mask_R = sprintf('%s/Scripts/CIFTI_RELATED/Resources/cifti_masks/R.atlasroi.%sk_fs_LR.shape.gii',cfg.labDir, cfg.vertex_num); %where is the R surface atlas?
cfg.subcort_mask = sprintf('%s/Scripts/CIFTI_RELATED/Resources/cifti_masks/subcortical_mask_LR_%s_MNI_Label.nii.gz', cfg.labDir, cfg.res_short); %where is the subcortical mask? Make the mask in 1mm
cfg.sw_medial_mask_L = []; % [] disables smallwall mode, provide to enable 
cfg.sw_medial_mask_R = []; % [] disables smallwall mode, provide to enable 
cfg.smoothnum = 0.42;  % sigma for smoothing kernel [sigma:FWHM 0.42:1mm, 0.85:2mm, 1.27:3mm, 1.70:4mm, 2.55:6mm]
cfg.space_short = 'MNI';
cfg.T1name_end = '_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz';
cfg.force_remake_concat = 0;
cfg.force_ribbon = 0;
cfg.force_goodvoxels = 0;
cfg.do_smallwall = true;
cfg.freelabels = sprintf('%s/Scripts/CIFTI_RELATED/Cifti_creation/FreeSurferAllLut.txt',cfg.labDir); %/home/data/scripts/Cifti_creation/FreeSurferAllLut.txt

%%%%%%%%%%%%%%%%%%%%%%%%%
% make-dconn            %
%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.data_folder = cfg.CIFTIoutfolder;
cfg.tmask_folder = cfg.fmriprepTopDir;
cfg.sessions = [1]; %[1,2,3,4], can be 1+
cfg.runs = [1]; % assumes these are numbered 1:runnum, in order of sessions above
cfg.output_file = sprintf('%s/sub-%s/sub-%s_allsess_tmasked.dconn.nii', cfg.CIFTIoutfolder, sub, sub); %CHANGE IF NEEDED
cfg.save_concat_data = '1';