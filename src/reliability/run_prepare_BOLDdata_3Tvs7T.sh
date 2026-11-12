#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=02:00:00
#SBATCH -n 4
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --job-name=prepBOLD
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.out
#SBATCH --error=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/%x_%j.err
# ------------------------------------------

# Load MATLAB module
module load matlab

main_path="/projects/illinois/las/psych/cgratton/networks-pm"

# Check if scanner is provided
if [ -z "$1" ]; then
    echo "Error: No scanner provided."
    echo "Usage: sbatch run_prepare_BOLDdata_3Tvs7T.sh <7T|3T>"
    exit 1
fi

if [ "$1" != "7T" ] && [ "$1" != "3T" ]; then
    echo "Error: scanner must be 7T or 3T (got '$1')."
    exit 1
fi

# prepare_BOLDdata_3Tvs7T.m reads the scanner from this variable
export SCANNER=$1

# Define directories
SCRIPT_DIR="${main_path}/7t/7t_protocol/src/reliability"
LOG_DIR="${main_path}/7t/logs/reliability"
mkdir -p ${LOG_DIR}

# Print debug message
echo "Running prepare_BOLDdata_3Tvs7T for scanner: ${SCANNER}"

# Run MATLAB script and log output
matlab -nodisplay -nosplash -r "addpath('${SCRIPT_DIR}'); prepare_BOLDdata_3Tvs7T; exit;" > ${LOG_DIR}/prepare_BOLDdata_${SCANNER}.log 2>&1

# Print completion message
echo "prepare_BOLDdata completed for scanner ${SCANNER}. Log saved to ${LOG_DIR}/prepare_BOLDdata_${SCANNER}.log"
