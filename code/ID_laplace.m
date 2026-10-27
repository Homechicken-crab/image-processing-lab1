%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'laplace');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置模板
h = [1 0 1; 0 -4 0; 1 0 1]; % 指导书指定模板

%% 进行高通滤波
J = imfilter(I, h, 'symmetric', 'conv', 'same');

%% 设置正负响应色标
a = max(abs(J(:)));
t = linspace(0, 1, 128)';
map = [t t ones(128,1); ones(128,1) flipud(t) flipud(t)];

%% 显示并保存结果
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1100 570], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
ax1 = subplot(1, 2, 1);
imshow(I, [0 1]);
colormap(ax1, gray(256));
title('原图，显示范围 [0,1]');
ax2 = subplot(1, 2, 2);
imagesc(J, [-a a]);
axis image off;
colormap(ax2, map);
colorbar;
title('Laplace 有符号响应：蓝负、红正');
sgtitle('模板 [1 0 1; 0 -4 0; 1 0 1]，对称延拓');
drawnow;
exportgraphics(f, fullfile(out, 'laplace_signed_response.png'), 'Resolution', 180);
close(f);
fprintf('Laplace 高通滤波完成。\n');
