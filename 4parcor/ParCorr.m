% Get Tract FA and compute partial correlation with Behavioural scores
% AM - Jul 10 2024

% add AFQ and script paths
addpath(genpath('/panfs/accrepfs.vampire/data/booth_lab/DTI_Tools/AFQ-1.2'));
addpath(genpath('/panfs/accrepfs.vampire/data/booth_lab/DTI_Tools/vistasoft-master'));
addpath('/panfs/accrepfs.vampire/data/booth_lab/LabCode/typical_data_analysis/spm12');   
addpath '/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/afq_ses5' % add AFQ path select ses-5/ses-7
%addpath '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/AM/ELP_DTI/afq_ses5' % add AFQ path select ses-5/ses-7
addpath '/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/Scripts' %add Scripts

% Load the variables from AFQ_100.mat to matlab workspace - ses path
% selected above
load('All_afq_100.mat')

% Get FA values of 100 nodes of tracts of interest - 11 IFOF, 13 ILF, 15 SLF, 19 AF.
data_AF_100 = AFQ_get(afq,'left Arcuate', 'fa');
data_IFOF_100 = AFQ_get(afq,'left IFOF', 'fa');
data_ILF_100 = AFQ_get(afq,'left ILF', 'fa');
data_SLF_100 = AFQ_get(afq,'left SLF', 'fa');

% Load the variables from AFQ_30.mat to matlab workspace
load('All_afq_30.mat')

% Get FA values of 30 nodes of tracts of interest - 11 IFOF, 13 ILF, 15 SLF, 19 AF.
data_AF_30 = AFQ_get(afq,'left Arcuate', 'fa');
data_IFOF_30 = AFQ_get(afq,'left IFOF', 'fa');
data_ILF_30 = AFQ_get(afq,'left ILF', 'fa');
data_SLF_30 = AFQ_get(afq,'left SLF', 'fa');

%Read Behavioral Data
  data_info=['/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/Scripts/idfile_afq_ses7_corrected.xlsx']; %final_sample sheet, the subject column should have sub plus subject number.(e.g. sub-5003)
  M = readtable(data_info, 'Sheet','SIDS_ses7_Parcorr');

% % Read Behavioral Data
data_info=['/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/Scripts/idfile_afq_ses5.xlsx']; %final_sample sheet, the subject column should have sub plus subject number.(e.g. sub-5003)
M = readtable(data_info, 'Sheet','SIDS_ses5_Parcorr');


