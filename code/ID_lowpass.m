%% 读取图像
clear;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'lowpass');
if ~exist(out, 'dir')
    mkdir(out);
end
I = imread(fullfile(root, 'images', 'Low illumination.jpg'));
if size(I, 3) == 3
    I = rgb2gray(I);
end
I = im2double(I); % 转为 [0,1] 双精度

%% 设置参数
[M, N] = size(I);
D0 = 90; % 截止频率
n = 2; % Butterworth 阶数

%% 构建 384×384 频域滤波器
u0 = -192:191;
v0 = -192:191;
[u, v] = meshgrid(u0, v0);
D = sqrt(u.^2 + v.^2); % 到中心的距离
H1 = double(D <= D0); % 理想低通
H2 = 1 ./ (1 + (D/D0).^(2*n)); % Butterworth 低通

%% 显示并保存滤波器响应
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1150 900], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(2, 2, 1);
imagesc(u0, v0, H1, [0 1]);
axis image;
colorbar;
xlabel('u');
ylabel('v');
title('理想低通：二维响应');
subplot(2, 2, 2);
imagesc(u0, v0, H2, [0 1]);
axis image;
colorbar;
xlabel('u');
ylabel('v');
title('二阶 Butterworth：二维响应');
subplot(2, 2, 3);
surf(u0, v0, H1, 'EdgeColor', 'none');
view(40, 35);
axis tight;
zlim([0 1]);
xlabel('u');
ylabel('v');
zlabel('H');
title('理想低通：三维响应');
subplot(2, 2, 4);
surf(u0, v0, H2, 'EdgeColor', 'none');
view(40, 35);
axis tight;
zlim([0 1]);
xlabel('u');
ylabel('v');
zlabel('H');
title('二阶 Butterworth：三维响应');
colormap(parula(256));
sgtitle('384×384 频域滤波器响应，截止频率 D_0=90');
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_responses_384.png'), 'Resolution', 180);
close(f);

%% 构建与补零频谱同尺寸的滤波器
P = 2*M;
Q = 2*N; % 图像零延拓到 2M×2N
[u, v] = meshgrid(-Q/2:Q/2-1, -P/2:P/2-1);
D = sqrt(u.^2 + v.^2);
H1 = double(D <= D0);
H2 = 1 ./ (1 + (D/D0).^(2*n));

%% 进行频域滤波
F = fft2(I, P, Q);
F = fftshift(F); % 频谱中心化

G = F .* H1; % 理想低通滤波
G = ifftshift(G); % 反中心化
J1 = ifft2(G);
J1 = real(J1);
J1 = J1(1:M, 1:N); % 裁剪到原图大小

G = F .* H2; % Butterworth 低通滤波
G = ifftshift(G);
J2 = ifft2(G);
J2 = real(J2);
J2 = J2(1:M, 1:N);

%% 显示并保存处理结果
% 图像使用固定范围，避免自动拉伸掩盖变化
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1400 850], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(2, 3, 1);
imshow(I, [0 1]);
title(sprintf('原图：%d×%d（宽×高）', N, M));
subplot(2, 3, 2);
imagesc(H1, [0 1]);
axis image off;
colorbar;
title(sprintf('ILPF：%d×%d（行×列）', P, Q));
subplot(2, 3, 3);
imshow(J1, [0 1]);
title('理想低通结果，显示 [0,1]');
subplot(2, 3, 4);
imshow(I, [0 1]);
title('同一幅原图');
subplot(2, 3, 5);
imagesc(H2, [0 1]);
axis image off;
colorbar;
title(sprintf('BLPF：二阶，D_0=%d', D0));
subplot(2, 3, 6);
imshow(J2, [0 1]);
title('Butterworth 结果，显示 [0,1]');
colormap(gray(256));
sgtitle(sprintf('频域低通：D_0=%d，零延拓到 %d×%d（行×列），左上角裁剪', D0, P, Q));
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_image_comparison.png'), 'Resolution', 180);
close(f);

%% 显示并保存局部对比
a = 360:650;
b = 100:650;
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1400 430], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
subplot(1, 3, 1);
imshow(I(a,b), [0 1]);
title('原图局部');
subplot(1, 3, 2);
imshow(J1(a,b), [0 1]);
title('理想低通局部');
subplot(1, 3, 3);
imshow(J2(a,b), [0 1]);
title('二阶 Butterworth 局部');
sgtitle('相同局部：行 360:650，列 100:650；统一显示 [0,1]');
drawnow;
exportgraphics(f, fullfile(out, 'lowpass_roi_comparison.png'), 'Resolution', 180);
close(f);
fprintf('频域低通滤波完成。\n');
