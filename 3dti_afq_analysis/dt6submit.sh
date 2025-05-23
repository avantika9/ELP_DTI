#!/bin/bash
# Runs dt6submit.sh for all IDS listed in test file idfile.txt
#root dir
root=/dors/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI
echo "Submitting jobs for ID list from idfile_dt6.txt"
echo

while read id; do
  if [[ ! -z "$id" ]];
  then 
  subject_id="sub-${id}"
  echo "Submitting job for Subject ID ${subject_id}"
  sbatch dt6.submit $subject_id
  fi
done </${root}/idfile_ses5.txt
