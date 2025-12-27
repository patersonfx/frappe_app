# Telegram Integration for Compliance App

This document provides instructions for setting up and using Telegram integration in your Compliance app.

## Overview

The Telegram integration allows you to:
- Receive compliance status updates via Telegram
- Send automated reminders for pending declarations
- Notify employees about NISM certificate expiry
- Update employees on trade permission approvals
- Enable two-way communication through a Telegram bot

## Prerequisites

1. A Telegram account
2. Basic knowledge of creating Telegram bots
3. Access to your Frappe/ERPNext site

## Setup Instructions

### Step 1: Create a Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Start a chat with BotFather and send `/newbot`
3. Follow the instructions:
   - Choose a name for your bot (e.g., "Compliance Portal Bot")
   - Choose a username for your bot (must end with 'bot', e.g., "compliance_portal_bot")
4. BotFather will provide you with a **Bot Token** (e.g., `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)
5. **Save this token** - you'll need it for configuration

### Step 2: Install the Integration

1. Navigate to your Frappe bench directory:
   ```bash
   cd /home/frappe/frappe-bench
   ```

2. Run migrations to create the Telegram Settings doctype:
   ```bash
   bench --site erp.forex migrate
   ```

3. Clear cache:
   ```bash
   bench --site erp.forex clear-cache
   ```

4. Restart the bench:
   ```bash
   bench restart
   ```

### Step 3: Configure Telegram Settings

1. Login to your ERPNext/Frappe site
2. Go to **Telegram Settings** (search in the awesome bar)
3. Configure the following:
   - **Enabled**: Check this box
   - **Bot Token**: Paste the token from BotFather
   - **Bot Username**: Enter your bot's username (without @)
   - **Enable Auto Reply**: Check this to enable automatic responses
   - **Enable Notifications**: Check this to send compliance notifications

4. Click **Save**

### Step 4: Setup Webhook

1. In the Telegram Settings form, click **Actions > Setup Webhook**
2. This will configure your bot to receive messages at:
   ```
   https://your-site.com/api/method/compliance.api.telegram_webhook.incoming_message
   ```
3. Verify the webhook is set by clicking **Actions > Check Webhook Status**

### Step 5: Test the Integration

1. In Telegram Settings, add your **Test Chat ID**:
   - Start a chat with your bot in Telegram
   - Send any message to the bot
   - The bot will respond (and log your chat ID)
   - Or use this bot to get your chat ID: @userinfobot

2. Enter a test message in the **Test Message** field
3. Click **Testing > Send Test Message**
4. You should receive the test message in Telegram

### Step 6: Configure Employee Telegram Details

1. Go to **Employee List**
2. Open an employee record
3. Scroll to the **Telegram Integration** section
4. Configure:
   - **Telegram Username**: Employee's Telegram username (without @)
   - **Enable Telegram Notifications**: Check to enable notifications for this employee

5. When the employee first messages the bot, their **Telegram Chat ID** will be automatically captured

## Usage

### For Employees

Employees can interact with the bot using these commands:

- `/start` or `/help` - Show available commands
- `/status` - Check compliance status
- `/pending` - View pending declarations
- `/mycertificates` - View NISM certificates
- `/mypermissions` - View trade permissions

### For Administrators

#### Sending Notifications Programmatically

```python
from compliance.utils.telegram_utils import send_notification_to_employee

# Send a custom notification
send_notification_to_employee(
    employee="EMP-00001",
    message="Your compliance declaration is due tomorrow!"
)
```

#### Sending Investment Declaration Reminders

```python
from compliance.utils.telegram_utils import notify_investment_declaration_reminder

notify_investment_declaration_reminder(
    employee="EMP-00001",
    declaration_type="Monthly Trading Declaration",
    due_date="2025-12-31"
)
```

#### Sending NISM Expiry Reminders

```python
from compliance.utils.telegram_utils import notify_nism_expiry_reminder

notify_nism_expiry_reminder(
    employee="EMP-00001",
    nism_module="NISM Series X-A",
    expiry_date="2026-01-15",
    days_remaining=45
)
```

#### Sending Trade Permission Updates

```python
from compliance.utils.telegram_utils import notify_trade_permission_status

notify_trade_permission_status(
    employee="EMP-00001",
    security_name="RELIANCE",
    transaction_type="Buy",
    status="Approved",
    remarks="Approved by compliance officer"
)
```

#### Sending Bulk Notifications

```python
from compliance.utils.telegram_utils import send_bulk_notification

employee_list = ["EMP-00001", "EMP-00002", "EMP-00003"]
message = "Reminder: Please submit your monthly declarations by EOD."

results = send_bulk_notification(employee_list, message)
print(f"Sent: {results['sent']}, Failed: {results['failed']}")
```

## Integration with Existing Features

### Auto-send notifications on declaration creation

You can add hooks to automatically send Telegram notifications. Add to `hooks.py`:

```python
doc_events = {
    "Investment Declaration": {
        "after_insert": "compliance.custom.send_declaration_notification"
    }
}
```

Then create the function:

```python
# compliance/custom.py
from compliance.utils.telegram_utils import send_notification_to_employee

def send_declaration_notification(doc, method):
    message = f"📋 New declaration created: {doc.declaration_type}\nDue: {doc.due_date}"
    send_notification_to_employee(doc.employee, message)
```

## Webhook Endpoint

The webhook endpoint is available at:
```
https://your-site.com/api/method/compliance.api.telegram_webhook.incoming_message
```

This endpoint is guest-accessible and handles incoming Telegram updates.

## API Functions

### Main Functions

#### `send_telegram_message(chat_id, message, parse_mode="Markdown")`
Send a message to a specific Telegram chat.

#### `send_notification_to_employee(employee, message, parse_mode="Markdown")`
Send a notification to an employee via Telegram.

#### `send_bulk_notification(employee_list, message, parse_mode="Markdown")`
Send notifications to multiple employees.

### Notification Helpers

- `notify_investment_declaration_reminder()` - Send investment declaration reminders
- `notify_nism_expiry_reminder()` - Send NISM expiry reminders
- `notify_trade_permission_status()` - Send trade permission updates
- `notify_welcome_message()` - Send welcome message to new employees

## Troubleshooting

### Bot not responding

1. Check if webhook is set correctly:
   - Go to Telegram Settings
   - Click **Actions > Check Webhook Status**
   - Verify the webhook URL is correct

2. Check Error Logs:
   - Go to **Error Log** in Frappe
   - Look for "Telegram" related errors

3. Verify bot token:
   - Make sure the Bot Token is correct
   - Test by calling Telegram API directly:
     ```bash
     curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe
     ```

### Employee not receiving notifications

1. Verify employee configuration:
   - Check if **Enable Telegram Notifications** is checked
   - Verify **Telegram Chat ID** is set (employee must message bot first)

2. Check Telegram Settings:
   - Verify **Enabled** is checked
   - Verify **Enable Notifications** is checked

3. Ask employee to:
   - Start a chat with the bot
   - Send any message (like `/start`)

### Messages not being logged

Check if Communication records are being created:
- Go to **Communication** list
- Filter by Communication Medium = "Chat"
- Look for Telegram messages

## Security Considerations

1. **Bot Token**: Keep your bot token secure. It's stored as a Password field in Telegram Settings.

2. **Webhook URL**: Ensure your site has HTTPS enabled. Telegram requires HTTPS for webhooks.

3. **Employee Privacy**: Only send notifications to employees who have opted in (Enable Telegram Notifications).

4. **Rate Limiting**: Telegram has rate limits. Avoid sending too many messages in a short time.

## Advanced Configuration

### Custom Commands

You can add custom commands by modifying the `process_incoming_message()` function in [telegram_webhook.py](compliance/api/telegram_webhook.py#L107):

```python
elif msg_lower == '/mycustomcommand':
    return "This is a custom response!"
```

### Custom Notification Templates

You can customize notification templates in Telegram Settings or create your own utility functions.

### Markdown Formatting

Telegram supports Markdown formatting:
- `*bold*` - **bold**
- `_italic_` - _italic_
- `[link](http://example.com)` - hyperlink
- `` `code` `` - monospace

## Files Created

- `/compliance/api/telegram_webhook.py` - Webhook handler and API functions
- `/compliance/compliance/doctype/telegram_settings/` - Settings DocType
- `/compliance/utils/telegram_utils.py` - Utility functions for notifications
- `/compliance/fixtures/custom_field.json` - Custom fields for Employee doctype

## Support

For issues or questions:
1. Check the Error Log in your Frappe site
2. Review the Telegram Bot API documentation: https://core.telegram.org/bots/api
3. Contact your system administrator

## License

Same as the Compliance app (MIT License)
