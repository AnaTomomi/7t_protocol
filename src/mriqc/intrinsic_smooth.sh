#!/usr/bin/bash

#SBATCH --partition=cglab
#SBATCH --time=00:20:00
#SBATCH --mem=50G
#SBATCH --cpus-per-task=20
#SBATCH --ntasks=1
#SBATCH --job-name=AFNI_smooth
#SBATCH --account=cgratton-ic
# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/logs/smoothing-%j.out
# ------------------------------------------


# SUBJECT (make an input eventually)
subject="sub-01"
session="ses-01"

# set up some directory information
BIDS_DIR="/projects/illinois/las/psych/cgratton/networks-pm/7t/HDnets/${subject}"

# Clear modules
module purge

# do singularity run
echo "Begin Preprocessing"

# 1. set paths
AFNI_SIMG=/projects/illinois/las/psych/cgratton/singularity_images/afni_make_build_latest.sif
FUNCDIR=${BIDS_DIR}/${session}/func

# 2. Where to write your combined results:
OUTFILE=/projects/illinois/las/psych/cgratton/networks-pm/7t/HDnets/derivatives/tsnr/intrinsic_smoothnes_raw.txt
mkdir -p "$(dirname "${OUTFILE}")"

# 3. Write a header row (you can customize column names)
echo -e "run\tFWHMx\tFWHMy\tFWHMz\tglobal" > "${OUTFILE}"

for BOLD in "${FUNCDIR}"/*_bold.nii.gz; do
  # derive run name, e.g. “task-rest_space-MNI152NLin6Asym”
  run=$(basename "${BOLD}" _bold.nii.gz)
  echo "${run}"
 
  stats=$(singularity exec -B /projects "${AFNI_SIMG}" \
     3dFWHMx -automask -input "${BOLD}" -detrend -ShowMeClassicFWHM \
     | awk 'NR==2{print}')   
  echo -e "${run}\t${stats}" >> "${OUTFILE}"
done

echo "Done → ${OUTFILE}"
