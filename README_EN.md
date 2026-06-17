# 🏗️ Jove Hermes Skills

**Hermes Agent Skills Collection**

> 🇬🇧 A curated, community-driven Hermes Agent skill tap — each skill is rigorously reviewed across multiple models before release.
>
> Use `hermes skills tap add` to add this repository as a skill source.

---

## 📋 Table of Contents

- [Quick Install](#-quick-install)
- [Skills List](#-skills-list)
- [Repository Structure](#-repository-structure)
- [Skill Details](#-skill-details)
  - [hermes-windows-migration](#hermes-windows-migration)
  - [hermes-wechat-integration](#hermes-wechat-integration)
- [Quality Assurance](#-quality-assurance)
- [FAQ](#-faq)
- [Contributing](#-contributing)

---

## ⚡ Quick Install

```bash
# 1. Add the tap
hermes skills tap add jove-rina/jove-hermes-skills

# 2. Search for a skill
hermes skills search windows-migration

# 3. Install the skill
hermes skills install jove-rina/jove-hermes-skills/hermes-windows-migration

# 4. Load in chat
/skill hermes-windows-migration
```

After installation, Hermes will automatically load the relevant skill when you mention related scenarios.

---

## 📦 Skills List

| Skill | Version | Description | Platform |
|---|---|---|---|
| [hermes-windows-migration](skills/hermes-windows-migration/) | v1.0.1 | Migrate Hermes data to a custom directory | Windows |
| [hermes-wechat-integration](skills/hermes-wechat-integration/) | v1.9.0 | WeChat integration for Hermes Agent | Cross-platform |

> More skills coming soon...

---

## 🗂️ Repository Structure

```
jove-hermes-skills/
├── skills/
│   └── hermes-windows-migration/     # Windows data migration skill
│       ├── SKILL.md                  # Skill definition (entry point)
│       ├── scripts/
│       │   └── migrate-hermes.ps1   # Fully automated migration script (PowerShell)
│       └── references/
│           ├── Windows-Migration-Guide.md      # 12-chapter reference manual
│           ├── review-checklist.md             # 38-item review checklist
│           ├── Release-Notes-v1.0.1.md         # Release notes
│           ├── Review-Report.md                # Full review report (34 issues)
│           └── cross-model-review-notes.md     # Review methodology & pitfalls
│   └── hermes-wechat-integration/          # WeChat integration skill
│       ├── SKILL.md                        # Skill definition (entry point)
│       └── references/
│           ├── faq.md                      # FAQ for troubleshooting
│           ├── placeholders.md             # Credential extraction table
│           └── official-docs.md            # Official docs links
└── README.md                               # This file
```

---

## 🔧 Skill Details

### hermes-windows-migration

**Windows Data Migration Solution**

Migrate Hermes Agent data from `C:\Users\<user>\AppData\Local\hermes` to a custom drive/directory, freeing up C: drive space.

#### When to Use

| Triggers |
|---|
| "My C: drive is full, I need to relocate Hermes data" |
| "How to set the HERMES_HOME environment variable?" |
| "I want to move my Hermes data to another drive" |
| "Where should I put my growing Hermes data?" |

#### Three Approaches

| Option | For Whom | Complexity |
|---|---|---|
| **A — Automated Script** | Regular users | ⭐ One-click |
| **B — Manual Steps** | PowerShell-savvy users | ⭐⭐ |
| **C — Let Agent Handle It** | Want full AI assistance | ⭐⭐⭐ |

#### File Overview

| File | Purpose |
|---|---|
| `SKILL.md` | Skill definition — triggers, workflow, FAQ |
| `scripts/migrate-hermes.ps1` | Fully automated migration script |
| `references/Windows-Migration-Guide.md` | 12-chapter reference manual |

#### Key Features

- ✅ **Zero deletion** — Copies only, never deletes
- ✅ **Incremental copy** — Supports resume, ACL & file attributes
- ✅ **Auto-detection** — Detects existing `HERMES_HOME` to locate source
- ✅ **Auto env-var setup** — Sets user-level env var, no admin needed
- ✅ **Verification checklist** — Post-migration verification checklist
- ✅ **WSL2/Linux/macOS not supported** — Windows native install only

### hermes-wechat-integration

**WeChat (Weixin) Integration**

Connect Hermes Agent to personal WeChat — message send/receive, multi-profile isolation, and troubleshooting.

#### When to Use

| Triggers |
|---|
| "I want to connect Hermes to WeChat" |
| "How to set up a WeChat bot?" |
| "WeChat messages not received / no reply" |
| "How to isolate multiple WeChat accounts?" |

#### File Overview

| File | Purpose |
|---|---|
| `SKILL.md` | Skill definition — install, config, auth, verify, troubleshoot |
| `references/faq.md` | 10 common troubleshooting scenarios |
| `references/placeholders.md` | Credential extraction placeholder table (lazy-loaded) |
| `references/official-docs.md` | Official docs links and iLink API notes |

#### Key Features

- ✅ **QR code auth** — Official iLink Bot API, no reverse engineering
- ✅ **AI-native protocols** — QR proxy, verification protocol, context_token awareness
- ✅ **Two-gate auth** — Policy gate + Routing gate with diagnosis matrix
- ✅ **Multi-profile isolation** — Each profile with its own WeChat account
- ✅ **Token-efficient** — Core 4.3K tokens, FAQ lazy-loaded
- ✅ **Cross-model reviewed** — 4 models × 7 rounds independent review
- ✅ **Cross-platform** — Linux/macOS/Windows Git Bash

---

## ✅ Quality Assurance

### hermes-windows-migration

This skill went through **3 models × 8 review rounds**, finding and fixing **34 issues** to ensure production quality.

| Round | Model | Issues | Focus |
|---|---|---|---|
| 1 | deepseek-v4-flash | 3 | Doc consistency, placeholders |
| 2 | deepseek-v4-flash | 1 | Missing Bypass |
| 3 | DeepSeek Pro | 2 | Runtime errors, robocopy flags |
| 4 | DeepSeek Pro | 2 | Dead function removal, regex tightening |
| 5 | kimi-k2.7-code | 8 | Deep code review + edge cases |
| 6 | kimi-k2.7-code | 5 | Fresh perspective |
| 7 | deepseek-v4-flash | 1 | HERMES_HOME root validation |
| 8 | kimi-k2.7-code | 14 | Final read-through, version sync |
| **Total** | **3 models** | **34** | **All fixed ✅** |

Full review report: [`skills/hermes-windows-migration/references/Review-Report.md`](skills/hermes-windows-migration/references/Review-Report.md)

### hermes-wechat-integration

Development history: **v1.0–v1.7** (original name `wechat-integration`, early community versions, review records not preserved) → **v1.8.0** (997 lines/12K tokens, community version) → **v1.9.0** (416 lines/4.3K tokens, current). Traceable reviews cover the v1.8.0 → v1.9.0 optimization phase:

| Round | Model | Reviewer | Findings | Focus |
|---|---|---|---|---|
| ① Mixed | DeepSeek V4 Flash | Rina 🔍 | ~383 redundant lines | First review assumed mixed audience (human+AI), found heavy narrative bloat |
| ② Mixed | DeepSeek V4 Flash | Jove ⚡ | ~12K tokens quantified | Token analysis, proposed lazy-loading FAQ/Placeholders |
| ③ AI-only | DeepSeek V4 Flash | Rina 🔍 | Direction flip 🔄 | User corrected to AI-only audience, all recommendations reversed |
| ④ AI-only | DeepSeek V4 Flash | Jove ⚡ | Direction flip 🔄 | Same: keep AI protocols, remove human narrative |
| ⑤ Final | Agnes-2.0-Flash | Hebe 🎀 | 2 P1-P2 tweaks | Cross-model verification, fixed 2 edge cases |
| ⑥ Cold start | DeepSeek V4 Pro | Independent | 8 issues (P0×1, P1×4, P2×3) | Fresh perspective caught broken refs, ambiguous instructions |
| ⑦ Family | Rina + Jove + Hebe | Family | 2 lingering items | Fixed §3.2 command clarity + FAQ Q8 ref |
| **Total** | **4 models** | **7 rounds** | **~400 improvements** | **All fixed ✅** |

---

## ❓ FAQ

### Will these skills conflict with skills from other taps?
**No.** Hermes Agent's tap system supports multiple sources concurrently. Skills with the same name resolve by tap-add order.

### How do I update installed skills?
```bash
hermes skills check          # Check for updates
hermes skills update         # Update all installable
```

### How do I uninstall?
```bash
hermes skills list                    # Find the index
hermes skills uninstall <index>       # Uninstall by index
```

---

## 🤝 Contributing

Contributions — new skills and improvements — are warmly welcome!

1. **Fork** this repository
2. Create `SKILL.md` under `skills/<category>/<your-skill-name>/`
3. Follow the [SKILL.md specification](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/)
4. Submit a Pull Request

### Skill Quality Standards

- ✅ Clear trigger conditions
- ✅ Actionable workflow with exact commands
- ✅ Common pitfalls section
- ✅ Verification checklist
- ✅ Cross-model review recommended

---

## 📄 License

All skills in this repository are released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) — public domain. Use, modify, and share freely.

---

<sub>
Maintained by [jove-rina](https://github.com/jove-rina) · Powered by [Hermes Agent](https://hermes-agent.nousresearch.com/)
</sub>
