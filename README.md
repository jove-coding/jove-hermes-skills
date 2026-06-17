# 🏗️ Jove Hermes Skills

**Hermes Agent 技能集合**

> 🇨🇳 一个精心打磨的 Hermes Agent 技能仓库，由社区驱动、经过多轮跨模型验证交付。
>
> 使用 `hermes skills tap add` 即可将本仓库添加为技能源。

---

## 📋 目录

- [快速安装](#-快速安装)
- [技能列表](#-技能列表)
- [仓库结构](#-仓库结构)
- [技能详情](#-技能详情)
  - [hermes-windows-migration](#hermes-windows-migration)
  - [hermes-wechat-integration](#hermes-wechat-integration)
- [验证质量](#-验证质量)
- [常见问题](#-常见问题)
- [贡献指南](#-贡献指南)

---

## ⚡ 快速安装

```bash
# 1. 添加技能源
hermes skills tap add jove-rina/jove-hermes-skills

# 2. 搜索技能
hermes skills search windows-migration

# 3. 安装技能
hermes skills install jove-rina/jove-hermes-skills/hermes-windows-migration

# 4. 在对话中加载
/skill hermes-windows-migration
```

安装后，当你在对话中提到相关场景时，Hermes 会自动加载对应技能~

---

## 📦 技能列表

| 技能 | 版本 | 描述 | 平台 |
|---|---|---|---|
| [hermes-windows-migration](skills/hermes-windows-migration/) | v1.0.1 | 迁移 Hermes 数据到自定义目录 | Windows |
| [hermes-wechat-integration](skills/hermes-wechat-integration/) | v1.9.0 | 微信接入 Hermes Agent | 跨平台 |

> 更多技能陆续添加中...

---

## 🗂️ 仓库结构

```
jove-hermes-skills/
├── skills/
│   └── hermes-windows-migration/     # Hermes Windows 数据迁移技能
│       ├── SKILL.md                  # 技能定义（加载入口）
│       ├── scripts/
│       │   └── migrate-hermes.ps1   # 全自动迁移脚本
│       └── references/
│           ├── Windows-Migration-Guide.md      # 12 章完整参考手册
│           ├── review-checklist.md             # 38 项审查清单
│           ├── Release-Notes-v1.0.1.md         # 发布说明
│           ├── Review-Report.md                # 完整审查报告
│           └── cross-model-review-notes.md     # 审查方法论
│   └── hermes-wechat-integration/          # 微信集成技能
│       ├── SKILL.md                        # 技能定义（加载入口）
│       └── references/
│           ├── faq.md                      # 常见故障排查
│           ├── placeholders.md             # 凭据提取占位符表
│           └── official-docs.md            # 官方文档链接
└── README.md                               # 本文件
```

---

## 🔧 技能详情

### hermes-windows-migration

**Hermes Agent Windows 数据迁移方案**

将 Hermes Agent 数据从 `C:\Users\<用户>\AppData\Local\hermes` 迁移到自定义目录（如 D 盘、E 盘），解决 C 盘空间不足问题。

#### 适用场景

| 触发词 |
|---|
| "C 盘满了，怎么把 Hermes 数据移走？" |
| "如何设置 HERMES_HOME 环境变量？" |
| "想把 Hermes 数据从 C 盘换到 D 盘" |
| "Hermes 数据太大了，放哪里合适？" |

#### 三种方案

| 方案 | 适合人群 | 复杂度 |
|---|---|---|
| **A — 自动脚本** | 普通用户 | ⭐ 一键 |
| **B — 手动操作** | 了解 PowerShell 的用户 | ⭐⭐ |
| **C — 交给 Agent 做** | 想完全交由 AI 操作 | ⭐⭐⭐ |

#### 文件说明

| 文件 | 用途 |
|---|---|
| `SKILL.md` | 技能定义 — 触发条件、工作流、FAQ |
| `scripts/migrate-hermes.ps1` | 全自动迁移脚本 |
| `references/Windows-Migration-Guide.md` | 12 章完整手册 |

#### 核心特性

- ✅ **零删除** — 只复制，不删除
- ✅ **robocopy 增量复制** — 支持断点续传、保留 ACL 和文件属性
- ✅ **自动检测** — 能感知已设置的 `HERMES_HOME`，智能判断源目录
- ✅ **环境变量自动配置** — 设置用户级 `HERMES_HOME`，无需管理员权限
- ✅ **验证清单** — 迁移完成后输出逐项检查清单
- ✅ **WSL2/Linux/macOS 不适用** — 仅 Windows 原生安装

### hermes-wechat-integration

**微信集成**

将 Hermes Agent 接入个人微信，实现消息收发、多 Profile 隔离和故障诊断。

#### 适用场景

| 触发词 |
|---|
| "我想把 Hermes 接到微信上" |
| "如何配置微信 bot？" |
| "微信消息收不到 / 不回复" |
| "多账号微信怎么隔离？" |

#### 文件说明

| 文件 | 用途 |
|---|---|
| `SKILL.md` | 技能定义 — 安装、配置、授权、验证、排错 |
| `references/faq.md` | 10 类常见故障排查 |
| `references/placeholders.md` | 凭据提取占位符表（懒加载） |
| `references/official-docs.md` | 官方文档链接和 iLink API 备注 |

#### 核心特性

- ✅ **QR 码登录** — 官方 iLink Bot API 接入，无需逆向工程
- ✅ **AI 专有协议** — QR 替代协议、验证协议、context_token 机制，AI 知道自身边界
- ✅ **双层门控授权** — Policy 门 + Routing 门，诊断矩阵精确定位问题
- ✅ **多 Profile 隔离** — 每个 Profile 独立微信账号，互不干扰
- ✅ **Token 优化** — 核心 4.3K tokens，FAQ 懒加载
- ✅ **跨模型验证** — 4 个模型 × 7 轮独立评审
- ✅ **跨平台** — Linux/macOS/Windows Git Bash

---

## ✅ 验证质量

### hermes-windows-migration

此技能经过 **3 个模型 × 8 轮审查**，共发现并修复 **34 条问题**，确保交付质量。

| 轮次 | 模型 | 发现数 | 重点 |
|---|---|---|---|
| 1 | deepseek-v4-flash | 3 | 文档一致性、占位符 |
| 2 | deepseek-v4-flash | 1 | 遗漏 Bypass |
| 3 | DeepSeek Pro | 2 | 运行时错误、robocopy 一致性 |
| 4 | DeepSeek Pro | 2 | 死函数删除、正则精确化 |
| 5 | kimi-k2.7-code | 8 | 深度代码审查 + 边界情况 |
| 6 | kimi-k2.7-code | 5 | 全新视角审查 |
| 7 | deepseek-v4-flash | 1 | HERMES_HOME 根目录校验 |
| 8 | kimi-k2.7-code | 14 | 最终通读、版本同步 |
| **总计** | **3 个模型** | **34** | **全部修复 ✅** |

完整审查报告参见：[`skills/hermes-windows-migration/references/Review-Report.md`](skills/hermes-windows-migration/references/Review-Report.md)

### hermes-wechat-integration

此技能开发历程：**v1.0–v1.7**（原名 `wechat-integration`，社区早期版本，评审记录未保留）→ **v1.8.0**（997行/12K tokens，社区版）→ **v1.9.0**（416行/4.3K tokens，当前版）。有据可查的评审轮次覆盖 v1.8.0→v1.9.0 优化阶段：

| 轮次 | 模型 | 评审者 | 发现数 | 重点 |
|---|---|---|---|---|
| ① 初评·混合 | DeepSeek V4 Flash | Rina 🔍 | ~383 冗余行 | 首次评审假设混合受众（人类+AI），发现大量人类叙事冗余 |
| ② 初评·混合 | DeepSeek V4 Flash | Jove ⚡ | ~12K tokens 量化 | Token 消耗分析，建议 FAQ/Placeholder 懒加载 |
| ③ 复评·纯 AI | DeepSeek V4 Flash | Rina 🔍 | 方向反转 🔄 | 主人纠正为纯 AI Agent 受众后重新评审，所有结论 180° 反转 |
| ④ 复评·纯 AI | DeepSeek V4 Flash | Jove ⚡ | 方向反转 🔄 | 同上，保留 AI 专有内容，删除人类叙事 |
| ⑤ 终审 | Agnes-2.0-Flash | Hebe 🎀 | 2 个 P1-P2 微调 | 跨模型确认优化结果，修复 2 处细节 |
| ⑥ 冷启动 | DeepSeek V4 Pro | 独立第三方 | 8 项（P0×1, P1×4, P2×3） | 全新视角发现交叉引用断裂、指令模糊等问题 |
| ⑦ 最终 | Rina + Jove + Hebe | 全家 | 2 个遗留项 | 修复 §3.2 命令明确性 + FAQ Q8 引用修复 |
| **总计** | **4 个模型** | **7 轮** | **~400 项改进** | **全部修复 ✅** |

---

## ❓ 常见问题

### 这个 Tap 里的技能和其他人的冲突吗？
**不会。** Hermes Agent 的 Tap 机制是多源并存的，同名技能按添加顺序优先。

### 如何更新技能？
```bash
hermes skills check          # 检查更新
hermes skills update         # 更新所有
```

### 如何卸载？
```bash
hermes skills list                    # 查看已安装列表
hermes skills uninstall <index>       # 按序号卸载
```

---

## 🤝 贡献指南

欢迎贡献新的技能或改进现有技能！

1. **Fork** 本仓库
2. 在 `skills/<category>/<your-skill-name>/` 下创建 `SKILL.md`
3. 确保遵循 [Hermes Agent SKILL.md 规范](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/)
4. 提交 PR

### 技能质量标准

- ✅ 有明确的触发条件
- ✅ 工作流清晰可操作
- ✅ 包含常见陷阱和注意事项
- ✅ 有验证/检查清单
- ✅ 推荐经过跨模型审查

---

## 📄 许可

本仓库的所有技能遵循 [CC0 1.0 通用](https://creativecommons.org/publicdomain/zero/1.0/) 许可证 —— 放弃所有版权，进入公有领域。随意使用、修改、分享。

---

<sub>
由 [jove-rina](https://github.com/jove-rina) 维护 · [Hermes Agent](https://hermes-agent.nousresearch.com/) 技能系统
</sub>
