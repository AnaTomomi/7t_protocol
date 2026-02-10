#!/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=23:55:00
#SBATCH --mem=200G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --job-name=fmriprep_7t
#SBATCH --account=cgratton-ic
#SBATCH --array=1-5%3
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/replica/fmriprep-%j.out
# ------------------------------------------

# SUBJECT (make an input eventually)
subject="1"
seq=$1
session="${SLURM_ARRAY_TASK_ID}"

# set up some directory information
BIDS_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/pilots/${seq}/"
DERIVS_DIR="derivatives/fmriprep-24.1.1"
WORK_DIR_BASE="/projects/illinois/las/psych/cgratton/networks-pm/7t/temp/${seq}/"
WORK_DIR="${WORK_DIR_BASE}/ses-${session}"

# Clear modules
module purge

# Prepare derivatives folder, work dir, anat templates
mkdir -p ${BIDS_DIR}/${DERIVS_DIR}
mkdir -p ${WORK_DIR}

#create the BIDS-filter file for preprocessing sessions
mkdir -p ${WORK_DIR}/filters
cat <<EOF > "${WORK_DIR}/filters/filter-ses-${session}.json"
{
  "fmap": {
  	"datatype": "fmap",
  	"session": "${session}"
  },
  "bold": {
    "datatype": "func",
    "suffix": "bold",
    "session": "${session}"
  }
}
EOF


export SINGULARITYENV_TEMPLATEFLOW_HOME="/projects/illinois/las/psych/cgratton/Atlases/templateflow/"

#clear modules
module purge

# do singularity run
echo "Begin Preprocessing"


singularity run --cleanenv \
    -B /projects/illinois/las/psych/cgratton,$SINGULARITYENV_TEMPLATEFLOW_HOME:/home/.cache/templateflow \
        /projects/illinois/las/psych/cgratton/singularity_images/fmriprep-24.1.1.simg \
    ${BIDS_DIR} \
    ${BIDS_DIR}/${DERIVS_DIR} \
    -w ${WORK_DIR} \
    participant --participant-label ${subject} \
    --fs-license-file /projects/illinois/las/psych/cgratton/singularity_images/freesurfer_license.txt \
    --output-spaces MNI152NLin6Asym:res-1:res-2:res-native T1w func \
    --ignore slicetiming \
    --fd-spike-threshold 0.2 \
    --bids-filter-file ${WORK_DIR}/filters/filter-ses-${session}.json \
    -d fmriprep=${BIDS_DIR}/${DERIVS_DIR} \
    --me-output-echos \
    --skip-bids-validation \
    --notrack \
