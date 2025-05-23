# /home/zhengh7/Downloads/Slicer/Slicer --no-main-window --no-splash --python-script /home/zhengh7/Downloads/qc_script.py
# /Applications/Slicer.app/Contents/MacOS/Slicer --no-main-window --no-splash --python-script /Volumes/JBooth-Lab/BDL/AM/ELP_DTI/qc_script.py

# ./Slicer
# /Applications/Slicer.app/Contents/MacOS/Slicer --launch ../python-install/bin/pip install openpyxl
# ./Slicer --launch ./bin/python-real -c "import pip; pip.main(['install', 'scipy'])"



import os
import re
import subprocess
from pathlib import Path

import sys


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import gzip
import shutil
import glob

root_dir = '/Volumes/JBooth-Lab/BDL/AM/ELP_DTI'
# /Volumes/JBooth-Lab/BDL/AM/ELP_DTI/sub-5003/ses-7/dicoms dwi anat
# root_dir = '/home/zhengh7/Downloads'
# root_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Huijia/'

slicer_dir = '/Applications/Slicer.app/Contents'
# '/Applications/Slicer.app/Contents/MacOS/Slicer'
# slicer_dir = '/home/zhengh7/Downloads/Slicer'
# slicer_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/Slicer-5.6.1-linux-amd64'

dtiprep_dir = '/Applications/DTIPrep.app/Contents/MacOS/DTIPrep'
# dtiprep_dir = '/home/zhengh7/Downloads/DTIPrep/bin/DTIPrep'
# dtiprep_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/DTIPrep-1.2.11/bin/DTIPrep'


# Read idfile.txt
idfile = open(root_dir + '/idfile_ses9.txt', 'r')
lines = idfile.readlines()

for l in lines:

    sub_name = 'sub-' + l.strip()



    dcm_dir = root_dir + '/' + sub_name + '/ses-9/dicoms'

    print("Starting anat file deletion for " + sub_name)

    output_dir = root_dir + '/' + sub_name + '/ses-9/dwi'


    # Read T1_ses-7_QC_DTI.xlsx for which of duplicage scans to remove/keep
    df = pd.read_excel(root_dir + '/T1_ses-7_QC_DTI.xlsx', sheet_name='ses-9')

    dup_keep = df['files_to_keep'].to_numpy()
    for fk in dup_keep:
        if type(fk) == str:
            keep = fk.strip()
            if keep.startswith(sub_name):
                for f in os.listdir(root_dir + '/' + sub_name + '/ses-9/anat'):
                    if keep not in f:
                        os.remove(root_dir + '/' + sub_name + '/ses-9/anat/' + f)
                break




    print("Ending anat file deletion for " + sub_name)


