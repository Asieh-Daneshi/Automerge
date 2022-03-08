close all
%--------------------------------------------------------------------------
if ~(exist(strcat(MyPath,'All_phantoms.mat'), 'file')==2 && exist(strcat(MyPath,'mergedImF.tiff'), 'file')==2 && exist(strcat(MyPath,'All_dists.mat'), 'file')==2)
    clc
    fprintf('Please run ''Panorama.m'' first!\n');
    return
end
load(strcat(MyPath,'All_dists.mat'))
load(strcat(MyPath,'All_phantoms.mat'))
mergedImF=imread(char(strcat(MyPath,'mergedImF.tiff')));
% for 'All_dists' and 'All_phantoms' just run 'Dist_computer.m', and for
% 'mergedImF' run 'Panorama_May22.m', or just use this line of code if you
% have done this before, and you have a saved 'mergedImF':
% mergedImF=imread(....);
flag=1;
count=1;
while flag==1
    close all
    clc
    fprintf('please press the "enter" key when you are ready to select the point that you are not satisfied with its surrounding area:\n');
    fprintf('You can move around the image or zoom it as much as you would like before selecting the point that you are not satisfied with!\n');
%     figure;imshow(mergedImF,[])
%     title({'Original Frame'})
    figure;imshow(mergedImF,[])
    title({'Original Frame'})
    currkey=0;
    % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey'); 
        if currkey=='return'
            currkey=1;
        else
            currkey=0;
        end
    end
%     if ismember('return', ch),
    fprintf('now please click on the point that you are not satisfied with its surrounding area:\n');
    [x,y]=ginput(1);
%     end
    sz=size(All_phantoms,3);
    [r,~,~]=find(reshape(All_phantoms(round(y),round(x),:),sz,1)==1);
    %% ========================================================================
    current_folder=CurrentDirectory;
    files=dir(fullfile(current_folder,'*BAK*.tiff'));
    files={files.name};
    files=sort(files);
    
    for pnom=1:size(r,1)
        filename=cell2mat(files(r(pnom)));
        I=double(imread(char(strcat(MyPath,filename))));
        Im=I(:,:,1);
        Iph=I(:,:,2);
        [r1,c1,~]=find(Iph);
        sx=round(max(r1)-min(r1));           % the width of the candidate patch
        sy=round(max(c1)-min(c1));          % the height of the candidate patch
        C=[(sx)/2+round(min(r1)),(sy)/2+round(min(c1))]; % center of the candidate patch
        
        Im_sub=zeros(size(Im));
        Im_sub(C(1,1)-round(0.35*sx):C(1,1)+round(0.35*sx),C(1,2)-round(0.35*sy):C(1,2)+round(0.35*sy))=Im(C(1,1)-round(0.35*sx):C(1,1)+round(0.35*sx),C(1,2)-round(0.35*sy):C(1,2)+round(0.35*sy));
        Iph_sub=zeros(size(Iph));
        Iph_sub(C(1,1)-round(0.35*sx):C(1,1)+round(0.35*sx),C(1,2)-round(0.35*sy):C(1,2)+round(0.35*sy))=Iph(C(1,1)-round(0.35*sx):C(1,1)+round(0.35*sx),C(1,2)-round(0.35*sy):C(1,2)+round(0.35*sy));
        SE=offsetstrel('ball',15,1);
        Iph_sub_inner=imdilate(Iph_sub/255,SE);
        Iph_sub_inner=Iph_sub_inner-min(Iph_sub_inner(:));
        Iph_sub_outer=1-Iph_sub_inner;
        All_images(:,:,pnom)=Im.*Iph_sub_inner+double(mergedImF).*Iph_sub_outer;
        figure;imshow(All_images(:,:,pnom),[])
        hold on
        rectangle('Position',[C(1,2)-round(0.5*sy),C(1,1)-round(0.5*sx),round(2*0.5*sy),round(2*0.5*sx)],'EdgeColor','y')
        title(strcat('Number:',num2str(pnom),';Frame Number=',num2str(r(pnom))))
        hold off
    end
    %%
    prompt='Which frame do you prefer? (select zero, if you prefer original frame)?\n';
    Fnom=input(prompt);
    if Fnom ==0
        imwrite(uint8(mergedImF),char(strcat(MyPath,'mergedImF.tiff')));
        close all
        figure;imshow(mergedImF,[])
    else
        prompt='Are you satisfied with the present image? (1=yes, 0=no)\n';
        resp=input(prompt);
        if resp==1
            imwrite(uint8(All_images(:,:,Fnom)),char(strcat(MyPath,'mergedImF.tiff')));
            close all
            figure;imshow(mergedImF,[])
        else
            fprintf('Please select a polygon:\n');
            filename=cell2mat(files(r(Fnom)));
            I=double(imread(char(strcat(MyPath,filename))));
            SE1=strel('disk',15);
            Im=I(:,:,1);
            Iph=I(:,:,2);
            Imtemp=imerode(Iph,SE1).*Im;
            imshowpair(mergedImF,Imtemp);
            Iph_sub=double(roipoly);
            clc
            SE=offsetstrel('ball',15,2);
            Iph_sub_inner=imdilate(Iph_sub,SE);
            Iph_sub_inner=Iph_sub_inner-min(Iph_sub_inner(:));
            Iph_sub_outer=1-Iph_sub_inner;
            mergedImF=Im.*Iph_sub_inner+double(mergedImF).*Iph_sub_outer;
            imwrite(uint8(mergedImF),char(strcat(MyPath,'mergedImF.tiff')));
            close all
            figure;imshow(mergedImF,[])
        end
    end
    prompt='Are there any other points that you are not satisfied with their surrounding areas? (1=yes, 0=no)\n';
    flag=input(prompt);
    backup=mergedImF;
    imwrite(uint8(backup),char(strcat(MyPath,'Backup',num2str(count),'.tiff')));
end