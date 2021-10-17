%% Demo code to test the algorithm

close all;
clearvars;
clc;

%% Add path R-DECO and ECG-kit

% Path Rdeco
addpath(genpath('C:\Users\avillago\Documents\r-deco'));
% addpath(genpath('.\r-deco'));
% Path ECG-kit
addpath(genpath('C:\Users\avillago\Documents\matlabToolboxes\ecg-kit'));
% addpath(genpath('.\ecg-kit'));

%% Load example signal

listFiles = [4,9,25,44];
close all;
for p = 1 : 4
    load(fullfile('.\templateFiles\',strcat('multiLeadECG',num2str(listFiles(p)))));
    
    %% 1 Filter signal and normalize
    
    Fsignal = filterSignal(ecg,fs,'HL',0.35,70); % Filtering up to 70Hz to keep fragmentation
    
    %% 2. Flat line detection
    flatChans = flatLineDet(Fsignal);
    leads2use = 1 : size(ecg,2);
    % if there is any flat lead
    if ~isempty(flatChans)
        % Exclude these leads from the analysis
        leads2use(flatChans) = [];
        Fsignal = Fsignal(:,leads2use);
        channels = length(leads2use);
    end
    
    %% 2 Segment heartbeats
    
    % Define quality limit to remove irregular heartbeats
    qualLim = 0.85;
    % Plot results flag - yes
    visu = 1;
    
    % Obtain Rpeaks, Q and S locations
    [rpeaks,qOn,qOff] = multiQRSseg(Fsignal,fs,qualLim,visu);
    
end
