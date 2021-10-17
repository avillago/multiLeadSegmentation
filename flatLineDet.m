function chansZero = flatLineDet(signal)

% Prepare data
[size1,size2] = size(signal);
if size1>size2
    nSamp = size1;
    nChan = size2;
elseif size2>size1
    nSamp = size2;
    nChan = size1;
    
    signal = signal';
end

% Calculare variance for channel
for ch = 1 : nChan
    varVal(ch) = var(signal(:,ch));
end

chansZero = find(varVal < 0.001);