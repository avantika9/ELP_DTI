# The following script uses dsi studio to convert the dwi.nii.gz files to src and saves it as 4D.nii.gz files.
# Run locally on MAC
# The subject names are specified in idfile.txt specified at the end of this script
#!/bin/bash
# specify session
# Session
ses="ses-9"

#root dir
#root=/Volumes/jbooth-lab/BDL/Alisha/ELP_DTI
root=/Volumes/sshfs/AM/ELP_DTI
# open the nii file with DSI-Studio
# Add DSI studio to path
export PATH="/Applications/dsi_studio.app/Contents/MacOS:$PATH"

while read -r id; do
 if [[ ! -z "$id" ]];
  then
  id="${id}"
  echo " working on ${id}"
  subject_id="sub-${id}"

# Path to dwi.nii.gz file
path=/Volumes/sshfs/AM/ELP_DTI/${subject_id}/${ses}/dicoms
  
    # Loop through all acq- files
 for acq in $(ls $path/*${id}_${ses}*.nii.gz); do
      acq_name=$(basename $acq .nii.gz)
      echo $acq_name
      bval=$path/${acq_name}.bval
      bvec=$path/${acq_name}.bvec

      # Convert to src
      dsi_studio --action=src --source=$acq --bval=$bval --bvec=$bvec

      # Reconstruct src file and save as 4d nifti file
      dsi_studio --action=rec --source=$acq.src.gz --save_nii=$path/${acq_name}_4D.nii.gz
      
    done
 
fi
###########################################################################
done < ${root}/idfile_test.txt
