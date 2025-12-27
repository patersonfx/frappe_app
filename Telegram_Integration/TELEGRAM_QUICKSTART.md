# Telegram Integration - Quick Start Guide

## 5-Minute Setup

### 1. Create Your Bot (2 minutes)

1. Open Telegram and find **@BotFather**
2. Send: `/newbot`
3. Name your bot: `Compliance Portal Bot`
4. Username: `your_company_compliance_bot`
5. Copy the **token** BotFather gives you

### 2. Configure in ERPNext (2 minutes)

1. Login to your site
2. Search for **Telegram Settings**
3. Fill in:
   - ✅ **Enabled**
   - **Bot Token**: Paste the token from step 1
   - **Bot Username**: your_company_compliance_bot
   - ✅ **Enable Auto Reply**
   - ✅ **Enable Notifications**
4. Click **Save**
5. Click **Actions > Setup Webhook**

### 3. Test It (1 minute)

1. Open Telegram and search for your bot
2. Send: `/start`
3. Bot should reply with a menu!

## Employee Setup

Each employee needs to:

1. **Update their Employee record**:
   - Add Telegram Username (without @)
   - Enable Telegram Notifications ✅

2. **Message the bot**:
   - Search for the bot in Telegram
   - Send `/start`
   - Chat ID will be automatically captured

## Quick Test

In Telegram Settings:
1. Get your Chat ID (message @userinfobot in Telegram)
2. Add it to **Test Chat ID**
3. Add a test message
4. Click **Testing > Send Test Message**

You're done! 🎉

## Available Commands

Send these to your bot in Telegram:

- `/help` - Show commands
- `/status` - Compliance status
- `/pending` - Pending items
- `/mycertificates` - NISM certificates
- `/mypermissions` - Trade permissions

## Send Notifications from Code

```python
from compliance.utils.telegram_utils import send_notification_to_employee

send_notification_to_employee(
    employee="EMP-00001",
    message="Your declaration is due tomorrow!"
)
```

## Troubleshooting

**Bot not responding?**
- Check webhook: Actions > Check Webhook Status
- Verify Bot Token is correct
- Check Error Log for issues

**Employee not receiving messages?**
- Employee must message the bot first
- Check "Enable Telegram Notifications" is enabled
- Verify Telegram Chat ID is set

## Next Steps

📖 Read the full documentation: [TELEGRAM_INTEGRATION.md](TELEGRAM_INTEGRATION.md)

🔧 Customize bot commands in: [telegram_webhook.py](compliance/api/telegram_webhook.py)

📬 Add automated notifications to your workflows

---

Need help? Check the Error Log or contact your administrator.
