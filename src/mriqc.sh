#!/bin/bash

#SBATCH --job-name=mriqc_sub01
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --export=NONE
#SBATCH --mail-user=YOUR_EMAIL
#SBATCH --mail-type=END,FAIL

# 1. Load Singularity (if needed on your cluster)
module load singularity

# 2. Define paths (edit as necessary)
SINGULARITY_IMG="/project/illinois/las/psych/cgratton/networks-pm/7t/software/singularity_images/mriqc-0.16.1.sif"
BIDS_DIR="/project/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids"
OUTPUT_DIR="${BIDS_DIR}/derivatives/mrqc"
WORK_DIR="${BIDS_DIR}/derivatives/work"  # optional, but recommended for large jobs

# 3. Run MRIQC
singularity run --cleanenv \
    -B /project:/project \
    "${SINGULARITY_IMG}" \
    "${BIDS_DIR}" \
    "${OUTPUT_DIR}" \
    participant \
    --participant-label 01 \
    --fft-spikes-detector \
    --fd_thres 0.2 \
    --despike \
    --work-dir "${WORK_DIR}" \
    --n_procs 8 \
    --mem_gb 32

echo "MRIQC finished."
