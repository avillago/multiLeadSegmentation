function crosCor12 = xcor12leads(s1,s2)
% s1Norm=(s1-min(s1))./(max(s1)-min(s1));
% s2Norm=(s2-min(s2))./(max(s2)-min(s2));
crosCor12 = max(xcorr(s1,s2,'coeff'));
end
