function ID_histogram()
% 归一化直方图和直方图均衡化
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'histogram');
if ~exist(out, 'dir'), mkdir(out); end

% 读取原图
I = imread(fullfile(root, 'images', 'Low illumination.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
[M, N] = size(I);
L = 256;

% 统计每个灰度的像素数
counts = zeros(L, 1);
for row = 1:M
    for col = 1:N
        k = double(I(row, col)) + 1;
        counts(k) = counts(k) + 1;
    end
end
p = counts / (M * N);

% 计算累计概率和灰度映射
cdf = zeros(L, 1);
cdf(1) = p(1);
for k = 2:L
    cdf(k) = cdf(k - 1) + p(k);
end
map = round((L - 1) * cdf);
J = zeros(M, N, 'uint8');
counts_after = zeros(L, 1);
for row = 1:M
    for col = 1:N
        value = map(double(I(row, col)) + 1);
        J(row, col) = uint8(value);
        counts_after(value + 1) = counts_after(value + 1) + 1;
    end
end
p_after = counts_after / (M * N);
assert(sum(counts) == M*N && sum(counts_after) == M*N);
assert(abs(sum(p)-1) < 1e-12 && all(diff(map) >= 0));

% 绘制处理前后图像和直方图
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1200 760], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(2, 2, 1); imshow(I, [0 255]); title('原图，显示范围 [0,255]');
subplot(2, 2, 2); imshow(J, [0 255]); title('自编直方图均衡化');
ymax = 1.05 * max([p; p_after]);
subplot(2, 2, 3); bar(0:255, p, 1); xlim([0 255]); ylim([0 ymax]);
xlabel('灰度级'); ylabel('概率'); title('原图归一化直方图');
subplot(2, 2, 4); bar(0:255, p_after, 1); xlim([0 255]); ylim([0 ymax]);
xlabel('灰度级'); ylabel('概率'); title('均衡后归一化直方图');
sgtitle('直方图均衡化：累计概率映射，四舍五入到 256 级');
drawnow;
exportgraphics(f, fullfile(out, 'histogram_comparison.png'), 'Resolution', 180);
close(f);
fprintf('ID_histogram PASS: pixels=%d, sum(p)=%.15g\n', M*N, sum(p));
end
