function x = read_hex(filename)
  fid = fopen(filename,'r');
  x = fscanf(fid,'%x');
  fclose(fid);

  x(x>32767) = x(x>32767)-65536;  % Handle two's complement representation

  x=x';

return
