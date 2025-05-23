# Python script to read _4D.nii.gz file (ses-9) and convert to nhdr (Slicer) and then generate the QC report.
# Writes qc_script_ses9_output.txt that states the number of DTI files for each subject.

# Run locally on MAC

# The subject names are specified in idfile.txt
#!/usr/bin/env python3

import subprocess
import os

slicer_dir = "/Applications/Slicer.app/Contents"
dtiprep_dir = "/Applications/DTIPrep.app/Contents/MacOS/DTIPrep"

# Specify the root dir
root_dir = '/Volumes/sshfs/AM/ELP_DTI/'
ses = '/ses-9'

# Read idfile.txt
with open(os.path.join(root_dir, 'idfile_ses9.txt'), 'r') as idfile:
    lines = idfile.readlines()

# DO NOT CHANGE BELOW ###############
# Loop across subjects in idfile
with open('qc_script_ses9_output.txt', 'w') as output_file:
    for l in lines:
        sub_name = 'sub-' + l.strip()
        print(sub_name)
        path = os.path.join(root_dir, sub_name + ses, 'dicoms')
        file_count = 0

        # Loop across dwi files in subject folder
        for acq in os.listdir(path):
            if acq.startswith(f"dicom_{sub_name.strip('sub-')}") and acq.endswith("_4D.nii.gz"):
                acq_name = os.path.basename(acq)
                print(acq_name)
                
                acq_name1 = acq_name.replace(".nii.gz", "")
                bval = os.path.join(path, f"{acq_name1}.bval")
                bvec = os.path.join(path, f"{acq_name1}.bvec")
                print(bval)
                print(bvec)
                file_count += 1

                output_dir = path
                # Convert nii to nhdr format
                command = [
                    f"{slicer_dir}/lib/Slicer-5.6/cli-modules/DWIConvert",
                    "--conversionMode", "FSLToNrrd",
                    "--outputVolume", os.path.join(output_dir, f"{acq_name1}.nhdr"),
                    "--fslNIFTIFile", os.path.join(path, acq_name),
                    "--inputBValues",  bval,
                    "--inputBVectors", bvec,
                    "--useBMatrixGradientDirections",
                    "--outputDirectory", output_dir,
                    "--transposeInputBVectors",
                    "--smallGradientThreshold", "0.2"
                ]

                subprocess.run(command, check=True)

        print(f"Total files: {file_count}")
        output_file.write(f"{sub_name}: {file_count}\n")

        # Read nhdr in DTI Prep and generate the QC report
        for acq_nhdr in os.listdir(path):
            if acq_nhdr.startswith(f"dicom_{sub_name.strip('sub-')}") and acq_nhdr.endswith("_4D.nhdr"):
                acq_nhdr_name = os.path.basename(acq_nhdr)
                print(acq_nhdr_name)
                
                p = subprocess.run([dtiprep_dir, '-w',os.path.join(path, acq_nhdr_name),
                                   '-d', '-c', '-p', 'test.xml', '--outputFolder', output_dir])
