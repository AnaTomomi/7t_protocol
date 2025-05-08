#!/bin/bash
#SBATCH --job-name=tsnr7T
#SBATCH --time=00:25:00
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=80G

#SBATCH --partition=secondary
#SBATCH --account=cgratton-ic

# Outputs ----------------------------------
#SBATCH --mail-user=amt89@illinois.edu
#SBATCH --mail-type=ALL
#SBATCH --output=/projects/illinois/las/psych/cgratton/networks-pm/7t/tsnr.out
# ------------------------------------------


module load matlab/24.1
matlab -nodisplay -nosplash -r "run('plot_tsnr.m'); exit"
