# How to preprocess data?

We assume the data is in BIDS format and valid.

There are different steps until we can have networks. Please note that each script name starts with step#_ and this is the cue to know in which order the scripts should be called. The *step#* scripts call other different scripts, so it can be confusion. They are also split over different folders, so let's see the full list in order.

1. Preprocess the data using fmriprep using the file: **./src/fmriprep/step1_fmriprep.sh**. Open the file and edit the folders or add participants labels as needed. 
   
2. Make the list of subjects you want to preprocess. Run the script **./src/preprocess/step2_make_datalist.m** in MATLAB. Make sure to change the TR accordingly. 

3. Calculate the motion. Open the MATLAB script **run_fdcalc.m** and modify the base_path and fmriprep variable. After that, run the file: **./src/preprocess/step3_fdcalc.sh**. The script requires the subject as an input, e.g. `sbatch step3_fdcalc.sh 1` for subject 1. 
   
4. Make the WM and CSF masks. 
