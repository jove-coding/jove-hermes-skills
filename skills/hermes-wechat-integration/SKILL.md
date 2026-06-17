---
name: hermes-wechat-integration
description: "Complete guide for integrating WeChat (Weixin/微信) with Hermes Agent — setup, authorization, multi-profile isolation, and troubleshooting"
version: 1.9.0
author: Hermes Agent Community
tags: [weixin, wechat, gateway, messaging, ilink, multi-profile, community]
related_skills: [hermes-profile-ops]
---

# WeChat (Weixin) Integration — AI Agent Guide

> **`$HERMES_HOME` = Hermes Agent config directory.** Default: `~/.hermes` (Linux/macOS) or `C:\Users\<user>\.hermes` (Windows Git Bash). Named profiles: `$HERMES_HOME/profiles/<profile_name>/`. Check: `hermes config path` or `echo $HERMES_HOME`.

---

## Quick Start

```bash
pip install aiohttp cryptography
hermes gateway setup                     # select Weixin, scan QR
# After success → save account_id from output
echo "WEIXIN_DM_POLICY=allowlist" >> $HERMES_HOME/.env
echo "WEIXIN_ALLOWED_USERS=<user_id>" >> $HERMES_HOME/.env
hermes gateway start
```
Then ask user to send a test message to the iLink bot contact. Confirm with `grep "inbound message" $HERMES_HOME/logs/gateway.log`.

---

## 1. Prerequisites & Installation

### 1.1 What's Needed

- WeChat account with iLink Bot API access (`https://ilinkai.weixin.qq.com`)
- Hermes Agent installed (`pip install hermes-agent`; verify: `hermes doctor`)
- Python 3.10+ with pip
- Network access to `ilinkai.weixin.qq.com` — verify:
  ```bash
  curl -s -o /dev/null -w "%{http_code}" https://ilinkai.weixin.qq.com
  # Expect 200 or 302
  ```

### 1.2 Install Dependencies

```bash
pip install aiohttp cryptography
pip install hermes-agent[messaging]       # optional: terminal QR display
```
Verify: `hermes doctor` (expect `✓ weixin`).

### 1.3 Run Setup Wizard (QR Code Login)

```bash
hermes gateway setup
```

**Interactive flow:**
1. Select **Weixin** from the platform list
2. Wizard requests a QR code from iLink API
3. **AI Agent cannot scan QR** — present this URL to the user:
   ```
   "Please open this URL in a browser, scan the QR code with your WeChat mobile app, and confirm the pairing. Reply 'done' when finished."
   ```
   The terminal prints a URL like `https://ilinkai.weixin.qq.com/qr/...` — extract it and ask the user.
4. Wait for user confirmation before proceeding
5. On success, output shows:
   ```
   微信连接成功，account_id=<bot_account_id>
   ```
6. Extract `<bot_account_id>` (value after `account_id=` until end of line/whitespace) — this is your `WEIXIN_ACCOUNT_ID`.

**Auto-configuration (Hermes v0.15+):**
- Credentials saved to `$HERMES_HOME/weixin/accounts/`
- `config.yaml` updated with `platforms.weixin` section
- `.env` updated with `WEIXIN_ACCOUNT_ID` and `WEIXIN_TOKEN`

> **QR code valid for ~2-3 minutes, single use.** If expired, re-run `hermes gateway setup`.

**If credential saving fails:** Credentials remain in `$HERMES_HOME/weixin/accounts/<account_id>.json`. The token field is `token` or `access_token` — extract the value and set `WEIXIN_TOKEN=<token>` in `.env`. (See `references/placeholders.md` for full extraction patterns.)

**Key constraint:** Each iLink bot identity supports **one active long-poll connection**. Two gateways connecting to the same `WEIXIN_ACCOUNT_ID` = second one fails.

---

## 2. Configuration

### 2.1 config.yaml

The wizard auto-writes this structure (Hermes v0.15+):

```yaml
platforms:
  weixin:
    home_channel:
      chat_id: <user_id>
      platform: weixin
    token: "<bot_account_id>:<secret>"
    extra:
      account_id: <bot_account_id>
      dm_policy: open
```

**Advanced `extra` options:**

