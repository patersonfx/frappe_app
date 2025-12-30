# WhatsApp Integration - Setup Complete ✓

## What Has Been Created

### 1. WhatsApp Settings DocType
**Location**: [apps/compliance/compliance/compliance/doctype/whatsapp_settings/](apps/compliance/compliance/compliance/doctype/whatsapp_settings/)

**Files Created**:
- `whatsapp_settings.json` - DocType definition with 28 fields
- `whatsapp_settings.py` - Server-side controller with validation
- `whatsapp_settings.js` - Client-side form interactions
- `test_whatsapp_settings.py` - Unit tests
- `README.md` - Complete documentation

**Features**:
- Single DocType (one record for entire system)
- Support for 3 API providers: Twilio, Meta WhatsApp Business, Custom/Other
- Secure password fields for credentials
- Dynamic form fields based on provider selection
- Built-in test message functionality
- Message logging with configurable retention
- Accessible via: **Desk → Setup → WhatsApp Settings**

### 2. WhatsApp Service Module
**Location**: [apps/compliance/compliance/compliance/services/whatsapp_service.py](apps/compliance/compliance/compliance/services/whatsapp_service.py)

**Functions**:
- `send_whatsapp_message()` - Send single message
- `send_via_twilio()` - Twilio API integration
- `send_via_meta()` - Meta WhatsApp Business API integration
- `send_via_custom_api()` - Custom API integration
- `send_bulk_whatsapp_messages()` - Send to multiple recipients
- `log_whatsapp_message()` - Log messages to Communication
- `clean_old_logs()` - Cleanup old message logs

### 3. Utility Wrapper
**Location**: [apps/compliance/compliance/utils/whatsapp.py](apps/compliance/compliance/utils/whatsapp.py)

Provides easy import path:
```python
from compliance.utils.whatsapp import send_whatsapp_message
```

## Quick Start Guide

### Step 1: Install Required Package (for Twilio)

```bash
cd /home/frappe/frappe-bench
./env/bin/pip install twilio
```

### Step 2: Configure WhatsApp Settings

1. Open your browser and navigate to:
   ```
   http://your-site-url/app/whatsapp-settings
   ```

2. For **Twilio** (Recommended):
   - Check "Enable WhatsApp Integration"
   - Select "Twilio" as API Provider
   - Enter your Twilio Account SID
   - Enter your Twilio Auth Token
   - Enter your WhatsApp-enabled Twilio number (format: +1234567890)
   - Click Save

3. For **Meta WhatsApp Business**:
   - Check "Enable WhatsApp Integration"
   - Select "Meta (WhatsApp Business)"
   - Enter Access Token
   - Enter Phone Number ID
   - Click Save

### Step 3: Test the Integration

1. In WhatsApp Settings form:
   - Enter a test phone number (your number)
   - Optionally customize the test message
   - Click "Send Test Message" button
   - Check if you receive the message

## Usage Examples

### Example 1: Send Message from DocType Event

```python
# In any DocType controller file
from compliance.utils.whatsapp import send_whatsapp_message

class TradePermission(Document):
    def after_insert(self):
        # Send WhatsApp notification when trade permission is created
        if self.employee_phone:
            message = f"""
Hi {self.employee_name},

Your trade permission request has been received.

Request ID: {self.name}
Status: {self.status}

You will be notified once reviewed.
"""
            try:
                send_whatsapp_message(self.employee_phone, message)
            except Exception as e:
                frappe.log_error(f"WhatsApp failed: {str(e)}")
```

### Example 2: Send Bulk Notifications

```python
from compliance.utils.whatsapp import send_bulk_whatsapp_messages

# Get all employees with pending compliance
employees = frappe.get_all(
    "Employee",
    filters={"status": "Active"},
    fields=["name", "employee_name", "cell_number"]
)

phone_numbers = [emp.cell_number for emp in employees if emp.cell_number]

message = """
Important: Please complete your compliance declaration by end of this week.

Login to the portal to submit your declaration.
"""

results = send_bulk_whatsapp_messages(phone_numbers, message)
print(f"Sent: {len(results['success'])}, Failed: {len(results['failed'])}")
```

### Example 3: Add to Server Script

You can also use WhatsApp in Server Scripts:

```python
# Server Script (DocType: Trade Permission, Event: After Insert)
from compliance.utils.whatsapp import send_whatsapp_message

if doc.employee_phone:
    message = f"Hi {doc.employee_name}, your trade request {doc.name} has been submitted."
    send_whatsapp_message(doc.employee_phone, message)
```

### Example 4: Scheduled Reminders

Add to [hooks.py](apps/compliance/compliance/hooks.py):

```python
scheduler_events = {
    "daily": [
        "compliance.compliance.compliance.doctype.your_doctype.send_daily_reminders"
    ],
    "weekly": [
        "compliance.utils.whatsapp.clean_old_logs"
    ]
}
```

Then create the function:
```python
# In your_doctype.py
def send_daily_reminders():
    from compliance.utils.whatsapp import send_whatsapp_message

    # Your reminder logic here
    pending_items = frappe.get_all(...)

    for item in pending_items:
        send_whatsapp_message(item.phone, "Your reminder message")
```

## API Provider Setup Links

### Twilio
1. **Sign up**: https://www.twilio.com/try-twilio
2. **Console**: https://console.twilio.com
3. **WhatsApp Sandbox**: https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn
4. **Pricing**: https://www.twilio.com/whatsapp/pricing

### Meta WhatsApp Business
1. **Business Manager**: https://business.facebook.com
2. **Developer Docs**: https://developers.facebook.com/docs/whatsapp
3. **Setup Guide**: https://developers.facebook.com/docs/whatsapp/cloud-api/get-started

## Files Structure

```
apps/compliance/
├── compliance/
│   ├── compliance/
│   │   ├── doctype/
│   │   │   └── whatsapp_settings/
│   │   │       ├── __init__.py
│   │   │       ├── whatsapp_settings.json
│   │   │       ├── whatsapp_settings.py
│   │   │       ├── whatsapp_settings.js
│   │   │       ├── test_whatsapp_settings.py
│   │   │       └── README.md
│   │   └── services/
│   │       └── whatsapp_service.py
│   └── utils/
│       ├── __init__.py
│       └── whatsapp.py
```

## Permissions

Only these roles can access WhatsApp Settings:
- **System Manager** (Full access)
- **Compliance Officer** (Read/Write)

## Security Features

✓ Encrypted password fields for API credentials
✓ Phone number validation (must start with +)
✓ Message logging for audit trail
✓ Error logging for debugging
✓ Role-based access control

## Next Steps

1. **Install Twilio** (if using Twilio):
   ```bash
   cd /home/frappe/frappe-bench
   ./env/bin/pip install twilio
   ```

2. **Configure Settings**:
   - Navigate to WhatsApp Settings
   - Enter your API credentials
   - Enable the integration

3. **Test**:
   - Send a test message to verify setup

4. **Integrate**:
   - Add WhatsApp notifications to your DocTypes
   - Create scheduled reminders
   - Build custom workflows

## Support & Documentation

- **Full Documentation**: See [README.md](apps/compliance/compliance/compliance/doctype/whatsapp_settings/README.md)
- **Error Logs**: Check Desk → Error Log
- **Message Logs**: Check Desk → Communication (if logging enabled)

## System Information

- **Created**: 2025-12-27
- **Module**: Compliance
- **Site**: erp.cm
- **Status**: ✓ Installed and Ready

---

**Ready to use!** Configure your API credentials and start sending WhatsApp messages. 🚀
