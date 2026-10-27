%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'rank_filter');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'airplane.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置参数
seed = 2027;
d = 0.05; % 椒盐噪声密度
rng(seed, 'twister');

%% 加入椒盐噪声
r = rand(size(I));
a = r < d/2; % 椒噪声位置
b = r >= 1-d/2; % 盐噪声位置
J = I;
J(a) = 0;
J(b) = 1; % 三种滤波共用这幅含噪图像

%% 进行统计排序滤波
[M, N] = size(I);
I0 = padarray(J, [1 1], 'symmetric', 'both'); % 对称延拓
J1 = zeros(M, N); % 最小值结果
J2 = zeros(M, N); % 中值结果
J3 = zeros(M, N); % 最大值结果
for i = 1:M
    for j = 1:N
        w = I0(i:i+2, j:j+2); % 3×3 邻域
        s = sort(w(:)); % 整个邻域展开排序
        J1(i, j) = s(1);
        J2(i, j) = s(5);
        J3(i, j) = s(9);
    end
end

%% 计算图中使用的峰值信噪比
e = [mean((J(:)-I(:)).^2); mean((J1(:)-I(:)).^2); ...
    mean((J2(:)-I(:)).^2); mean((J3(:)-I(:)).^2)];
p = 10*log10(1./e);

%% 显示并保存结果
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1250 760], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(2, 3, 1);
imshow(I, [0 1]);
title('原图');
subplot(2, 3, 2);
imshow(J, [0 1]);
title('同一幅椒盐噪声图，密度 0.05');
subplot(2, 3, 3);
imshow(a | b);
title('噪声选中位置（白色）');
subplot(2, 3, 4);
imshow(J1, [0 1]);
title(sprintf('3×3 最小值，PSNR %.2f dB', p(2)));
subplot(2, 3, 5);
imshow(J2, [0 1]);
title(sprintf('3×3 中值，PSNR %.2f dB', p(3)));
subplot(2, 3, 6);
imshow(J3, [0 1]);
title(sprintf('3×3 最大值，PSNR %.2f dB', p(4)));
sgtitle('统计排序滤波：对称延拓，图像统一显示 [0,1]，随机种子 2027');
drawnow;
exportgraphics(f, fullfile(out, 'rank_filter_comparison.png'), 'Resolution', 180);
close(f);
fprintf('统计排序滤波完成。\n');
