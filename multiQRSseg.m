function [rPeaksMat,qOnMat,qOffMat] = multiQRSseg(Fsignal,fs,qualLim,visu)

% Number of channels
nChan = size(Fsignal,2);

%% 1.1 Detect Rpeaks in each channel by the absolute 
% Obtain absolute signal for each channel and find Rpeaks
rpeaksDetected = cell(1,nChan);
for ch = 1 : nChan
    % Absolute of each chanel
    absCh = abs(Fsignal(:,ch));
    rpeaksDetected{1,ch} = rPeakDet(absCh,fs);
end

%% 1.2 Post processing Rpeaks - obtain matrix same number hbeats in all leads
rPeaksMat = postProcRpeaks(rpeaksDetected,Fsignal,fs);

%% 2.1 Detect QS points 
% Automatically detected QS using ECGkit
for ch = 1 : nChan
    % Params ECGkit
    ECG_header.nsig = 1; 
    ECG_header.freq = fs;
    wavedet_config.setup.wavedet.QRS_detection_only = 0;
    ECG_header.nsamp = size(Fsignal,1);
    [Fid,~,~] = wavedet_3D(Fsignal(:,ch), rPeaksMat(:,ch)', ECG_header, wavedet_config);
    qOnMat(:,ch) = Fid.QRSon';
    qOffMat(:,ch) = Fid.QRSoff';
end

%% 2.2 Post-processing QS to align heartbeats
[rPeaksMat,qOnMat,qOffMat] = postProcQRS(Fsignal,fs,rPeaksMat,qOnMat,qOffMat,qualLim,visu);


