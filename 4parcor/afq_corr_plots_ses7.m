% Display Correlation coefficients on tract profiles
% AM - Jul 10 2024
% 11 IFOF, 13 ILF, 15 SLF, 19 AF.
%% Make Tract Profiles 
sub_dirs = '/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/sub-5003/ses-7/dwi_analysis/dtitrilin';
% Load the cleaned segmented fibers for the first control subject
fg = dtiReadFibers(fullfile(sub_dirs,'fibers','MoriGroups_clean_D5_L4.mat'));
% Load the subject's dt6 file
dt = dtiLoadDt6(fullfile(sub_dirs,'dt6.mat'));
% Compute Tract Profiles with 100 nodes
%numNodes = 100;% change to 30 for 30
numNodes = 30;
[fa, md, rd, ad, cl, volume, TractProfile] = AFQ_ComputeTractProperties(fg,dt,numNodes);

%% Load data to display for IFOF - r  is the correlation value and p in the significance of the partial
% correlation computed with ParCorr Script  (LINE160-185)
% add these values to the tract profile
TractProfile(11) = AFQ_TractProfileSet(TractProfile(11),'vals','significant_r',significant_r(1,:));
TractProfile(11) = AFQ_TractProfileSet(TractProfile(11),'vals','p',p(1,:));

% Render
cmap = 'hot';
crange = [0 0.05]; % p - value
numfibers = 200;
AFQ_RenderFibers(fg(11),'color',[.8 .8 1],'tractprofile',TractProfile(11),...
    'val','p','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);

% Render sig correlation coeff
cmap = [0.9 0.9 0.9; colormap('autumn')];
colormap(cmap);
crange = [0 1]; % r - value
numfibers = 200;
AFQ_RenderFibers(fg(11),'color',[.8 .8 1],'tractprofile',TractProfile(11),...
    'val','significant_r','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);
grid off
%% Diplay of partial correlation results ILF - WID [results obtained from line302-347 of ParCorr script)
% Plot p -value
TractProfile(13) = AFQ_TractProfileSet(TractProfile(13),'vals','p',results.ILF.p(1,:));
AFQ_RenderFibers(fg(13),'color',[.8 .8 1],'tractprofile',TractProfile(13),...
    'val','p','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);

% Plor Correlation Coeff
TractProfile(13) = AFQ_TractProfileSet(TractProfile(13),'vals','significant_r',results.ILF.sig_r(1,:));
% Render sig correlation coeff
cmap = [colormap('winter'); 0.9 0.9 0.9];
colormap(cmap);
crange = [-1 0]; % r - value
numfibers = 200;
AFQ_RenderFibers(fg(13),'color',[.8 .8 1],'tractprofile',TractProfile(13),...
    'val','significant_r','numfibers',numfibers,'cmap',cmap,'crange',crange,...
    'radius',[1 6]);
grid off