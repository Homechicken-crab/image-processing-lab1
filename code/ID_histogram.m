%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'histogram');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'Low illumination.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end

%% 设置参数
[M, N] = size(I);
L = 256; % 灰度级数

%% 统计归一化直方图
h = zeros(L, 1); % 各灰度的像素数
for i = 1:M
    for j = 1:N
        k = double(I(i, j)) + 1;
        h(k) = h(k) + 1;
    end
end
p = h / (M * N); % 归一化概率

%% 进行直方图均衡化
s = zeros(L, 1); % 累计概率
s(1) = p(1);
for k = 2:L
    s(k) = s(k - 1) + p(k);
end
T = round((L - 1) * s); % 灰度映射
J = zeros(M, N, 'uint8');
h1 = zeros(L, 1);
for i = 1:M
    for j = 1:N
        g = T(double(I(i, j)) + 1);
        J(i, j) = uint8(g);
        h1(g + 1) = h1(g + 1) + 1;
    end
end
p1 = h1 / (M * N);

%% 显示并保存结果
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1200 760], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(2, 2, 1);
imshow(I, [0 255]);
title('原图，显示范围 [0,255]');
subplot(2, 2, 2);
imshow(J, [0 255]);
title('自编直方图均衡化');
ymax = 1.05 * max([p; p1]);
subplot(2, 2, 3);
bar(0:255, p, 1);
xlim([0 255]);
ylim([0 ymax]);
xlabel('灰度级');
ylabel('概率');
title('原图归一化直方图');
subplot(2, 2, 4);
bar(0:255, p1, 1);
xlim([0 255]);
ylim([0 ymax]);
xlabel('灰度级');
ylabel('概率');
title('均衡后归一化直方图');
sgtitle('直方图均衡化：累计概率映射，四舍五入到 256 级');
drawnow;
exportgraphics(f, fullfile(out, 'histogram_comparison.png'), 'Resolution', 180);
close(f);
fprintf('直方图实验完成。\n');
