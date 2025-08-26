# @Author: AM -Senior Research Analyst - BDL lab, May 2024
# @Date:   2024-06-18

## This script converts "5" to "0" of bval files in dwi folder
## The script uses idfile specified  at the end of this code with subject numbers to loop across subjects

#!/bin/bash

#subject_id="sub-5003"

# specify session
ses="ses-5"
#root dir
root=/dors/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI
#Specify folder with bval file
bval_dir="dwi"
#######################################################################
#Do not change below

while read -r id; do
 if [[ ! -z "$id" ]]; then
  id="${id}"
  echo " working on ${id}"
  subject_id="sub-${id}"
  dwi_directory="${root}/${subject_id}/${ses}/${bval_dir}"
  # Original bval file name
  bval_file="${dwi_directory}/${subject_id}_${ses}.bval"
  # New bval file name
  output_file="${dwi_directory}/${subject_id}_${ses}_0.bval"
  echo $bval_file
  if [ -f "$bval_file" ]; then
    cp "$bval_file" "$output_file"
    sed -i 's/\b5\b/0/g' "$output_file"
    echo "Updated $output_file"
  else
    echo "File not found: $bval_file"
  fi
fi
###########################################################################
done < "/${root}/idfile_ses5.txt"
