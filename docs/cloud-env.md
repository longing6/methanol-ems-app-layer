# 云端运行环境：methanol-ems

本文记录本项目的 TRAE 云端运行环境配置，供团队成员照此创建。

## 用途与边界

云端运行环境**不是给建模用的**，它只承担纯文本类工作。

| 能做 | 不能做 |
| --- | --- |
| 解析《数据清单》《需求规范》，抽取需求 ID | Simulink 建模、编译、代码生成 |
| 生成与维护需求追溯矩阵 | SIL / PIL / HIL 测试 |
| 脚本的接口一致性与命名规范检查 | 任何依赖 MATLAB 授权的操作 |

原因：TraeWork 云端只提供官方 all-in-one 通用容器镜像，**不支持自定义容器镜像**，因此无法安装 MATLAB / Simulink。

## 适用范围

仅 **Code 模式**可用。

## 创建步骤

1. 左下角 **头像 → 设置**
2. 左侧导航栏选择 **云端运行环境**
3. 面板右上角点击 **创建**
4. 按下表填写后点击 **确认**

## 配置参数

| 字段 | 值 |
| --- | --- |
| 环境名称 | `methanol-ems` |
| 预装依赖 · Python | `3.12` |
| 预装依赖 · Node.js | `20` |
| 敏感变量 | 留空 |
| 启动脚本 | 留空 |

**环境变量**

| Key | Value | 用途 |
| --- | --- | --- |
| `TZ` | `Asia/Shanghai` | 时区 |
| `LOG_LEVEL` | `info` | 日志级别 |
| `PYTHONIOENCODING` | `utf-8` | 中文文档读写防乱码 |

**安装脚本**

```
pip install --no-input pandas openpyxl python-docx pyyaml
```

各依赖用途：`pandas` + `openpyxl` 读写《数据清单》Excel；`python-docx` 读取需求规范；`pyyaml` 生成追溯矩阵。

## 参数依据

| 决定 | 依据 |
| --- | --- |
| Python 3.12 | 官方支持 3.10 / 3.11 / 3.12 / 3.13 / 3.14 |
| Node.js 20 | 官方支持 18 / 20 / 22 / 24 |
| 敏感变量留空 | 敏感变量走 KMS 加密（上限 50），普通变量明文存储（上限 100）。本项目云端不放任何凭据 |

## 硬限制

| 限制项 | 值 | 后果 |
| --- | --- | --- |
| 自定义容器镜像 | 不支持 | 无法运行 MATLAB / Simulink |
| `install` 命令长度 | ≤ 10 KB | 超出无法保存 |
| `install` 执行失败 | 阻断后续步骤 | 环境不可用，需修正后重启 |
| `start` 命令长度 | ≤ 10 KB | 后台执行，不阻塞 |
| `terminals` 数量 | ≤ 10 个 | 并行启动，无先后顺序 |
| 单个 `terminals` 命令长度 | ≤ 4 KB | — |

执行顺序：`install`（阻塞）→ `start`（后台）→ `terminals`（并行）。

## 启用方式

- **网页版**：所有任务均在云端运行，对话前在输入框右下角选择 `methanol-ems`
- **桌面版**：需先打开一个**从 GitHub 拉取的项目**，再在输入框左下角把运行环境设为 **云端**，然后选择 `methanol-ems`

## 相关约定

涉及 MATLAB 的操作必须在本机执行，云端不得尝试安装或运行 —— 见 `.trae/rules/20-toolchain-and-safety.md`。

来源：[TraeWork 云端运行环境配置](https://docs.trae.cn/work_set-up-the-remote-environment)
