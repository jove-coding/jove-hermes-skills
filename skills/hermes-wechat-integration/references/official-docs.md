# Official Documentation Links

These are the authoritative upstream references. When the SKILL.md and these docs differ, the
official docs at hermes-agent.nousresearch.com are the source of truth.

| Resource | URL |
|----------|-----|
| Weixin adapter | https://hermes-agent.nousresearch.com/docs/user-guide/messaging/weixin/ |
| Messaging Gateway | https://hermes-agent.nousresearch.com/docs/user-guide/messaging/ |
| Profiles | https://hermes-agent.nousresearch.com/docs/user-guide/profiles/ |
| SOUL.md | https://hermes-agent.nousresearch.com/docs/guides/use-soul-with-hermes/ |
| Configuration | https://hermes-agent.nousresearch.com/docs/user-guide/configuration/ |
| Gateway CLI | https://hermes-agent.nousresearch.com/docs/reference/cli-commands/ |

## iLink Bot API Notes

- iLink base URL: `https://ilinkai.weixin.qq.com`
- Account ID format: `<hex>@im.bot`
- User ID format: `<hex>@im.wechat`
- Token format: `<account_id>:<hex_secret>`
- Token is **single-session** — only one gateway can connect at a time
- Session expires after prolonged inactivity (errcode=-14)
- QR code is valid for ~2-3 minutes, one-time use

## Common Error Codes

| Code | Meaning | Fix |
|------|---------|-----|
| errcode=-14 | Session expired | Restart gateway or re-run QR login |
| errcode=-1 | Token already in use | Kill conflicting process |

## Known Limitations

- **`context_token` limitation:** The iLink API requires a valid `context_token` for each conversation. When sending messages from outside the gateway's live long-poll connection (e.g., via direct Python API, `hermes send` CLI, or cron jobs), a throwaway adapter is created that may lack this token, causing messages to be silently dropped by iLink. Always prefer the gateway's natural reply flow for outbound messages.

## Related Skills in Internal Library

- `hermes-profile-ops` — Profile management and credential migration

## Upstream Resources

- GitHub: https://github.com/NousResearch/hermes-agent
