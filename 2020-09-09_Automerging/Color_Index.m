Color_indexes=uint8(dist_color_app2+dist_color_app3);
% figure;imshow(Color_indexes,[]);
max_color=double(max(Color_indexes(:)));
rgbImage=ind2rgb(Color_indexes, jet(max_color+1));
figure;imshow(rgbImage,[]);numColors=max_color+1;colormap(jet(numColors));
h=colorbar;
set(h,'XTickLabel',num2cell(0:numColors))
imwrite(rgbImage,'Colored_Overlaps.tif')