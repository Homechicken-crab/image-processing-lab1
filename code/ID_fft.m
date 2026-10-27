%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'fft');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置频率坐标
[M, N] = size(I);
u = -floor(N/2):ceil(N/2)-1;
v = -floor(M/2):ceil(M/2)-1;

%% 计算中心化频谱
F = fft2(I);
F = fftshift(F); % 频谱中心化
S = abs(F); % 幅度谱
S = log(1 + S); % 对数压缩，便于显示

%% 显示并保存二维和三维频谱
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1120 580], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(1, 2, 1);
imshow(I, [0 1]);
title('原图，512×512');
subplot(1, 2, 2);
imagesc(u, v, S, [0 max(S(:))]);
axis image;
colormap(gray(256));
colorbar;
xlabel('水平频率索引 u');
ylabel('垂直频率索引 v');
title('中心化二维对数幅度谱');
sgtitle('FFT：fftshift(fft2(I))，显示 log(1+|F|)');
drawnow;
exportgraphics(f, fullfile(out, 'fft_2d_spectrum.png'), 'Resolution', 180);
close(f);

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1050 730], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
surf(u, v, S, 'EdgeColor', 'none');
view(45, 35);
axis tight;
colormap(parula(256));
colorbar;
xlabel('水平频率索引 u');
ylabel('垂直频率索引 v');
zlabel('log(1+|F|)');
title('中心化三维对数幅度谱，使用完整 512×512 数据');
drawnow;
exportgraphics(f, fullfile(out, 'fft_3d_spectrum.png'), 'Resolution', 180);
close(f);
fprintf('FFT 频谱实验完成。\n');
