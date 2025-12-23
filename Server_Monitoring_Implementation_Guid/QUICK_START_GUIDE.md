# Server Monitoring System - Quick Start Guide

## 🚀 Get Up and Running in 30 Minutes

This guide will help you quickly deploy the Server Monitoring and Alerting System.

---

## Prerequisites Checklist

- [ ] Ubuntu 20.04+ server
- [ ] Frappe Framework v14/v15 installed
- [ ] Python 3.8+
- [ ] MariaDB/MySQL running
- [ ] SMTP access for emails
- [ ] Root/sudo access

---

## Step 1: Install System Dependencies (5 minutes)
```bash
# Install monitoring tools
sudo apt-get update
sudo apt-get install -y sysstat htop iotop nethogs

# Install Python package
pip install psutil --break-system-packages

# Verify installation
python3 -c "import psutil; print('psutil installed successfully')"
```

---

## Step 2: Create Frappe App (5 minutes)
```bash
# Navigate to bench
cd ~/frappe-bench

# Create new app
bench new-app monitoring_system
# When prompted:
# - App Title: Monitoring System
# - App Description: Server Monitoring and Alerting System
# - Publisher: Your Company
# - Email: your-email@company.com
# - License: MIT

# Install app to site
bench --site your-site.local install-app monitoring_system
```

---

## Step 3: Create DocTypes (10 minutes)

### 3.1 Create Server Monitoring DocType
```bash
cd ~/frappe-bench/apps/monitoring_system
bench --site your-site.local console
```
```python
# In console, run:
import frappe

# Create Server Monitoring DocType
doc = frappe.get_doc({
    "doctype": "DocType",
    "name": "Server Monitoring",
    "module": "Monitoring System",
    "custom": 0,
    "is_submittable": 0,
    "track_changes": 1,
    "fields": [
        {"fieldname": "timestamp", "fieldtype": "Datetime", "label": "Timestamp", "reqd": 1},
        {"fieldname": "section_break_2", "fieldtype": "Section Break", "label": "CPU Metrics"},
        {"fieldname": "cpu_percent", "fieldtype": "Float", "label": "CPU Usage (%)", "precision": "2"},
        {"fieldname": "cpu_count", "fieldtype": "Int", "label": "CPU Count"},
        {"fieldname": "column_break_4", "fieldtype": "Column Break"},
        {"fieldname": "memory_total_gb", "fieldtype": "Float", "label": "Total Memory (GB)", "precision": "2"},
        {"fieldname": "memory_used_gb", "fieldtype": "Float", "label": "Used Memory (GB)", "precision": "2"},
        {"fieldname": "memory_percent", "fieldtype": "Float", "label": "Memory Usage (%)", "precision": "2"},
        {"fieldname": "section_break_8", "fieldtype": "Section Break", "label": "Disk Metrics"},
        {"fieldname": "disk_total_gb", "fieldtype": "Float", "label": "Total Disk (GB)", "precision": "2"},
        {"fieldname": "disk_used_gb", "fieldtype": "Float", "label": "Used Disk (GB)", "precision": "2"},
        {"fieldname": "disk_free_gb", "fieldtype": "Float", "label": "Free Disk (GB)", "precision": "2"},
        {"fieldname": "disk_percent", "fieldtype": "Float", "label": "Disk Usage (%)", "precision": "2"},
        {"fieldname": "column_break_13", "fieldtype": "Column Break"},
        {"fieldname": "database_size_mb", "fieldtype": "Float", "label": "Database Size (MB)", "precision": "2"},
        {"fieldname": "network_sent_mb", "fieldtype": "Float", "label": "Network Sent (MB)", "precision": "2"},
        {"fieldname": "network_recv_mb", "fieldtype": "Float", "label": "Network Received (MB)", "precision": "2"}
    ],
    "permissions": [{"role": "System Manager", "read": 1, "write": 1, "create": 1}]
})
doc.insert()
frappe.db.commit()
print("Server Monitoring DocType created successfully!")

# Create Server Monitoring Settings DocType
settings_doc = frappe.get_doc({
    "doctype": "DocType",
    "name": "Server Monitoring Settings",
    "module": "Monitoring System",
    "custom": 0,
    "issingle": 1,
    "fields": [
        {"fieldname": "monitoring_enabled", "fieldtype": "Check", "label": "Monitoring Enabled", "default": "1"},
        {"fieldname": "collection_interval", "fieldtype": "Int", "label": "Collection Interval (Minutes)", "default": "5"},
        {"fieldname": "retention_days", "fieldtype": "Int", "label": "Metrics Retention (Days)", "default": "30"},
        {"fieldname": "section_break_3", "fieldtype": "Section Break", "label": "Threshold Settings"},
        {"fieldname": "cpu_threshold", "fieldtype": "Float", "label": "CPU Threshold (%)", "default": "80"},
        {"fieldname": "memory_threshold", "fieldtype": "Float", "label": "Memory Threshold (%)", "default": "85"},
        {"fieldname": "disk_threshold", "fieldtype": "Float", "label": "Disk Threshold (%)", "default": "90"},
        {"fieldname": "disk_free_gb_threshold", "fieldtype": "Float", "label": "Disk Free Space Threshold (GB)", "default": "10"},
        {"fieldname": "section_break_8", "fieldtype": "Section Break", "label": "Email Configuration"},
        {"fieldname": "alert_email_addresses", "fieldtype": "Small Text", "label": "Alert Email Addresses"},
        {"fieldname": "cc_email_addresses", "fieldtype": "Small Text", "label": "CC Email Addresses"},
        {"fieldname": "sender_email", "fieldtype": "Data", "label": "Sender Email"},
        {"fieldname": "section_break_12", "fieldtype": "Section Break", "label": "SMTP Configuration"},
        {"fieldname": "smtp_server", "fieldtype": "Data", "label": "SMTP Server"},
        {"fieldname": "smtp_port", "fieldtype": "Int", "label": "SMTP Port", "default": "25"},
        {"fieldname": "section_break_15", "fieldtype": "Section Break", "label": "Cleanup Settings"},
        {"fieldname": "enable_log_cleanup", "fieldtype": "Check", "label": "Enable Log Cleanup", "default": "1"},
        {"fieldname": "log_retention_days", "fieldtype": "Int", "label": "Log Retention (Days)", "default": "30"},
        {"fieldname": "enable_backup_cleanup", "fieldtype": "Check", "label": "Enable Backup Cleanup", "default": "1"},
        {"fieldname": "backup_retention_days", "fieldtype": "Int", "label": "Backup Retention (Days)", "default": "7"}
    ],
    "permissions": [{"role": "System Manager", "read": 1, "write": 1}]
})
settings_doc.insert()
frappe.db.commit()
print("Server Monitoring Settings DocType created successfully!")

exit()
```

