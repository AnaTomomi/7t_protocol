#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=00:40:00
#SBATCH -n 4
#SBATCH --mem=30G
#SBATCH --nodes=1
#SBATCH --job-name=NORDIC
#SBATCH --account=cgratton-ic
#SBATCH --array=1-24
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
#SBATCH --error=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.err
# ------------------------------------------

# Load modules
module load matlab
module load fsl

main_path="/projects/illinois/las/psych/cgratton/networks-pm"
SCRIPT_DIR="${main_path}/software/GrattonLab-General-Repo"
LOG_DIR="${main_path}/7t/logs/NORDIC"
mkdir -p ${LOG_DIR}

# check the file list -- one sourcedata part-mag filename per line,
# built with list_NORDIC_files.m
FILE_LIST="${main_path}/7t/7t_protocol/src/fmriprep/nordic_file_list.txt"
PARAMS="/projects/illinois/las/psych/cgratton/networks-pm/7t/7t_protocol/src/get_config.m"

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

# Run MATLAB -- one run/echo per array task. run_NORDIC uses
# SLURM_ARRAY_JOB_ID/SLURM_ARRAY_TASK_ID (inherited from this job's
# environment) to build a unique scratch directory per task.
matlab -nodisplay -nosplash -r "addpath(genpath('${SCRIPT_DIR}')); run_NORDIC('${FILE}','${PARAMS}'); exit;" > ${LOG_DIR}/runNORDIC_${FILE}.log 2>&1

echo "NORDIC completed for file ${FILE}. Log saved to ${LOG_DIR}/runNORDIC_${FILE}.log"
