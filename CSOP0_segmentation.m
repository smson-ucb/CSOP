%% Son et. al., Molecular height measurement by cell surface optical profilometry (CSOP)
% 0. Optional image segmentation code that generates a separate image for each circle
% - input: the root path of CSOP images, which contains several circles per image
% - output: separate images containing individual circles 
% - major variables: img_thres, Rmin, Rmax, s, and e 

close all;
clear all;

PathName={
'..\example\CSOP_image_example'
}

img_thres=0.003;     % threshold to be used for binary image conversion 
Rmin=50;    % minimum radius of CSOP image in pixel
Rmax=100;    % maximum radius of CSOP image in pixel
s=0.9;      % Sensitivity for imfindcircles function
e=0.1;      % EdgeThreshold for imfindcircles function

fig=figure(1);
set(fig, 'position', [50 600 500 600]);
fig=figure(2);
set(fig, 'position', [550 600 500 600]);

for ipath=1:length(PathName)
    dirinfo = dir(PathName{ipath});
    dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
    subdirinfo = cell(length(dirinfo));

    for K = 3:length(dirinfo)
        % find tif files in the subfolders
        thisdir = dirinfo(K).name;
        filename = dir(fullfile(PathName{ipath}, thisdir, '*.tif'));
        f = fullfile(PathName{ipath}, thisdir, filename.name);
        [pathstr,name,ext] = fileparts(f);
        fprintf('Processing... %s\n', thisdir);
        
        % find the center of the first image
        img=imread(f, 1);
        Ibw=im2bw(img, img_thres);
        figure(1);
        imshow(imresize(Ibw, .5));
        [c, r, metric] = imfindcircles(Ibw, [Rmin Rmax], ...
            'ObjectPolarity', 'bright', 'Sensitivity', s, 'EdgeThreshold', e);
        rec=[c(:,1)-r*3 c(:,2)-r*3 r*6 r*6];      
        ImgCircle=insertShape(img, 'rectangle', rec, 'LineWidth', 2);
        figure(2);
        imshow(imresize(ImgCircle*30, .5));
        
        % crop and create a stack for each circle
        for j=1:length(c(:,1))
            fd=fullfile(pathstr, sprintf('x%04.0f_y%04.0f', c(j,1), c(j,2)));
            mkdir(fd);
            ff=fullfile(fd, sprintf('x%04.0f_y%04.0f.tif', c(j,1), c(j,2)));
            info=imfinfo(f);
            for k=1:numel(info)
                I=imread(f,k);
                cimg=imcrop(I, rec(j,:));
                imwrite(cimg, ff, 'WriteMode', 'append');
            end
        end
    end
end
