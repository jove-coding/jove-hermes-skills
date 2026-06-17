# 🏗️ Jove Hermes Skills

**Hermes Agent 技能集合 / Hermes Agent Skills Collection**

> 🇨🇳 一个精心打磨的 Hermes Agent 技能仓库，由社区驱动、经过多轮跨模型验证交付。
>
> 🇬🇧 A curated, community-driven Hermes Agent skill tap — each skill is rigorously reviewed across multiple models before release.
>
> 使用 `hermes skills tap add` 即可将本仓库添加为技能源 / Use `hermes skills tap add` to add this repository as a skill source.

---

## 📋 目录 / Table of Contents

- [快速安装 / Quick Install](#-快速安装--quick-install)
- [技能列表 / Skills List](#-技能列表--skills-list)
- [仓库结构 / Repository Structure](#-仓库结构--repository-structure)
- [技能详情 / Skill Details](#-技能详情--skill-details)
  - [hermes-windows-migration](#hermes-windows-migration)
  - [hermes-wechat-integration](#hermes-wechat-integration)
- [验证质量 / Quality Assurance](#-验证质量--quality-assurance)
- [常见问题 / FAQ](#-常见问题--faq)
- [贡献指南 / Contributing](#-贡献指南--contributing)

---

## ⚡ 快速安装 / Quick Install

```bash
# 1. 添加技能源 / Add the tap
hermes skills tap add jove-rina/jove-hermes-skills

# 2. 搜索技能 / Search for a skill
hermes skills search windows-migration

# 3. 安装技能 / Install the skill
hermes skills install jove-rina/jove-hermes-skills/hermes-windows-migration

# 4. 在对话中加载 / Load in chat
/skill hermes-windows-migration
```

安装后，当你在对话中提到相关场景时，Hermes 会自动加载对应技能~
After installation, Hermes will automatically load the relevant skill when you mention related scenarios.

---

## 📦 技能列表 / Skills List

| 技能 / Skill | 版本 / Version | 描述 / Description | 平台 / Platform |
|---|---|---|---|
| [hermes-windows-migration](skills/hermes-windows-migration/) | v1.0.1 | 迁移 Hermes 数据到自定义目录 / Migrate Hermes data to a custom directory | Windows |
| [hermes-wechat-integration](skills/hermes-wechat-integration/) | v1.9.0 | 微信接入 Hermes Agent / WeChat integration for Hermes Agent | Cross-platform |

> 更多技能陆续添加中 / More skills coming soon...

---

## 🗂️ 仓库结构 / Repository Structure

```
jove-hermes-skills/
├── skills/
│   └── hermes-windows-migration/     # Hermes Windows 数据迁移技能 / Windows data migration skill
│       ├── SKILL.md                  # 技能定义（加载入口）/ Skill definition (entry point)
│       ├── scripts/
│       │   └── migrate-hermes.ps1   # 全自动迁移脚本 / Fully automated migration script (PowerShell)
│       └── references/
│           ├── Windows-Migration-Guide.md      # 12 章完整参考手册 / 12-chapter reference manual
│           ├── review-checklist.md             # 38 项审查清单 / 38-item review checklist
│           ├── Release-Notes-v1.0.1.md         # 发布说明 / Release notes
│           ├── Review-Report.md                # 完整审查报告 / Full review report (34 issues)
│           └── cross-model-review-notes.md     # 审查方法论 / Review methodology & pitfalls
│   └── hermes-wechat-integration/          # 微信集成技能 / WeChat integration skill
│       ├── SKILL.md                        # 技能定义（加载入口）/ Skill definition (entry point)
│       └── references/
│           ├── faq.md                      # 常见故障排查 / FAQ for troubleshooting
│           ├── placeholders.md             # 凭据提取占位符表 / Credential extraction table
│           └── official-docs.md            # 官方文档链接 / Official docs links
└── README.md                               # 本文件 / This file
```

---

## 🔧 技能详情 / Skill Details

### hermes-windows-migration

**Hermes Agent Windows 数据迁移方案 / Windows Data Migration Solution**

将 Hermes Agent 数据从 `C:\Users\<用户>\AppData\Local\hermes` 迁移到自定义目录（如 D 盘、E 盘），解决 C 盘空间不足问题。
Migrate Hermes Agent data from `C:\Users\<user>\AppData\Local\hermes` to a custom drive/directory, freeing up C: drive space.

#### 🇨🇳 适用场景 / 🇬🇧 When to Use

| 中文触发词 | English Triggers |
|---|---|
| "C 盘满了，怎么把 Hermes 数据移走？" | "My C: drive is full, I need to relocate Hermes data" |
| "如何设置 HERMES_HOME 环境变量？" | "How to set the HERMES_HOME environment variable?" |
| "想把 Hermes 数据从 C 盘换到 D 盘" | "I want to move my Hermes data to another drive" |
| "Hermes 数据太大了，放哪里合适？" | "Where should I put my growing Hermes data?" |

#### 三种方案 / Three Approaches

| 方案 / Option | 适合人群 / For Whom | 复杂度 / Complexity |
|---|---|---|
| **A — 自动脚本 / Automated Script** | 普通用户 / Regular users | ⭐ One-click |
| **B — 手动操作 / Manual Steps** | 了解 PowerShell 的用户 / PowerShell-savvy users | ⭐⭐ |
| **C — 交给 Agent 做 / Let Agent Handle It** | 想完全交由 AI 操作 / Want full AI assistance | ⭐⭐⭐ |

#### 文件说明 / File Overview

| 文件 / File | 🇨🇳 用途 | 🇬🇧 Purpose |
|---|---|---|
| `SKILL.md` | 技能定义 — 触发条件、工作流、FAQ | Skill definition — triggers, workflow, FAQ |
| `scripts/migrate-hermes.ps1` | 全自动迁移脚本 | Fully automated migration script |
| `references/Windows-Migration-Guide.md` | 12 章完整手册 | 12-chapter reference manual |

#### 核心特性 / Key Features

- ✅ **零删除 / Zero deletion** — 只复制，不删除 / Copies only, never deletes
- ✅ **robocopy 增量复制 / Incremental copy** — 支持断点续传、保留 ACL 和文件属性 / Supports resume, ACL & file attributes
- ✅ **自动检测 / Auto-detection** — 能感知已设置的 `HERMES_HOME`，智能判断源目录 / Detects existing `HERMES_HOME` to locate source
- ✅ **环境变量自动配置 / Auto env-var setup** — 设置用户级 `HERMES_HOME`，无需管理员权限 / Sets user-level env var, no admin needed
- ✅ **验证清单 / Verification checklist** — 迁移完成后输出逐项检查清单 / Post-migration verification checklist
- ✅ **WSL2/Linux/macOS 不适用** — 仅 Windows 原生安装 / Windows native install only

### hermes-wechat-integration

**微信集成 / WeChat (Weixin) Integration**

将 Hermes Agent 接入个人微信，实现消息收发、多 Profile 隔离和故障诊断。
Connect Hermes Agent to personal WeChat — message send/receive, multi-profile isolation, and troubleshooting.

#### 🇨🇳 适用场景 / 🇬🇧 When to Use

| 中文触发词 | English Triggers |
|---|---|
| "我想把 Hermes 接到微信上" | "I want to connect Hermes to WeChat" |
| "如何配置微信 bot？" | "How to set up a WeChat bot?" |
| "微信消息收不到 / 不回复" | "WeChat messages not received / no reply" |
| "多账号微信怎么隔离？" | "How to isolate multiple WeChat accounts?" |

#### 文件说明 / File Overview

| 文件 / File | 🇨🇳 用途 | 🇬🇧 Purpose |
|---|---|---|
| `SKILL.md` | 技能定义 — 安装、配置、授权、验证、排错 | Skill definition — install, config, auth, verify, troubleshoot |
| `references/faq.md` | 10 类常见故障排查 | 10 common troubleshooting scenarios |
| `references/placeholders.md` | 凭据提取占位符表（懒加载） | Credential extraction placeholder table (lazy-loaded) |
| `references/official-docs.md` | 官方文档链接和 iLink API 备注 | Official docs links and iLink API notes |

#### 核心特性 / Key Features

- ✅ **QR 码登录 / QR code auth** — 官方 iLink Bot API 接入，无需逆向工程 / Official iLink Bot API, no reverse engineering
- ✅ **AI 专有协议 / AI-native protocols** — QR 替代协议、验证协议、context_token 机制，AI 知道自身边界 / QR proxy, verification protocol, context_token awareness
- ✅ **双层门控授权 / Two-gate auth** — Policy 门 + Routing 门，诊断矩阵精确定位问题 / Policy gate + Routing gate with diagnosis matrix
- ✅ **多 Profile 隔离 / Multi-profile isolation** — 每个 Profile 独立微信账号，互不干扰 / Each profile with its own WeChat account
- ✅ **Token 优化 / Token-efficient** — 核心 4.3K tokens，FAQ 懒加载 / Core 4.3K tokens, FAQ lazy-loaded
- ✅ **跨模型验证 / Cross-model reviewed** — 4 轮 × 3 个模型独立评审 / 4 rounds × 3 models independent review
- ✅ **Cross-platform** — Linux/macOS/Windows Git Bash

---

## ✅ 验证质量 / Quality Assurance

### hermes-windows-migration

此技能经过 **3 个模型 × 8 轮审查**，共发现并修复 **34 条问题**，确保交付质量。
This skill went through **3 models × 8 review rounds**, finding and fixing **34 issues** to ensure production quality.

| 轮次 / Round | 模型 / Model | 发现数 / Issues | 重点 / Focus |
|---|---|---|---|
| 1 | deepseek-v4-flash | 3 | 文档一致性、占位符 / Doc consistency, placeholders |
| 2 | deepseek-v4-flash | 1 | 遗漏 Bypass / Missing Bypass |
| 3 | DeepSeek Pro | 2 | 运行时错误、robocopy 一致性 / Runtime errors, robocopy flags |
| 4 | DeepSeek Pro | 2 | 死函数删除、正则精确化 / Dead function removal, regex tightening |
| 5 | kimi-k2.7-code | 8 | 深度代码审查 + 边界情况 / Deep code review + edge cases |
| 6 | kimi-k2.7-code | 5 | 全新视角审查 / Fresh perspective |
| 7 | deepseek-v4-flash | 1 | HERMES_HOME 根目录校验 / Root directory validation |
| 8 | kimi-k2.7-code | 14 | 最终通读、版本同步 / Final read-through, version sync |
| **总计 / Total** | **3 个模型 / 3 models** | **34** | **全部修复 / All fixed ✅** |

完整审查报告参见 / Full review report: [`skills/hermes-windows-migration/references/Review-Report.md`](skills/hermes-windows-migration/references/Review-Report.md)

### hermes-wechat-integration

此技能经过 **4 个模型 × 4 轮审查**，从 v1.8.0（997行/12K tokens）优化到 v1.9.0（416行/4.3K tokens），覆盖 10 类问题。
This skill went through **4 models × 4 review rounds**, optimized from v1.8.0 (997 lines/12K tokens) to v1.9.0 (416 lines/4.3K tokens), covering 10 issue categories.

| 轮次 / Round | 模型 / Model | 发现数 / Issues | 重点 / Focus |
|---|---|---|---|
| ① 初评 | DeepSeek V4 Flash | ~383 冗余行 | 信息架构/Token 优化 / Info architecture & token optimization |
| ② 终审 | Agnes-2.0-Flash | 2 个 P1-P2 微调 | 跨模型确认 / Cross-model verification |
| ③ 冷启动 | DeepSeek V4 Pro | 8 项（P0×1, P1×4, P2×3） | 独立第三方视角 / Independent fresh-pair-of-eyes review |
| ④ 最终 | Rina + Jove + Hebe | 1 个漏网引用 | 三位成员终审 / Family final review |
| **总计 / Total** | **4 个模型 / 4 models** | **~400 项改进** | **全部修复 / All fixed ✅** |

---

## ❓ 常见问题 / FAQ

### 🇨🇳 这个 Tap 里的技能和其他人的冲突吗？
**不会。** Hermes Agent 的 Tap 机制是多源并存的，同名技能按添加顺序优先。

### 🇬🇧 Will these skills conflict with skills from other taps?
**No.** Hermes Agent's tap system supports multiple sources concurrently. Skills with the same name resolve by tap-add order.

---

### 🇨🇳 如何更新技能？
```bash
hermes skills check          # 检查更新 / Check for updates
hermes skills update         # 更新 / Update all
```

### 🇬🇧 How do I update installed skills?
```bash
hermes skills check          # Check for updates
hermes skills update         # Update all installable
```

---

### 🇨🇳 如何卸载？
```bash
hermes skills list                    # 查看已安装列表
hermes skills uninstall <index>       # 按序号卸载
```

### 🇬🇧 How do I uninstall?
```bash
hermes skills list                    # Find the index
hermes skills uninstall <index>       # Uninstall by index
```

---

## 🤝 贡献指南 / Contributing

欢迎贡献新的技能或改进现有技能！
Contributions — new skills and improvements — are warmly welcome!

1. **Fork** 本仓库 / Fork this repository
2. 在 `skills/<category>/<your-skill-name>/` 下创建 `SKILL.md` / Create `SKILL.md` under `skills/<category>/<your-skill-name>/`
3. 确保遵循 [Hermes Agent SKILL.md 规范](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/) / Follow the [SKILL.md specification](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/)
4. 提交 PR / Submit a Pull Request

### 技能质量标准 / Skill Quality Standards

- ✅ 有明确的触发条件 / Clear trigger conditions (both CN & EN)
- ✅ 工作流清晰可操作 / Actionable workflow with exact commands
- ✅ 包含常见陷阱和注意事项 / Common pitfalls section
- ✅ 有验证/检查清单 / Verification checklist
- ✅ 推荐经过跨模型审查 / Cross-model review recommended

---

## 📄 许可 / License

本仓库的所有技能遵循 [CC0 1.0 通用](https://creativecommons.org/publicdomain/zero/1.0/) 许可证 —— 放弃所有版权，进入公有领域。随意使用、修改、分享。
All skills in this repository are released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) — public domain. Use, modify, and share freely.

---

<sub>
🇨🇳 由 [jove-rina](https://github.com/jove-rina) 维护 · [Hermes Agent](https://hermes-agent.nousresearch.com/) 技能系统
🇬🇧 Maintained by [jove-rina](https://github.com/jove-rina) · Powered by [Hermes Agent](https://hermes-agent.nousresearch.com/)
</sub>
