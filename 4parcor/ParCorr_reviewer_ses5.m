% Get Tract FA and compute partial correlation with Behavioural scores -
% EDITED for answering reviewer's comment "Relatedly, it might make sense to include partial correlations for each of the tracts and groups for 
% phonological processing and word classes without controlling for the other (only controlling for age and NVIQ) for broader comparison 
% to other studies. This could be included in the SM only."
% AM - Aug 7 2025

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
% load('All_afq_30.mat')
% 
% % Get FA values of 30 nodes of tracts of interest - 11 IFOF, 13 ILF, 15 SLF, 19 AF.
% data_AF_30 = AFQ_get(afq,'left Arcuate', 'fa');
% data_IFOF_30 = AFQ_get(afq,'left IFOF', 'fa');
% data_ILF_30 = AFQ_get(afq,'left ILF', 'fa');
% data_SLF_30 = AFQ_get(afq,'left SLF', 'fa');

%Read Behavioral Data
data_info=['/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/Scripts/idfile_afq_ses7_corrected.xlsx']; %final_sample sheet, the subject column should have sub plus subject number.(e.g. sub-5003)
M = readtable(data_info, 'Sheet','SIDS_ses7_Parcorr');

% % Read Behavioral Data
data_info=['/panfs/accrepfs.vampire/data/booth_lab/AM/ELP_DTI/Scripts/4parcor/idfile_afq_ses5.xlsx']; %final_sample sheet, the subject column should have sub plus subject number.(e.g. sub-5003)
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
%  nodes) with raw Scores Elision, controlling for NVIQ, Age
x100 = data_AF_100; % FA of arcuate at 100 nodes

y = [M.CTOPP_2_EL_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
%c = [M.CELF_WC_Raw]; % Control
covariates = [a,b]; % Combine control covariates

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
significant_r(p >= 0.0023) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at FWE corrected level');
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
% x30 = data_SLF_30; % FA of SLF at 30 nodes

y = [M.CTOPP_2_EL_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
% c = [M.CELF_WC_Raw]; % Control
covariates = [a,b]; % Combine control covariates

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
significant_r(p >= 0.004) = 0;
% Display significant_r if there are any values greater than 0
if any(significant_r > 0)
    [~, cols] = find(significant_r);
    disp(cols);
else
    disp('No significant values at statFWE');
end
%% Left IFOF
% The following codes runs partial correlation analysis of FA -IFOF (100 nodes) with raw Scores Word classes (CELF), controlling for NVIQ, Age
x100 = data_IFOF_100; % FA of IFOF at 100 nodes

y = [M.CELF_WC_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
%c = [M.CTOPP_2_EL_Raw]; % Control
covariates = [a,b]; % Combine control covariates

% Partial Correlation IFOF with raw Scores Word classes, controlling for
% NVIQ, Age, raw scores Elision
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
    [~, cols] = find(significant_r); % Significant nodes at p < 0.05, uncorrected
    disp(cols);
else
    disp('No significant values at uncorrected p <0.05');
end


%% Left ILF
% The following codes runs partial correlation analysis of FA -ILF (100 and 30 nodes) with raw Scores Word classes (CELF), controlling for NVIQ, Age, raw scores Elision

x100 = data_ILF_100; % FA of ILF at 100 nodes
y = [M.CELF_WC_Raw]; % Predictor vector
a = [M.Age]; % Control
b = [M.KBIT_Nonverbal_StS];% Control
%c = [M.CTOPP_2_EL_Raw]; % Control
covariates = [a,b]; % Combine control covariates

% Partial Correlation ILF with raw Scores Elision, controlling for NVIQ, Age, raw scores CELF
% Word Classes
r = zeros(1,100);
p = zeros(1,100);
for i = 1:100
[r(i),p(i)] = partialcorr(x100(:,i),y, covariates,'rows','pairwise','Type','Spearman');
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
