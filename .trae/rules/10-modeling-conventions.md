---
alwaysApply: true
description: Simulink 建模的命名/分层规范，以及模型文件的修改方式硬性约束
---

# 建模规范

## 硬性约束（不可违背）

1. **禁止用文本编辑器直接修改 `.slx` / `.mdl`**。模型是二进制文件，直接改会损坏。所有模型变更必须以**可执行的 MATLAB 脚本**形式交付（`add_block` / `add_line` / `set_param` / `Simulink.BlockDiagram.*` 等），由人在本地 Simulink 环境中执行。此约束同样适用于通过 MCP 工具发起的变更，详见下文「Simulink MCP 工具使用边界」。
2. **禁止虚构**信号名、标定量名、接口名、模块名、需求 ID。每一个都必须能在《需求规范》或《数据清单》中找到出处；无法找到时必须停下并提问。
3. **信息缺失时**输出 `【待确认：<需要确认的内容>】`，不得用"通常做法"自行补全阈值、量纲、采样周期或标定默认值。
4. **不得修改 `calibration/` 下的标定数据**，除非任务明确要求，且改动需逐条列出 before/after。
5. 涉及算式或控制逻辑时，必须同时给出**单位**与**数据类型（定/浮点、位宽）**的处理说明。

## 分层与命名（以下为默认约定，若项目有正式 P0++ 规范，以正式规范为准，并请告知我更新本文件）

- 层级命名：`L<层号>_<层名>`，与 P0++ 的 11 层一一对应。
- 子系统命名：`<层名>_<功能>`，例如 `Torque_Arbitration`。
- 算法模块命名：`P0_<模块编号>_<模块名>`，与 52 个 P0 算法模块编号保持一致。
- 信号命名：`<来源>_<物理量>_<单位>`，例如 `EMS_EngSpd_rpm`。
- 标定量命名：`CAL_<功能>_<物理量>`；观测量/测量量命名：`MEAS_<功能>_<物理量>`。
- 端口方向：Inport 命名 `In_<信号名>`，Outport 命名 `Out_<信号名>`。

## 模型组织要求

- 52 个 P0 模块必须能在 11 层子系统中**逐一定位**，不得出现无归属模块。
- 每个 P0 模块需维护到需求 ID 的映射（见 `requirements/traceability/`）。
- 新增模块必须同时给出：所属层、模块名、输入输出信号清单、对应需求 ID。

## 变更交付格式

任何模型变更必须以下列结构输出：

1. 变更摘要（一句话）
2. 涉及的文件 / 模块清单
3. 可执行 MATLAB 脚本（完整、可直接粘贴运行）
4. 受影响的信号与标定量
5. 未确认项与风险

## Simulink MCP 工具使用边界

本项目已接入官方 MATLAB MCP Server（MATLAB R2026a + Simulink）。可用工具分两组：

- **MATLAB 基础**：`detect_matlab_toolboxes`、`check_matlab_code`、`evaluate_matlab_code`、`run_matlab_file`、`run_matlab_test_file`
- **Simulink 扩展**（需 `--extension-file` 加载）：`model_overview`、`model_read`、`model_edit`、`model_check`、`model_read_diagnostics`、`model_test`、`model_query_params`、`model_resolve_params`

使用规则：

1. **只读工具可直接使用**：`model_overview`、`model_read`、`model_check`、`model_read_diagnostics`、`model_query_params`、`model_resolve_params`、`check_matlab_code`、`detect_matlab_toolboxes` 不改变模型与工作区状态。
2. **`model_edit` 是写操作，受「硬性约束 1」管辖**。调用前必须依次完成：
   1. 列出将要修改的块、子系统、连线的明确清单；
   2. 说明回退方式（模型是否已提交、是否需要先另存副本）；
   3. 取得人工确认；
   4. 修改后立刻用 `model_check` 与 `model_read_diagnostics` 自检，并输出自检结果。
3. **`evaluate_matlab_code` 与 `run_matlab_file` 会真实执行代码**。当代码涉及删除、覆盖、`save_system`、`slbuild` 等有副作用的调用时，同样走第 2 条的确认流程。
4. **`model_test` 需要 Simulink Test 许可证**，未确认安装前不得调用；MATLAB 侧单元测试改用 `run_matlab_test_file`。
5. 通过 MCP 工具产生的任何模型变更，仍须按上文「变更交付格式」补一份可重现的 MATLAB 脚本记录，保证他人可重放。

## 工作树（Worktree）使用约束

工作树会为每个任务创建独立分支与目录，但 `.slx` / `.mdl` 是二进制文件，Git 无法自动合并：

1. **禁止在并行工作树中修改同一个 `.slx` / `.mdl`**。两个工作树同时改一个模型，合并时只能人工挑拣，极易丢失改动。
2. 涉及模型文件的任务，一律在**主工作目录、单分支串行**执行。
3. 工作树仅用于**纯文本产物**：MATLAB 脚本、测试用例、需求追溯材料、文档。
4. 工作树仅适用于 Code 模式的**本地任务**，云端任务不适用。
