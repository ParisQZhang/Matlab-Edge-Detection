%% Parameter
file_img1 = '20200227_104101.jpg';
file_img2 = 'IMG_0080.JPG';

%% Processing
img1 = imread(fullfile(file_img1));
img2 = imread(fullfile(file_img2));

figure(1); imshow(img1);
p = drawpolygon('LineWidth',5,'Color','black');
corner1 = p.Position;

%%fun_imgprocess functions process "img1" then overlay it on "img2"
img2_new = fun_imgprocess(img1, img2, corner1);
imshow(img2_new);
