# How to preprocess data?

We assume the data is in BIDS format and valid. The GIT has all steps numbered, so following the numbers should do. However, they can be in different folders, so here's the complete list:
1. preprocess the data using fmriprep using the file: **/fmriprep/step1_fmriprep.sh**
2. make the list of subjects you want to preprocess: **/preprocess/step2_make_datalist.m**
3. calculate the motion. This is done by running the file: **/preprocess/step3_fdcalc.sh**
4. make the WM and CSF masks. 
