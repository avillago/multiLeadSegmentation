function [rPeaksMat,qOnCorr,qOffCorr] = postProcQRS(Fsignal,fs,rPeaksMat,qOnMat,qOffMat,qualLim,visu)

% Number of channels
nChan = size(Fsignal,2);

%% 0. Is any Q or S Nan in all leads? - wrong beat
wrongBeat = [];
if sum(all(isnan(qOffMat),2))>0
    wrongBeat = [wrongBeat;find(all(isnan(qOffMat),2))];
end
if sum(all(isnan(qOnMat),2))>0
    wrongBeat = [wrongBeat;find(all(isnan(qOnMat),2))];
end

% Remove heartbeat from all QRS
rPeaksMat(wrongBeat,:) = [];
qOnMat(wrongBeat,:) = [];
qOffMat(wrongBeat,:) = [];

%% 1. Ajust annotations to the median of each point between all leads
for hb = 1 : size(rPeaksMat,1)
    qOnMat(hb,:) = round(median(qOnMat(hb,:),'omitnan'));
    qOffMat(hb,:) = round(median(qOffMat(hb,:),'omitnan'));
end

%% 2. Segment heartbeats and normalize by the maximum
segmentedBeats = cell(size(rPeaksMat));
for ch = 1 : nChan
    for hb = 1 : size(rPeaksMat,1)
        % Store segmented heartbeats
        segment = Fsignal(qOnMat(hb,ch):qOffMat(hb,ch),ch);
        % Store segment normalized
        segment = segment/max(abs(segment));
        segmentedBeats{hb,ch} = segment;
    end
end

if visu == 1
    % close all;
    figure()
    for ch = 1 : 12
        subplot(3,4,ch)
        for hb = 1 : size(rPeaksMat,1)
            plot(segmentedBeats{hb,ch})
            hold on;
            axis tight;
        end
    end
end

%% 3. Align heartbeats to obtain correlation matrix
corrMats = corrMatPerLead(segmentedBeats);

%% 4. Select template beat per lead is the one with highest cum. correlation and align heartbeats to it
newSegments = cell(size(segmentedBeats));
qrsOnCorr = zeros(size(qOnMat));
qrsOffCorr = zeros(size(qOffMat));
if visu == 1
    figure()
end
for ch = 1 : nChan
    %% 4.1 Find template beat
    [~,template] = max(sum(corrMats{1,ch})-1);
    
    %% 4.2 Aign heartbeats to it
    % Length of the template
    tempLength = length(segmentedBeats{template,ch});
    if visu == 1
        subplot(3,4,ch)
    end
    % Find templates in signal for each heartbeat
    for hb = 1 : size(corrMats{1,ch},2)
        if hb ~= template
            currLength = length(segmentedBeats{hb,ch});
            diffBeats = abs(tempLength - currLength);
            % Select segment signal around actual heartbeat currently
            % segmented
            
            approxBeat = Fsignal(qOnMat(hb,ch) - (diffBeats+5) : qOffMat(hb,ch) + (diffBeats+5),ch);
            % Normalize it
            approxBeat = approxBeat/max(abs(approxBeat));
            % Match
            offset = xcorrAlign(segmentedBeats{template,ch},approxBeat);
            if offset > 0
                % Correct Q position
                qrsOnCorr(hb,ch) = qOnMat(hb,ch) - (diffBeats+15) + abs(offset);
                % Correct S position
                qrsOffCorr(hb,ch) = qrsOnCorr(hb,ch) + tempLength - 1;
                % Store segment
                newSegments{hb,ch} = Fsignal(qrsOnCorr(hb,ch):qrsOffCorr(hb,ch),ch);
                % Normalize
                newSegments{hb,ch} = newSegments{hb,ch}/max(abs(newSegments{hb,ch}));
            else
                % Correct Q position
                qrsOnCorr(hb,ch) = qOnMat(hb,ch) - (diffBeats+5) + abs(offset);
                % Correct S position
                qrsOffCorr(hb,ch) = qrsOnCorr(hb,ch) + tempLength - 1;
                % Store segment
                newSegments{hb,ch} = Fsignal(qrsOnCorr(hb,ch):qrsOffCorr(hb,ch),ch);
                % Normalize
                newSegments{hb,ch} = newSegments{hb,ch}/max(abs(newSegments{hb,ch}));
            end
        else
            % Store template beat
            newSegments{hb,ch} = segmentedBeats{hb,ch};
            % Store Q position
            qrsOnCorr(hb,ch) = qOnMat(hb,ch);
            % Correct S position
            qrsOffCorr(hb,ch) = qrsOnCorr(hb,ch) + tempLength - 1;
        end
        if visu == 1
            plot(newSegments{hb,ch})
            hold on;
        end
    end
