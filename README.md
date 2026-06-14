# 🏗️ Jove Hermes Skills

**Hermes Agent 技能集合 — 一个开源的 Hermes Skills Tap**

> 一个精心打磨的 Hermes Agent 技能仓库，由社区驱动、通过多轮跨模型验证交付。
>
> 使用 `hermes skills tap add` 即可将本仓库添加为技能源，一键安装所有技能。

---

## 📋 目录

- [快速安装](#-快速安装)
- [技能列表](#-技能列表)
- [仓库结构](#-仓库结构)
- [技能详情](#-技能详情)
  - [hermes-windows-migration](#hermes-windows-migration)
- [验证质量](#-验证质量)
- [常见问题](#-常见问题)
- [贡献指南](#-贡献指南)

---

## ⚡ 快速安装

```bash
# 1. 将本仓库添加为技能源（Tap）
hermes skills tap add jove-coding/jove-hermes-skills

# 2. 搜索可用技能
hermes skills search windows-migration

# 3. 安装技能
hermes skills install jove-coding/jove-hermes-skills/hermes-windows-migration

# 4. 在聊天中加载使用
/skill hermes-windows-migration
```

安装后，当你在对话中提到"迁移 Hermes 数据"、"C 盘满了"等场景时，Hermes 会自动加载此技能。

---

## 📦 技能列表

| 技能 | 版本 | 描述 | 平台 |
|------|------|------|------|
| [hermes-windows-migration](skills/hermes-windows-migration/) | v1.0.1 | 将 Hermes Agent 数据从 Windows 默认路径迁移到自定义目录 | Windows |

> 更多技能陆续添加中……

---

## 🗂️ 仓库结构

```
jove-hermes-skills/
├── skills/
│   └── hermes-windows-migration/     # Hermes Windows 数据迁移技能
│       ├── SKILL.md                  # 技能定义（加载入口）
│       ├── scripts/
│       │   └── migrate-hermes.ps1   # 全自动迁移脚本（交互式 PowerShell）
│       └── references/
│           ├── Windows-Migration-Guide.md      # 12 章完整参考手册
│           ├── review-checklist.md             # 38 项审查清单
│           ├── Release-Notes-v1.0.1.md         # 发布说明 / 变更日志
│           ├── Review-Report.md                # 完整审查报告（34 条问题逐条记录）
│           └── cross-model-review-notes.md     # 审查方法论与常见陷阱
└── README.md                        # 本文件
```

---

## 🔧 技能详情

### hermes-windows-migration

**Hermes Agent Windows 数据迁移方案**

将 Hermes Agent 数据从 `C:\Users\<用户>\AppData\Local\hermes` 迁移到自定义目录（如 D 盘、E 盘等大容量驱动器），解决 C 盘空间不足的问题。

#### 适用场景

- ❓ "我的 C 盘满了，怎么把 Hermes 数据移走？"
- ❓ "如何设置 `HERMES_HOME` 环境变量？"
- ❓ "想把 Hermes 数据从 C 盘换到 D 盘"
- ❓ "Hermes 数据太大了，应该放哪里？"

#### 三种方案（由简到繁）

| 方案 | 适合人群 | 复杂度 |
|------|----------|--------|
| **A — 自动脚本** | 普通用户 | ⭐ 一键运行 |
| **B — 手动操作** | 了解 PowerShell 的用户 | ⭐⭐ |
| **C — 交给 Rina 做** | 我在线时，我来远程操作 | ⭐⭐⭐ |

#### 文件说明

| 文件 | 用途 |
|------|------|
| `SKILL.md` | Agent 技能定义 — 触发条件、工作流、FAQ |
| `scripts/migrate-hermes.ps1` | 全自动迁移脚本 — 交互式，支持 `-Target` 参数静默运行 |
| `references/Windows-Migration-Guide.md` | 12 章完整手册 — 从原理到排错，每个命令都解释 |

#### 核心特性

- ✅ **零删除** — 迁移脚本只复制，不删除旧目录的任何文件
- ✅ **robocopy 增量复制** — 支持断点续传、保留 ACL 和文件属性
- ✅ **自动检测** — 能感知已设置的 `HERMES_HOME`，智能判断源目录
- ✅ **环境变量自动配置** — 设置用户级 `HERMES_HOME`，无需管理员权限
- ✅ **验证清单** — 迁移完成后输出逐项检查清单
- ✅ **WSL2/Linux/macOS 不适用** — 仅 Windows 原生安装

---

## ✅ 验证质量

此技能经过了 **3 个模型 × 8 轮审查**，共发现并修复 **34 条问题**，确保交付质量。

| 轮次 | 模型 | 发现数 | 重点 |
|------|------|--------|------|
| 1 | deepseek-v4-flash | 3 | 文档一致性、占位符 |
| 2 | deepseek-v4-flash | 1 | 遗漏 Bypass |
| 3 | DeepSeek Pro | 2 | 运行时错误、robocopy 一致性 |
| 4 | DeepSeek Pro | 2 | 死函数删除、正则精确化 |
| 5 | kimi-k2.7-code | 8 | 深度代码审查 + 边界情况 |
| 6 | kimi-k2.7-code | 5 | 全新视角审查 |
| 7 | deepseek-v4-flash | 1 | HERMES_HOME 根目录校验 |
| 8 | kimi-k2.7-code | 14 | 最终通读、版本同步、全路径硬化 |
| **合计** | **3 个模型** | **34** | **全部修复 ✅** |

完整审查报告参见: [`skills/hermes-windows-migration/references/Review-Report.md`](skills/hermes-windows-migration/references/Review-Report.md)

---

## ❓ 常见问题

### 这个 Tap 里的技能和其他人的技能冲突吗？

不会。Hermes Agent 的 Tap 机制是多源并存的 —— 你的技能列表会聚合所有已添加 Tap 中的技能，同名技能会按添加顺序优先。

### 如何更新技能？

```bash
hermes skills check          # 检查所有已安装技能的更新
hermes skills update         # 更新所有可更新的技能
```

### Tap 只支持 `skills/` 路径吗？

默认路径是 `skills/`，但可以通过编辑 `~/.hermes/.hub/taps.json` 修改为其他路径。

---

## 🤝 贡献指南

欢迎贡献新的技能或改进现有技能！

1. Fork 本仓库
2. 在 `skills/<category>/<your-skill-name>/` 下创建 `SKILL.md`
3. 确保遵循 [Hermes Agent SKILL.md 规范](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/)
4. 提交 PR

### 技能质量标准

- ✅ 有明确的触发条件（"当用户说……"）
- ✅ 工作流清晰，步骤可操作
- ✅ 包含常见陷阱和注意事项
- ✅ 有验证/检查清单
- ✅ 经过跨模型审查（推荐：flash → pro → kimi 三轮）

---

## 📄 许可

本仓库的所有技能遵循 [CC0 1.0 通用](https://creativecommons.org/publicdomain/zero/1.0/) 许可证 —— 放弃所有版权，进入公有领域。随意使用、修改、分享。

---

<sub>由 [jove](https://github.com/jove-coding) 维护 · 使用 [Hermes Agent](https://hermes-agent.nousresearch.com/) 技能系统</sub>