| Option | Default | Description |
|--------|---------|-------------|
| `dm_policy` | `open` | DM access: `open`, `allowlist`, `disabled`, `pairing` |
| `group_policy` | `disabled` | Group chat: `open`, `allowlist`, `disabled` |
| `group_allow_from` | `[]` | Group chat allowlist (list of group IDs) |
| `allow_from` | `[]` | DM allowlist |
| `base_url` | `https://ilinkai.weixin.qq.com` | iLink API base URL |
| `split_multiline_messages` | `false` | Split long replies into multiple messages |
| `text_batch_delay_seconds` | `3.0` | Debounce delay for message batching |

**Validate config.yaml:**
```bash
python -c "import yaml; yaml.safe_load(open('$HERMES_HOME/config.yaml')); print('✓ valid')"
```

### 2.2 .env — Secrets Layer

| Variable | Required | Purpose |
|----------|----------|---------|
| `WEIXIN_ACCOUNT_ID` | ✅ | iLink bot account ID |
| `WEIXIN_TOKEN` | — | iLink bot token (auto-saved; set manually to rotate) |
| `WEIXIN_DM_POLICY` | — | DM policy: `open`, `allowlist`, `disabled`, `pairing` |
| `WEIXIN_ALLOWED_USERS` | — | Comma-separated allowed user IDs |
| `WEIXIN_ALLOW_ALL_USERS` | — | Gateway-level allow-all (dev only) |
| `WEIXIN_GROUP_POLICY` | — | Group policy: `open`, `allowlist`, `disabled` |
| `WEIXIN_GROUP_ALLOWED_USERS` | — | Comma-separated allowed group chat IDs |
| `WEIXIN_BASE_URL` | — | iLink API base URL |
| `WEIXIN_CDN_BASE_URL` | — | iLink CDN for file transfer |
| `WEIXIN_HOME_CHANNEL` | — | Default chat for cron delivery |
| `WEIXIN_HOME_CHANNEL_NAME` | — | Home channel display name |

**Token priority:** Wizard writes token to both `config.yaml` and `.env`. `.env` takes precedence when both present. Rotate by updating `.env` only.

**Validate .env:**
```bash
python -c "
with open('$HERMES_HOME/.env') as f:
    for i, line in enumerate(f, 1):
        line = line.strip()
        if line and not line.startswith('#') and '=' not in line:
            print(f'Warning: line {i} may be invalid: {line}')
print('✓ .env checked')
"
```

### 2.3 channel_directory.json

Path: `$HERMES_HOME/channel_directory.json` (default profile) or `$HERMES_HOME/profiles/<profile_name>/channel_directory.json` (named profile).

**Structure (single authoritative skeleton):**
```json
{
  "updated_at": "<ISO_8601_timestamp>",
  "platforms": {
    "weixin": [
      {
        "id": "<user_id>@im.wechat",
        "name": "<user_id>@im.wechat",
        "type": "dm",
        "thread_id": null
      }
    ]
  }
}
```

**Key rules:**
- File is **only read at gateway startup** — modification requires `hermes gateway restart`.
- Each profile has its own independent `channel_directory.json`.
- The `@im.wechat` suffix is critical — never omit it.
- **Preferred approach:** Use `WEIXIN_ALLOWED_USERS` env var as primary authorization. Only edit `channel_directory.json` if user is still rejected after setting `WEIXIN_ALLOWED_USERS`.

**Validate channel_directory.json:**
```bash
python -c "import json; json.load(open('$HERMES_HOME/channel_directory.json')); print('✓ valid')"
```

### 2.4 Migrate Credentials to a Named Profile

> **Known issue:** `hermes gateway setup` only operates on the default profile. Manual migration needed for named profiles.

```bash
# 1. Verify credentials saved
ls -la $HERMES_HOME/weixin/accounts/

# 2. Create target profile (if needed)
hermes profile create <profile_name>

# 3. Copy credentials
cp -r $HERMES_HOME/weixin $HERMES_HOME/profiles/<profile_name>/weixin

# 4. Edit profile's config.yaml — add this minimal platforms.weixin section:
#    ```yaml
#    platforms:
#      weixin:
#        home_channel:
#          chat_id: <user_id>
#          platform: weixin
#        token: "<bot_account_id>:<secret>"
#        extra:
#          account_id: <bot_account_id>
#          dm_policy: open
#    ```
#    Also edit profile's .env and add WEIXIN_ACCOUNT_ID, WEIXIN_TOKEN.

