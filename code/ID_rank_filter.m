function ID_rank_filter()
% 椒盐噪声和最小值、中值、最大值滤波
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'rank_filter');
if ~exist(out, 'dir'), mkdir(out); end
I = imread(fullfile(root, 'images', 'airplane.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
seed = 2027;
density = 0.05;
rng(seed, 'twister');

% 三种滤波使用同一幅含噪图像
r = rand(size(I));
pepper = r < density/2;
salt = r >= 1-density/2;
noisy = I;
noisy(pepper) = 0;
noisy(salt) = 1;
[M, N] = size(I);
padded = padarray(noisy, [1 1], 'symmetric', 'both');
Jmin = zeros(M, N);
Jmedian = zeros(M, N);
Jmax = zeros(M, N);

% 对整个 3×3 邻域排序
for row = 1:M
    for col = 1:N
        block = padded(row:row+2, col:col+2);
        values = sort(block(:));
        Jmin(row, col) = values(1);
        Jmedian(row, col) = values(5);
        Jmax(row, col) = values(9);
    end
end
reference = medfilt2(noisy, [3 3], 'symmetric');
median_error = max(abs(Jmedian(:)-reference(:)));
assert(median_error == 0 && all(Jmin(:)<=Jmedian(:)) && all(Jmedian(:)<=Jmax(:)));
mse_values = [mean((noisy(:)-I(:)).^2); mean((Jmin(:)-I(:)).^2); ...
    mean((Jmedian(:)-I(:)).^2); mean((Jmax(:)-I(:)).^2)];
psnr_values = 10*log10(1./mse_values);

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1250 760], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(2, 3, 1); imshow(I, [0 1]); title('原图');
subplot(2, 3, 2); imshow(noisy, [0 1]); title('同一幅椒盐噪声图，密度 0.05');
subplot(2, 3, 3); imshow(pepper | salt); title('噪声选中位置（白色）');
subplot(2, 3, 4); imshow(Jmin, [0 1]); title(sprintf('3×3 最小值，PSNR %.2f dB', psnr_values(2)));
subplot(2, 3, 5); imshow(Jmedian, [0 1]); title(sprintf('3×3 中值，PSNR %.2f dB', psnr_values(3)));
subplot(2, 3, 6); imshow(Jmax, [0 1]); title(sprintf('3×3 最大值，PSNR %.2f dB', psnr_values(4)));
sgtitle('统计排序滤波：对称延拓，图像统一显示 [0,1]，随机种子 2027');
drawnow;
exportgraphics(f, fullfile(out, 'rank_filter_comparison.png'), 'Resolution', 180);
close(f);
fprintf('ID_rank_filter PASS: median reference error=%.3g, PSNR=%.4f dB\n', median_error, psnr_values(3));
end
