#!/usr/bin/bash

#SBATCH --partition=secondary
#SBATCH --time=01:00:00
#SBATCH -n 10
#SBATCH --mem=50G
#SBATCH --nodes=1
#SBATCH --job-name=makefsmasks
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
#SBATCH --error=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
# ------------------------------------------

# Load MATLAB module
module load matlab

# Check if subject ID is provided
if [ -z "$1" ]; then
    echo "Error: No subject ID provided."
    echo "Usage: sbatch run_makefsmasks.sh <SUBJECT_ID>"
    exit 1
fi

SUBJECT_ID=$1

# Define directories
main_path="/projects/illinois/las/psych/cgratton/networks-pm/7t"

SCRIPT_DIR="${main_path}/7t_protocol/src/preproc"
LOG_DIR="${main_path}/logs/FDcalc/makefsmasks"
mkdir -p ${LOG_DIR}

# Run MATLAB script with subject ID and log output
matlab -nodisplay -nosplash -r "addpath('${SCRIPT_DIR}'); run_makefsmasks('${SUBJECT_ID}'); exit;" > ${LOG_DIR}/makefsmasks_${SUBJECT_ID}.log 2>&1

echo "makefsmasks completed for subject ${SUBJECT_ID}. Log saved to ${LOG_DIR}/runmakefsmasks_${SUBJECT_ID}.log"
