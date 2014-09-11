function y = write_hex(filename,x)
  fid = fopen(filename,'w');

  x=floor(x);
  x(x<-32768) = -32768;
  x(x>32767) = 32767;
  x(x<0) = x(x<0)+65536;  % Handle two's complement representation

  y = fprintf(fid,'%04x\n',x);
  fclose(fid);


return
