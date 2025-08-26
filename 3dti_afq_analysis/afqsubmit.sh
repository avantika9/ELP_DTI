#!/bin/bash
# Runs afqsubmit.sh for all IDS listed in test file idfile.txt
root=/dors/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI
echo "Submitting jobs for ID list from idfile.txt"
echo

while read id; do
  if [[ ! -z "$id" ]];
  then 
  subject_id="sub-${id}"
  echo "Submitting job for Subject ID ${subject_id}"
  sbatch afq.submit $subject_id
  fi
done </${root}/idfile_ses5.txt
