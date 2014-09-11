function relerr = visualize_timedomain(x,y,y_senior, t,h)

  figure(1);
  clf
  set(gcf,'name','Time domain analysis');

  % plot noisy signal
  subplot(411), plot(t,x);
  xlabel('t [s]');
  title('ecg + 50 Hz noise');

  subplot(412),plot(h,'.');
  title(sprintf('FIR filter of %d taps',length(h)));


  subplot(413), plot(t,y);
  xlabel('t [s]');
  title('Signal as recovered by Matlab');


  subplot(414), plot(t,y_senior);
  xlabel('t [s]');

  relerr=norm(y-y_senior)/norm(y);
	title(sprintf('Signal as recovered by Senior (rel.error=%f)',relerr));

return 
