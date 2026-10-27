function ID_lowpass()
% 理想低通和二阶 Butterworth 低通滤波
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'lowpass');
if ~exist(out, 'dir'), mkdir(out); end
D0 = 90;
order = 2;

% 构建指定的 384×384 响应
u384 = -192:191;
v384 = -192:191;
[u, v] = meshgrid(u384, v384);
D = sqrt(u.^2 + v.^2);
H_ideal_384 = double(D <= D0);
H_butter_384 = 1 ./ (1 + (D/D0).^(2*order));
assert(isequal(size(H_ideal_384), [384 384]));
assert(H_butter_384(193, 193+90) == 0.5);

f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1150 900], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(2, 2, 1); imagesc(u384, v384, H_ideal_384, [0 1]); axis image; colorbar;
xlabel('u'); ylabel('v'); title('理想低通：二维响应');
subplot(2, 2, 2); imagesc(u384, v384, H_butter_384, [0 1]); axis image; colorbar;
xlabel('u'); ylabel('v'); title('二阶 Butterworth：二维响应');
subplot(2, 2, 3); surf(u384, v384, H_ideal_384, 'EdgeColor', 'none');
view(40, 35); axis tight; zlim([0 1]); xlabel('u'); ylabel('v'); zlabel('H'); title('理想低通：三维响应');
subplot(2, 2, 4); surf(u384, v384, H_butter_384, 'EdgeColor', 'none');
view(40, 35); axis tight; zlim([0 1]); xlabel('u'); ylabel('v'); zlabel('H'); title('二阶 Butterworth：三维响应');
colormap(parula(256)); sgtitle('384×384 频域滤波器响应，截止频率 D_0=90');
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_responses_384.png'), 'Resolution', 180);
close(f);

% 读取大图，补零到 2M×2N
I = imread(fullfile(root, 'images', 'Low illumination.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
[M, N] = size(I);
assert(M > 512 && N > 512);
P = 2*M;
Q = 2*N;
[u, v] = meshgrid(-Q/2:Q/2-1, -P/2:P/2-1);
D = sqrt(u.^2 + v.^2);
H_ideal = double(D <= D0);
H_butter = 1 ./ (1 + (D/D0).^(2*order));
clear u v D;

% 频域相乘后反中心化，再逆变换
F = fftshift(fft2(I, P, Q));
assert(isequal(size(F), size(H_ideal), size(H_butter)));
inverse_ideal = ifft2(ifftshift(F .* H_ideal));
inverse_butter = ifft2(ifftshift(F .* H_butter));
imaginary_ideal = max(abs(imag(inverse_ideal(:))));
imaginary_butter = max(abs(imag(inverse_butter(:))));
J_ideal = real(inverse_ideal(1:M, 1:N));
J_butter = real(inverse_butter(1:M, 1:N));
reconstruction = real(ifft2(ifftshift(F)));
reconstruction = reconstruction(1:M, 1:N);
identity_error = max(abs(reconstruction(:)-I(:)));
assert(identity_error < 1e-12 && max(imaginary_ideal, imaginary_butter) < 1e-12);
assert(H_ideal(P/2+1,Q/2+1) == 1 && H_butter(P/2+1,Q/2+1) == 1);
clear F inverse_ideal inverse_butter reconstruction;

% 图像使用固定范围，避免自动拉伸掩盖变化
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1400 850], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(2, 3, 1); imshow(I, [0 1]); title(sprintf('原图：%d×%d（宽×高）', N, M));
subplot(2, 3, 2); imagesc(H_ideal, [0 1]); axis image off; colorbar; title(sprintf('ILPF：%d×%d（行×列）', P, Q));
subplot(2, 3, 3); imshow(J_ideal, [0 1]); title('理想低通结果，显示 [0,1]');
subplot(2, 3, 4); imshow(I, [0 1]); title('同一幅原图');
subplot(2, 3, 5); imagesc(H_butter, [0 1]); axis image off; colorbar; title(sprintf('BLPF：二阶，D_0=%d', D0));
subplot(2, 3, 6); imshow(J_butter, [0 1]); title('Butterworth 结果，显示 [0,1]');
colormap(gray(256));
sgtitle(sprintf('频域低通：D_0=%d，零延拓到 %d×%d（行×列），左上角裁剪', D0, P, Q));
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_image_comparison.png'), 'Resolution', 180);
close(f);

% 放大同一区域，便于观察边缘和振铃
roi_rows = 360:650;
roi_cols = 100:650;
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1400 430], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
subplot(1, 3, 1); imshow(I(roi_rows,roi_cols), [0 1]); title('原图局部');
subplot(1, 3, 2); imshow(J_ideal(roi_rows,roi_cols), [0 1]); title('理想低通局部');
subplot(1, 3, 3); imshow(J_butter(roi_rows,roi_cols), [0 1]); title('二阶 Butterworth 局部');
sgtitle('相同局部：行 360:650，列 100:650；统一显示 [0,1]');
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_roi_comparison.png'), 'Resolution', 180);
close(f);
fprintf('ID_lowpass PASS: image=%dx%d, padded=%dx%d, identity error=%.6g\n', M, N, P, Q, identity_error);
end
