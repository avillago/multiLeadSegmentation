function offset = xcorrAlign(s1,s2)
 [c,lags] = xcorr(s1,s2,round(1/3*mean([length(s1),length(s2)])));
 offset = lags(find(c==max(c)));
if length(offset) > 1
    offset = offset(1,1);
end
%  % Verify
% if offset > (1/4)*mean([length(s1),length(s2)])
%     
% end
end