#!/usr/bin/bash

#SBATCH --partition=secondary
#SBATCH --time=03:00:00
#SBATCH -n 10
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --job-name=fcproc
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=jacobc16@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/member_directories/jchernicky/Logs/SLURM_Outputs/%x_%j.out
#SBATCH --error=/projects/illinois/las/psych/cgratton/member_directories/jchernicky/Logs/SLURM_Outputs/errors/%x_%j.err
# ------------------------------------------

# Load MATLAB module
module load matlab

# Get subject ID from command-line argument
SUBJECT_ID=$1

# Check if subject ID is provided
if [ -z "$SUBJECT_ID" ]; then
  echo "Error: No subject ID provided. Usage: sbatch run_fcproc.sh <subject_id>"
  exit 1
fi

# Define directories
SCRIPT_DIR="/projects/illinois/las/psych/cgratton/member_directories/jchernicky/easyRun/wrappers"
LOG_DIR="/projects/illinois/las/psych/cgratton/member_directories/jchernicky/Logs/FCProc"
mkdir -p ${LOG_DIR}

# Run MATLAB script with subject ID and log output
matlab -nodisplay -nosplash -r "addpath('${SCRIPT_DIR}'); run_fcproc('${SUBJECT_ID}'); exit;" > ${LOG_DIR}/run_fcproc_${SUBJECT_ID}.log 2>&1

echo "FCProc completed for subject ${SUBJECT_ID}. Log saved to ${LOG_DIR}/run_fcproc_${SUBJECT_ID}.log"
