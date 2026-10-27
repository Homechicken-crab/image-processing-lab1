# 光电图像处理第一次上机实验

使用 MATLAB 完成图像增强、空间滤波和频域滤波。项目包含代码、三张原始图片及实际运行生成的十张主要结果图，暂不包含实验报告。

## 环境

- MATLAB R2022a（已在该版本后台运行验证）。
- Image Processing Toolbox。
- 中文图中文字使用 Microsoft YaHei 字体。

## 运行

在项目根目录通过命令行运行全部实验：

```powershell
matlab -wait -nosplash -batch "addpath('code'); ID_main"
```

单独运行某项，例如高斯平滑：

```powershell
matlab -wait -nosplash -batch "addpath('code'); ID_gaussian"
```

七个分项均为独立脚本，按 `%%` 分节，每次运行先清理工作区。`ID_main.m` 只按顺序运行七项脚本。

程序按自身位置定位输入和输出，移动整个项目后仍可运行。图形窗口均设置为不可见，结果直接导出到 `results`；再次运行会覆盖对应图片。程序只生成十张主要结果图，简短完成提示直接输出到命令行。

## 实验与参数

| 程序 | 内容与主要参数 |
| --- | --- |
| `ID_histogram.m` | 低照度图像；逐像素统计归一化直方图；自编 `round(255*CDF)` 均衡化，不调用 `histeq`。 |
| `ID_gaussian.m` | Barbara 图像；高斯噪声均值 0、方差 0.01，twister 种子 2026；加噪后截断到 [0,1]；5×5、σ=1 高斯核，对称延拓卷积。 |
| `ID_laplace.m` | Barbara 图像；模板 `[1 0 1; 0 -4 0; 1 0 1]`；对称延拓；蓝白红对称色标显示有符号响应。 |
| `ID_rank_filter.m` | 飞机图像；椒盐密度 0.05，盐、椒概率各 0.025，twister 种子 2027；同一含噪图像分别做 3×3 最小值、中值和最大值滤波，对称延拓。 |
| `ID_fft.m` | Barbara 图像；`fftshift(fft2(I))` 中心化；绘制二维和三维 `log(1+abs(F))`。 |
| `ID_lowpass.m` | 384×384 响应展示，D₀=90，Butterworth 二阶；实际输入宽 1198、高 767，补零为 1534×2396（行×列），滤波器匹配该尺寸，反中心化、逆变换后裁剪左上角原图区域。 |
| `ID_spatial_frequency.m` | Barbara 图像；同一 5×5、σ=1 高斯核，两种方法都使用零延拓卷积；FFT 尺寸 516×516，将核中心移到 (1,1)，统一裁剪，输出最大绝对误差和均方误差。 |

直方图使用 uint8 灰度 0～255，其余图像转为 double [0,1]。同组图像采用固定显示范围；低通结果未先修改计算值，显示 [0,1] 时超范围响应不可见。空频差值图使用约 10⁻¹⁵ 的放大色标展示浮点误差。所有噪声、模板、边界和裁剪参数均可在对应代码中查看。

## 目录

```text
.
├── README.md
├── code/                       ID_main.m 和七个分项程序
├── images/                     airplane.jpg、barbara.jpg、Low illumination.jpg
└── results/
    ├── histogram/              直方图对比
    ├── gaussian/               高斯平滑对比
    ├── laplace/                Laplace 响应对比
    ├── rank_filter/            排序滤波对比
    ├── fft/                    二维、三维频谱
    ├── lowpass/                滤波器响应、处理对比、局部对比
    └── spatial_frequency/      空域与频域对比
```

原始图片来自实验附件，保留原始尺寸。仓库不包含课程课件、报告模板、运行日志或数值数据文件。
