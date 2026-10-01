---
alwaysApply: true
description: 2.0L 增程式甲醇发动机 EMS 应用层模型项目的基础上下文与总体约束
---

# 项目上下文

## 项目定位

- 名称：2.0L 增程式甲醇发动机 EMS（ECU）应用层模型
- 架构：P0++ 分层架构，11 层子系统，52 个 P0 算法模块
- 交付物：Simulink 应用层模型（.slx）+ 自动生成 C 代码 + 测试与需求追溯材料

## 权威输入（唯一事实来源）

以下三份材料是本项目的唯一事实来源，任何结论都必须能追溯到其中一处：

1. 《2.0L 增程式甲醇发动机 EMS 应用层模型所需的全部数据清单》
2. 《2.0L 增程式甲醇发动机 ECU 系统控制需求规范》
3. 《2.0L 增程式甲醇发动机 ECU 与 VCU 交互控制需求规范》

当三份材料之间出现冲突，或材料中未定义某项内容时，必须显式标注冲突或缺口，不得自行取舍或补全。

## 工具链

- MATLAB / Simulink 版本：**MATLAB R2026a**（已确认）
- 运行平台：**Windows**
- MCP：已接入官方 MATLAB MCP Server（本地 stdio），配置见 `.trae/mcp.json`
- Simulink 技能组：已注册 `model-based-design-core`、`verification-validation-and-test`、`code-generation`
- Stateflow / Embedded Coder / Simulink Test / Fixed-Point Designer：【待确认：已安装哪些工具箱】
- 目标 MCU 与编译器：【待确认】
- 是否 AUTOSAR（若是，AUTOSAR 版本与 RTE 约定）：【待确认】

以上「待确认」项在补齐之前，涉及版本差异、代码生成选项、定浮点策略的问题一律先提问，不得假设。

## 目录约定

| 目录 | 用途 |
| --- | --- |
| `requirements/` | 需求规范与数据清单的录入、需求追溯矩阵 |
| `requirements/traceability/` | 自动生成的追溯矩阵与缺口清单 |
| `model/` | Simulink 模型（.slx） |
| `scripts/` | MATLAB 脚本、模型构建与批量处理脚本 |
| `tests/` | 测试用例、SIL/PIL 测试脚本 |
| `calibration/` | 标定数据（标定量表、A2L 等） |
| `docs/` | 设计说明、评审记录 |

## 沟通语言

- 所有回复、代码注释、生成的文档默认使用中文。
- 变量名、信号名、模块名、标定量名保持项目原有英文命名，不翻译。
