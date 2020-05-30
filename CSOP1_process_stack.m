%% Son et. al., Molecular height measurement by cell surface optical profilometry (CSOP)
% 1. CSOP Image processing code
% - input: the root path of CSOP images 
% - output1: a text file containing the list of center positions in the CSOP image stack
% - output2: text files containing the radial fluorescence profile per image stack
% - major variables: img_thres, Rmin, Rmax, s, and e 
 
close all;
clear all;

PathName={
'..\example\CSOP_image_example\CSOP_ex1'
};

cam_depth=2^16;     % camera bit depth
img_thres=0.97;     % threshold to be used for binary image conversion (eg. 0.95 selects pixels with the highest 95% intensity values)
Rmin=50;    % minimum radius of CSOP image in pixel
Rmax=100;    % maximum radius of CSOP image in pixel
s=0.9;      % Sensitivity for imfindcircles function
e=0.1;      % EdgeThreshold for imfindcircles function

for ipath=1:length(PathName)
    dirinfo = dir(PathName{ipath});
    dirinfo(~[dirinfo.isdir]) = [];  % remove non-directories
    subdirinfo = cell(length(dirinfo));

    ifile=0;
    for K = 3:length(dirinfo)
        % find .tif files in subfolders
        ifile=ifile+1;
        thisdir = dirinfo(K).name;
        filename = dir(fullfile(PathName{ipath}, thisdir, '*.tif'));
        f = fullfile(PathName{ipath}, thisdir, filename.name);
        info=imfinfo(f);
        [pathstr,name,ext] = fileparts(f);
        data=zeros(numel(info), 3);    % initialize a data array for each fluorescence channel

        for j=1:numel(info)
            fprintf('...%s...%d\n', name, j);
            img=imread(f, j);
            
            % detect circles in the current image
            [pdf, I]=imhist(img, cam_depth);
            cdf=cumsum(pdf);
            Irange=find(cdf>cdf(end)*img_thres); 
            Gbw=im2bw(img, Irange(1)/cam_depth);

            [c, r, metric] = imfindcircles(imresize(imfill(Gbw, 'holes'), 0.5), [Rmin/2 Rmax/2], ...
                'ObjectPolarity', 'bright', 'Sensitivity', s, 'EdgeThreshold', e);
            ImgCircle=insertShape(img, 'circle', [c r]*2, 'LineWidth', 2);
            fig=figure(1);
            fig.Position=[750 450 500 500];
            imshowpair(imresize(ImgCircle*30, 2), imresize(Gbw, 2), 'montage');
            
            % when more than one circles are found select the one closest to the center of image
            dc=zeros(1,1);
            for m=1:length(c(:,1))
                dc(m)=sum(abs(c(m,:)*2-length(img)/2));
            end
            idx=find(dc==min(dc));
            
            output = CSOPf_process_img(img, c(idx,:)*2, r(idx)*2, j, f);    

            data(j,:)=[j output'];
            fprintf('%02dth - C[%2.4f %2.4f] \n', data(j,1), data(j,2), data(j,3));
        end
        % save data
        [pathstr,name,ext] = fileparts(f);
        ff=fullfile(pathstr, sprintf('%s_rad_prof.txt', name));
        save(ff, 'data', '-ascii');
    end
end
