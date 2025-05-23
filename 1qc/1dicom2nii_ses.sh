# The following script - Creates separate temp folders for multiple DICOMS and CONVERTS dicom to nii
# Run on ACCRE
# The subject names are specified in idfile.txt
#!/bin/bash
# specify session
# Author - AM

# load modules
module load gcc/12.3
ml dcm2niix/1.0.20230411

# session
ses="ses-9"

#root dir
#root=/dors/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI
root=/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI

# Script to save errors in a single file
error_file="$root/Scripts/dicom2nii_ses9_error.txt"

###############################################################

while read -r id; do
 if [[ ! -z "$id" ]];
  then
  id="${id}"
  
  subject_id="sub-${id}"
  echo "working on ${subject_id}"
  subject_dir=${root}/${subject_id}/${ses}/dicoms
  
    # Unzip the DICOM files and place them in separate directories
    dicom_archives=$(find "${root}" -name "${id}_${ses}_*.tar.gz")
    
    for archive in $dicom_archives; do
    dicom_dir="${subject_dir}/dicom_$(basename "${archive}" .tar.gz)"
      # If Dicom_dir already exists then skip
     if [ -d "$dicom_dir" ]; then
        echo "Directory $dicom_dir already exists. Skipping this archive."
        continue
     fi
      
    mkdir -p "$dicom_dir"
    
    # Uncompress
    tar -xzf "$archive" -C "$dicom_dir"
     
    #Convert DICOM to NIfTI
    dcm2niix -z y -f "%p_%t_%s" -o $dicom_dir $dicom_dir
      
    # Copy the files - nii/bvec/bval/json
    cp $dicom_dir/*.nii.gz $dicom_dir.nii.gz >> $error_file 2>&1
    cp $dicom_dir/*.bval $dicom_dir.bval >> $error_file 2>&1
    cp $dicom_dir/*.bvec $dicom_dir.bvec >> $error_file 2>&1
    cp $dicom_dir/*.json $dicom_dir.json >> $error_file 2>&1

    echo "done copying files $dicom_dir.nii.gz $dicom_dir.bval $dicom_dir.bvec $dicom_dir.json for ${subject_id}"
    
     # Remove the temporary dicom_dir directory
      rm -rf "$dicom_dir"

 done
fi
###########################################################################
done < ${root}/idfile_test.txt
