#!/usr/bin/bash

#SBATCH --partition=IllinoisComputes
#SBATCH --time=72:00:00
#SBATCH --mem=200G
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --job-name=fmriprep_7t_sms
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/fmriprep_sms.out
# ------------------------------------------


# SUBJECT (make an input eventually)
subject="sub-01"

# set up some directory information
BIDS_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_sms/"
DERIVS_DIR="derivatives/fmriprep-24.1.1"
WORK_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/temp_fmriprep_sms/"

# Prepare derivatives folder, work dir, anat templates
mkdir -p ${BIDS_DIR}/${DERIVS_DIR}
mkdir -p ${WORK_DIR}
export SINGULARITYENV_TEMPLATEFLOW_HOME="/projects/illinois/las/psych/cgratton/Atlases/templateflow/"

# Clear modules
module purge

# do singularity run
echo "Begin Preprocessing"

singularity run --cleanenv \
    -B /projects/illinois/las/psych/cgratton,$SINGULARITYENV_TEMPLATEFLOW_HOME:/home/.cache/templateflow \
        /projects/illinois/las/psych/cgratton/singularity_images/fmriprep-24.1.1.simg \
    ${BIDS_DIR} \
    ${BIDS_DIR}/${DERIVS_DIR} \
    participant --participant-label ${subject} \
    -w ${WORK_DIR} \
    --fs-license-file /projects/illinois/las/psych/cgratton/singularity_images/freesurfer_license.txt \
    --output-spaces MNI152NLin6Asym:res-1  \
    --ignore slicetiming \
    --fd-spike-threshold 0.2 \
    --notrack \



#can add --skip-bids-validation if testing
#the --notrack flag stops fmriprep from trying to access internet for sending reports; RCC compute nodes don't have internet

# convert BOLD volume files to float
# module load fsl/5.0.8
#for filename in ${BIDS_DIR}/${DERIVS_DIR}/fmriprep/sub-${subject}/ses-*/func/sub-${subject}_*_desc-preproc_bold.nii.gz
#do
#  fslmaths -dt input ${filename} ${filename} -odt float
#done

# clear contents of working directory
#cd ${WORK_DIR} && rm -rf *
