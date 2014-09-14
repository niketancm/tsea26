% Load noisy input data into x
x=read_hex('IOS0010');

Fs=500; % Sampling frequency
N=length(x);
t = (0:N-1)/Fs; % time axis

% Create a low pass filter with a cut-off frequency of 15 Hz

order=31;
FIXME = 0.06;
h = fir1(order, FIXME );  % FIXME - Insert the correct value here!

% Matlab based filtering
y = filter(h, 1, x);

if exist('IOS0011')
  y_senior=read_hex('IOS0011');
 else
   fprintf('Warning: IOS0011 output from srsim not found!\n'); 
   y_senior=zeros(1,length(y));
end

relerr = visualize_timedomain(x,y,y_senior,t,h);
fprintf('Relative error of Senior implementation compared to Matlab implementation: %f\n',relerr);
visualize_freqdomain(x,y,y_senior,t,h,Fs);

