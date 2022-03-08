%% Single frame field correction
% This code enhances the contrast of single frames before doing automerging
% it should be run after automontaging
% Asieh Daneshi February. 2021
close all
clear
clc
%%
current_folder=pwd;
files=dir(fullfile(current_folder,'\*.tiff'));
files={files.name};
files=sort(files);


sfiles=size(files,2);

for pnom=1:sfiles      % 'size(files,2)' is the number of original images
    filename=cell2mat(files(pnom));
    I=imread(filename);
    I1=I(:,:,1);
    I2=I(:,:,2);
    [r,c]=find(I1);
    I3=I1(min(r):max(r),min(c):max(c));
    J1=imflatfield(I3,100);
    I1(min(r):max(r),min(c):max(c))=J1;
    I_complete(:,:,1)=I1;
    I_complete(:,:,2)=I2;
    [r,c]=find(I1);
    I3=I1(min(r):max(r),min(c):max(c));
    I4=I2(min(r):max(r),min(c):max(c));
    I3(I4==0)=NaN;
    figure;
    subplot(1,2,1);imshow(I3,[])
    subplot(1,2,2);imshow(J1,[])
    
    tiffwrite(I_complete,[filename(1:end-5),'_corrected.tiff'])
end