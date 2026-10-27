function ID_spatial_frequency()
% 比较同一高斯模板的空域和频域实现
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'spatial_frequency');
if ~exist(out, 'dir'), mkdir(out); end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
[M, N] = size(I);
sigma = 1.0;
[x, y] = meshgrid(-2:2, -2:2);
h = exp(-(x.^2+y.^2)/(2*sigma^2));
h = h/sum(h(:));

% 空域卷积，边界补零，保留与原图相同的中央部分
J_spatial = conv2(I, h, 'same');

% 补零后将模板中心移动到左上角原点
P = M + size(h,1) - 1;
Q = N + size(h,2) - 1;
hp = zeros(P, Q);
hp(1:5, 1:5) = h;
hp = circshift(hp, [-2 -2]);
H = fft2(hp);
inverse = ifft2(fft2(I, P, Q) .* H);
J_frequency = real(inverse(1:M, 1:N));

% 检查数值误差和裁剪位置
difference = J_frequency-J_spatial;
max_abs_error = max(abs(difference(:)));
mse = mean(difference(:).^2);
imaginary_max = max(abs(imag(inverse(:))));
reference = imfilter(I, h, 0, 'conv', 'same');
reference_error = max(abs(reference(:)-J_spatial(:)));
assert(max_abs_error < 1e-12 && imaginary_max < 1e-12 && reference_error < 1e-12);
assert(abs(H(1,1)-1) < 1e-12 && hp(1,1) == h(3,3));

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1250 850], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(2, 3, 1); imshow(I, [0 1]); title('原图');
subplot(2, 3, 2); imagesc(-2:2, -2:2, h); axis image; colorbar; title('同一 5×5 高斯模板，σ=1');
xlabel('列偏移'); ylabel('行偏移');
subplot(2, 3, 3); imagesc(abs(fftshift(H)), [0 1]); axis image off; colorbar; title('由空间模板构建的频域幅度 |H|');
subplot(2, 3, 4); imshow(J_spatial, [0 1]); title('空域卷积，零延拓');
subplot(2, 3, 5); imshow(J_frequency, [0 1]); title('频域相乘，零延拓');
subplot(2, 3, 6); imagesc(difference, [-max(max_abs_error,eps) max(max_abs_error,eps)]);
axis image off; colorbar; title(sprintf('差值（放大色标），最大误差 %.3g', max_abs_error));
colormap(gray(256));
sgtitle(sprintf('空频对照：补零 %d×%d，最大绝对误差 %.3g，MSE %.3g', P, Q, max_abs_error, mse));
drawnow;
exportgraphics(f, fullfile(out, 'spatial_frequency_comparison.png'), 'Resolution', 180);
close(f);
fprintf('ID_spatial_frequency PASS: max abs error=%.16g, MSE=%.16g\n', max_abs_error, mse);
end