### 3.2 Create Python Files

**Create monitoring module:**
```bash
cd ~/frappe-bench/apps/monitoring_system/monitoring_system/monitoring_system/doctype

# Create directory structure
mkdir -p server_monitoring
mkdir -p server_monitoring_settings
mkdir -p ../tasks
mkdir -p ../utils
```

**Copy the Python files from the main documentation** to:
- `server_monitoring/server_monitoring.py`
- `server_monitoring_settings/server_monitoring_settings.py`
- `../tasks/disk_cleanup.py`
- `../tasks/database_maintenance.py`
- `../utils/alert_system.py`

---

## Step 4: Configure Scheduler (2 minutes)

Edit `~/frappe-bench/apps/monitoring_system/monitoring_system/hooks.py`:
```python
scheduler_events = {
    "cron": {
        "*/5 * * * *": [
            "monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics"
        ]
    },
    "daily": [
        "monitoring_system.monitoring_system.tasks.disk_cleanup.cleanup_old_files"
    ],
    "weekly": [
        "monitoring_system.monitoring_system.tasks.database_maintenance.optimize_database"
    ]
}
```

---

## Step 5: Configure Settings (5 minutes)
```bash
# Access Frappe UI
# Navigate to: Server Monitoring Settings
```

### Configuration Values:
```yaml
Monitoring Enabled: ✓ (checked)
Collection Interval: 5 minutes
Retention Days: 30 days

Thresholds:
  CPU Threshold: 80%
  Memory Threshold: 85%
  Disk Threshold: 90%
  Disk Free Space: 10 GB

Email Configuration:
  Alert Emails: admin@company.com, devops@company.com
  CC Emails: manager@company.com
  Sender Email: monitoring@company.com
  SMTP Server: localhost (or your SMTP server)
  SMTP Port: 25

Cleanup Settings:
  Enable Log Cleanup: ✓
  Log Retention: 30 days
  Enable Backup Cleanup: ✓
  Backup Retention: 7 days
```

