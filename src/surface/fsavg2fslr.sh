#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=00:45:00
#SBATCH -n 10
#SBATCH --mem=60G
#SBATCH --nodes=1
#SBATCH --job-name=fsavg2fslr
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
# ------------------------------------------

# Load MATLAB module
module load matlab

main_path="/projects/illinois/las/psych/cgratton/networks-pm"

# Check if subject ID is provided
if [ -z "$1" ]; then
    echo "Error: No subject ID provided."
    echo "Usage: sbatch run_fdcalc.sh <SUBJECT_ID>"
    exit 1
fi

SUBJECT_ID=$1 #the subject ID  is whatever comes after sub-

# Define directories
SCRIPT_DIR="${main_path}/software/GrattonLab-General-Repo"
LOG_DIR="${main_path}/7t/logs/surface"
mkdir -p ${LOG_DIR}

# Print debug message
echo "Running fsavg2fslr for subject: ${SUBJECT_ID}"

# Run MATLAB script with subject ID and log output
matlab -nodisplay -nosplash -r "addpath(genpath('${SCRIPT_DIR}')); PostFreeSurferPipeline_fsavg2fslr('${SUBJECT_ID}'); exit;" > ${LOG_DIR}/fsavg2fslr_${SUBJECT_ID}.log 2>&1

# Print completion message
echo "fsavg2fslr completed for subject ${SUBJECT_ID}. Log saved to ${LOG_DIR}/fsavg2fslr_${SUBJECT_ID}.log"


