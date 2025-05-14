#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=00:05:00
#SBATCH -n 4
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --job-name=FDCalc
#SBATCH --account=cgratton-ic
#SBATCH --reservation=cglab_new
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
# ------------------------------------------

# Load MATLAB module
module load matlab

main_path="/projects/illinois/las/psych/cgratton/networks-pm/7t"

# Check if subject ID is provided
if [ -z "$1" ]; then
    echo "Error: No subject ID provided."
    echo "Usage: sbatch run_fdcalc.sh <SUBJECT_ID>"
    exit 1
fi

SUBJECT_ID=$1

# Define directories
SCRIPT_DIR="${main_path}/7t_protocol/src/preproc"
LOG_DIR="${main_path}/logs/FDcalc"
mkdir -p ${LOG_DIR}

# Print debug message
echo "Running FDCalc for subject: ${SUBJECT_ID}"

# Run MATLAB script with subject ID and log output
matlab -nodisplay -nosplash -r "addpath('${SCRIPT_DIR}'); run_fdcalc('${SUBJECT_ID}'); exit;" > ${LOG_DIR}/runFDCalc_${SUBJECT_ID}.log 2>&1

# Print completion message
echo "FDCalc completed for subject ${SUBJECT_ID}. Log saved to ${LOG_DIR}/runFDCalc_${SUBJECT_ID}.log"
