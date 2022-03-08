Dist_computer
close all
%% ========================================================================
[sx,sy,~]=size(All_dists);
All_dists(All_dists==0)=NaN;
% "dist_index" contains points belonging to more than one image.
% "dist_index(:,:,1:2)" contains minimum distance to the center of one of
% our images and the number of image that it belongs to, "dist_index(:,:,3:4)"
% contains next minimum distance to the center of one of our images and the
% number of image that it belongs to
% "dist_index_extra" contains points that belong only to one image.
dist_index=zeros(sx,sy,4);
dist_index_extra=zeros(sx,sy,2);
for a1=1:sx
    for a2=1:sy
        dists_temp=All_dists(a1,a2,:);
        siz=size(dists_temp,3);
        dists(1:siz,1)=reshape(dists_temp,siz,1);
        dists(1:siz,2)=(1:siz)';
        sorted_dists=sortrows(dists);
        if ~isnan(sorted_dists(2,1))
            dist_index(a1,a2,1:2)=sorted_dists(1,:);
            dist_index(a1,a2,3:4)=sorted_dists(2,:);
        elseif ~isnan(sorted_dists(1,1))
            dist_index_extra(a1,a2,1:2)=sorted_dists(1,:);
        end
        clear sorted_dists
    end
end

dist_color=dist_index(:,:,2)+dist_index_extra(:,:,2);
ind=sort(setdiff(unique(dist_color),0));
n=1;
for a1=ind(1):ind(size(ind,1))
    mask=zeros(size(dist_color));
    mask(dist_color==a1)=1;
    for a2=(a1+1):ind(size(ind,1))
        mask(dist_color==a2)=1;
        clear BW_temp siz sort_siz
        BW_temp=bwconncomp(mask);
        mask(dist_color==a2)=0;
        conn_flag(n,1:2)=[a1,a2];   % 'conn_flag' shows which frames are connected in the final automontaged frame
        conn_flag(n,3)=1;
        if (BW_temp.NumObjects>1)
            for a3=1:BW_temp.NumObjects
                siz(a3,1)=size(BW_temp.PixelIdxList{1,a3},1);
            end
            sort_siz=sort(siz,'descend');
            if (sort_siz(1)>10)
                if sort_siz(2)>=10
                    conn_flag(n,3)=0;
                else
                    conn_flag(n,3)=1;
                end
            end
        end
        n=n+1;
    end
end

[rf,~,~]=find(conn_flag(:,3)==1);
conn_new=[conn_flag(rf,1:2);[conn_flag(rf,2) conn_flag(rf,1)]];
unique1=unique(conn_new(:,1));
Best=zeros(size(dist_color));
for d1=1:size(unique1,1)
    [rt,~,~]=find(conn_new(:,1)==unique1(d1));
    conn_temp=conn_new(rt,2);
    Im1Phantom=All_phantoms(:,:,unique1(d1));
    [row1,col1,~]=find(Im1Phantom);
    C1=[floor((max(row1)-min(row1))/2+min(row1))+1,floor((max(col1)-min(col1))/2+min(col1))+1];
    clear C
    for d2=1:size(conn_temp,1)
        id=conn_temp(d2);
        Im1Phantom=All_phantoms(:,:,id);
        [row1,col1,~]=find(Im1Phantom);
        C(d2,1:2)=[floor((max(row1)-min(row1))/2+min(row1))+1,floor((max(col1)-min(col1))/2+min(col1))+1];
    end
    mask_temp=zeros(size(dist_color));
    mask_temp(dist_color==d1)=1;
    clear rtemp ctemp
    [rtemp,ctemp,~]=find(mask_temp);
    dists=zeros([size(dist_color),size(conn_temp,1)]);
    for d3=1:size(rtemp)
        dists(rtemp(d3),ctemp(d3),1:size(conn_temp,1))=pdist2([rtemp(d3),ctemp(d3)],C);
        best_dist(rtemp(d3),ctemp(d3))=min(dists(rtemp(d3),ctemp(d3),:));
        Best(rtemp(d3),ctemp(d3))=conn_temp(min(find(dists(rtemp(d3),ctemp(d3),:)==best_dist(rtemp(d3),ctemp(d3)))));
    end
end

%%
new_mask1=zeros(size(dist_color));
new_mask2=zeros(size(dist_color));
new_mask1((dist_color==1)|(dist_color==2))=1;
new_mask2((Best==1)|(Best==2))=1;
new_mask=new_mask1.*new_mask2;

current_folder=CurrentDirectory;
files=dir(fullfile(current_folder,'*BAK*.tiff'));
files={files.name};
files=sort(files);
sfiles=size(files,2);
mergedImF=zeros(size(All_dists(:,:,1)));
mergedMask=zeros(size(All_dists(:,:,1)));
Wmasks=zeros(size(All_dists(:,:,1)));
m=1;
n=1;

