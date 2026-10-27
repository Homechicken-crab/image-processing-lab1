%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'gaussian');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置参数
seed = 2026;
mu = 0; % 噪声均值
v = 0.01; % 噪声方差
sigma = 1.0; % 高斯标准差
rng(seed, 'twister');

%% 加入高斯白噪声
n = mu + sqrt(v) * randn(size(I));
J0 = I + n; % 含噪图像
J0 = min(max(J0, 0), 1);

%% 进行高斯平滑
[x, y] = meshgrid(-2:2, -2:2);
h = exp(-(x.^2 + y.^2) / (2*sigma^2)); % 5×5 高斯模板
h = h / sum(h(:));
J = imfilter(J0, h, 'symmetric', 'conv', 'same'); % 对称延拓

%% 显示并保存结果
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1350 500], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(1, 3, 1);
imshow(I, [0 1]);
title('原图');
subplot(1, 3, 2);
imshow(J0, [0 1]);
title(sprintf('高斯噪声：均值 0，方差 %.2f', v));
subplot(1, 3, 3);
imshow(J, [0 1]);
title(sprintf('5×5 高斯平滑，σ=%.1f', sigma));
sgtitle('高斯平滑：对称延拓，统一显示 [0,1]，随机种子 2026');
drawnow;
exportgraphics(f, fullfile(out, 'gaussian_comparison.png'), 'Resolution', 180);
close(f);
fprintf('高斯平滑实验完成。\n');
