#!/usr/bin/env python3
"""
step1_preparedataset.py

Prepares a session's sourcedata/ for fmriprep:
  1. Denoise the MP2RAGE UNIT1 image with LayNii's LN_MP2RAGE_DNOISE (using
     INV1 + INV2 as auxiliary inputs).
  2. Rename the denoised image to the BIDS T1w convention.
  3. Deface the denoised T1w with pydeface.
  4. Extract one volume from the first functional run of the session (per the
     subject's Excel tracking sheet) and save it as a synthetic AP fieldmap.
  5. Add IntendedFor (all included func runs of the session) to the existing
     PA fieldmap json.
  6. Copy that json to the new AP fieldmap.

Everything is read from and written back into sourcedata/ in place — there is
no separate BIDS/ output directory for this step.

Usage:
    python step1_preparedataset.py --sub 01 --ses 01
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile

import nibabel as nib

from step0_dicom2nii import parse_excel

# ---------------------------------------------------------------------------
# Hard-coded project paths (edit these for your environment)
# ---------------------------------------------------------------------------
SOURCEDATA_DIR   = '/Users/anatriana/Documents/7T/HDnets/sourcedata'
PROJECT_DIR      = os.path.dirname(SOURCEDATA_DIR)
EXCEL_TEMPLATE   = os.path.join(PROJECT_DIR, 'sub-HD{sub_int}_datacollection-notes.xlsx')

LAYNII_DIR              = '/Users/anatriana/Documents/software/LayNii'
LN_MP2RAGE_DNOISE_BIN   = os.path.join(LAYNII_DIR, 'LN_MP2RAGE_DNOISE')

# pydeface lives in a separate environment (miniforge3) from whatever
# interpreter runs this script — not resolvable via PATH, so call it by
# absolute path rather than assuming it's on PATH.
PYDEFACE_BIN = '/Users/anatriana/miniforge3/bin/pydeface'

MP2RAGE_DNOISE_BETA = 0.4

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args():
    p = argparse.ArgumentParser(
        description='Denoise/deface T1w and build the AP fieldmap for one session (step 1).')
    p.add_argument('--sub', required=True, help='Subject number, zero-padded (e.g. 01)')
    p.add_argument('--ses', required=True, help='Session number, zero-padded (e.g. 01)')
    return p.parse_args()

# ---------------------------------------------------------------------------
# MP2RAGE denoising + defacing
# ---------------------------------------------------------------------------

def denoise_mp2rage(inv1_path, inv2_path, uni_path, out_path, beta=MP2RAGE_DNOISE_BETA):
    cmd = [
        LN_MP2RAGE_DNOISE_BIN,
        '-INV1', inv1_path,
        '-INV2', inv2_path,
        '-UNI', uni_path,
        '-beta', str(beta),
        '-output', out_path,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f'LN_MP2RAGE_DNOISE failed:\n{result.stderr}')


def deface_t1w(in_path, out_path):
    cmd = [PYDEFACE_BIN, '--outfile', out_path, '--force', in_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f'pydeface failed:\n{result.stderr}')

# ---------------------------------------------------------------------------
# AP fieldmap (single volume lifted from the session's first func run)
# ---------------------------------------------------------------------------

def first_excel_run(sub, ses):
    """First functional task row (in sheet order) from the subject's Excel that
    was marked successful (col D and col F both 'Y')."""
    excel_path = EXCEL_TEMPLATE.format(sub_int=int(sub))
    excel_runs = parse_excel(excel_path, ses)
    successful = [r for r in excel_runs if r['successful']]
    if not successful:
        sys.exit(f'ERROR: no successful functional rows found for ses-{ses} in {excel_path}')
    first = successful[0]
    return first['bids_task'], f'{first["run_num"]:02d}'


def extract_first_volume(bold_path, out_path):
    img = nib.load(bold_path)
    vol0 = img.dataobj[..., 0]
    out_img = nib.Nifti1Image(vol0, img.affine, img.header)
    nib.save(out_img, out_path)

# ---------------------------------------------------------------------------
# IntendedFor
# ---------------------------------------------------------------------------

def load_scan_mapping(sub_ses_dir):
    mapping_path = os.path.join(sub_ses_dir, 'scan_mapping.json')
    if not os.path.isfile(mapping_path) or os.path.getsize(mapping_path) == 0:
        sys.exit(f'ERROR: {mapping_path} missing or empty — run step0_dicom2nii.py first.')
    with open(mapping_path) as f:
        return json.load(f)


def build_intended_for(sub, ses, mapping):
    paths = []
    for entry in mapping.get('func', []):
        if not entry['include']:
            continue
        fname = (f'sub-{sub}_ses-{ses}_task-{entry["bids_task"]}'
                  f'_run-{entry["run"]}_part-mag_bold.nii.gz')
        paths.append(f'ses-{ses}/func/{fname}')
    return paths


def update_fmap_json(json_path, intended_for):
    if os.path.isfile(json_path) and os.path.getsize(json_path) > 0:
        with open(json_path) as f:
            data = json.load(f)
    else:
        data = {}
    data['IntendedFor'] = intended_for
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=2)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    args = parse_args()
    sub = args.sub.zfill(2)
    ses = args.ses.zfill(2)

    sub_ses_dir = os.path.join(SOURCEDATA_DIR, f'sub-{sub}', f'ses-{ses}')
    anat_dir = os.path.join(sub_ses_dir, 'anat')
    fmap_dir = os.path.join(sub_ses_dir, 'fmap')
    func_dir = os.path.join(sub_ses_dir, 'func')

    mapping = load_scan_mapping(sub_ses_dir)

    # ── 1+2+3: denoise MP2RAGE, rename to T1w, deface ──────────────────────
    print('[Step 1] Denoising MP2RAGE (UNIT1) with LN_MP2RAGE_DNOISE...')
    inv1_path = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_inv-1_MP2RAGE.nii.gz')
    inv2_path = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_inv-2_MP2RAGE.nii.gz')
    uni_path  = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_UNIT1.nii.gz')
    t1w_path  = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_T1w.nii.gz')
    t1w_json  = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_T1w.json')
    uni_json  = os.path.join(anat_dir, f'sub-{sub}_ses-{ses}_UNIT1.json')

    with tempfile.TemporaryDirectory(prefix='mp2rage_dnoise_out_') as tmp:
        denoised_path = os.path.join(tmp, 'denoised.nii.gz')
        denoise_mp2rage(inv1_path, inv2_path, uni_path, denoised_path)

        print('[Step 2/3] Defacing denoised T1w with pydeface...')
        deface_t1w(denoised_path, t1w_path)

    if os.path.isfile(uni_json) and os.path.getsize(uni_json) > 0:
        shutil.copy2(uni_json, t1w_json)
    print(f'  → {t1w_path}')

    # ── 4: AP fieldmap from the first functional run (per Excel) ──────────
    print('[Step 4] Building synthetic AP fieldmap...')
    bids_task, run = first_excel_run(sub, ses)
    bold_path = os.path.join(
        func_dir, f'sub-{sub}_ses-{ses}_task-{bids_task}_run-{run}_part-mag_bold.nii.gz')
    if not os.path.isfile(bold_path):
        sys.exit(f'ERROR: expected func run not found on disk: {bold_path}')

    ap_epi_path = os.path.join(fmap_dir, f'sub-{sub}_ses-{ses}_dir-AP_epi.nii.gz')
    extract_first_volume(bold_path, ap_epi_path)
    print(f'  {bold_path} (volume 0) → {ap_epi_path}')

    # ── 5: IntendedFor on the existing PA fieldmap json ────────────────────
    print('[Step 5] Adding IntendedFor to the PA fieldmap json...')
    pa_json_path = os.path.join(fmap_dir, f'sub-{sub}_ses-{ses}_dir-PA_epi.json')
    intended_for = build_intended_for(sub, ses, mapping)
    update_fmap_json(pa_json_path, intended_for)
    print(f'  {pa_json_path}  IntendedFor: {len(intended_for)} run(s)')

    # ── 6: copy to the AP fieldmap json ────────────────────────────────────
    print('[Step 6] Copying fieldmap json for the AP fieldmap...')
    ap_json_path = os.path.join(fmap_dir, f'sub-{sub}_ses-{ses}_dir-AP_epi.json')
    shutil.copy2(pa_json_path, ap_json_path)
    print(f'  → {ap_json_path}')

    print(f'\nDone. Outputs in: {sub_ses_dir}')


if __name__ == '__main__':
    main()
