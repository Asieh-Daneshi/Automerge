%% 'PaddImages.m' adds a 20 pixels black margin around all the '.tif' images
% in the current folder that their name starts with 'BAK'
% Asieh Daneshi July. 2020
%--------------------------------------------------------------------------
current_folder=CurrentDirectory;
files=dir(fullfile(current_folder,'*BAK*.tif'));
files={files.name};
files=sort(files);
if size(files,1)==0
    fprintf('There is no frame to merge in this folder! Please run ''AutoAOMontagingGUI'' first.\n');
end

sfiles=size(files,2);    

for pnom = 1:sfiles
    filename = cell2mat(files(pnom));
    I=imread(char(strcat(MyPath,filename)));     
    IPadd=padarray(I,[20 20],0,'both');
    tiffwrite(uint8(IPadd),char(strcat(MyPath,strrep(filename,'tif','tiff'))));
end