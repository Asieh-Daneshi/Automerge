function [All_dists,All_phantoms]=Dist_computer_Appendix(CurrentDirectory,MyPath)
%--------------------------------------------------------------------------
% this function is like 'Dist_computer', except that it considers the whole
% image
%--------------------------------------------------------------------------
%% ========================================================================
% read names of all the files with format 'tif' in the current folder -----
current_folder=CurrentDirectory;
files=dir(fullfile(current_folder,'*BAK*.tiff'));
files={files.name};
files=sort(files);

sfiles=size(files,2);

for pnom = 1:sfiles     % 'size(files,2)' is the number of original images
    filename = cell2mat(files(pnom));
    I=double(imread(char(strcat(MyPath,filename))));       % original image in the range [0 255]
    IPhantom=I(:,:,2)/255;
    [row1,col1,~]=find(IPhantom);
    for a=min(row1):max(row1)
        for a2=min(col1):max(col1)
            temp=IPhantom(a-1:a+1,a2-1:a2+1);
            [r1,c1,~]=find(temp);
            if size(r1,1)==8
                IPhantom(a,a2)=1;
            end
        end
    end
    I=I(:,:,1).*IPhantom;
    [row,col,~]=find(I);          % find nonzero elements in original image
    % C is the center of nonzero parts of the phantom ---------------------
    C=[floor((max(row)-min(row))/2+min(row))+1,floor((max(col)-min(col))/2+min(col))+1];
    % initialize dist (the matrix containing the distance between center
    % and each nonzero point of phantom) ----------------------------------
    dist=zeros(size(I));
    ssz=size(row,1);
    for m1=1:ssz
        dist(row(m1),col(m1))=myDist([row(m1) col(m1)],C);
    end
    All_dists(:,:,pnom)=dist;
    All_phantoms(:,:,pnom)=IPhantom;
end