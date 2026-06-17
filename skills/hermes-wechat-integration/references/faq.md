# FAQ

## Q1: Message sent but no reply (including "connected" but no response)

**Checklist:**
1. Is the gateway running? → `hermes --profile <name> gateway status`
2. Are you messaging the **iLink bot contact** (e.g. `xxxx@im.bot`), not your personal WeChat contact or your friend? They are different contacts in your WeChat app.
3. Check gateway logs for the message arrival.

| Log symptom | Likely cause | Fix |
|-------------|--------------|-----|
| No inbound log at all | Bot not connected, or wrong recipient | Verify iLink bot contact |
| `Unauthorized user` | User not in `channel_directory` | See §3.2 in SKILL.md |
| `inbound` but no `response ready` | Model API failure | Check API key |
| `response ready` but no delivery | Message filtered by iLink | Check message length (< 4000 chars; only text messages guaranteed) |

---

## Q2: Changed `channel_directory.json` but it doesn't work

- Did you edit the **correct profile's** file? Default and named profiles are independent.
- Did you **restart the gateway**? The file is only read at startup.
- Is the JSON format valid? Missing commas or brackets can silently fail.
- Did you include the full user ID (`@im.wechat` suffix)?

---

## Q3: `/restart` and `/stop` commands rejected / gateway not responding

**Symptom:** The agent reports that `/restart` or `/stop` is denied.

**Root cause:** Security design — the agent should not be able to shut down its own gateway.

**Fix:** Run from an external terminal:

```bash
hermes --profile <name> gateway restart
```

Or to stop:

```bash
hermes --profile <name> gateway stop
```

---

## Q4: Message shows "Sent" (API / CLI / cron) but recipient never receives it

**Symptom:**
- `send_message` returns success but message not received.
- `hermes send` CLI shows "Sent" but recipient never gets it.

**Root cause:** The send originates from outside the gateway's live connection (direct Python API, `hermes send` CLI, or cron). The throwaway adapter lacks a valid `context_token` for the target user, and iLink silently discards the message. The CLI uses a **different transport layer** (REST API token) than the gateway's QR-login connection (long-poll); the two are not interchangeable.

**Additional possible causes:**
- Target user not in `channel_directory.json` → message silently dropped.
- Message exceeds 4000 characters → truncated or dropped.
- iLink API transient failure → retry.

**Diagnostic:** Check the gateway logs for a `[Weixin] Sending response` entry. If absent, the message was likely dropped at the iLink API level.

**Fix:**
1. Have the recipient send a message to the bot first (this establishes a `context_token` in the token store).
2. Then retry the proactive send.
3. For the CLI, use the gateway's natural reply flow instead — have the user message the bot, let the agent process it, and the reply will be delivered through the live adapter.

---

## Q5: Messages between profiles are mixed up

**Root cause:** Multiple profiles using the **same iLink bot account** (same `WEIXIN_ACCOUNT_ID`).

**Fix:** Each profile must use a **different iLink bot identity** (different WeChat accounts scanned via QR). Never share bot tokens between profiles.

---

## Q6: Token is already in use / login refused

**Symptom:** Gateway refuses to start; token is reported as in use.

**Root cause:** iLink bot tokens are single-session. Only one gateway can connect per token.

**Fix:**
1. Find and kill the process using the token: `kill <pid>`
2. Wait 10–30 seconds for server-side session expiration.
3. Restart gateway.

---

## Q7: Session expired (errcode=-14)

**Symptom:** Gateway log shows `errcode=-14, errmsg=session expired`.

**Fix:** Restart the gateway. If that doesn't work, re-run the QR login wizard.

This is an iLink API standard error code, not a Hermes bug. Occasional expirations are normal.

---

## Q8: `hermes gateway setup` doesn't show a QR code

**Possible causes:**
- Missing `hermes-agent[messaging]` dependency: install with `pip install hermes-agent[messaging]`.
- Network block to `https://ilinkai.weixin.qq.com`: verify with `curl` (see §1.1 in SKILL.md).
- Terminal emulator doesn't support QR rendering: the wizard prints a URL you can open in a browser as a fallback.

---

## Q9: How are media messages (images, voice) handled?

See §4.5 in SKILL.md — the gateway **discards incoming media** but can **send** media/files outbound via encrypted transfer.

---

## Q10: How do I rotate or re-authenticate the iLink token?

```bash
# 1. Stop the gateway
hermes gateway stop

# 2. Delete old credentials (this forces re-auth on next setup)
rm -rf $HERMES_HOME/weixin/accounts/

# 3. Re-run the setup wizard
hermes gateway setup

# 4. Start the gateway
hermes gateway start
```

For a named profile:
```bash
rm -rf $HERMES_HOME/profiles/<profile_name>/weixin/accounts/
```
