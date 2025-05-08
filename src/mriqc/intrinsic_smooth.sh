#!/usr/bin/bash

#SBATCH --partition=secondary
#SBATCH --time=00:20:00
#SBATCH --mem=50G
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --job-name=AFNI_smooth
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/smooth-%j.out
# ------------------------------------------


# SUBJECT (make an input eventually)
subject="sub-1"

# set up some directory information
BIDS_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_cups/"
DERIVS_DIR="derivatives/fmriprep-24.1.1"

# Clear modules
module purge

# do singularity run
echo "Begin Preprocessing"

# 1. set paths
AFNI_SIMG=/projects/illinois/las/psych/cgratton/singularity_images/afni_make_build_latest.sif
FUNCDIR=${BIDS_DIR}/${DERIVS_DIR}/sub-1/ses-1/func

# 2. Where to write your combined results:
OUTFILE=${BIDS_DIR}/derivatives/tsnr/intrinsic_smoothness.txt

# 3. Write a header row (you can customize column names)
echo -e "run\tFWHMx\tFWHMy\tFWHMz\tglobal" > "${OUTFILE}"

for BOLD in "${FUNCDIR}"/*desc-preproc_bold.nii.gz; do
  # derive run name, e.g. “task-rest_space-MNI152NLin6Asym”
  run=$(basename "${BOLD}" _desc-preproc_bold.nii.gz)
  MASK="${BOLD/_desc-preproc_bold.nii.gz/_desc-brain_mask.nii.gz}"
 
  stats=$(singularity exec "${AFNI_SIMG}" \
     3dFWHMx -mask "${MASK}" "${BOLD}" \
     | awk 'NR==2{print}')   
  echo -e "${run}\t${stats}" >> "${OUTFILE}"
done

echo "Done → ${OUTFILE}"
