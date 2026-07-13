#!/usr/bin/env python3
"""
tSNR.py

Computes temporal SNR (mean / std across time) for every part-mag_bold NIfTI
in sourcedata/sub-XX/ses-YY/func/ and saves one diagnostic PDF per image to
sourcedata/tsnr/sub-XX/ses-YY/.

Each PDF has 3 rows × 8 columns:
    Row 0 — sagittal  (slices along axis 0)
    Row 1 — coronal   (slices along axis 1)
    Row 2 — axial     (slices along axis 2)

Usage:
    python tSNR.py --sub 01 --ses 01
    python tSNR.py --sub 01 --ses 01 --path /custom/sourcedata
"""

import argparse
import os
import sys

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
import nibabel as nib
import numpy as np

# ---------------------------------------------------------------------------
# Hard-coded paths
# ---------------------------------------------------------------------------
SOURCEDATA_DIR = '/Users/anatriana/Documents/7T/sourcedata'

# ---------------------------------------------------------------------------
# Plot settings
# ---------------------------------------------------------------------------
VMIN     = 0
VMAX     = 30
CMAP     = 'jet'
N_SLICES = 8


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args():
    p = argparse.ArgumentParser(
        description='Compute and plot tSNR for BOLD magnitude images.')
    p.add_argument('--sub',  required=True,
                   help='Subject number, zero-padded (e.g. 01)')
    p.add_argument('--ses',  required=True,
                   help='Session number, zero-padded (e.g. 01)')
    p.add_argument('--path', default=None,
                   help='Override sourcedata directory (default: hard-coded SOURCEDATA_DIR)')
    return p.parse_args()


# ---------------------------------------------------------------------------
# tSNR computation
# ---------------------------------------------------------------------------

def compute_tsnr(data):
    """Voxel-wise tSNR = mean / std across the time axis. Zero where std == 0."""
    mean = np.asarray(data).mean(axis=3)
    std  = np.asarray(data).std(axis=3, ddof=1)
    tsnr = np.zeros_like(mean)
    valid = std > 0
    tsnr[valid] = mean[valid] / std[valid]
    return tsnr


def pick_slices(n_voxels, n=N_SLICES):
    """N evenly-spaced integer indices spanning the full dimension."""
    return np.linspace(20, n_voxels - 20, n).astype(int)


# ---------------------------------------------------------------------------
# Plotting
# ---------------------------------------------------------------------------

def plot_tsnr(tsnr, title, out_pdf):
    """
    3 rows × N_SLICES columns figure; one shared jet colorbar (vmin=0, vmax=30).
    Slices are transposed so the superior direction is up in all three planes.
    """
    nx, ny, nz = tsnr.shape

    planes = [
        ('Sagittal', [tsnr[i, :, :].T for i in pick_slices(nx)]),
        ('Coronal',  [tsnr[:, j, :].T for j in pick_slices(ny)]),
        ('Axial',    [tsnr[:, :, k].T for k in pick_slices(nz)]),
    ]

    fig, axes = plt.subplots(
        3, N_SLICES,
        figsize=(N_SLICES * 2.2, 8),
        gridspec_kw={'hspace': 0.05, 'wspace': 0.03},
    )
    fig.suptitle(title, fontsize=8, y=1.005)

    for row, (plane_name, slices) in enumerate(planes):
        for col, sl in enumerate(slices):
            ax = axes[row, col]
            ax.imshow(
                sl,
                cmap=CMAP,
                vmin=VMIN, vmax=VMAX,
                origin='lower',
                aspect='auto',
                interpolation='nearest',
            )
            ax.set_xticks([])
            ax.set_yticks([])
            for spine in ax.spines.values():
                spine.set_visible(False)

        # Row label on the left of the first column
        axes[row, 0].set_ylabel(plane_name, fontsize=8, labelpad=4)

    # Shared colorbar to the right of the grid
    sm   = ScalarMappable(cmap=CMAP, norm=Normalize(vmin=VMIN, vmax=VMAX))
    cbar = fig.colorbar(sm, ax=axes, shrink=0.7, pad=0.02, aspect=30)
    cbar.set_label('tSNR', fontsize=9)
    cbar.ax.tick_params(labelsize=8)

    fig.savefig(out_pdf, bbox_inches='tight')
    plt.close(fig)
    print(f'  → {out_pdf}')


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    args  = parse_args()
    sub   = args.sub.zfill(2)
    ses   = args.ses.zfill(2)
    sdata = args.path or SOURCEDATA_DIR

    func_dir = os.path.join(sdata, f'sub-{sub}', f'ses-{ses}', 'func')
    out_dir  = os.path.join(sdata, 'tsnr', f'sub-{sub}', f'ses-{ses}')
    os.makedirs(out_dir, exist_ok=True)

    niftis = sorted(
        f for f in os.listdir(func_dir)
        if f.endswith('_part-mag_bold.nii.gz')
    )

    if not niftis:
        sys.exit(f'No part-mag_bold.nii.gz files found in {func_dir}')

    print(f'sub-{sub}  ses-{ses}  —  {len(niftis)} magnitude image(s) found')

    for fname in niftis:
        print(f'\n{fname}')
        img  = nib.load(os.path.join(func_dir, fname))
        data = img.get_fdata(dtype=np.float32)

        if data.ndim != 4:
            print(f'  Skipping: expected 4D, got {data.ndim}D')
            continue

        tsnr    = compute_tsnr(data)

        stem    = fname.replace('.nii.gz', '')
        out_nii = os.path.join(out_dir, f'{stem}_tSNR.nii.gz')
        out_pdf = os.path.join(out_dir, f'{stem}_tSNR.pdf')

        nib.save(nib.Nifti1Image(tsnr.astype(np.float32), img.affine), out_nii)
        print(f'  → {out_nii}')

        plot_tsnr(tsnr, title=fname, out_pdf=out_pdf)

    print(f'\nDone. PDFs in {out_dir}')


if __name__ == '__main__':
    main()
