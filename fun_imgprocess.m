function img2_new = fun_imgprocess(img1, img2, corner)
imgBoard = img1;

%%Extract booklet corners
I = rgb2gray(img2);
I=imgaussfilt(I,8);
BW = edge(I, 'canny', [0.2 0.4]);
rho_res = 1;
theta = -90:1:89;
[H,T,R] = hough(BW, 'RhoResolution',rho_res,'Theta',theta);
peaks=houghpeaks(H,4);

lines = houghlines(BW,T,R,peaks,'FillGap',5,'MinLength',10);

fourlines = [-cos(pi*(lines(1).theta/180))/sin(pi*(lines(1).theta/180)),-1,lines(1).rho/sin(pi*(lines(1).theta/180))];

for ii = 1:length(lines)-1
    if abs(lines(ii+1).theta-lines(ii).theta)>0.1 && abs(lines(ii+1).rho-lines(ii).rho)>0.1
        fourlines = [fourlines;[-cos(pi*(lines(ii+1).theta/180))/sin(pi*(lines(ii+1).theta/180)),-1,lines(ii+1).rho/sin(pi*(lines(ii+1).theta/180))]];
    else
    end
end

P = [];linepair2 = [];
k = 1;r = 2;
temp1 = abs(fourlines(k,1)-fourlines(r,1));
for i = 3:4
    temp2 = abs(fourlines(k,1)-fourlines(i,1));
    if temp2<temp1
       temp1 = temp2;
       r = i;
    else 
    end
end
 linepair1 = [k,r];
if fourlines(k,3)>fourlines(r,3)
    linepair1 = [r,k];
end

for j = 1:4
    if j~=linepair1(1)&&j~=linepair1(2)
        linepair2 = [linepair2,j];
    end
end
if fourlines(linepair2(1),3)>fourlines(linepair2(2),3)
    linepair3 = [linepair2(2),linepair2(1)];
    linepair2 = linepair3;
end

for ii = 1:2
    for jj = 1:2
        P = [P; cross(fourlines(linepair1(ii),:),fourlines(linepair2(jj),:))];
     end
end

%check the order of the corner points
corners = [P(:,1)./P(:,3),P(:,2)./P(:,3)];
len1 = sqrt((corners(1,1)-corners(2,1))^2+(corners(1,2)-corners(2,2))^2);
len2 = sqrt((corners(1,1)-corners(3,1))^2+(corners(1,2)-corners(3,2))^2);
if len1>len2
  corners2 = [corners(1,:);corners(3,:);corners(4,:);corners(2,:)]; 
else 
  corners2 = [corners(1,:);corners(2,:);corners(4,:);corners(3,:)]; 
end

%%remove projective distortion and create this new image
movingPoints = corners2;   
p1 = [24 31.5];
bookletImgSize = p1*50;
H=bookletImgSize(2);W=bookletImgSize(1);
p = [1,1;W,1;W,H;1,H];
fixedPoints = p;
H = fitgeotrans(movingPoints,fixedPoints,'projective');
[imgTran, RA] = imwarp(img2,H);
bookletImg = imcrop(imgTran, [-RA.XWorldLimits(1), -RA.YWorldLimits(1) bookletImgSize]);
imwrite(bookletImg, 'bookletcorner.JPG');

imgPicFile = 'bookletcorner.JPG';
info = imfinfo(imgPicFile);
sizePic = [info.Width info.Height];
bookletP = [1,1;sizePic(1),1;sizePic(1),sizePic(2);1,sizePic(2)];
movingPoints2 = bookletP;
T = fitgeotrans(movingPoints2,corner,'projective');

imgPic = imread(imgPicFile);

[imgPicTran, RB] = imwarp(imgPic, T);

BWPic = roipoly(imgPicTran, corner(:,1)-RB.XWorldLimits(1), corner(:,2)-RB.YWorldLimits(1));

BWBoard = ~roipoly(imgBoard, corner(:,1), corner(:,2));

RA = imref2d(size(BWBoard));

imgBoardMask = bsxfun(@times, imgBoard, cast(BWBoard, 'like', imgBoard));
imgPicTranMask = bsxfun(@times, imgPicTran, cast(BWPic, 'like', imgPicTran));

imgFinal(:,:,1) = imfuse(imgBoardMask(:,:,1),RA, imgPicTranMask(:,:,1),RB,'diff');
imgFinal(:,:,2) = imfuse(imgBoardMask(:,:,2),RA, imgPicTranMask(:,:,2),RB,'diff');
imgFinal(:,:,3) = imfuse(imgBoardMask(:,:,3),RA, imgPicTranMask(:,:,3),RB,'diff');

imshow(imgFinal); imwrite(imgFinal, 'result.jpg');
img2_new = 'result.jpg';
end
