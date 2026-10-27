function ID_laplace()
% 指定模板的 Laplace 高通滤波
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'results', 'laplace');
if ~exist(out, 'dir'), mkdir(out); end

% 读取原图
I = imread(fullfile(root, 'images', 'barbara.jpg'));
if size(I, 3) == 3, I = rgb2gray(I); end
I = im2double(I);
h = [1 0 1; 0 -4 0; 1 0 1];
response = imfilter(I, h, 'symmetric', 'conv', 'same');
assert(sum(h(:)) == 0 && min(response(:)) < 0 && max(response(:)) > 0);

% 响应使用对称色标，保留正负值
limit = max(abs(response(:)));
t = linspace(0, 1, 128)';
signed_map = [t t ones(128,1); ones(128,1) flipud(t) flipud(t)];
f = figure('Visible', 'off', 'Color', 'w', 'Position', [80 80 1100 570], ...
    'DefaultAxesFontName', 'Microsoft YaHei', 'DefaultTextFontName', 'Microsoft YaHei');
% 绘制结果
ax1 = subplot(1, 2, 1); imshow(I, [0 1]); colormap(ax1, gray(256)); title('原图，显示范围 [0,1]');
ax2 = subplot(1, 2, 2); imagesc(response, [-limit limit]); axis image off;
colormap(ax2, signed_map); colorbar; title('Laplace 有符号响应：蓝负、红正');
sgtitle('模板 [1 0 1; 0 -4 0; 1 0 1]，对称延拓');
drawnow;
exportgraphics(f, fullfile(out, 'laplace_signed_response.png'), 'Resolution', 180);
close(f);
fprintf('ID_laplace PASS: signed range=[%.8g, %.8g]\n', min(response(:)), max(response(:)));
end
