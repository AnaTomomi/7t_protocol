# How to preprocess data?

We assume the data is in BIDS format and valid.

There are different steps until we can have networks. They are split over different folders, so let's see the full list in order.

1. Preprocess the data using fmriprep using the file: **/fmriprep/step1_fmriprep.sh**. Open the file and edit the folders or add participants labels as needed. 
   
2. Make the list of subjects you want to preprocess. Run the script **/preprocess/step2_make_datalist.m** in MATLAB. Make sure to change the 

3. calculate the motion. This is done by running the file: **/preprocess/step3_fdcalc.sh**
4. make the WM and CSF masks. 
