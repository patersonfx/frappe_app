# Twilio WhatsApp Sandbox - Configuration Details

## ✅ Your Twilio Credentials

Copy these values into your Frappe WhatsApp Settings:

### From Twilio Console:

**Account SID**: `YOUR_TWILIO_ACCOUNT_SID`

**Auth Token**: `[Get this from Twilio Console → Account Dashboard → Click "Show" next to Auth Token]`

**WhatsApp Sandbox Number**: `+14155238886`

**Sandbox Join Code**: `join victory-took` (Already joined ✓)

---

## 🔧 How to Configure in Frappe

### Step 1: Navigate to WhatsApp Settings

Open your browser and go to:
```
http://your-site-url/app/whatsapp-settings
```

Or via menu:
```
Desk → Setup → WhatsApp Settings
```

### Step 2: Fill in the Form

```
✓ Enable WhatsApp Integration: [x] Checked

API Provider: Twilio

Twilio Account SID: YOUR_TWILIO_ACCOUNT_SID

Twilio Auth Token: [Paste your Auth Token from Twilio Dashboard]

From WhatsApp Number: +14155238886
```

### Step 3: Save

Click **Save**

### Step 4: Test

In the Test Configuration section:
- **Test Phone Number**: `+919199200112` (or your number in format +countrycode + number)
- **Test Message**: Leave default or customize
- Click **Actions** → **Send Test Message**

You should receive the message on WhatsApp!

---

## 📱 Important Notes

### Phone Number Format
All phone numbers must be in international format:
- ✅ Correct: `+919876543210`
- ❌ Wrong: `9876543210`
- ❌ Wrong: `+91-9876543210`

### Sandbox Limitations
- ✓ Can send messages to any number that has joined the sandbox
- ✓ Free for testing
- ✓ 24-hour conversation window after user replies
- ✗ Cannot send to users who haven't joined the sandbox
- ✗ For production, you need to upgrade to WhatsApp Business API

### To Add More Test Numbers
Anyone who wants to receive test messages must:
1. Save `+14155238886` as a contact
2. Send `join victory-took` to that number on WhatsApp
3. Wait for confirmation

---

## 🚀 Next Steps After Configuration

Once configured, you can send WhatsApp messages from anywhere in your Compliance app:

```python
from compliance.utils import send_whatsapp_message

send_whatsapp_message("+919876543210", "Hello from Compliance App!")
```

---

## 📚 Documentation

Full documentation available at:
- [WhatsApp Settings README](apps/compliance/compliance/compliance/doctype/whatsapp_settings/README.md)
- [Integration Summary](WHATSAPP_INTEGRATION_SUMMARY.md)

---

**Created**: 2025-12-27
**Status**: Sandbox Active ✓
**Twilio Package**: Installed ✓
