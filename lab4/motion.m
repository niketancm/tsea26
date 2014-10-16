fid = fopen('image1.raw','r');
img1 = fread(fid,176*144,'uint8');
fclose(fid);

fid = fopen('image2.raw','r');
img2 = fread(fid,176*144,'uint8');
fclose(fid);

img1 = reshape(img1,176,144);
img2 = reshape(img2,176,144);

cmap = (0:255)/255;
cmap = [cmap' cmap' cmap'];
figure(1);
subplot(2,3,1);

image(img1');
title('Original image');
axis off
subplot(2,3,2);
image(img2');
title('New image');
axis off
subplot(2,3,4);
image(abs(img2'-img1'));
title('Difference between new image and old image');
axis off

colormap(cmap);


fid = fopen('results.hex','r');
motion_indices = fscanf(fid,'%x');
motion_indices = motion_indices + 1; % Adjust because matlab use 1 based arrays
fclose(fid);




% Create coordinates for motion estimation indices

clear coords

i=1;


  coords(i,1:2) = [0 0];
i = i + 1;
x=1;
y=0;

limit=1;

while limit < 17




while y < limit
  coords(i,1:2) = [y x];
i = i + 1;
  y = y + 1;
end

while x > -limit
  coords(i,1:2) = [y x];
i = i + 1;
  x = x - 1;
end

while y > -limit
  coords(i,1:2) = [y x];
i = i + 1;
  y = y - 1;
end

while x <= limit
  coords(i,1:2) = [y x];
i = i + 1;
  x = x + 1;
end
limit = limit + 1;

  coords;
end




motion_vectors = [coords(motion_indices,1) coords(motion_indices, 2)];

index=1;
newimg = zeros(176,144);
% Go through all blocks and reconstruct the new image from the old
% image and the motion vectors (ignoring the boundary blocks)
% (Plus 1 because matlab arrays are 1 based instead of 0 based)
for y = (16:4:144-20) + 1
  for x = (16:4:176-20) + 1
    if(motion_indices(index) < 25006)
    newimg(x:x+3,y:y+3) = img1((x:x+3)+motion_vectors(index,1),(y: ...
                                                      y+3)+motion_vectors(index,2));
    else
    fprintf('Marker at %d x %d\n',x,y);
newimg(x:x+3,y:y+3) = ones(4,4)+255;
end


    index = index + 1;
  end
end

subplot(2,3,3);
image(newimg');
title('Motion compensated image');
axis off
subplot(2,3,6);
image(abs(newimg-img2)');
axis off
title('Difference between motion compensated image and new image');