---

## Step 6: Restart Services (2 minutes)
```bash
cd ~/frappe-bench

# Migrate database
bench --site your-site.local migrate

# Clear cache
bench --site your-site.local clear-cache

# Restart all services
bench restart
```

---

## Step 7: Test the System (5 minutes)

### Test 1: Manual Metric Collection
```bash
bench --site your-site.local execute monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics
```

**Expected Output:**
```
Server metrics collected successfully
```

### Test 2: Verify Data Collection
```bash
bench --site your-site.local console
```
```python
import frappe
records = frappe.get_all('Server Monitoring', limit=1)
print(f"Records found: {len(records)}")
if records:
    doc = frappe.get_doc('Server Monitoring', records[0].name)
    print(f"CPU: {doc.cpu_percent}%")
    print(f"Memory: {doc.memory_percent}%")
    print(f"Disk: {doc.disk_percent}%")
exit()
```

### Test 3: Test Alert Email
```bash
bench --site your-site.local console
```
```python
from monitoring_system.monitoring_system.utils.alert_system import send_alert_email

test_alerts = [{
    'parameter': 'Test Alert',
    'current_value': '100%',
    'threshold': '80%',
    'severity': 'High'
}]

send_alert_email(test_alerts, "Test Alert")
print("Test alert sent! Check your email.")
exit()
```

### Test 4: Test Cleanup
```bash
bench --site your-site.local execute monitoring_system.monitoring_system.tasks.disk_cleanup.cleanup_old_files
```

---

## Step 8: Verify Scheduler (2 minutes)
```bash
# Check scheduler status
bench --site your-site.local doctor

# Watch scheduler logs
tail -f ~/frappe-bench/sites/your-site.local/logs/schedule.log
```

You should see entries like:
```
[timestamp] Executing: monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics
[timestamp] Success
```

---

## 🎉 Success Checklist

- [ ] Server Monitoring DocType created
- [ ] Settings configured
- [ ] Manual test successful
- [ ] Data visible in Server Monitoring list
- [ ] Test alert email received
- [ ] Scheduler running and logging
- [ ] Cleanup tasks configured

---

## Quick Commands Reference
```bash
# View metrics
bench --site site1 list-view "Server Monitoring"

# Manual collection
bench --site site1 execute monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics

# Manual cleanup
bench --site site1 execute monitoring_system.monitoring_system.tasks.disk_cleanup.cleanup_old_files

# Check logs
tail -f ~/frappe-bench/sites/site1/logs/schedule.log

# Restart services
bench restart
```

---

## Next Steps

1. **Set up Grafana** (Optional): See main documentation Section 8
2. **Customize thresholds**: Adjust based on your baseline
3. **Add more recipients**: Update email addresses in settings
4. **Create dashboards**: Use Server Monitoring report
5. **Review weekly**: Check metrics trends

---

## Common Issues

### Issue: "Module not found"
```bash
# Solution:
bench --site site1 migrate
bench restart
```

### Issue: "No metrics collected"
```bash
# Solution:
# 1. Check if monitoring is enabled in settings
# 2. Manually run collection to test
# 3. Check scheduler logs for errors
```

### Issue: "Email not received"
```bash
# Solution:
# 1. Verify SMTP settings
# 2. Test SMTP: telnet smtp-server 25
# 3. Check spam folder
```

---

## Support

- 📧 Email: support@company.com
- 📚 Full Documentation: [SERVER_MONITORING_IMPLEMENTATION_GUIDE.md](./SERVER_MONITORING_IMPLEMENTATION_GUIDE.md)
- 🔧 Troubleshooting: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

**Quick Start Guide Version:** 1.0
**Last Updated:** December 23, 2025
**Estimated Setup Time:** 30 minutes
