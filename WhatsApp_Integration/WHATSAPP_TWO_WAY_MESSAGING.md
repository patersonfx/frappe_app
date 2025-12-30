# WhatsApp Two-Way Messaging Setup Guide

## Overview

Two-way messaging allows your Compliance app to **receive** incoming WhatsApp messages from users, not just send them. This enables:

✅ Users can reply to compliance notifications
✅ Auto-respond to common queries
✅ Log all incoming messages in Frappe
✅ Build interactive compliance workflows

---

## 🚀 Quick Start

### Step 1: Enable Incoming Messages in Frappe

1. Navigate to: **Desk → Setup → WhatsApp Settings**
2. Scroll to **"Webhook Settings (Incoming Messages)"**
3. Check **"Enable Incoming Messages"**
4. Click **Save**

The system will auto-generate two webhook URLs:
- **Webhook URL**: For receiving messages
- **Status Callback URL**: For delivery status updates

---

### Step 2: Configure Twilio Webhook

#### For Twilio Sandbox:

1. Go to [Twilio Console](https://console.twilio.com)
2. Navigate to: **Messaging** → **Try it out** → **Send a WhatsApp message**
3. Click on **"Sandbox settings"** tab
4. Find **"WHEN A MESSAGE COMES IN"** section
5. Enter your Webhook URL (from WhatsApp Settings):
   ```
   https://your-domain.com/api/method/compliance.api.whatsapp_webhook.incoming_message
   ```
6. Set HTTP Method to: **POST**
7. Click **Save**

#### Optional - Status Updates:

In the same Twilio Sandbox settings:
1. Find **"STATUS CALLBACK URL"** section
2. Enter your Status Callback URL:
   ```
   https://your-domain.com/api/method/compliance.api.whatsapp_webhook.status_callback
   ```
3. Click **Save**

---

### Step 3: Test Incoming Messages

1. From your WhatsApp (number that joined sandbox):
   - Send: **"Hello"** to `+1 415 523 8886`
   - You should receive: **"Hello! Thank you for contacting us..."**

2. Check in Frappe:
   - Go to: **Desk → Communication**
   - Filter by **Medium**: Phone
   - You should see: **"[WhatsApp Incoming] Hello"**

---

## 📱 Available Auto-Reply Commands

The webhook handler includes built-in responses for common commands:

| Command | Response |
|---------|----------|
| `Hi`, `Hello`, `Hey` | Welcome message |
| `HELP`, `MENU` | Shows available commands |
| `STATUS` | Checks compliance status |
| `PENDING` | Shows pending items |
| `STOP` | Unsubscribe from notifications |
| `START` | Re-subscribe to notifications |
| Other messages | Default acknowledgment |

---

## 🔧 Customizing Auto-Replies

Edit the webhook handler to customize responses:

**File**: [apps/compliance/compliance/api/whatsapp_webhook.py](apps/compliance/compliance/api/whatsapp_webhook.py)

**Function**: `process_incoming_message(from_number, message)`

### Example Customization:

```python
def process_incoming_message(from_number, message):
    msg_lower = message.lower().strip()

    # Custom command for checking NISM status
    if msg_lower == 'nism':
        # Query employee's NISM certificates
        certificates = frappe.get_all(
            "NISM Certificates",
            filters={"employee_phone": from_number},
            fields=["certificate_name", "expiry_date"]
        )

        if certificates:
            response = "Your NISM Certificates:\\n"
            for cert in certificates:
                response += f"• {cert.certificate_name} - Expires: {cert.expiry_date}\\n"
            return response
        else:
            return "No NISM certificates found for your number."

    # ... rest of the logic
```

---

## 📊 Viewing Incoming Messages

### In Communication List:

1. Go to: **Desk → Communication**
2. Filter by:
   - **Medium**: Phone
   - **Sent or Received**: Received
3. Look for messages starting with `[WhatsApp Incoming]`

### Fields Captured:

- **Phone Number**: Sender's number
- **Content**: Message text
- **Subject**: "WhatsApp from [number]"
- **Status**: Open
- **Reference Name**: Twilio Message SID (for deduplication)

---

## 🔐 Security Considerations

### 1. Webhook Verification

The current implementation uses `allow_guest=True` for the webhook. For production, consider adding:

- **Twilio Signature Validation**: Verify requests are from Twilio
- **IP Whitelisting**: Allow only Twilio IPs
- **Custom Token**: Add authentication token

### 2. Rate Limiting

Protect against spam:
- Limit messages per phone number per day
- Block abusive numbers
- Implement cooldown periods

### 3. Data Privacy

- Incoming messages are logged in Communication
- Consider GDPR/data retention policies
- Implement message purging via `clean_old_logs()`

---

## 🛠️ Troubleshooting

### Messages Not Being Received

**Check 1: Webhook URL Configuration**
- Verify the URL in Twilio matches WhatsApp Settings
- Ensure it's publicly accessible (not localhost)
- Use HTTPS (required by Twilio)

**Check 2: Error Logs**
```
Desk → Error Log → Filter by "WhatsApp Webhook"
```

**Check 3: Twilio Debugger**
- Go to: Twilio Console → Monitor → Logs → Errors
- Check for webhook delivery failures

### Auto-Replies Not Working

**Check 1**: Verify `process_incoming_message()` logic
**Check 2**: Check return value (must be valid TwiML)
**Check 3**: Review Twilio webhook logs for response errors

### Duplicate Messages

The webhook handler uses `MessageSid` to prevent duplicates. If you see duplicates:
- Check `reference_name` in Communication records
- Twilio may retry failed webhooks

---

## 🎯 Advanced Use Cases

### 1. Interactive Compliance Workflows

```python
# Auto-respond based on employee's compliance status
def process_incoming_message(from_number, message):
    # Get employee by phone number
    employee = frappe.get_value(
        "Employee",
        {"cell_number": from_number},
        ["name", "employee_name"]
    )

    if not employee:
        return "Phone number not registered. Please contact HR."

    # Check for pending declarations
    pending = frappe.get_all(
        "Investment Declaration",
        filters={
            "employee": employee,
            "status": "Pending"
        }
    )

    if pending:
        return f"You have {len(pending)} pending investment declarations. Please submit them at the portal."
    else:
        return "All your compliance requirements are up to date!"
```

### 2. Approval via WhatsApp

```python
# Allow managers to approve via WhatsApp
if msg_lower.startswith('approve '):
    doc_id = msg_lower.split(' ')[1]

    # Verify sender is authorized
    # Approve the document
    # Send confirmation
```

### 3. Reminders with Acknowledgment

When sending reminders, track if employees acknowledge:

```python
# In your reminder sending code
send_whatsapp_message(
    employee_phone,
    "Reminder: NISM certificate expires soon. Reply ACK to confirm you've seen this."
)

# In webhook handler
if msg_lower == 'ack':
    # Mark reminder as acknowledged
    # Update employee record
```

---

## 📈 Monitoring & Analytics

### Track Incoming Messages

```python
# Get message statistics
from frappe.utils import getdate, add_days

messages_today = frappe.db.count(
    "Communication",
    filters={
        "communication_medium": "Phone",
        "sent_or_received": "Received",
        "creation": [">=", getdate()],
        "content": ["like", "[WhatsApp Incoming]%"]
    }
)
```

### Most Common Commands

```sql
SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(content, ']', -1), ' ', 2) as command,
    COUNT(*) as count
FROM `tabCommunication`
WHERE communication_medium = 'Phone'
AND sent_or_received = 'Received'
AND content LIKE '[WhatsApp Incoming]%'
GROUP BY command
ORDER BY count DESC
LIMIT 10;
```

---

## 🔄 Webhook URL Changes

If your domain changes or you move to production:

1. Update WhatsApp Settings (Enable Incoming Messages will refresh URLs)
2. Copy new Webhook URLs
3. Update in Twilio Console
4. Test with a message

---

## 📝 Webhook API Reference

### Endpoint 1: Incoming Message

**URL**: `/api/method/compliance.api.whatsapp_webhook.incoming_message`

**Method**: POST

**Parameters** (from Twilio):
- `From`: Sender's WhatsApp number (format: `whatsapp:+1234567890`)
- `To`: Your Twilio number (format: `whatsapp:+14155238886`)
- `Body`: Message text
- `MessageSid`: Unique message identifier
- `NumMedia`: Number of media attachments

**Response**: TwiML XML (optional auto-reply)

### Endpoint 2: Status Callback

**URL**: `/api/method/compliance.api.whatsapp_webhook.status_callback`

**Method**: POST

**Parameters**:
- `MessageSid`: Message identifier
- `MessageStatus`: Status (sent, delivered, read, failed, etc.)

**Response**: "OK" or "ERROR"

---

## ✅ Success Checklist

- [ ] Enabled Incoming Messages in WhatsApp Settings
- [ ] Copied Webhook URL from Frappe
- [ ] Configured Webhook URL in Twilio Sandbox Settings
- [ ] Sent test message from WhatsApp
- [ ] Received auto-reply
- [ ] Verified message logged in Communication
- [ ] Customized auto-reply logic (optional)
- [ ] Tested with multiple commands

---

## 🆘 Support

**Error Logs**: Desk → Error Log → Filter by "WhatsApp"
**Message Logs**: Desk → Communication → Medium: Phone
**Twilio Logs**: [Twilio Console → Monitor → Logs](https://console.twilio.com/us1/monitor/logs)

---

**Created**: 2025-12-27
**Module**: Compliance
**Version**: 1.0
**Status**: Ready for Production ✅
