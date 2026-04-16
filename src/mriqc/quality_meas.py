''' This script creates the tSNR, SNR, and tCNR maps for a .nii.gz file. 
Only change the image variable

04/2026: AMT created the file
'''

import numpy as np
import nibabel as nib
from pathlib import Path

# Which image will be processed?
path = "/Volumes/illinois-las-psych-gratton/networks-pm/7t/pilots/3D-EPI"
image = f'{path}/sub-2/ses-1/func/sub-2_ses-1_task-faces_run-1_bold.nii.gz'
savepath = f'{path}/derivatives/quality'

#Create the savepath if it doesn't exist
directory = Path(savepath)
directory.mkdir(parents=True, exist_ok=True)

# Load data
img = nib.load(image)
data = img.get_fdata()   # (X, Y, Z, T)
affine = img.affine
header = img.header

# Strip extension to build output paths (.nii.gz or .nii)
base = Path(image).name 
base = base[:-12]

# Background mask and background noise
mean_vol = np.mean(data, axis=3)
std_vol = np.std(data,  axis=3)
threshold = 0.05 * mean_vol.max()
noise_mask = mean_vol < threshold
noise_std = np.std(data[noise_mask])   # scalar — global noise floor

# SNR (mean signal / global noise floor)
with np.errstate(divide='ignore', invalid='ignore'):
    snr_map = mean_vol/noise_std

snr_img = nib.Nifti1Image(snr_map.astype(np.float32), affine, header)
nib.save(snr_img, f'{savepath}/{base}_snr.nii.gz')
print(f"Saved: {base}_snr.nii.gz")

#tSNR (mean signal/temporal std, voxel-wise)
with np.errstate(divide='ignore', invalid='ignore'):
    tsnr_map = mean_vol/std_vol

tsnr_img = nib.Nifti1Image(tsnr_map.astype(np.float32), affine, header)
nib.save(tsnr_img, f'{savepath}/{base}_tsnr.nii.gz')
print(f"Saved: {base}_tsnr.nii.gz")

#tCNR (temporal std / global noise floor)
with np.errstate(divide='ignore', invalid='ignore'):
    tcnr_map = std_vol/noise_std

tcnr_img = nib.Nifti1Image(tcnr_map.astype(np.float32), affine, header)
nib.save(tcnr_img, f'{savepath}/{base}_tcnr.nii.gz')
print(f"Saved: {base}_tcnr.nii.gz")