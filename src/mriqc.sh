#!/usr/bin/bash

#SBATCH --partition=IllinoisComputes
#SBATCH --time=70:00:00
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --job-name=mriqc_7t
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/mriqc.out
# ------------------------------------------

# SUBJECT (make an input eventually)
subject="sub-01"

# do singularity run
echo "Begin Quality Control"

# clean all modules
module purge

# 2. Define paths (edit as necessary)
SING_IMA="/projects/illinois/las/psych/cgratton/networks-pm/software/singularity_images"
BIDS_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids"
OUTPUT_DIR="${BIDS_DIR}/derivatives/mriqc"
WORK_DIR="/projects/illinois/las/psych/cgratton/networks-pm/temp2"


mkdir -p ${OUTPUT_DIR}
mkdir -p ${WORK_DIR}

# 3. tell MRIQC where the templates are
export SINGULARITYENV_TEMPLATEFLOW_HOME="/projects/illinois/las/psych/cgratton/Atlases/templateflow/"

# 4. Run MRIQC
singularity run --cleanenv \
    --bind /projects/illinois/las/psych/cgratton,$SINGULARITYENV_TEMPLATEFLOW_HOME:/home/.cache/templateflow \
    --bind ${BIDS_DIR}:/data \
    --bind ${OUTPUT_DIR}:/out \
    ${SING_IMA}/mriqc-0.16.1.sif \
    /data \
    /out \
    participant \
    --participant-label 01 \
    --fft-spikes-detector \
    --fd_thres 0.2 \
    --despike 

echo "MRIQC finished."
