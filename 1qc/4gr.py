

import os
import re
import subprocess
from pathlib import Path

import sys

import openpyxl
# pip install openpyxl
from openpyxl.chart import BarChart, Reference, Series
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import gzip
import shutil
import glob


root_dir = '/Volumes/JBooth-Lab/BDL/AM/ELP_DTI'

slicer_dir = '/Applications/Slicer.app/Contents'

dtiprep_dir = '/Applications/DTIPrep.app/Contents/MacOS/DTIPrep'

ses = 'ses-5'

idfilename = root_dir + '/idfile_ses5.txt'

# the criteria for removing a gradient: >= how much bad slices to remove the entire gradient?
criteria_vol = 3


# Read idfile.txt
idfile = open(idfilename, 'r')
lines = idfile.readlines()

ls = []

open(root_dir + '/gr_commands.txt', 'w').close()

for l in lines:

    sub_id = l.strip()
    sub_name = 'sub-' + sub_id

    dcm_dir = root_dir + '/' + sub_name + '/' + ses + '/dicoms'


    print("Starting gr prep for " + sub_name)

    gradient_remove = []
    final_gr_all=[]
    final_fname = ""
    final_gr_str = ""
    final_gr_list = ""
    
    #keeps track of multiple dcm loops
    i = 0

    #loop for multiple dicoms
    #if len(glob.glob1(dcm_dir, "*4D_QCreport.txt")) > 1:
    for f in glob.glob(dcm_dir + "/*4D_QCReport.txt"):
        gradient_remove = []
        
        os.chdir(dcm_dir)

        qc_file = open(f,'r')
        qc_lines = qc_file.readlines()
        for line in qc_lines[36:]:
            if line.startswith('whole'):
                gr = str(line.split()[1]).zfill(4)
                gradient_remove.append(gr)
            else:
                break

        # backup for all gradients with bad slice
        gr_all = gradient_remove

        # check if more than 3 bad slices in gradient
        gradient_remove = []
        for g in gr_all:
            if (gr_all.count(g) >= criteria_vol):
                gradient_remove.append(g)


        # keep only unique elements (may have read in multiple times for slices from the same gradient)
        gradient_remove = list(dict.fromkeys(gradient_remove))
        # make string for shell script input
        #compare multiple dicoms
        gr_str = '-'.join(gradient_remove)
        print('gr_str:' + gr_str)

        if i == 0:
            final_gr_str = gr_str
            final_gr_list = gradient_remove
            final_fname = f
            final_gr_all = gr_all

        if len(gr_str) < len(final_gr_str):
            final_gr_str = gr_str
            final_gr_list = gradient_remove
            final_fname = f
            final_gr_all = gr_all
        elif len(gr_str) == len(final_gr_str):
            if len(gr_all) < len(final_gr_all):
                final_gr_str = gr_str
                final_gr_list = gradient_remove
                final_fname = f
                final_gr_all = gr_all


        print(str(i) + final_gr_str + f)
        print(gr_all)
        
        i+=1
        print('finals: ' + final_gr_str)

    with open(root_dir + '/gr_commands.txt', 'a') as g:
        #final_fname.lstrip('/dicoms/')
        final_fname=final_fname[(final_fname.find('oms/')+4):]
        f_write = final_fname.replace('dicom_','').replace('_4D_QCReport.txt','.tar.gz')
        print(f_write)
        if len(final_gr_str) == 0:
            g.write(f_write + ',' + sub_name + '\n')
        else:
            g.write(f_write + ',' + sub_name+ ','+ gr_str+ '\n')


    print("Ending gr prep for " + sub_name)