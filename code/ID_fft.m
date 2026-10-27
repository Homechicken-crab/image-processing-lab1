function ID_fft()
% FFT 和中心化频谱显示
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'fft');
if ~exist(out, 'dir'), mkdir(out); end
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
[M, N] = size(I);

% 计算频谱，移到中心后取对数幅度
F = fftshift(fft2(I));
amplitude = abs(F);
log_amplitude = log(1 + amplitude);
u = -floor(N/2):ceil(N/2)-1;
v = -floor(M/2):ceil(M/2)-1;

% 检查反中心化和逆变换
inverse = ifft2(ifftshift(F));
reconstruction = real(inverse);
max_error = max(abs(reconstruction(:)-I(:)));
imaginary_max = max(abs(imag(inverse(:))));
spatial_energy = sum(I(:).^2);
frequency_energy = sum(amplitude(:).^2)/(M*N);
parseval_error = abs(spatial_energy-frequency_energy)/spatial_energy;
assert(max_error < 1e-12 && imaginary_max < 1e-12 && parseval_error < 1e-12);

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1120 580], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(1, 2, 1); imshow(I, [0 1]); title('原图，512×512');
subplot(1, 2, 2); imagesc(u, v, log_amplitude, [0 max(log_amplitude(:))]);
axis image; colormap(gray(256)); colorbar;
xlabel('水平频率索引 u'); ylabel('垂直频率索引 v'); title('中心化二维对数幅度谱');
sgtitle('FFT：fftshift(fft2(I))，显示 log(1+|F|)');
drawnow;
exportgraphics(f, fullfile(out, 'fft_2d_spectrum.png'), 'Resolution', 180);
close(f);

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1050 730], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
surf(u, v, log_amplitude, 'EdgeColor', 'none');
view(45, 35); axis tight; colormap(parula(256)); colorbar;
xlabel('水平频率索引 u'); ylabel('垂直频率索引 v'); zlabel('log(1+|F|)');
title('中心化三维对数幅度谱，使用完整 512×512 数据');
drawnow;
exportgraphics(f, fullfile(out, 'fft_3d_spectrum.png'), 'Resolution', 180);
close(f);
fprintf('ID_fft PASS: inverse max error=%.6g, Parseval relative error=%.6g\n', max_error, parseval_error);
end
