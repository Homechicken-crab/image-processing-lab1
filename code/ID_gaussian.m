function ID_gaussian()
% 高斯白噪声和高斯平滑
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'gaussian');
if ~exist(out, 'dir'), mkdir(out); end

% 读取原图并转为 [0,1] 双精度
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
seed = 2026;
noise_mean = 0;
noise_var = 0.01;
sigma = 1.0;
rng(seed, 'twister');

% 加入噪声，超出图像范围的值截断
noise = noise_mean + sqrt(noise_var) * randn(size(I));
noisy_unclipped = I + noise;
noisy = min(max(noisy_unclipped, 0), 1);

% 设计 5×5 高斯模板
[x, y] = meshgrid(-2:2, -2:2);
h = exp(-(x.^2 + y.^2) / (2*sigma^2));
h = h / sum(h(:));
J = imfilter(noisy, h, 'symmetric', 'conv', 'same');
assert(abs(sum(h(:))-1) < 1e-12 && isequal(size(J), size(I)));
mse_noisy = mean((noisy(:)-I(:)).^2);
mse_filtered = mean((J(:)-I(:)).^2);

% 使用相同范围显示
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1350 500], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制三幅对比图
subplot(1, 3, 1); imshow(I, [0 1]); title('原图');
subplot(1, 3, 2); imshow(noisy, [0 1]); title(sprintf('高斯噪声：均值 0，方差 %.2f', noise_var));
subplot(1, 3, 3); imshow(J, [0 1]); title(sprintf('5×5 高斯平滑，σ=%.1f', sigma));
sgtitle('高斯平滑：对称延拓，统一显示 [0,1]，随机种子 2026');
drawnow;
exportgraphics(f, fullfile(out, 'gaussian_comparison.png'), 'Resolution', 180);
close(f);
fprintf('ID_gaussian PASS: MSE noisy=%.8g, filtered=%.8g\n', mse_noisy, mse_filtered);
end
