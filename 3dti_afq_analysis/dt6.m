function [dt6FileName, outBaseDir] = dt6(sfolder)
% This matlab script takes the DWI data after quality check
% to compute FA, probablistic tractography
% one input variable "sfolder": name of the subject's data folder
% Runs with Matlab 2016a and SPM8
% Creators:  Avantika Mathur
% PI: Dr. James Booth
% Bugs or comments:  avantika9mathur@gmail.com


datapath = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI'; %Specify the path where subject data exists
ses = 'ses-5';
%% add all toolbox paths which are needed for AFQ
if isempty(strfind(path,'/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/AFQ-1.2'));    
    addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/AFQ-1.2'));
end

if isempty(strfind(path,'/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/vistasoft-master'))
    addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/vistasoft-master'));
end

if isempty(strfind(path,'/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12'))
    addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12');    
    % set SPM batch working environment
	spm('Defaults','fmri');
    spm_jobman('initcfg');
end

%% check if the subject folder exists
if exist(fullfile(datapath,sfolder),'dir') ~= 7 % see if the subject directory exists    
	msg = 'sorry, cannot find the subject data folder. Please double check!';
    error(msg)
	%return;
end

if exist(fullfile(datapath,sfolder,ses,'anat',strcat(sfolder,'_acpc.nii.gz')),'file') ~= 2 % see if the T1 in subject directory exists    
    msg = 'sorry, cannot find t1_acpc.nii.gz in the subject folder. Please double check!';
    error(msg)
	%return;
end

if exist(fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'.nii.gz')),'file') ~= 2 % see if the DTI.nii.gz in subject directory exists    
    msg = 'sorry, cannot find dwi.nii.gz in the subject dwi folder. Please double check!';
    error(msg)
	%return;
end

if exist(fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'_0.bval')),'file') ~= 2 % see if bval in the subject directory exists 
	msg = 'sorry, cannot find bval file in the subject raw folder. Please double check!';
    error(msg)
	%return;
end

if exist(fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'.bvec')),'file') ~= 2 % see if bvec in the subject directory exists    
    msg = 'sorry, cannot find bvec file in the subject raw folder. Please double check!';
    error(msg)
	%return;
end

if isempty(strfind(path,'/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/Scripts'))   
    addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/Scripts');
end
    
% check mask thresh
defaults = spm('GetGlobal','defaults');
if defaults.mask.thresh ~= 0.8
    defaults.mask.thresh = 0.8;
end

% cd into working directory
cd(fullfile(datapath,sfolder,ses));
mkdir('dwi_analysis')
cd dwi_analysis

%
T1 = fullfile(datapath,sfolder,ses,'anat',strcat(sfolder,'_acpc.nii.gz'));
dwi = fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'.nii.gz'));
bval = fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'_0.bval'));
bvec = fullfile(datapath,sfolder,ses,'dwi',strcat(sfolder,'_',ses,'.bvec'));
% Setting parameters: dtiInitParams
if exist(fullfile(datapath,sfolder,ses,'dwi_analysis','/dtitrilin/dt6.mat'),'file') ~= 2
    dwParams = dtiInitParams('dt6BaseName','dtitrilin','outDir',fullfile(datapath,sfolder,ses,'dwi_analysis/'),'phaseEncodeDir',2,'rotateBvecsWithCanXform',1,'bvecsFile',bvec,'bvalsFile',bval);
    [dt6FileName, outBaseDir] = dtiInit(dwi,T1,dwParams);
else
    disp('dt6.mat already exists.');    
end
end
