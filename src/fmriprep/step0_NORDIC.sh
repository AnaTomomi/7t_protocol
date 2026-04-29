#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=08:00:00
#SBATCH -n 4
#SBATCH --mem=48G
#SBATCH --nodes=1
#SBATCH --job-name=NORDIC
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
# ------------------------------------------

# Load modules
module load matlab
module load fsl

main_path="/projects/illinois/las/psych/cgratton/networks-pm"

# Check if subject ID is provided
if [ -z "$1" ]; then
    echo "Error: No subject ID provided."
    echo "Usage: sbatch step0_NORDIC.sh <SUBJECT_ID> <PARAMS_PATH>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: No params file provided."
    echo "Usage: sbatch step0_NORDIC.sh <SUBJECT_ID> <PARAMS_PATH>"
    exit 1
fi

SUBJECT_ID=$1  # subject label without 'sub-' prefix, e.g. PM01 or 1
PARAMS=$2      # full path to the config/params file

# Define directories
SCRIPT_DIR="${main_path}/software/GrattonLab-General-Repo"
LOG_DIR="${main_path}/7t/logs/NORDIC"
mkdir -p ${LOG_DIR}

# Print debug message
echo "Running NORDIC for subject: ${SUBJECT_ID}"

# Run MATLAB — discovers all sessions and runs automatically
matlab -nodisplay -nosplash -r "addpath(genpath('${SCRIPT_DIR}')); run_NORDIC('${SUBJECT_ID}','${PARAMS}'); exit;" > ${LOG_DIR}/runNORDIC_${SUBJECT_ID}.log 2>&1

# Print completion message
echo "NORDIC completed for subject ${SUBJECT_ID}. Log saved to ${LOG_DIR}/runNORDIC_${SUBJECT_ID}.log"
