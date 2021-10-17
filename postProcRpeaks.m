function rPeaksMat = postProcRpeaks(cellRpeaks,Fsignal,fs)


%% Remove if first or last visit are too close to the extremes

beatsDist = 0.12*fs; % At least Rpeak at more than 120ms from extremes

for ch = 1 : length(cellRpeaks)
    if cellRpeaks{1,ch}(1,1) <= beatsDist 
        cellRpeaks{1,ch} = cellRpeaks{1,ch}(2:end);
    end
    if cellRpeaks{1,ch}(1,end) + beatsDist > size(Fsignal,1)
        cellRpeaks{1,ch} = cellRpeaks{1,ch}(1:end-1);
    end
end
% removeBeats = zeros(1,2);
% % If the first beat is before beatDist
% if sum(rPeaksMat(1,:) <= beatsDist) > 0
%     removeBeats(1,1) = 1;
%     % If the last beat is closer than beatDist to the end of the signal
% elseif sum(rPeaksMat(end,:) >= (size(Fsignal,1)-beatsDist)) > 0
%     removeBeats(1,2) = 1;
% end
% 
% % If some of them are 1, remove from beats
% if removeBeats(1,1) == 1
%     rPeaksMat(1,:) = [];
% elseif removeBeats(1,2) == 1
%     rPeaksMat(end,:) = [];
% end

%% Calculate nR as the mode of the number of Rpeaks detected in all the leads
nR = mode(cellfun(@length,cellRpeaks));
% New container correct Rpeaks
rPeaksMat = nan(nR,12);

% First store correctly detected Rpeaks
chCorr = find(cellfun(@length,cellRpeaks)==nR);
for ch = 1 : length(chCorr)
    rPeaksMat(:,chCorr(ch)) = cellRpeaks{1,chCorr(ch)}';
end

% Find channels where there were problems in Rpeak detection
chIncorr = find(cellfun(@length,cellRpeaks)~=nR);

%% Correct problematic leads
% Check window = 40ms
checkWin = round(0.040*fs);
for ch = 1 : length(chIncorr)
    % If number of detected Rpeaks is greater than nR
    if length(cellRpeaks{1,chIncorr(ch)}) > nR
        % For each correct Rpeak find closest peak detected in that lead
        % and save it
        for hb = 1 : nR
            % Approx position of correct Rpeak based on correct leads
            approxPos = round(nanmean(rPeaksMat(hb,:)));
            % Find location of the correct Rpeak in all peaks detected
            [~,pos] = min(abs(cellRpeaks{1,chIncorr(ch)} - approxPos));
            % Store the correct one
            rPeaksMat(hb,chIncorr(ch)) = cellRpeaks{1,chIncorr(ch)}(pos);
        end
    % If there are less peaks detected in that lead than nR
    elseif length(cellRpeaks{1,chIncorr(ch)}) < nR
        % For each correct Rpeak find closest peak detected in that lead.
        % If i was not detected, check again around that position in window
        % 8ms
        for hb = 1 : nR
            % Approx position of correct Rpeak based on correct leads
            approxPos = round(nanmean(rPeaksMat(hb,:)));
            % Find location and minDis to the correct Rpeak in all peaks detected
            [minDis,pos] = min(abs(cellRpeaks{1,chIncorr(ch)} - approxPos));
            % If that distance is smaller than 10
            if minDis < checkWin
                % Store that Rpeak
                rPeaksMat(hb,chIncorr(ch)) = cellRpeaks{1,chIncorr(ch)}(pos);
            % If greater than 10, that Rpeak was not detected    
            else
                % Select segment 21 samples around actual position Rpeak in aboslute signal   
                absChSegment = abs(Fsignal(approxPos - checkWin : approxPos + checkWin,ch));
                % Find maximum in that segment
                [~,locMaxAround] = max(absChSegment);
                % Store the Rpeak
                rPeaksMat(hb,chIncorr(ch)) = approxPos - checkWin + locMaxAround - 1;
            end
        end
    end
end


