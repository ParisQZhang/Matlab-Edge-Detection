function corners2 = FindCorner2(img)
I = rgb2gray(img);
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
end

