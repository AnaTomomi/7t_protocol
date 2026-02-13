#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=01:00:00
#SBATCH -n 20
#SBATCH --mem=50G
#SBATCH --nodes=1
#SBATCH --job-name=postfcproc
#SBATCH --account=cgratton-ic
#SBATCH --array=1
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/sandbox/logs/%x_%j.out
#SBATCH --error=/projects/illinois/las/psych/cgratton/networks-pm/sandbox/logs/%x_%j.err
# ------------------------------------------

# Load MATLAB module
module load matlab

# Define directories
main_path="/projects/illinois/las/psych/cgratton/networks-pm"
SCRIPT_DIR="${main_path}/software/GrattonLab-General-Repo"
LOG_DIR="${main_path}/7t/logs/"
mkdir -p ${LOG_DIR}

# check the file list
FILE_LIST="${main_path}/7t/7t_protocol/src/surface/file_list.txt"
PARAMS="/projects/illinois/las/psych/cgratton/networks-pm/software/GrattonLab-General-Repo/get_config_me.m"

# Check if file list exists
if [ ! -f "$FILE_LIST" ]; then
    echo "Error: File list $FILE_LIST not found."
    exit 1
fi

# Get the file name for this array task
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$FILE_LIST")

# Check if file name was retrieved
if [ -z "$FILE" ]; then
    echo "Error: No file found for array task ID $SLURM_ARRAY_TASK_ID"
    exit 1
fi

echo "Processing file: $FILE"

# Run MATLAB script with subject ID and log output
matlab -nodisplay -nosplash -r "addpath(genpath('${SCRIPT_DIR}')); post_fc_processing_GrattonLab('${FILE}','${PARAMS}'); exit;" > ${LOG_DIR}/fcproc_${FILE}.log 2>&1

echo "postFCProc completed for file ${FILE}. Log saved to ${LOG_DIR}/postFCPROC_${FILE}.log"
