% Put 'Stitch.m' in the folder containing all primary images with format
% 'tif', make sure there is no other file with the same format in that folder
%==========================================================================

tic     % initialize timer to find out how muc time this code takes
close all
clear
clc

%% ========================================================================
% read names of all the files with format 'tif' in the current folder
current_folder = pwd;
files = dir(fullfile(current_folder,'\*.tif'));
files = {files.name};
files = sort(files);

sfiles=size(files,2);
% sfiles=3;
for pnom = 1:sfiles  % 'size(files,2)' is the number of original images
    filename = cell2mat(files(pnom));
    I=double(imread(filename));     % original image in the range [0 255]
    I=I(:,:,1);
    [row1,col1,~]=find(I);     % find nonzero elements in original image
    % C is the center of nonzero parts of the phantom
    C=[(max(row1)-min(row1))/2+min(row1),(max(col1)-min(col1))/2+min(col1)];
    % initialize pic (the matrix containing all original images)
    pic=zeros(size(I));
    pic(find(I~=0))=I(find(I~=0));
    All_pics(:,:,pnom)=pic;
end

%
[sx,sy]=size(All_pics(:,:,1));
Colored=zeros(sx,sy);
for a1=1:sx
    for a2=1:sy
        Colored(a1,a2)=size(nonzeros(All_pics(a1,a2,:)),1);
    end
end
Colored=uint8(Colored);
figure;imshow(Colored,[]);
max_color=double(max(Colored(:)));
rgbImage=ind2rgb(Colored, jet(max_color+1));
figure;imshow(rgbImage,[]);numColors=max_color+1;colormap(jet(numColors));colorbar
imwrite(rgbImage,'Colored_Overlaps.tif')