%% Normality check
y = [M.CTOPP_2_EL_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
c = [M.CELF_WC_Raw]; % Control
matrices = {data_AF_100,data_IFOF_100, data_ILF_100, data_SLF_100,data_AF_30, data_IFOF_30,data_ILF_30, data_SLF_30,y,a,b,c};
matrices = {data_IFOF_30,data_ILF_30, data_SLF_30,y,a,b,c};
% Assume you have multiple matrices stored in a cell array 'matrices'
for i = 1:length(matrices)
    x = matrices{i};
    [h, p] = jbtest(x(:)); % Jarque-Bera test for normality
    if h == 0
        disp(['Matrix ', num2str(i), ' is normally distributed']);
    else
        disp(['Matrix ', num2str(i), ' is not normally distributed']);
    end
    % Alternatively, you can display the p-value
    disp(['p-value: ', num2str(p)]);
end

% The results indicate that only KBIT is normally distributed, all the
% other variables are not normally distributed, thus we decide to use
% Spearman Correlations


%% Left AF
% The following codes runs partial correlation analysis of FA -arcuate (100
% and 30 nodes) with raw Scores Elision, controlling for NVIQ, Age, raw
% scores CELF-Word classes
x100 = data_AF_100; % FA of arcuate at 100 nodes
x30 = data_AF_30; % FA of arcuate at 30 nodes

y = [M.CTOPP_2_EL_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
c = [M.CELF_WC_Raw]; % Control
covariates = [a,b,c]; % Combine control covariates

% Word Classes
r = zeros(1,100);
p = zeros(1,100);
for i = 1:100
[r(i),p(i)] = partialcorr(x100(:,i),y, covariates,'rows','pairwise','Type','spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end
% compute the average FA of significant cluster 
y_AF_Elision_SIGNODES = nanmean(data_AF_100(:, 68:87), 2);


% Do not change below
% Multiple Comparison correction
% the AFQ_multicomcorrection does not account for partial correlation - the code has been edited to account for control vectors
% The code below generates the FWE corrected p value and cluster threshold.
% These values are used to check the significance of partial correlation
% results.
[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100) 

% ses5% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.0028) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at FWE corrected level');
end

% AFQ-30
% Partial Correlation AF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,30);
p = zeros(1,30);
for i = 1:30
[r(i),p(i)] = partialcorr(x30(:,i),y, covariates,'rows','pairwise','Type','spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end

% Do not change below
% Multiple Comparison correction
% the AFQ_multicomcorrection does not account for partial correlation - the code has been edited to account for control vectors
% The code below generates the FWE corrected p value and cluster threshold.
% These values are used to check the significance of partial correlation
% results.
[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100) 


%% Left SLF
% The following codes runs partial correlation analysis of FA -SLF (100 and
% 30 nodes) with raw Scores Elision, controlling for NVIQ, Age, raw scores
% CELF-Word classes

x100 = data_SLF_100; % FA of SLF at 100 nodes
x30 = data_SLF_30; % FA of SLF at 30 nodes

y = [M.CTOPP_2_EL_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
c = [M.CELF_WC_Raw]; % Control
covariates = [a,b,c]; % Combine control covariates

% Do not change below
% AFQ100 
% Multiple Comparison correction
% the AFQ_multicomcorrection does not account for partial correlation - the
% code has been edited to account for control vectors
% The code below generates the FWE corrected p value and cluster threshold.
% These values are used to check the significance of partial correlation
% results.
[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

% Partial Correlation FA-SLF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,100);
p = zeros(1,100);
for i = 1:100
[r(i),p(i)] = partialcorr(x100(:,i),y, covariates,'rows','pairwise','Type','spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end

% AFQ-30
[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)

% Partial Correlation AF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,30);
p = zeros(1,30);
for i = 1:30
[r(i),p(i)] = partialcorr(x30(:,i),y, covariates,'rows','pairwise','Type','spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end

%% Left IFOF
% The following codes runs partial correlation analysis of FA -IFOF (100 and 30 nodes) with raw Scores Word classes (CELF), controlling for NVIQ, Age, raw scores Elision
x100 = data_IFOF_100; % FA of IFOF at 100 nodes
x30 = data_IFOF_30; % FA of IFOF at 30 nodes

y = [M.CELF_WC_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
c = [M.CTOPP_2_EL_Raw]; % Control
covariates = [a,b,c]; % Combine control covariates

% AFQ100 
% Multiple Comparison correction
% the AFQ_multicomcorrection does not account for partial correlation - the
% code has been edited to account for control vectors
[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

% Partial Correlation IFOF with raw Scores Word classes, controlling for
% NVIQ, Age, raw scores Elision
% Word Classes
r = zeros(1,100);
p = zeros(1,100);
for i = 1:100
[r(i),p(i)] = partialcorr(x100(:,i),y, covariates,'rows','pairwise','Type','spearman');
end

significant_r = r;
significant_r(p >= 0.0016) = 0; % P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected fwe');
end

% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r); % Significant nodes at p < 0.05, uncorrected
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end
% compute the average FA of significant cluster (41-57)
y_IFOF_SIGNODES = mean(data_IFOF_100(:, 41:57), 2);

% AFQ-30
[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)
% Partial Correlation AF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,30);
p = zeros(1,30);
for i = 1:30
[r(i),p(i)] = partialcorr(x30(:,i),y, covariates,'rows','pairwise', 'Type', 'spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end
%% Left ILF
% The following codes runs partial correlation analysis of FA -ILF (100 and 30 nodes) with raw Scores Word classes (CELF), controlling for NVIQ, Age, raw scores Elision

x100 = data_ILF_100; % FA of ILF at 100 nodes
x30 = data_ILF_30; % FA of ILF at 30 nodes

y = [M.CELF_WC_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
c = [M.CTOPP_2_EL_Raw]; % Control
covariates = [a,b,c]; % Combine control covariates

% AFQ100 
% Multiple Comparison correction
% the AFQ_multicomcorrection does not account for partial correlation - the
% code has been edited to account for control vectors
[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

% Partial Correlation ILF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,100);
p = zeros(1,100);
for i = 1:100
[r(i),p(i)] = partialcorr(x100(:,i),y, covariates,'rows','pairwise','Type','Spearman');
end

significant_r = r;
significant_r(p >= 0.0019) = 0;%P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)

% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected fwe');% Significant nodes at p < 0.05, uncorrected
end

% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end

% AFQ-30
[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)
% Partial Correlation AF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,30);
p = zeros(1,30);
for i = 1:30
[r(i),p(i)] = partialcorr(x30(:,i),y, covariates,'rows','pairwise','Type', 'Spearman');
end
% Compute a new vector that converts non-significant values in the 'r' vector to 0 and displays only significant values
significant_r = r;
significant_r(p >= 0.05) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end


%% FA of SLF, AF, ILF, and IFOF correlated with Word ID controlling for NVIQ, Age,
tract_names = {'SLF', 'AF', 'IFOF', 'ILF'};
data_names_100 = {'data_SLF_100', 'data_AF_100', 'data_IFOF_100', 'data_ILF_100'};
data_names_30 = {'data_SLF_30', 'data_AF_30', 'data_IFOF_30', 'data_ILF_30'};
% Specify number of nodes here
num_nodes = 30;% or 30
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine control covariates

results = struct();
% Partial Correlation
for tract_idx = 1:length(tract_names)
    r = zeros(1,num_nodes);
    p = zeros(1,num_nodes);
        
        switch num_nodes
        case 100
            data_names = data_names_100;
        case 30
            data_names = data_names_30;
        otherwise
            error('Invalid number of nodes');
        end
    tract_fa = evalin('base',data_names{tract_idx});
    for i = 1:num_nodes
        [r(i),p(i)] = partialcorr(tract_fa(:,i), y, covariates,'rows','pairwise', 'Type', 'Spearman');
    end
    significant_r = r;
    significant_r(p >= 0.05) = 0;

    results.(tract_names{tract_idx}).r = r;
    results.(tract_names{tract_idx}).p = p;
    results.(tract_names{tract_idx}).sig_r = significant_r;

    if any(significant_r(:) ~= 0) 
        [~, cols] = find(significant_r);
        disp([tract_names{tract_idx}, ' significant nodes: ', num2str(cols)]);
    else
        disp(['No significant values in ', tract_names{tract_idx}, '.']);
    end
end

%% AF Multiple Comparison correction
x100 = data_AF_100; % FA of arcuate at 100 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)


x30 = data_AF_30; % FA of arcuate at 30 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)

% AF Multiple Comparison correction - Load r and p and set FWE p threshold
significant_r = results.AF.r;
p = results.AF.p;
significant_r(p >= 0.0025) = 0;% P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected FWE');
end
% compute the average FA of significant cluster 
y_AF_WID_SIGNODES = nanmean(data_AF_100(:, 67:77), 2);

%% SLF Multiple Comparison correction
x100 = data_SLF_100; % FA of SLF at 100 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

x30 = data_SLF_30; % FA of SLF at 30 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)

% SLF Multiple Comparison correction - Load r and p and set FWE p threshold
significant_r = results.SLF.r;
p = results.AF.p;
significant_r(p >= 0.0051) = 0;% P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected FWE');
end

%% ILF Multiple Comparison correction
x100 = data_ILF_100; % FA of arcuate at 100 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

% ILF Multiple Comparison correction- Load r and p and set FWE p threshold
significant_r = results.ILF.r;
p = results.ILF.p;
significant_r(p >= 0.05) = 0;% P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected FWE');
end

% compute the average FA of significant cluster
y_ILF_SIGNODES = nanmean(data_ILF_100(:, 11:19), 2);

%% IFOF Multiple Comparison correction
x100 = data_IFOF_100; % FA of ifof at 100 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_100, statFWE_100, clusterFWE_100, stats_100] = AFQ_MultiCompCorrection_parcorr(x100,y,covariates);
output_100 = struct('alphaFWE', alphaFWE_100, 'statFWE', statFWE_100, 'clusterFWE', clusterFWE_100, 'stats', stats_100);
disp(output_100)

x30 = data_IFOF_30; % FA of ifof at 30 nodes
y = [M.WJ_III_WordID_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
covariates = [a,b]; % Combine covariates

[alphaFWE_30, statFWE_30, clusterFWE_30, stats_30] = AFQ_MultiCompCorrection_parcorr(x30,y,covariates);
output_30 = struct('alphaFWE', alphaFWE_30, 'statFWE', statFWE_30, 'clusterFWE', clusterFWE_30, 'stats', stats_30);
disp(output_30)

% IFOF Multiple Comparison correction - Load r and p and set FWE p threshold
significant_r = results.IFOF.r;
p = results.AF.p;
significant_r(p >= 0.0017) = 0;% P IS SET HERE AS THE OUTPUT OF AFQ_MultiCompCorrection (alphaFWE)
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at corrected FWE');
end