for e1=1:size(unique1,1)
    clear rt conn_temp 
    [rt,~,~]=find(conn_new(1:size(conn_new,1)/2,1)==unique1(e1));
    conn_temp=conn_new(rt,2);
    for e2=1:size(conn_temp,1)
        clear mask_asi mergedIm
        new_mask1=zeros(size(dist_color));
        new_mask2=zeros(size(dist_color));
        new_mask1((dist_color==unique1(e1))|(dist_color==conn_temp(e2)))=1;
        new_mask2((Best==unique1(e1))|(Best==conn_temp(e2)))=1;
        mask_asi=new_mask1.*new_mask2;
        mask_sub=mask_asi.*mergedMask;
        mask_sub((mask_sub)~=0)=1;
        mask_sub=mask_asi-mask_sub;
        Wmasks(mask_sub==1)=m;
        m=m+1;
        if ~isempty(mask_sub)
            filename1=cell2mat(files(unique1(e1)));
            I1=imread(char(strcat(MyPath,filename1)));
            filename2=cell2mat(files(conn_temp(e2)));
            I2=imread(char(strcat(MyPath,filename2)));
            dist1=All_dists(:,:,unique1(e1))+1;
            dist2=All_dists(:,:,conn_temp(e2))+1;
            phantom1=All_phantoms(:,:,unique1(e1));
            phantom2=All_phantoms(:,:,conn_temp(e2));
            %--------------------------------------------------------------
            [mergedImNM,Im1,Im2]=MergeIm_Intensity(I1,I2,dist1,dist2,phantom1,phantom2);
            mergedIm=mask_sub.*mergedImNM;
            mergedImF=mergedImF+mergedIm;
            mergedMask=mergedMask+mask_sub;
        end
    end
end
zapas1=mergedImF;


clear All_dists All_phantoms
[All_dists,All_phantoms]=Dist_computer_Appendix(CurrentDirectory,MyPath);
[sx,sy,~]=size(All_dists);
All_dists(All_dists==0)=NaN;
dist_index_app=zeros(sx,sy,4);
dist_index_extra_app=zeros(sx,sy,2);
for a1=1:sx
    for a2=1:sy
        dists_temp_app=All_dists(a1,a2,:);
        siz_app=size(dists_temp_app,3);
        dists_app(1:siz_app,1)=reshape(dists_temp_app,siz_app,1);
        dists_app(1:siz_app,2)=(1:siz_app)';
        sorted_dists_app=sortrows(dists_app);
        if ~isnan(sorted_dists_app(2,1))
            dist_index_app(a1,a2,1:2)=sorted_dists_app(1,:);
            dist_index_app(a1,a2,3:4)=sorted_dists_app(2,:);
        elseif ~isnan(sorted_dists_app(1,1))
            dist_index_extra_app(a1,a2,1:2)=sorted_dists_app(1,:);
        end
        clear sorted_dists_app
    end
end
dist_color_app1=dist_index_app(:,:,2);
dist_color_app2=dist_index_app(:,:,4);
dist_color_app3=dist_index_extra_app(:,:,2);
borders_app=zeros(size(mergedImF));
p=1;
Xmasks=zeros(size(All_dists(:,:,1)));
for k1=1:size(All_dists,3)
    phant=All_phantoms(:,:,k1);
    borders_app((phant==1)&(zapas1==0))=1;
    filename=cell2mat(files(k1));
    I_alone=imread(char(strcat(MyPath,filename)));
    I_alone=I_alone(:,:,1);
    mergedImF(dist_color_app3==k1)=I_alone(dist_color_app3==k1);
    Xmasks((dist_color_app3==k1)&(~zapas1))=p;
    p=p+1;
end
index_app1=borders_app.*dist_color_app1;
index_app2=borders_app.*dist_color_app2;
index_app3=borders_app.*dist_color_app3;
mask_border=zeros(size(mergedImF));

for f1=1:size(All_dists,3)
    for f2=f1+1:size(All_dists,3)
        filename1=cell2mat(files(f1));
        I1=imread(char(strcat(MyPath,filename1)));
        I1=I1(:,:,1);
        filename2=cell2mat(files(f2));
        I2=imread(char(strcat(MyPath,filename2)));
        I2=I2(:,:,1);
        mask_border=zeros(size(mergedImF));
        mask_border(((index_app1==f1)&(index_app2==f2))|((index_app1==f2)&(index_app2==f1)))=1;
        [rfind,~,~]=find(mask_border);
        if ~isempty(rfind)
            dist1=All_dists(:,:,f1)+1;
            dist2=All_dists(:,:,f2)+1;
            phantom1=All_phantoms(:,:,f1);
            phantom2=All_phantoms(:,:,f2);
            [mergedImB,~,~]=MergeIm_Intensity(I1,I2,dist1,dist2,phantom1,phantom2);
            mergedImB_new=mergedImB.*mask_border;
            mergedImF=mergedImF+mergedImB_new;
            Xmasks(mask_border==1)=p;
            p=p+1;
        end
        clear mergedImB mergedImB_new
    end
end

H=fspecial('average',3);
mergedImFilt=imfilter(double(mergedImF),H,'replicate');
se=offsetstrel('ball',5,2);
[Gmag1,~]=imgradient(Wmasks);
[Gmag2,~]=imgradient(Xmasks);
Gmag1(Gmag1~=0)=1;
Gmag2(Gmag2~=0)=1;
Gmag=Gmag1|Gmag2;
dilated_Gmag=imdilate(double(Gmag),se);
dilated_Gmag1=dilated_Gmag-min(dilated_Gmag(:));
dilated_Gmag2=1-dilated_Gmag1;
zapas=mergedImF;
mergedImF=mergedImFilt.*dilated_Gmag1+mergedImF.*dilated_Gmag2;
imwrite(uint8(mergedImF),char(strcat(MyPath,'mergedImF.tiff')));
save(strcat(MyPath,'All_dists.mat'),'All_dists');
save(strcat(MyPath,'All_phantoms.mat'),'All_phantoms');