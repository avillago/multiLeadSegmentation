function rpeaksDetected = rPeaksJo(filteredECG,fs)

% Prepare data
[size1,size2] = size(filteredECG);
if size1>size2
    nSamp = size1;
    nChan = size2;
elseif size2>size1
    nSamp = size2;
    nChan = size1;
    
    filteredECG = filteredECG';
end

% Find Rpeaks per lead
for l = 1 : nChan
    [locs,~,~,~] = peak_detection({300,100,0,0,0},filteredECG(:,l),fs,0);
    rpeaksDetected = locs{1,1};
end
