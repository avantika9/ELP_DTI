
% This matlab script takes the dt6.mat data
% to generate whole brain tractography
% to compute FA, probablistic tractography
% Creators: Avantika Mathur (Ph.D., Post-doc)
% Bugs or comments:  avantika9mathur@gmail.com
% Authorship to be given to  Avantika Mathur for using this script
% BDL lab
% Last updated: 7/8/2015
parpool;
tic
%SubId = {'sub-5003'; 'sub-5004'};
SubId ={};
data_info=['/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/Scripts/idfile_afq_fmri_dti.xlsx']; %final_sample sheet, the subject column should have sub plus subject number.(e.g. sub-5003)
if isempty(SubId)
    M=readtable(data_info, sheet, );
    SubId=M.SubId;
end

try
% Output Name - define by number of nodes
%output_name = char(strcat('All','_afq_100.mat'));
output_name = char(strcat('Sub_fMRI_DTI_n98','_afq_100.mat'));
%output_name = char(strcat('All','_afq_30.mat'));
%%
datapath = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/';%Specify the path where subject data exists
afq_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/afq_ses7/'; %Path where afq structure will be stored
ses = 'ses-7';

% add all toolbox paths which are needed for AFQ
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/AFQ-1.2'));
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/vistasoft-master'));
addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12');    
% set SPM batch working environment
spm('Defaults','fmri');
spm_jobman('initcfg'); %params = defaults.old.normalise.estimate % edited in %afq_segmentfibergroups

% check mask thresh
defaults = spm('GetGlobal','defaults');
if defaults.mask.thresh ~= 0.8
    defaults.mask.thresh = 0.8;
end

% List sub dir and sub names
cd(datapath);
sub_dirs = [];
sub_names = [];

for isub=1:numel(SubId)
		if exist(strcat(datapath,SubId{isub,1},'/',ses,'/dwi_analysis','/dtitrilin/dt6.mat'),'file') ~= 2 % check if dt6.mat file exist
			disp('------------------------------------------------------');
			disp(strcat(datapath,SubId{isub,1},'/',ses,'/dwi_analysis','/dtitrilin/dt6.mat',' cannot be found'));			
			disp('------------------------------------------------------');
			return;
		end
sub_dirs{isub,1} = strcat(datapath,SubId{isub,1},'/',ses,'/dwi_analysis','/dtitrilin/');
sub_names{isub,1} = SubId{isub,1};
end	


% Enter Group information (ie : 1 1 0 0 1 0 0 1) :: 1 for patient and 0 for control data
% Since we only have control subjects.
% We assign zero to all participants.

sub_group = cell(numel(SubId),1);
sub_group(1:end) = num2cell(zeros);
% AFQ_run
if size(SubId,1) ~= size(sub_group,1)
	errordlg('The number of subjects does not match the group array!  Please double check!');
	return;
end

% convert sub_group to vector
sub_group = [sub_group{:}];

% define afq -use the deafault params
afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_names', sub_names, 'sub_group',sub_group);

% The number of nodes to represent each fiber
%afq.params.numberOfNodes = 100; % Changed to 100 or 30 
afq.params.numberOfNodes = 100;

% Run AFQ
[afq patient_data control_data abn abnTracts] = AFQ_run(sub_dirs, sub_group, afq);
%save(strcat(afq_dir,output_name),'afq','patient_data','control_data','abn','abnTracts')

% plot 'Left IFOF','Right IFOF','Left ILF','Right ILF','Left SLF','Right SLF','Left Uncinate','Right Uncinate','Left Arcuate','Right Arcuate'
%AFQ_plot('patient',patient_data,'control',control_data,'tracts',[11,12,13,14,15,16,19,20],'group')

% plot 'Left IFOF',,'Left ILF','Left SLF','Left Arcuate'
% AFQ_plot('patient',patient_data,'control',control_data,'tracts',[11,13,15,19],'group')

%AFQ_plot('control',control_data, 'legend',afq.sub_names,'tracts',[11,12,13,14,15,16,19,20],'individual');
%
catch
% Code to handle the error
    disp('An error occurred, skipping to the next line.')
end

% Each subjects AFQ.mat file is saved as sub-id_afq.mat
save(char(strcat(afq_dir,output_name)),'afq','patient_data','control_data','abn','abnTracts', '-v7.3')
toc
