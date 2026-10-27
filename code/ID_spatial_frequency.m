%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'spatial_frequency');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置高斯模板
[M, N] = size(I);
sigma = 1.0;
[x, y] = meshgrid(-2:2, -2:2);
h = exp(-(x.^2+y.^2)/(2*sigma^2)); % 5×5 高斯模板
h = h/sum(h(:));

%% 进行空域滤波
J1 = conv2(I, h, 'same'); % 零延拓卷积，保留中央部分

%% 构建频域滤波器
P = M + size(h,1) - 1;
Q = N + size(h,2) - 1; % 满足线性卷积的补零尺寸
hp = zeros(P, Q);
hp(1:5, 1:5) = h;
hp = circshift(hp, [-2 -2]); % 将模板中心移到 (1,1)
H = fft2(hp);

%% 进行频域滤波
F = fft2(I, P, Q);
G = F .* H; % 两者都使用未中心化频谱
J2 = ifft2(G);
J2 = real(J2);
J2 = J2(1:M, 1:N); % 与空域结果对齐

%% 计算两种结果的误差
d = J2 - J1;
e = max(abs(d(:))); % 最大绝对误差
mse = mean(d(:).^2); % 均方误差

%% 显示并保存结果
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1250 850], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(2, 3, 1);
imshow(I, [0 1]);
title('原图');
subplot(2, 3, 2);
imagesc(-2:2, -2:2, h);
axis image;
colorbar;
title('同一 5×5 高斯模板，σ=1');
xlabel('列偏移');
ylabel('行偏移');
subplot(2, 3, 3);
imagesc(abs(fftshift(H)), [0 1]);
axis image off;
colorbar;
title('由空间模板构建的频域幅度 |H|');
subplot(2, 3, 4);
imshow(J1, [0 1]);
title('空域卷积，零延拓');
subplot(2, 3, 5);
imshow(J2, [0 1]);
title('频域相乘，零延拓');
subplot(2, 3, 6);
imagesc(d, [-max(e,eps) max(e,eps)]);
axis image off;
colorbar;
title(sprintf('差值（放大色标），最大误差 %.3g', e));
colormap(gray(256));
sgtitle(sprintf('空频对照：补零 %d×%d，最大绝对误差 %.3g，MSE %.3g', P, Q, e, mse));
drawnow;
exportgraphics(f, fullfile(out, 'spatial_frequency_comparison.png'), 'Resolution', 180);
close(f);
fprintf('最大绝对误差 %.16g，均方误差 %.16g。\n', e, mse);
