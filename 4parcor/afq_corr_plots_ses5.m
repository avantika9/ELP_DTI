% Display Correlation coefficients on tract profiles
% AM - Jul 10 2024
% 11 IFOF, 13 ILF, 15 SLF, 19 AF.
%% Make Tract Profiles 
sub_dirs = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/sub-5008/ses-5/dwi_analysis/dtitrilin';
% Load the cleaned segmented fibers for the first control subject
fg = dtiReadFibers(fullfile(sub_dirs,'fibers','MoriGroups_clean_D5_L4.mat'));
% Load the subject's dt6 file
dt = dtiLoadDt6(fullfile(sub_dirs,'dt6.mat'));
% Compute Tract Profiles with 100 nodes
numNodes = 100;%
%numNodes = 30;
[fa, md, rd, ad, cl, volume, TractProfile] = AFQ_ComputeTractProperties(fg,dt,numNodes);

%% Load data to display for AF - r  is the correlation value and p in the significance of the partial
% correlation computed with ParCorr Script  (LINE160-185)
% add these values to the tract profile
TractProfile(19) = AFQ_TractProfileSet(TractProfile(19),'vals','significant_r',significant_r(1,:));
TractProfile(19) = AFQ_TractProfileSet(TractProfile(19),'vals','p',p(1,:));

% Render p - value
cmap = 'hot';
crange = [0 0.05]; % p - value
numfibers = 200;
AFQ_RenderFibers(fg(19),'color',[.8 .8 1],'tractprofile',TractProfile(19),...
    'val','p','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);

% Render sig correlation coeff
cmap = [0.9 0.9 0.9; colormap('autumn')];
colormap(cmap);
crange = [0 1]; % r - value
numfibers = 200;
AFQ_RenderFibers(fg(19),'color',[.8 .8 1],'tractprofile',TractProfile(19),...
    'val','significant_r','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);
% Remove grid lines globally
grid off

%% Diplay of partial correlation results AF/SLF/IFOF - WID [results obtained from line302-347 of ParCorr script)
% 11 IFOF, 13 ILF, 15 SLF, 19 AF.

TractProfile(19) = AFQ_TractProfileSet(TractProfile(19),'vals','significant_r',results.AF.sig_r(1,:));
% Render
cmap = [0.9 0.9 0.9; colormap('autumn')];
colormap(cmap);
crange = [0 1]; % r - value
numfibers = 200;
AFQ_RenderFibers(fg(19),'color',[.8 .8 1],'tractprofile',TractProfile(19),...
    'val','significant_r','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);
grid off
