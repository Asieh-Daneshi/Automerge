%% Final montage field correction
% This code enhances the contrast of the complete merged image (the output
% of Automerging.m)
% it shifts a window through the whole image (each time 10 pixels shift)
% and enhances the contrast in the area falling in that window
% it should be run after automerging
% Asieh Daneshi February. 2021
close all
clear
clc
%%
I_before=im2double(imread('mergedImF.tiff'));
% figure;subplot(1,2,1);imshow(I_before)
% I_after=imflatfield(I_before,1500);
% I_before(I_before==0)=NaN;
% figure;subplot(1,2,1);imshow(I_before)
% I_after=adapthisteq(I_before,'clipLimit',0.001,'Distribution','rayleigh');
% I_after=imlocalbrighten(I_before,0.05*(max(I_before(:))-min(I_before(:))));
% subplot(1,2,2);imshow(I_after)


[sx1,sy1]=size(I_before);
% windowSizeX=round(sx1/20);
% windowSizeY=round(sy1/20);
windowSizeX=200;
windowSizeY=200;
% filterSize=round(min([windowSizeX,windowSizeX]/2));
filterSize=200;
I_before=padarray(I_before,[2*windowSizeX,2*windowSizeY],0,'post');
[sx,sy]=size(I_before);
for a1=1:10:sx-windowSizeX
    for a2=1:10:sy-windowSizeY
        Icrop=I_before(a1:a1+windowSizeX-1,a2:a2+windowSizeY-1);
        if ~isempty(find(Icrop,1))
            I_flatfield=imflatfield(Icrop,filterSize);
            I_new(a1:a1+9,a2:a2+9)=I_flatfield(1:10,1:10);
        else
            I_new(a1:a1+9,a2:a2+9)=0;
        end
    end
end
I_new=I_new(1:sx1,1:sy1);
figure;imshow(I_new,[])
imwrite(I_new,'Out2_1_2.tif');

% 
I_before1=im2double(imread('Out2_1_2.tif'));
I_before2=im2double(imread('Out2_1_1.tiff'));
[sx,sy]=size(I_before1);
for a1=1:sx
    for a2=1:sy
        I_after(a1,a2)=max(I_before1(a1,a2),I_before2(a1,a2));
    end
end
figure;imshow(I_after,[])
imwrite(I_after,'Out2_1_3.tif');