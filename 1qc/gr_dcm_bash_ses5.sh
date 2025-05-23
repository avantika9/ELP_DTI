# @Author: AM - Senior Research Analyst - BDL lab, May 2024
# @Date:   2024-06-18
# Runs on Accre as ./gr_dcm_bash_ses5.sh

## This script makes a copy of dicom folder, delete the bad .dcm files according to QC report (gr_commands_ses5.txt) and then runs the dcm2nii conversion to give three files - DTI file, bval and bvec for each subject - and makes a copy of the new nii/bval/bvec/json files to subject specific dwi folder.
## The script uses idfile specified  at the end of this code with subject numbers to loop across subjects

#!/bin/bash

#subject_id="sub-5003"

# specify session
ses="ses-5"
#root dir
root=/dors/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI
# Read text file gr_commands_ses7.txt as input.
# Note:: the gradients reported in this script are to be removed as per DTI Prep QC report {>3 bad slices}. But, DTI Prep reports gradients from 0-69, thus we will add 1 to this number to remove the corresponding .dcm file.
input="$root/Scripts/gr_commands_ses5.txt"

# Script to save errors in a single file
error_file="$root/Scripts/copy_error_ses5.txt"

# load modules
module load GCCcore/.8.2.0
module load dcm2niix/1.0.20190902             


#######################################################################
#Do not change below
# Temporary file to store extracted last two digits
tmp_file="last_two_digits.txt"

while read -r id; do
 if [[ ! -z "$id" ]];then
  id="${id}"
  echo " working on ${id}"
  subject_id="sub-${id}"
    # dwi_directory path for this subject and this ses
    # dicom dir contains original dicoms
    dicom_directory="${root}/${subject_id}/${ses}/dicoms"
    # dwi dir will contain the nii, bval and bvec file after QC
    dwi_directory="${root}/${subject_id}/${ses}/dwi"
    
    # Copy the better dicom to dicoms_QC folder
    cd ${root}/${subject_id}/${ses}
    # If the dicoms_QC folder exists then delete it
    if [ -d "dicoms_QC" ]; then
      rm -rf dicoms_QC
    fi
    # make new dicoms_QC folder
    mkdir -p dicoms_QC
    dcm_directory="${root}/${subject_id}/${ses}/dicoms_QC"
    
    # Copy the listed dicom file
    while read line; do
    # Check if the line contains the desired subject
    if [[ $line == *"$subject_id"* ]]; then
        # Extract the tar.gz file name
        tar_file=$(echo $line | cut -d',' -f1)
        echo "Tar file: $tar_file"
        cp $dicom_directory/$tar_file $dcm_directory # Copy tar file to dcm_dir
        chmod -R 755 $dcm_directory
        # Uncompress the tar file
        cd $dcm_directory
        tar -xzf $dcm_directory/$tar_file
        rm $tar_file # remove tar file
        
        # Look for the second comma and extract what comes after it
        if [[ $line == *","*","* ]]; then
            numbers=${line#*,}
            numbers=${numbers#*,}
            # For each number (delimited by hyphens)
            IFS='-' read -ra nums <<< "$numbers"
            for num in "${nums[@]}"; do
                # Echo the last two digits
                last_two_digits=("${num: -2}")
                # Use arithmetic expansion to remove leading zero if present to match the .dcm filename as end with 1-9, and then 11-70
                last_two_digits=$((10#$last_two_digits))
                # Add 1 to the last_two_digits
                last_two_digits=$((last_two_digits + 1))
                echo "bad volumes with >3 slices deleted $last_two_digits"
                echo "$last_two_digits" >> "$tmp_file"
            done
        fi
     fi
    done < "$input"
  fi

# Read the temporary file with the last two digits
while IFS= read -r digits; do
    # Find and delete files with matching last two digits before .dcm in a directory
    # Please note this will list the files for verification, remove `echo` to actually delete
    find "$dcm_directory" -type f -name "*_${digits}.dcm" -exec rm '{}' +
done < "$tmp_file"

# Cleanup the temporary file
rm "$tmp_file"

# Convert the remaining dcm to nii/bvec/bval
dcm2niix -z y -f "%p_%t_%s" -o $dcm_directory $dcm_directory

# Copy the files - nii/bvec/bval/json to dwi directory and rename
cp $dcm_directory/*.bval $dwi_directory/${subject_id}_${ses}.bval >> $error_file 2>&1
cp $dcm_directory/*.bvec $dwi_directory/${subject_id}_${ses}.bvec >> $error_file 2>&1
cp $dcm_directory/*.nii.gz $dwi_directory/${subject_id}_${ses}.nii.gz >> $error_file 2>&1
cp $dcm_directory/*.json $dwi_directory/${subject_id}_${ses}.json >> $error_file 2>&1

echo "done copying files ${subject_id}_${ses}.bval ${subject_id}_${ses}.bvec ${subject_id}_${ses}.nii ${subject_id}_${ses}.json for ${subject_id}"

###########################################################################
done < /${root}/idfile_ses5.txt
