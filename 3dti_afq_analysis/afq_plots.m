% AFQ plots - representing average FA across subjects.
% AM - Jul 10 2024
addpath(genpath('/panfs/accrepfs.vampire/data/booth_lab/DTI_Tools/AFQ-1.2'));
addpath(genpath('/panfs/accrepfs.vampire/data/booth_lab/DTI_Tools/vistasoft-master'));
% Load the variables from AFQ.mat to matlab workspace
addpath '/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/afq_ses5'
load('All_afq_100.mat')

% line plots of mean FA and standard error - 'Left IFOF',,'Left ILF','Left SLF','Left Arcuate' tract FA

% repeat the following code for tracts 11, 13, 15,19 for making tract
% profiles
AFQ_plot('patient',patient_data,'control',control_data,'tracts',[13],'group');

hold on
ylim([0.25 0.60])
set(gcf,'color','w')
%set(get(gca, 'XLabel'), 'FontSize', 18);
% Set the y-axis tick labels
%set(gca, 'XTick', 0:10:100, 'XTickLabel', 0:10:100);
%set(gca, 'XTickLabel', get(gca, 'XTick'), 'FontSize', 18);
% Set the X-axis tick labels
%set(gca, 'YTick', 0.25:0.05:0.60, 'YTickLabel', 0.25:0.05:0.60);
%set(get(gca, 'YLabel'), 'FontSize', 18);
%set(gca, 'YTickLabel', get(gca, 'YTick'), 'FontSize', 18);

%% Average FA along each fiber tract for each of the 100 nodes
% Loop over all 20 fiber groups
for jj = 1:20
    [h(jj,:)] = nanmean(afq.control_data(jj).FA,1);
end


%% Make Tract Profiles 
sub_dirs = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/sub-5010/ses-5/dwi_analysis/dtitrilin';

%sub_dirs = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/sub-5008/ses-7/dwi_analysis/dtitrilin';

% Load the cleaned segmented fibers for the first control subject
fg = dtiReadFibers(fullfile(sub_dirs,'fibers','MoriGroups_clean_D5_L4.mat'));
% Load the subject's dt6 file
dt = dtiLoadDt6(fullfile(sub_dirs,'dt6.mat'));
% Compute Tract Profiles with 100 nodes
numNodes = 100;
[fa, md, rd, ad, cl, volume, TractProfile] = AFQ_ComputeTractProperties(fg,dt,numNodes);
% Add the average from the group to the tract
% profile. This same code could be used to add correlation coeficients or
% other statistics
for jj = 1:20
    TractProfile(jj) = AFQ_TractProfileSet(TractProfile(jj),'vals','fa',h(jj,:));
end

%% Render The tract Profiles 

% The hot colormap is a good one because it will allow us to make regions
% of the profile where p>0.05 black.
cmap = 'hot';
% Set the color range 
crange = [0 1]; % FA average range between 0 and 1
% Set the number of fibers to render. More fibers takes longer
numfibers = 400;
% Render the left corticospinal tract (fibers colored light blue) with a
% Tract Profile of T statistics. Each fiber will have a 1mm radius and the
% tract profile will have a 6mm radius.
% 11 IFOF, 13 ILF, 15 SLF, 19 AF.
AFQ_RenderFibers(fg(13),'color',[.8 .8 1],'tractprofile',TractProfile(13),...
    'val','fa','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);
hold on
caxis([0.25 0.60])
%caxis([0.35 0.45])
grid off


% Add the defining ROIs to the rendering.
[roi1 roi2] = AFQ_LoadROIs(13,sub_dirs);
% The rois will be rendered in dark blue
AFQ_RenderRoi(roi1,[0 0 .7]);
AFQ_RenderRoi(roi2,[0 0 .7]);
% Add the slice x=-15 from the subject's b=0 image
b0 = readFileNifti(dt.files.b0);
AFQ_AddImageTo3dPlot(b0,[-15,0,0]);



%% Just Tracts
figure
% Render 400 tract fibers in blue.
AFQ_RenderFibers(fg(11),'numfibers',2000,'color',[0 0 1]); %blue IFOF
AFQ_RenderFibers(fg(13),'numfibers',2000,'color',[0 1 0],'newfig',false)%GREEN ILF
AFQ_RenderFibers(fg(15),'numfibers',2000,'color',[1 1 0],'newfig',false) %YELLOW SLF
AFQ_RenderFibers(fg(19),'numfibers',2000,'color',[1 0 0],'newfig',false)% RED AF

% Surface rendering
% Load mesh
msh = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/DTI_Tools/AFQ-1.2/data/mesh/segmentation.nii.gz';
% Add mesh to fibres
AFQ_RenderCorticalSurface(msh, 'alpha',0.3,'boxfilter',5 ,'newfig', false);

grid off
axis off


% Sice
% Then add the slice X = -2 to the 3d rendering.
AFQ_AddImageTo3dPlot(b0,[-2, 0, 0]);
zlim([-50 100])


% % Load a nifti image
% Spm average template
nifti = readFileNifti('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP/spm12_elp/canonical/avg305T1.nii');
% Lab template
nifti = readFileNifti('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP/templates_cerebroMatic/ELP_7_105Template/mw_com_T1_Age_0105.nii');
% % Add a sagittal slice to the figure;
h = AFQ_AddImageTo3dPlot(nifti, [-20 0 0])

