---
name: build-model
description: 针对指定层或 P0 模块生成可执行的 Simulink 建模脚本，由人在本地执行
---

对本命令后面跟随的参数（层名 / P0 模块编号 / 需求 ID）生成 Simulink 建模脚本。若未提供参数，先询问目标范围。

执行步骤：

1. 读取对应需求条目，列出该模块的输入信号、输出信号、标定量与算法描述。
2. 在 `scripts/` 下生成脚本 `build_<模块名>.m`，使用 `add_block` / `add_line` / `set_param` 完成建模，要求：
   - 幂等：重复运行不产生重复模块
   - 命名遵循 `.trae/rules/10-modeling-conventions.md`
   - 每个模块标注对应需求 ID
3. 输出建模前的**待确认事项**清单（量纲、采样周期、定浮点、边界条件），不要自行假设。
4. 提醒执行方式：`matlab -batch "cd('<项目根>'); build_<模块名>"`。

注意：不要尝试在云端沙箱运行 Simulink，脚本交由人在本地执行。
