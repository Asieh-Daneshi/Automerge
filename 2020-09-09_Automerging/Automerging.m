%==========================================================================
% First we have to find the right position for each frame. We use
% 'AutoAOMontagingGUI' for this
%==========================================================================
clear
clc
warning ('off','all');
prompt='Have you run the ''AutoAOMontagingGUI'' before? (yes=1, no=0)\n';
Rnom=input(prompt);
while (Rnom~=0 && Rnom~=1)
    fprintf('Wrong choice! You can ony select 1 or 0.\n');
    prompt='Have you run the ''AutoAOMontagingGUI'' before? (yes=1, no=0)\n';
    Rnom=input(prompt);
end
if Rnom==0
    clc
    fprintf('Running Automontaging program ...\n');
    f=AutoAOMontagingGUI;
    uiwait(f);
    close all
    clear
    clc
    fprintf('Please select the folder containing the output images from ''Automontaging'' program:\n');
    CurrentDirectory=uigetdir;
    % cd(CurrentDirectory)
    MyPath=[CurrentDirectory,filesep];
    if (exist(strcat(MyPath,'All_phantoms.mat'), 'file')==2 && exist(strcat(MyPath,'mergedImF.tiff'), 'file')==2 && exist(strcat(MyPath,'All_dists.mat'), 'file')==2)
        %----------------------------------------------------------------------
        % Finally, we can modify the parts that we are not satisfied with
        %----------------------------------------------------------------------
        clc
        fprintf('Now, we can modify the parts that we are not satisfied with ...\n');
        AfterMerge
    else
        %----------------------------------------------------------------------
        % Now, we add 20 pixels black margin around each frame
        %----------------------------------------------------------------------
        clc
        fprintf('Adding a 20 pixels black margin around each frame ...\n');
        PaddImages
        %----------------------------------------------------------------------
        % Now, we merge and montage all the frames
        %----------------------------------------------------------------------
        clc
        fprintf('Merging and montaging (this step is time consuming) ...\n');
        Panorama
        %----------------------------------------------------------------------
        % Finally, we can modify the parts that we are not satisfied with
        %----------------------------------------------------------------------
        clc
        fprintf('Now, we can modify the parts that we are not satisfied with ...\n');
        AfterMerge
    end
elseif Rnom==1
    close all
    clear
    clc
    fprintf('Please select the folder containing the output images from ''Automontaging'' program:\n');
    CurrentDirectory=uigetdir;
    % cd(CurrentDirectory)
    MyPath=[CurrentDirectory,filesep];
    if (exist(strcat(MyPath,'All_phantoms.mat'), 'file')==2 && exist(strcat(MyPath,'mergedImF.tiff'), 'file')==2 && exist(strcat(MyPath,'All_dists.mat'), 'file')==2)
        %----------------------------------------------------------------------
        % Finally, we can modify the parts that we are not satisfied with
        %----------------------------------------------------------------------
        clc
        fprintf('Now, we can modify the parts that we are not satisfied with ...\n');
        AfterMerge
    else
        %----------------------------------------------------------------------
        % Now, we add 20 pixels black margin around each frame
        %----------------------------------------------------------------------
        clc
        fprintf('Adding a 20 pixels black margin around each frame ...\n');
        PaddImages
        %----------------------------------------------------------------------
        % Now, we merge and montage all the frames
        %----------------------------------------------------------------------
        clc
        fprintf('Merging and montaging (this step is time consuming) ...\n');
        Panorama
        %----------------------------------------------------------------------
        % Finally, we can modify the parts that we are not satisfied with
        %----------------------------------------------------------------------
        clc
        fprintf('Now, we can modify the parts that we are not satisfied with ...\n');
        AfterMerge
    end
end
warning ('on','all');