end


%% 5. Recalculate correlation matrix for correctly aligned beats
for ch = 1 : nChan
    for hb1 = 1 : size(corrMats{1,ch},2)
        for hb2 = 1 : size(corrMats{1,ch},2)
            if hb1 == hb2
                corrMats{1,ch}(hb1,hb2) = 1;
            else
                corrMats{1,ch}(hb1,hb2)=xcor12leads(newSegments{hb1,ch},newSegments{hb2,ch});
            end
        end
    end
end


%% 6. Remove hbeats with correlation lower than qualLim
probBeat = findProbBeats(corrMats,qualLim);
% If some problematic beat
if sum(sum(probBeat)) > 0
    % Check per lead
    probLead = find(sum(probBeat) > 0);
    for pl = 1 : length(probLead)
        % If the heartbeat is problematic in 10 of the leads, remove it from
        % all leads
        if sum(probBeat(:,probLead(pl))) > (size(newSegments,1) - 2)
            for hb = 1 : size(probBeat,1)
                newSegments{hb,probLead(pl)} = NaN;
            end
            rPeaksMat(:,probLead(pl)) = NaN;
            qrsOffCorr(:,probLead(pl)) = NaN;
            qrsOnCorr(:,probLead(pl)) = NaN;
            
            % Otherwise remove each specific lead
        else
            for hb = 1 : size(probBeat,1)
                if probBeat(hb,probLead(pl)) == 1
                    newSegments{hb,probLead(pl)} = NaN;
                    rPeaksMat(hb,probLead(pl)) = NaN;
                    qrsOffCorr(hb,probLead(pl)) = NaN;
                    qrsOnCorr(hb,probLead(pl)) = NaN;
                end
            end
        end
    end
end

%% * Remove parts around zero in the first and last 20% of the signals
for ch = 1 : nChan
    % Find beats that are not nan: length is larger than 1
    numBeats = sum(cellfun(@length,newSegments(:,ch))>1);
    idxBeats = find(cellfun(@length,newSegments(:,ch))>1);
    % Save new limits beats in segment
    zeroHb = ones(numBeats,2);
    zeroHb(:,2) = mode(cellfun(@length,newSegments(:,ch)));
    for hb = 1 : numBeats
        rangeCheck = round(0.2*length(newSegments{idxBeats(hb),ch}));
        % If there are zero crossings at the beginning of the signal
        if ~isempty(find(diff(sign(newSegments{idxBeats(hb),ch}(1:rangeCheck)))))
            idxZeros = find(diff(sign(newSegments{idxBeats(hb),ch}(1:rangeCheck))))+1;
            zeroHb(hb,1) = idxZeros(end);
        end
        % If there are zero crossings at the end of the signal
        if ~isempty(find(diff(sign(newSegments{idxBeats(hb),ch}(length(newSegments{idxBeats(hb),ch})-rangeCheck:end)))))
            idxZeros = find(diff(sign(newSegments{idxBeats(hb),ch}(length(newSegments{idxBeats(hb),ch})-rangeCheck:end))))+1;
            zeroHb(hb,2) = length(newSegments{idxBeats(hb),ch})-rangeCheck + idxZeros(1) -1;
        end
        
    end
    
    for hb = 1 : numBeats
        % Update beat
        newSegments{idxBeats(hb),ch} = newSegments{idxBeats(hb),ch}(median(zeroHb(:,1)):median(zeroHb(:,2)));
        % Update QS
        qrsOnCorr(idxBeats(hb),ch) = qrsOnCorr(idxBeats(hb),ch) + median(zeroHb(:,1)) - 1;
        qOffCorr(idxBeats(hb),ch) = qrsOnCorr(idxBeats(hb),ch) + median(zeroHb(:,2)) - 1;
    end
    
end

if visu == 1
    figure()
    for ch = 1 : 12
        subplot(3,4,ch)
        for hb = 1 : size(newSegments,1)
            plot(newSegments{hb,ch})
            hold on;
        end
        axis tight;
    end
end
    
    
