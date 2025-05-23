function afq(SubId)
% This matlab script takes the dt6.mat data to generate whole brain tractography
% to compute FA, probablistic tractography
% Creators: Avantika Mathur (Ph.D., Post-doc)
% Bugs or comments:  avantika9mathur@gmail.com
% Authorship to be given to  Avantika Mathur for using this script
% BDL lab-PI James Booth
% Last updated: 7/8/2015

%SubId = ('sub-5479');
tic
parpool;

try
% Output Name - for the afq.mat file
output_name = char(strcat(SubId,'_afq.mat'));
SubId = {SubId};

datapath = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/';%Specify the path where subject data exists
afq_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/afq_ses5/';%Specify the path where the afq output file will be used
ses = 'ses-5'; % session

% add all toolbox paths which are needed for AFQ
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/AFQ-1.2'));
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/vistasoft-master'));
addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12');    
% set SPM batch working environment
spm('Defaults','fmri');
spm_jobman('initcfg'); %params = defaults.old.normalise.estimate % edited in %afq_segmentfibergroups
%% don not change below
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
% Since we only have control subjects. We assign zero to all participants.

sub_group = cell(numel(SubId),1);
sub_group(1:end) = num2cell(zeros);
% Convert sub_group to a vector
sub_group = [sub_group{:}];

% AFQ_run
if size(SubId,1) ~= size(sub_group,1)
	errordlg('The number of subjects does not match the group array!  Please double check!');
	return;
end

% define afq -use the deafault params
afq = AFQ_Create('sub_dirs', sub_dirs, 'sub_names', sub_names, 'sub_group',sub_group(:,1));
[afq patient_data control_data abn abnTracts] = AFQ_run(sub_dirs, sub_group, afq);

% plot 'Left IFOF','Right IFOF','Left ILF','Right ILF','Left SLF','Right SLF','Left Uncinate','Right Uncinate','Left Arcuate','Right Arcuate'
%AFQ_plot('patient',patient_data,'control',control_data,'tracts',[11,12,13,14,15,16,19,20],'group')
%AFQ_plot('patient',patient_data,'control',control_data, 'legend',afq.sub_names,'tracts',[11,12,13,14,15,16,19,20],'individual');

catch
% Code to handle the error
    disp('An error occurred, skipping to the next line.')
end

% Each subjects AFQ.mat file is saved as sub-id_afq.mat
save(char(strcat(afq_dir,output_name)),'afq','patient_data','control_data','abn','abnTracts', '-v7.3')
toc
