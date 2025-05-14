# How to preprocess data?

We assume the data is in BIDS format and valid.

There are different steps until we can have networks. Please note that each script name starts with step#_ and this is the cue to know in which order the scripts should be called. The *step#* scripts call other different scripts, so it can be confusion. They are also split over different folders, so let's see the full list in order.

1. Preprocess the data using fmriprep using the file: **./src/fmriprep/step1_fmriprep.sh**. Open the file and edit the folders or add participants labels as needed. 
   
2. Make the list of subjects you want to preprocess. Run the script **./src/preprocess/step2_make_datalist.m** in MATLAB. Make sure to change the TR accordingly. 

3. Calculate the motion. Open the MATLAB script **run_fdcalc.m** and modify the base_path and fmriprep variable. After that, run the file: **./src/preprocess/step3_fdcalc.sh**. The script requires the subject as an input, e.g. `sbatch step3_fdcalc.sh 1` for subject 1. 
   
4. Make the WM and CSF masks. This is a two-step process. First, we create masks to include ventricles and exclude thamalic areas using the **./src/preprocess/make_masks2correct.m**. We noticed that the WM masks preprocessed by fmriprep include the thalamus. This is problematic because we will use the WM mask to extract the WM signal and then regress it from the data, but if the thalamus is included, then its signal will be regressed. To avoid this situation, we can create masks to exclude the thalamus and basal ganglia area from the WM mask. At the same time (and for similar reasons), we can also create a mask to include only the ventricles for the CSF mask. Second, create the masks for preprocessing. Open the script **run_makefsmasks.m** and modify the paths. Then, run the file: **./src/preprocess/step4_makefsmasks.sh**. The script requires the subject as an input, e.g. `sbatch step4_makefsmasks.sh 1` for subject 1.
   
5. Preprocess (Denoise). Open the MATLAB script **./src/preprocess/run_fcproc.m** and modify the paths. Then, run the file: **step5_fcproc.sh**. The script requires the subject as an input, e.g. `sbatch step3_fdcalc.sh 1` for subject 1. 
