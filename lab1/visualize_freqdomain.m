function dummy = visualize_freqdomain(x,y,y_senior, t,h, Fs)

  figure(2);
  clf
N=length(x);
X = abs(fft(x)); X = X(1:N/5);
H = abs(fft([h zeros(1,N-(length(h)))])); H = H(1:N/5);
Y = abs(fft(y)); Y = Y(1:N/5);
f = (1:N/5)*(Fs/N);

set(gcf,'name','Frequency domain analysis');
subplot(311), plot(f,X);
argh=axis;
xlabel('f [Hz]');
ylabel('|X|');
title('Noisy signal');

subplot(312), plot(f,H);
xlabel('f [Hz]');
ylabel('|H|');
title('Filter');

subplot(313), plot(f,Y);
axis(argh);
xlabel('f [Hz]');
ylabel('|Y|');
title('Restored signal');
