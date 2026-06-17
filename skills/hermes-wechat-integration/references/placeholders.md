Load this file when you need to extract credential values from command output.

| Placeholder | Source | Extraction Pattern | Example Value |
|-------------|--------|-------------------|---------------|
| `<your_bot_account_id>` | `hermes gateway setup` output | After `account_id=` until end of line | `a1b2c3d4e5f6` |
| `<secret>` | `hermes gateway setup` (auto-saved) | `$HERMES_HOME/weixin/accounts/<account_id>.json`, field `token` or `access_token` | `hex:...` |
| `<your_wechat_user_id>` | Gateway log after first message | After `user=` before `@im.wechat` | `o9cq806VjCf` |
| `<user_id_1>`, `<user_id_2>` | Same as `<your_wechat_user_id>` | Same extraction | `o9cq806VjCf` |
| `<your_profile_name>` | User-defined | Chosen when creating profile; also used in paths: `$HERMES_HOME/profiles/<name>/` | `personal`, `my-bot` |
| `<user_id>@im.wechat` | Gateway log / channel_directory | Full ID with suffix | `o9cq806VjCf@im.wechat` |
| `<name>` (in `hermes --profile`) | User-defined profile name | From `hermes profile create <name>` | `personal` |
