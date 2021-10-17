function corrMats = corrMatPerLead(segmentedBeats)

nChan = size(segmentedBeats,2);
corrMats = cell(1,nChan);
% For each lead
for ch = 1 : nChan
    %% Correlate beats
    % Create correlation matrix
    corrMats{1,ch} = zeros(size(segmentedBeats,1),size(segmentedBeats,1));
    for hb1 = 1 : size(segmentedBeats,1)
        if isempty(segmentedBeats{hb1,ch})
            corrMats{1,ch}(hb1,:) = 0;
        else
            for hb2 = 1 : size(segmentedBeats,1)
                if isempty(segmentedBeats{hb2,ch})
                    corrMats{1,ch}(hb1,hb2) = 0;
                else
                    % If it is the same beat
                    if hb1 == hb2
                        corrMats{1,ch}(hb1,hb2) = 1;
                        % If different beats of same length
                    elseif length(segmentedBeats{hb1,ch}) == length(segmentedBeats{hb2,ch})
                        % Calculate correlation btw both beats
                        corrMats{1,ch}(hb1,hb2) = xcor12leads(segmentedBeats{hb1,ch},segmentedBeats{hb2,ch});
                        % If different beats of different length
                    elseif length(segmentedBeats{hb1,ch}) ~= length(segmentedBeats{hb2,ch})
                        %% Use xcorr to align
                        offset = xcorrAlign(segmentedBeats{hb1,ch},segmentedBeats{hb2,ch});
                        % Remove offset - cut extra things
                        % If offset >0 then s1 must be taken from offset
                        if offset > 0
                            % Check lengths
                            if length(segmentedBeats{hb1,ch})-offset+1<=...
                                    length(segmentedBeats{hb2,ch})
                                s1 = segmentedBeats{hb1,ch}(offset:end);
                                s2 = segmentedBeats{hb2,ch}(1:length(s1));
                            else
                                s1 = segmentedBeats{hb1,ch}(offset:offset-1+length(segmentedBeats{hb2,ch}));
                                s2 = segmentedBeats{hb2,ch}(1:end);
                            end
                            % If offset <0 then s2 must be taken from offset
                            % If <0, s2 is delayed
                        elseif offset < 0
                            if length(segmentedBeats{hb2,ch})-abs(offset)+1 <= ...
                                    length(segmentedBeats{hb1,ch})
                                s2 = segmentedBeats{hb2,ch}(1+abs(offset):end);
                                s1 = segmentedBeats{hb1,ch}(1:length(s2));
                            else
                                s1 = segmentedBeats{hb1,ch};
                                s2 = segmentedBeats{hb2,ch}(abs(offset):abs(offset)-1+length(s1));
                            end
                        elseif offset == 0
                            if length(segmentedBeats{hb1,ch}) <= length(segmentedBeats{hb2,ch})
                                s1 = segmentedBeats{hb1,ch};
                                s2 = segmentedBeats{hb2,ch}(1:length(segmentedBeats{hb1,ch}));
                            else
                                s1 = segmentedBeats{hb1,ch}(1:length(segmentedBeats{hb2,ch}));
                                s2 = segmentedBeats{hb2,ch};
                            end
                            
                        end
                        % Extract normalized correlation of signals with at
                        % least 10 samples
                        if length(s1) < 10 || length(s2) < 10
                            corrMats{1,ch}(hb1,hb2)=0;
                        else
                            corrMats{1,ch}(hb1,hb2)=xcor12leads(s1,s2);
                        end
                    end
                end
            end
        end
    end
end
