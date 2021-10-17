%% Check signals for plots

close all;
clearvars;
clc;
    fileInfo = '\\samba-sista\avillago\UZLeuven\fQRSDB.xlsx';
pathMyLaptop = '\\samba-sista\avillago\UZLeuven\';

warning off all;
%% Read files and see which ones are useful

dataExcelGriet = readtable(fileInfo);

%% Extract features all files and we will see later
listPats = dataExcelGriet.EAD;

pathStorage = 'C:\Users\avillago\Documents\PhD\data\vtStorm\multiLeadSegmentation\templateFiles\';

for p = 31 : 45
    
    %% load data
    disp(['Processing file : ', num2str(listPats(p))]);
    if isfile(fullfile(pathMyLaptop,strcat(num2str(listPats(p)),'.csv')))
        signal = readmatrix(fullfile(pathMyLaptop,strcat(num2str(listPats(p)),'.csv')));
        ecg = signal(:,2:13);
        fs = 1/(signal(2,1)-signal(1,1));
    end
    save(fullfile(pathStorage,strcat('multiLeadECG',num2str(p))),'ecg','fs');
end