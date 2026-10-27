function ID_main()
% 依次运行七项实验，只保存主要结果图
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'code'));
assert(~isempty(which('imfilter')), '需要 Image Processing Toolbox。');

% 隐藏图形窗口，结束后恢复设置
old_visible = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
visible_cleanup = onCleanup(@() set(groot, 'DefaultFigureVisible', old_visible));
fprintf('MATLAB %s\n实验目录：%s\n', version, root);

tasks = {@ID_histogram, @ID_gaussian, @ID_laplace, @ID_rank_filter, ...
    @ID_fft, @ID_lowpass, @ID_spatial_frequency};
passed = 0;
for k = 1:numel(tasks)
    name = func2str(tasks{k});
    fprintf('\n[%d/%d] %s\n', k, numel(tasks), name);
    timer = tic;
    try
        tasks{k}();
        passed = passed + 1;
        fprintf('完成，用时 %.2f 秒\n', toc(timer));
    catch err
        fprintf(2, '%s 失败：%s\n', name, err.message);
    end
end

fprintf('\n成功 %d / %d\n', passed, numel(tasks));
assert(passed == numel(tasks), '存在失败项目，请查看命令行提示。');
plots = dir(fullfile(root, 'results', '**', '*.png'));
assert(numel(plots) == 10, '结果图数量应为 10 张。');
fprintf('10 张主要结果图已保存到 results。\n');
end
