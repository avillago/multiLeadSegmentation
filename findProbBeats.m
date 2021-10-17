function probBeat = findProbBeats(corrMats,qualLim)

% Number Channels
nChan = length(corrMats);
% Number heartbeats
nBeats = size(corrMats{1,1},1);
% Location problematic beats
probBeat = zeros(nBeats,nChan);

% If all corrs are low in one lead, useless lead
for ch = 1 : nChan
    corrMats{2,ch} = corrMats{1,ch};
    % Set scores above qualLim to 1,rest to 0
    corrMats{2,ch}(corrMats{2,ch} < qualLim) = 0;
    corrMats{2,ch}(corrMats{2,ch} >= qualLim) = 1;
    % If sum of zeros is greater than the amount of beats - prolematic case
    %     if sum(sum(corrMats{2,ch}==0,1)) > size(corrMats{2,ch})
    lowScores = sum(corrMats{2,ch}==0,1);
    if sum(lowScores) > 0
        for hb = 1 : length(lowScores)
            % If some hb brings too much problem, remove it from considered
            % heartbeats
            if lowScores(hb) > floor(size(corrMats{1,ch})/2)
                probBeat(hb,ch) = 1;
            end
        end
       
    end
end