clear; close all; clc; format shortG;

%% Parameter
bookletSize = [24 31.5]; % cm
bookletImgSize = bookletSize*50; % output image size
dirImg = 'img'; % image folder
dirOut = 'out'; % output image folder
imgList = dir('img/*.JPG'); 
nImg = numel(imgList);

%% Processing
for ii=1:nImg
    img = imread(fullfile(dirImg, imgList(ii).name));
    corner = FindCorner2(img); % find ordered four corners
   
    H = ComputeH4(corner, bookletImgSize); % compute a homography
    
    %[imgTran, RA] = imwarp(img, projective2d(H'));
    [imgTran, RA] = imwarp(img,H);
    bookletImg = imcrop(imgTran, [-RA.XWorldLimits(1), -RA.YWorldLimits(1) bookletImgSize]);
    imwrite(bookletImg, fullfile(dirOut,imgList(ii).name));
end