# 5. Create profile's channel_directory.json (use skeleton from §2.3)

# 6. Verify
hermes --profile <profile_name> gateway run
```

### 2.5 Unbind / Remove WeChat from a Profile

```bash
hermes --profile <profile_name> gateway stop
rm -rf $HERMES_HOME/profiles/<profile_name>/weixin
# Remove platforms.weixin from config.yaml (or comment it out)
```
Simply deleting `weixin/` credentials is enough — `.env` and `config.yaml` platform section are inert without valid credentials.

---

## 3. Authorization & Troubleshooting

### 3.1 Two-Gate Authorization Model

Messages pass **two independent gates**. Both must pass:

| Gate | Layer | Controlled by | Rejection log |
|------|-------|---------------|---------------|
| **Policy gate** (applied first) | Adapter | `WEIXIN_DM_POLICY` / `WEIXIN_ALLOWED_USERS`, or config `extra.dm_policy` / `extra.allow_from` | `WARNING: ... denied by policy` |
| **Routing gate** (applied second) | Routing | `channel_directory.json` | `WARNING: Unauthorized user: <id> on weixin` |

**Diagnosis matrix:**

| Scenario | Result |
|----------|--------|
| User in `ALLOWED_USERS` but **not** in `channel_directory.json` | ❌ Rejected by routing gate: "Unauthorized user" |
| User in `channel_directory.json` but **not** in `ALLOWED_USERS` (with `dm_policy=allowlist`) | ❌ Rejected by policy gate: "denied by policy" |
| User in **both** | ✅ Message delivered to agent |

### 3.2 Unauthorized User Fix

**Symptom:** Gateway log shows `WARNING gateway.run: Unauthorized user: <user_id>@im.wechat on weixin`.

**First try:** Append user ID to `.env` and restart:
```bash
echo "WEIXIN_ALLOWED_USERS=<user_id>" >> $HERMES_HOME/.env
hermes gateway restart
```

**If still failing:**

1. Extract `<user_id>` from the warning log
2. Add to profile's `channel_directory.json` (skeleton in §2.3). **Append** a new `{"id": "<user_id>@im.wechat", "name": "<user_id>@im.wechat", "type": "dm", "thread_id": null}` object to the `platforms.weixin` array — do NOT replace the whole file. Read the existing file first with `read_file`, merge the new entry, then `write_file`.
3. Restart gateway: `hermes --profile <profile_name> gateway restart`
4. Verify: ask the user to send another test message to the iLink bot contact, then check gateway log for `inbound message` entry.

### 3.3 FAQ

For troubleshooting specific error patterns, load `references/faq.md`:
```
skill_view(name='hermes-wechat-integration', file_path='references/faq.md')
```
Load when you see: `no reply`, `unauthorized user`, `session expired`, `send_message` silent failure, gateway connection issues, or token rotation needs.

---

## 4. Start, Verify & Limits

### 4.1 Gateway Commands

| Command | Action |
|---------|--------|
| `hermes gateway run` | Foreground (Ctrl+C to stop) |
| `hermes gateway start` | Background service |
| `hermes gateway stop` | Stop background |
| `hermes gateway restart` | Restart |
| `hermes gateway status` | Check running/PID |
| `hermes --profile <name> gateway run` | Profile-specific foreground |
| `hermes --profile <name> gateway start` | Profile-specific background |

### 4.2 Logs

```bash
tail -f $HERMES_HOME/logs/gateway.log                           # default profile
tail -f $HERMES_HOME/profiles/<profile_name>/logs/gateway.log   # named profile
grep -i "error\|failed\|warning" $HERMES_HOME/logs/gateway.log | tail -20
```

### 4.3 Output Parsing Tables

**`hermes gateway status`:**

| Output | Meaning |
|--------|---------|
| `Gateway is running (PID: 12345)` | Active ✅ |
| `Gateway is not running` | Stopped/never started ❌ |
| No output / command not found | Hermes not installed ❌ |

**`hermes doctor` (relevant lines):**

| Output line | Meaning |
|-------------|---------|
| `✓ hermes X.Y.Z` | Hermes installed ✅ |
| `✓ messaging` | Messaging deps OK ✅ |
| `✓ weixin` | WeChat adapter available ✅ |
| `✗ messaging` | Missing deps — run `pip install hermes-agent[messaging]` |

**Gateway log patterns:**

| Log line | Status |
|----------|--------|
| `✓ weixin connected` | WeChat adapter connected ✅ |
| `inbound message: platform=weixin user=... msg='...'` | Message received ✅ |
| `response ready: platform=weixin chat=... time=...` | Response sent ✅ |
| `WARNING: Unauthorized user: <id> on weixin` | User not in channel_directory ❌ |
| `errcode=-14, errmsg=session expired` | Session expired ❌ |
| `WARNING: ... denied by policy` | Policy gate rejection ❌ |

### 4.4 AI Verification Protocol

Since the AI Agent cannot send a message from WeChat directly:

1. Start gateway, check `hermes gateway status` → expect "running"
2. Check log for `✓ weixin connected`: `grep "weixin connected" $HERMES_HOME/logs/gateway.log`
3. Ask user: "Please send a test message to the iLink bot contact in WeChat. Reply 'done' when finished."
4. After user confirms, wait a few seconds for the agent to process, then check:
   ```bash
   sleep 3
   grep "inbound message" $HERMES_HOME/logs/gateway.log
   grep "response ready" $HERMES_HOME/logs/gateway.log
   ```
5. Both appearing = setup working ✅. If `response ready` is missing, wait longer and retry (agent may still be processing).

### 4.5 Message Limits & context_token

**Message limits:**

| Item | Limit |
|------|-------|
| Max single message | 4000 characters |
| Overflow handling | Auto-split at paragraph/code block boundaries |
| Split interval | 0.3s (rate limit protection) |

**context_token (critical):**
- iLink assigns a unique `context_token` to each active conversation. The gateway's live connection maintains these automatically.
- `send_message` returning `success` does **not** guarantee delivery — if called from outside the gateway session (direct API, cron), a throwaway adapter may lack a valid `context_token`.

**Workaround decision table:**

| You want to... | Verdict | Correct approach |
|---------------|---------|------------------|
| Reply in natural conversation (inbound → agent → response) | ✅ Always works | Use live adapter reply flow |
| Proactive DM to user who recently messaged bot | ⚠️ Risky | Have them message bot first, then reply |
| Proactive DM to user who never messaged bot | ❌ Almost certainly dropped | Route through natural reply flow instead |
| Send via `hermes send` CLI or `send_message` API | ❌ Uses different transport layer | Use gateway's live connection |

| Capability | Support |
|-----------|---------|
| Reply to current conversation | ✅ Fully supported |
| Proactive DM to authorized users | ⚠️ Limited — may silently drop |
| Proactive DM to users who never messaged | ❌ Almost certainly dropped |
| Send media/files | ✅ AES-128-ECB encrypted transfer |
| Inbound media (images/voice/files) | ❌ Discarded by gateway — only text processed |

---

## 5. Cross-Profile Isolation

One iLink bot identity = one active long-poll connection.

**Multi-bot layout:**

```
$HERMES_HOME/
├── config.yaml
├── .env
└── profiles/
    ├── personal/
    │   ├── config.yaml
    │   ├── .env                    # WEIXIN_ACCOUNT_ID=bot_A
    │   └── SOUL.md
    └── support/
        ├── config.yaml
        ├── .env                    # WEIXIN_ACCOUNT_ID=bot_B
        └── SOUL.md
```

**Start per-profile:** `hermes --profile personal gateway run`

---

## 6. Config Effect Rules

| File | Change takes effect... | Scope |
|------|------------------------|-------|
| `.env` | After gateway **restart** | Profile-wide secrets |
| `config.yaml` (platform sections) | After gateway **restart** | Platform adapter settings |
| `SOUL.md` | Start a **new session** (new message) | Agent identity |
| `channel_directory.json` | After gateway **restart** | Message routing |
| `weixin/accounts/` | After **QR re-authentication** | Stored credentials |

**Most changes require `hermes gateway restart`, not session reset.** Only `SOUL.md` changes take effect on new messages.

---

## References

- **FAQ:** `skill_view('hermes-wechat-integration', 'references/faq.md')` — load when troubleshooting errors.
- **Placeholder Reference:** `skill_view('hermes-wechat-integration', 'references/placeholders.md')` — load when extracting credentials from command output.
- **Official docs:** `references/official-docs.md` — quick-reference links and iLink API notes.
