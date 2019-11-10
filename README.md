# the-FiveStarred-Red-Flag

绘制五星红旗 ( The Five-Starred Red Flag )

![The Five-Starred Red Flag](examples/flag.png)

## 开源许可

[The MIT License](http://tchel.mit-license.org)

## LaTeX

[LaTeX 红旗绘制代码](flag.tex) 借鉴 [此处](https://www.overleaf.com/6690642bgpdbs) 重制而成。原代码采用西班牙语注释，且四颗小五角星 ★ 的角度不够准确，都在本文中作了适当调整。

在安装有 TexLive 的 Linux 机器上，通过命令 `$ make` 即可生成国旗图案 pdf 格式文件。

[文档](flag.tex) 中根据 \ischeck 宏的值确定是否绘制辅助线。修改 [该行](flag.tex#L6) 内容为 \def\ischeck{1} 即可绘制辅助线。

## GMT

#### GMT v5

[GMT-5 红旗绘制代码](flag-GMT5.sh) 根据标准国旗的制作过程，采用 GMT-5 ([Generic Mapping Tools](https://www.generic-mapping-tools.org/), version: 5.x.x) 绘图工具来绘制五星红旗。

在安装有 GMT-5（或 GMT-6）的 Linux 机器上，通过命令 `$ ./flag.sh [high_value]` 即可按标准绘制高度为 high_value（默认为 10）的国旗图案。

[脚本](flag-GMT5.sh) 中 gmt_check 函数为辅助线绘制模块。取消 [该行](flag-GMT5.sh#L194) 注释即可绘制辅助线，具体效果可见 [此处](examples/flag_check.pdf)。

#### GMT v6

[GMT-6 红旗绘制代码](flag-GMT6.sh) 根据标准国旗的制作过程，采用 GMT-6 ([Generic Mapping Tools](https://www.generic-mapping-tools.org/), version: 6.0.0) 绘图工具来绘制五星红旗。

在安装有 GMT-6 的 Linux 机器上，通过命令 `$ ./flag.sh [ high_value [output_format] ]` 即可按标准绘制高度为 high_value（默认为 10）且输出文件格式为 output_format（支持 pdf、eps、png 和 ps）的国旗图案。

[脚本](flag-GMT6.sh) 中 gmt_check 函数为辅助线绘制模块。取消 [该行](flag-GMT6.sh#L173) 注释即可绘制辅助线。

## Author

Tche LIU, seistche@gmail.com, USTC

