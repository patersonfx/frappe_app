# WhatsApp Settings - Integration Guide

## Overview

The WhatsApp Settings DocType allows you to integrate WhatsApp messaging capabilities into your Compliance app. You can send automated notifications, alerts, and messages to employees via WhatsApp.

## Features

- **Multiple API Providers**: Support for Twilio, Meta (WhatsApp Business), and custom API providers
- **Secure Credentials**: Password fields for storing sensitive API keys and tokens
- **Message Logging**: Optional logging of all WhatsApp messages sent
- **Test Functionality**: Built-in test message feature to verify integration
- **Flexible Configuration**: Provider-specific settings that show/hide based on selection

## Setup Instructions

### 1. Access WhatsApp Settings

Navigate to:
```
Desk → Setup → WhatsApp Settings
```

### 2. Choose Your API Provider

Select one of the following providers:

#### Option A: Twilio (Recommended for Quick Setup)

1. Sign up at [twilio.com/try-twilio](https://www.twilio.com/try-twilio)
2. Get your credentials from [console.twilio.com](https://console.twilio.com):
   - Account SID
   - Auth Token
3. Enable WhatsApp on your Twilio phone number
4. Enter credentials in WhatsApp Settings:
   - **Twilio Account SID**: Your Account SID
   - **Twilio Auth Token**: Your Auth Token
   - **From WhatsApp Number**: Your Twilio WhatsApp number (format: +1234567890)

5. Install the Twilio Python package:
```bash
cd /home/frappe/frappe-bench
./env/bin/pip install twilio
```

#### Option B: Meta (WhatsApp Business API)

1. Create a Meta Business account at [business.facebook.com](https://business.facebook.com)
2. Set up WhatsApp Business API through Meta Business Manager
3. Get your credentials:
   - Access Token
   - Phone Number ID
   - Business Account ID (optional)
   - Webhook Verify Token (for receiving messages)
4. Enter credentials in WhatsApp Settings

#### Option C: Custom/Other API

1. Enter your custom API endpoint URL
2. Provide authentication details:
   - Auth Header Name (e.g., "Authorization", "X-API-Key")
   - API Key/Token
3. Ensure your API accepts POST requests with the following JSON format:
```json
{
  "to": "+1234567890",
  "message": "Your message here"
}
```

### 3. Enable Integration

Check the **Enable WhatsApp Integration** checkbox and save.

### 4. Test the Integration

1. Enter a test phone number (format: +1234567890)
2. Optionally customize the test message
3. Click the **Send Test Message** button in the Actions menu
4. Check if the message was received

## Usage in Code

### Sending a Simple Message

```python
from compliance.utils.whatsapp import send_whatsapp_message

# Send a WhatsApp message
send_whatsapp_message(
    to_number="+1234567890",
    message="Hello! Your application has been approved."
)
```

### Sending Messages from DocType Events

```python
# In your DocType controller
from compliance.utils.whatsapp import send_whatsapp_message

class YourDocType(Document):
    def on_submit(self):
        if self.phone_number:
            message = f"""
Hello {self.customer_name},

Your request {self.name} has been processed successfully.

Thank you!
"""
            send_whatsapp_message(self.phone_number, message)
```

### Sending Bulk Messages

```python
from compliance.utils.whatsapp import send_bulk_whatsapp_messages

# Send to multiple recipients
recipients = ["+1234567890", "+0987654321", "+1122334455"]
message = "Important compliance update for all employees."

results = send_bulk_whatsapp_messages(recipients, message)

print(f"Successfully sent: {len(results['success'])}")
print(f"Failed: {len(results['failed'])}")
```

### Using Meta WhatsApp Templates

```python
from compliance.compliance.compliance.services.whatsapp_service import send_whatsapp_message

# Send using Meta template
send_whatsapp_message(
    to_number="+1234567890",
    message="",  # Not used for templates
    template_name="welcome_message",
    template_params={
        "language_code": "en",
        "components": [
            {
                "type": "body",
                "parameters": [
                    {"type": "text", "text": "John Doe"}
                ]
            }
        ]
    }
)
```

## Notification Settings

### Enable Message Logging

When enabled, all WhatsApp messages are logged in the Communication DocType for audit purposes.

- **Enable Message Logging**: Check to enable logging
- **Log Retention Days**: Number of days to keep message logs (default: 90 days)

### Automatic Log Cleanup

Add a scheduled job to clean up old logs. In your `hooks.py`:

```python
scheduler_events = {
    "weekly": [
        "compliance.utils.whatsapp.clean_old_logs"
    ]
}
```

## Integration with Compliance App Features

### Example: Trade Permission Notification

```python
# In Trade Permission DocType
def after_insert(self):
    settings = frappe.get_single("WhatsApp Settings")
    if settings.enabled and self.employee_phone:
        message = f"""
Hi {self.employee_name},

Your trade permission request has been received.

Request ID: {self.name}
Stock: {self.stock_symbol}
Status: Pending Review

You will be notified once reviewed.
"""
        send_whatsapp_message(self.employee_phone, message)
```

### Example: NISM Certificate Expiry Reminder

```python
# Scheduled function to send reminders
def send_nism_expiry_reminders():
    from compliance.utils.whatsapp import send_whatsapp_message

    # Get certificates expiring in 30 days
    expiring_certs = frappe.get_all(
        "NISM Certificates",
        filters={
            "expiry_date": ["between", [today(), add_days(today(), 30)]]
        },
        fields=["name", "employee", "employee_phone", "certificate_name", "expiry_date"]
    )

    for cert in expiring_certs:
        if cert.employee_phone:
            message = f"""
Hi {cert.employee},

Reminder: Your {cert.certificate_name} is expiring on {cert.expiry_date}.

Please renew it before expiry.
"""
            send_whatsapp_message(cert.employee_phone, message)
```

## Troubleshooting

### Common Issues

1. **"WhatsApp integration is not enabled"**
   - Solution: Check the "Enable WhatsApp Integration" checkbox in WhatsApp Settings

2. **"Phone number must be in international format"**
   - Solution: Ensure phone numbers start with + and country code (e.g., +1234567890)

3. **"Twilio library not installed"**
   - Solution: Run `cd /home/frappe/frappe-bench && ./env/bin/pip install twilio`

4. **"Failed to send test message"**
   - Check your API credentials are correct
   - Verify your account has sufficient balance (for Twilio)
   - Check Error Log for detailed error messages

### Viewing Logs

All WhatsApp errors are logged in:
```
Desk → Error Log → Filter by "WhatsApp"
```

Message logs (if enabled) are stored in:
```
Desk → Communication → Filter by Medium: "WhatsApp"
```

## Security Best Practices

1. **Restrict Permissions**: Only System Manager and Compliance Officer roles can modify WhatsApp Settings
2. **Password Fields**: All sensitive credentials are stored in encrypted password fields
3. **Message Logging**: Review logs regularly for audit purposes
4. **Phone Number Validation**: Always validate phone numbers before sending
5. **Rate Limiting**: Be aware of API provider rate limits to avoid account suspension

## API Provider Comparison

| Feature | Twilio | Meta WhatsApp Business | Custom API |
|---------|--------|----------------------|------------|
| Setup Difficulty | Easy | Medium | Varies |
| Cost | Pay per message | Free tier available | Varies |
| Template Required | No | Yes (for some cases) | Varies |
| Two-way Messaging | Yes | Yes | Depends |
| Best For | Quick setup, testing | Production, official use | Existing infrastructure |

## Support

For issues or questions:
1. Check the Error Log in Frappe
2. Review this documentation
3. Check your API provider's documentation
4. Contact your system administrator

---

**Created**: 2025-12-27
**Module**: Compliance
**Version**: 1.0
