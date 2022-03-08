%% "MergeIm_Intensity.m" can stich two input gray images (Im1 and Im2)
% and result in one gray output image (mergedImF). The input images get
% merged so that the border of each image degrades towards the other image
% Asieh Daneshi July. 2020
%--------------------------------------------------------------------------
function [mergedImF,Im1,Im2]=MergeIm_Intensity(Im1,Im2,dist1,dist2,Im1Phantom,Im2Phantom)
% dist1: the distance of each pixel of the first image from its center ----
% dist2: the distance of each pixel of the second image from its center ---
Im1=double(Im1(:,:,1)).*Im1Phantom;
Im2=double(Im2(:,:,1)).*Im2Phantom;
%% ========================================================================
% dist1 & dist2 -> dists is zero wherever dist1 or dist2 is zero ----------
dists=(1-dist1).*(1-dist2);
[row3,col3,~]=find(dists);
% finding the distance between corresponding pixels in the overlapping area
% of the first image and the second image =================================
% here I just wanted pixels other than main pixels have a value not between (-1,1)
dist_dif=ones(size(dists))*5;
for c1=1:size(row3)
    dist_dif(row3(c1),col3(c1))=dist1(row3(c1),col3(c1))-dist2(row3(c1),col3(c1));
end
%% ========================================================================
% here we merge images into mergedIm ======================================
mergedIm=zeros(size(dist_dif));                        % initiate mergedIm
dist_border=zeros(size(dist_dif));       % sharp border between two images 
Condit=(Im1Phantom.*Im2Phantom)~=0;
dist_border((dist_dif<=0.1)&(dist_dif>=-0.1)&Condit)=1;
asi=dist_border;
[row1,col1,~]=find(Im1Phantom);
C1=[floor((max(row1)-min(row1))/2+min(row1))+1,floor((max(col1)-min(col1))/2+min(col1))+1];
[row2,col2,~]=find(Im2Phantom);
C2=[floor((max(row2)-min(row2))/2+min(row2))+1,floor((max(col2)-min(col2))/2+min(col2))+1];
[r,c,~]=find(Im1Phantom.*Im2Phantom);
sign_dist=zeros(size(dist_dif));
for s=1:size(r,1)
    dis1=myDist([r(s) c(s)],C1);
    dis2=myDist([r(s) c(s)],C2);
    if dis1-dis2>1
        sign_dist(r(s),c(s))=1;
    elseif dis1-dis2<-1
        sign_dist(r(s),c(s))=-1;
    end
end
% we need "sign_dist" to understand which part of the overlapping region
% belongs to "Im1" and which part belongs to "Im2" ------------------------
dist_border_p=zeros(size(dist_dif));
dist_border_p((sign_dist==0)&(Im1Phantom&Im2Phantom))=1;
dist_border=dist_border_p;
se=offsetstrel('ball',20,2);
dilated_dist_border=imdilate(dist_border,se);          % dilate dist border
dist_border_blur=3-dilated_dist_border;
dist_border_blur=dist_border_blur.*sign_dist;
dist_border_blur(dist_border_blur>=0&Condit)=1;
mergedIm(dist_border_blur>=1)=Im2(dist_border_blur>=1);
mergedIm(dist_border_blur<=-1)=Im1(dist_border_blur<=-1);
mergedIm(dist_border_blur<0&dist_border_blur>-1&Condit)=Im1(dist_border_blur<0&dist_border_blur>-1&Condit).*abs(dist_border_blur(dist_border_blur<0&dist_border_blur>-1&Condit))+Im2(dist_border_blur<0&dist_border_blur>-1&Condit).*(1-abs(dist_border_blur(dist_border_blur<0&dist_border_blur>-1&Condit)));
mergedIm(Im1Phantom~=0&Im2Phantom==0)=Im1(Im1Phantom~=0&Im2Phantom==0);
mergedIm(Im2Phantom~=0&Im1Phantom==0)=Im2(Im2Phantom~=0&Im1Phantom==0);
% -------------------------------------------------------------------------
% making a white mask for the overlapping area ----------------------------
overlap_mask=zeros(size(Im1));
% overlap_mask(((1-dist1).*(1-dist2))~=0)=1;
overlap_mask((Im1Phantom.*Im2Phantom)~=0)=1;
% finding the border of the overlapping area ------------------------------
mask_border=bwboundaries(overlap_mask);
% -------------------------------------------------------------------------
outerBorder=mask_border{1,1};                  % border of the overlap_mask
% -------------------------------------------------------------------------
n=1;m=1;
for e1=1:size(outerBorder,1)
    e2=outerBorder(e1,1);
    e3=outerBorder(e1,2);
    % one pixel neighbors of each point on the border of overlap_mask -----
    temp_mask=mergedIm(e2-1:e2+1,e3-1:e3+1);
    % in the next two lines we want to know how many neighbors belong to
    % "Im1" and how many belong to "Im2", then in the following lines we
    % find out if all neighbors of each pixel on the border belong to first
    % image of the second image or both. If they belong to both, this means
    % that it is a sharp edge that should be smoothed
    temp_mask_Im1=temp_mask-Im1(e2-1:e2+1,e3-1:e3+1);
    temp_mask_Im2=temp_mask-Im2(e2-1:e2+1,e3-1:e3+1);
    S1=size(find(temp_mask_Im1==0),1);
    S2=size(find(temp_mask_Im2==0),1);
    if (S1==0)||(S2==0)
        %     if ((temp_mask==Im1(e2-1:e2+1,e3-1:e3+1))||(temp_mask==Im2(e2-1:e2+1,e3-1:e3+1)))
        % borders are merged well in B1 -----------------------------------
        B1(n,1:2)=outerBorder(e1,:);    % soft parts of the outer border
        n=n+1;
    else
        % borders are not merged in B2 ------------------------------------
        B2(m,1:2)=outerBorder(e1,:);    % coarse parts of the outer border
        m=m+1;
    end
end
%% ========================================================================
% here we soften the coarse borders (B2) ----------------------------------
mergedImF=mergedIm;
for g1=1:size(B2,1)
    xB2=B2(g1,1);
    yB2=B2(g1,2);
    H=fspecial('average',3);
    mergedImF1=imfilter(mergedIm,H,'replicate');
    mergedImF(xB2-4:xB2+4,yB2-4:yB2+4)=mergedImF1(xB2-4:xB2+4,yB2-4:yB2+4);
end