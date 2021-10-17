function [Fsignal] = filterSignal(signal,fs,type,hpf,lpf,stopf)

%  INPUT:   signal  - Signal
%           fs   - Sampling frequency
%           type - Filter type 'All', 'high', 'low', 'stop', 
%                  'HL' high and low, 
%                  'HS' high and stop, 
%                  'LS' low and stop
%                  
%           hpf   - cutoff frequency for highpass filter
%           lpf   - cutoff frequency for lowpass filter
%           stopf - cutoff frequency for band stop filter
%  OUTPUT:  Fsignal - Filtered signal
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nf = fs/2;  % Nyquist frequency

if strcmp(type,'high') || strcmp(type,'All') || strcmp(type,'HS') || strcmp(type,'HL')
    Cf = hpf/Nf;        % Cutoff freq. Passband corner freq. 0.5Hz
    
    [bh,ah] = butter(2,Cf,'high');   % High pass filter
    yh      = filtfilt(bh,ah,signal);
    signal  = yh;
end

% Low pass filter
if strcmp(type,'low') || strcmp(type,'All') || strcmp(type,'LS') || strcmp(type,'HL')
    Cf = lpf/Nf;        % Cutoff freq. Passband corner freq. 100Hz
   
    [bl,al] = butter(4,Cf,'low');    % Low pass filter
    yl      = filtfilt(bl,al,signal);
    signal  = yl;
end

if strcmp(type,'stop') || strcmp(type,'All') || strcmp(type,'HS') || strcmp(type,'LS')
    Cf = [max([1 stopf-5]) stopf+5]/Nf;    % Cutoff freq. Passband corner freq. 0.5Hz
    
    [bs,as] = butter(6,Cf,'stop');   % stopband filter
    ys      = filtfilt(bs,as,signal);
    signal  = ys;
end
  
Fsignal = zscore(signal);
   
    
