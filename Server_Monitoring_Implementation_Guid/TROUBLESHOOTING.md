# Server Monitoring System - Troubleshooting Guide

## 📋 Table of Contents

1. [Installation Issues](#installation-issues)
2. [Monitoring Issues](#monitoring-issues)
3. [Email Alert Issues](#email-alert-issues)
4. [Scheduler Issues](#scheduler-issues)
5. [Performance Issues](#performance-issues)
6. [Database Issues](#database-issues)
7. [Grafana Issues](#grafana-issues)
8. [Cleanup Issues](#cleanup-issues)
9. [Common Error Messages](#common-error-messages)
10. [Emergency Procedures](#emergency-procedures)

---

## Installation Issues

### Issue 1: "psutil module not found"

**Error Message:**
```
ModuleNotFoundError: No module named 'psutil'
```

**Solution:**
```bash
# Install psutil
pip install psutil --break-system-packages

# Verify installation
python3 -c "import psutil; print(psutil.__version__)"

# If still failing, try:
sudo pip3 install psutil

# For virtual environment:
source ~/frappe-bench/env/bin/activate
pip install psutil
```

**Verification:**
```bash
bench --site site1 console
>>> import psutil
>>> print(psutil.cpu_percent())
>>> exit()
```

---

### Issue 2: "DocType creation failed"

**Error Message:**
```
frappe.exceptions.ValidationError: DocType already exists
```

**Solution:**
```bash
# Delete existing DocType
bench --site site1 console
```
```python
import frappe
frappe.delete_doc('DocType', 'Server Monitoring', force=1)
frappe.db.commit()
exit()
```
```bash
# Recreate DocType (follow Quick Start Guide Step 3)
```

---

### Issue 3: "Permission denied on log files"

**Error Message:**
```
PermissionError: [Errno 13] Permission denied: '/path/to/log'
```

**Solution:**
```bash
# Fix ownership
cd ~/frappe-bench
sudo chown -R $USER:$USER sites/

# Fix permissions
chmod -R 755 sites/*/private/
chmod -R 755 sites/*/logs/

# For specific site
sudo chown -R $USER:$USER sites/your-site/
```

---

## Monitoring Issues

### Issue 4: "No metrics being collected"

**Symptoms:**
- Empty Server Monitoring list
- No new records created
- Scheduler showing success but no data

**Diagnosis:**
```bash
# Check if monitoring is enabled
bench --site site1 console
```
```python
import frappe
settings = frappe.get_single('Server Monitoring Settings')
print(f"Enabled: {settings.monitoring_enabled}")
print(f"Interval: {settings.collection_interval}")
exit()
```

**Solution 1: Enable monitoring**
```bash
bench --site site1 set-value "Server Monitoring Settings" None monitoring_enabled 1
```

**Solution 2: Manual test**
```bash
# Run collection manually
bench --site site1 execute monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics

# Check for errors
tail -f ~/frappe-bench/sites/site1/logs/frappe.log
```

**Solution 3: Check scheduler**
```bash
# Verify scheduler is running
bench --site site1 doctor

# Expected output should show:
# ✓ scheduler enabled
# ✓ scheduler running
```

---

### Issue 5: "Incorrect CPU/Memory readings"

**Symptoms:**
- CPU always showing 0%
- Memory values incorrect
- Disk space wrong

**Solution 1: Verify psutil**
```bash
python3 << EOF
import psutil
print(f"CPU: {psutil.cpu_percent(interval=1)}%")
print(f"Memory: {psutil.virtual_memory().percent}%")
print(f"Disk: {psutil.disk_usage('/').percent}%")
EOF
```

**Solution 2: Check system tools**
```bash
# Install monitoring tools if missing
sudo apt-get install -y sysstat

# Verify they work
iostat
mpstat
free -h
df -h
```

**Solution 3: Restart monitoring**
```bash
bench restart
sleep 10
bench --site site1 execute monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics
```

---

### Issue 6: "Database size showing 0 MB"

**Symptoms:**
- Database size always 0 or NULL

**Solution:**
```bash
# Check database manually
mysql -u root -p << EOF
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'your_database_name'
GROUP BY table_schema;
EOF

# Grant required permissions
mysql -u root -p << EOF
GRANT SELECT ON information_schema.* TO 'your_db_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

---

## Email Alert Issues

### Issue 7: "Alerts not being sent"

**Diagnosis:**
```bash
bench --site site1 console
```
```python
import frappe
settings = frappe.get_single('Server Monitoring Settings')
print(f"Alert Emails: {settings.alert_email_addresses}")
print(f"SMTP Server: {settings.smtp_server}")
print(f"SMTP Port: {settings.smtp_port}")
print(f"Sender: {settings.sender_email}")
exit()
```

**Solution 1: Verify email configuration**
```bash
# Test SMTP connection
telnet your-smtp-server 25

# Or using nc
nc -zv your-smtp-server 25
```

**Solution 2: Test email manually**
```bash
# Send test email via command line
echo "Test email" | mail -s "Test" -r "from@company.com" to@company.com

# If mail command not available
sudo apt-get install mailutils
```

**Solution 3: Check firewall**
```bash
# Check if SMTP port is open
sudo ufw status
sudo iptables -L -n | grep 25

# Allow SMTP if blocked
sudo ufw allow 25/tcp
```

**Solution 4: Test from Python**
```python
import smtplib
from email.mime.text import MIMEText

msg = MIMEText("Test email body")
msg['Subject'] = "Test Email"
msg['From'] = "monitoring@company.com"
msg['To'] = "admin@company.com"

try:
    with smtplib.SMTP('localhost', 25) as server:
        server.sendmail(msg['From'], [msg['To']], msg.as_string())
    print("Email sent successfully!")
except Exception as e:
    print(f"Error: {e}")
```

---

### Issue 8: "Emails going to spam"

**Solution:**

1. **Add SPF record** (DNS):
```
v=spf1 ip4:your.server.ip.address ~all
```

2. **Add DKIM** (if available)

3. **Use proper sender email**:
```bash
bench --site site1 set-value "Server Monitoring Settings" None sender_email "noreply@yourdomain.com"
```

4. **Whitelist sender** in recipient email client

---

### Issue 9: "Too many alert emails"

**Symptoms:**
- Receiving alerts every 5 minutes
- Alert fatigue

**Solution 1: Adjust thresholds**
```bash
bench --site site1 console
```
```python
import frappe
settings = frappe.get_single('Server Monitoring Settings')
settings.cpu_threshold = 90  # Increase from 80
settings.memory_threshold = 90  # Increase from 85
settings.disk_threshold = 95  # Increase from 90
settings.save()
frappe.db.commit()
exit()
```

**Solution 2: Implement alert cooldown** (code modification required)

Add to `server_monitoring.py`:
```python
# Global cache for last alert time
last_alert_time = {}

def check_thresholds(metrics):
    global last_alert_time
    import time

    current_time = time.time()
    cooldown_period = 3600  # 1 hour in seconds

    # Check if we sent alert recently
    if 'disk' in last_alert_time:
        if current_time - last_alert_time['disk'] < cooldown_period:
            return  # Skip alert

    # ... existing threshold checking code ...

    if alerts:
        send_alert_email(alerts)
        last_alert_time['disk'] = current_time
```

---

## Scheduler Issues

### Issue 10: "Scheduler not running"

**Diagnosis:**
```bash
# Check scheduler status
bench --site site1 doctor

# Check scheduler process
ps aux | grep schedule

# Check scheduler logs
tail -f ~/frappe-bench/sites/site1/logs/schedule.log
```

**Solution 1: Enable scheduler**
```bash
# Enable scheduler for site
bench --site site1 enable-scheduler

# Verify
bench --site site1 doctor
```

**Solution 2: Restart scheduler**
```bash
# Restart all bench services
bench restart

# Or restart scheduler specifically
sudo supervisorctl restart frappe-bench-frappe:frappe-bench-frappe-schedule
```

**Solution 3: Check supervisor config**
```bash
# View supervisor config
cat ~/frappe-bench/config/supervisor.conf

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart all
```

---

### Issue 11: "Scheduled tasks not executing"

**Symptoms:**
- Scheduler running but tasks not executing
- No entries in schedule.log

**Solution 1: Check cron syntax**

Edit `hooks.py` and verify cron syntax:
```python
scheduler_events = {
    "cron": {
        "*/5 * * * *": [  # Every 5 minutes (correct)
            "monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics"
        ]
    }
}
```

**Solution 2: Test task manually**
```bash
# Run task directly
bench --site site1 execute monitoring_system.monitoring_system.doctype.server_monitoring.server_monitoring.collect_server_metrics

# Check for errors
echo $?  # Should be 0 if successful
```

**Solution 3: Reinstall app**
```bash
bench --site site1 uninstall-app monitoring_system
bench --site site1 install-app monitoring_system
bench restart
```

---

### Issue 12: "Scheduler running but errors in log"

**Common Errors:**

**Error: "Database connection lost"**
```bash
# Solution: Increase MySQL wait_timeout
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# Add:
wait_timeout = 28800
interactive_timeout = 28800

# Restart MySQL
sudo systemctl restart mysql
```

**Error: "Memory error"**
```bash
# Solution: Increase system memory or reduce collection frequency
bench --site site1 set-value "Server Monitoring Settings" None collection_interval 15
```

---

## Performance Issues

### Issue 13: "High CPU usage from monitoring"

**Symptoms:**
- psutil consuming high CPU
- System slow during collection

**Solution 1: Reduce collection frequency**
```bash
# Change from 5 minutes to 10 minutes
bench --site site1 set-value "Server Monitoring Settings" None collection_interval 10
```

**Solution 2: Optimize collection code**

Edit `server_monitoring.py`:
```python
# Use shorter interval for CPU measurement
cpu_percent = psutil.cpu_percent(interval=0.5)  # Changed from 1

# Reduce disk I/O checks
# Only check specific mount points
disk = psutil.disk_usage('/')  # Only root partition
```

---

### Issue 14: "Database growing too fast"

**Symptoms:**
- Server Monitoring table size increasing rapidly
- Database disk usage high

**Solution 1: Reduce retention**
```bash
# Set shorter retention period
bench --site site1 set-value "Server Monitoring Settings" None retention_days 7
```

**Solution 2: Manual cleanup**
```bash
bench --site site1 console
```
```python
import frappe
from datetime import datetime, timedelta

cutoff = datetime.now() - timedelta(days=7)
frappe.db.sql("""
    DELETE FROM `tabServer Monitoring`
    WHERE timestamp < %s
""", (cutoff,))
frappe.db.commit()
print("Old records deleted")
exit()
```

**Solution 3: Optimize table**
```bash
mysql -u root -p << EOF
USE your_database_name;
OPTIMIZE TABLE \`tabServer Monitoring\`;
EOF
```

---

## Database Issues

### Issue 15: "Database connection errors"

**Error Message:**
```
Lost connection to MySQL server during query
```

**Solution 1: Increase timeouts**
```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# Add/modify:
wait_timeout = 28800
interactive_timeout = 28800
max_allowed_packet = 256M

sudo systemctl restart mysql
```

**Solution 2: Check connection pool**
```bash
# Check MySQL max connections
mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"

# Increase if needed
mysql -u root -p << EOF
SET GLOBAL max_connections = 500;
EOF
```

---

### Issue 16: "Disk space full (database)"

**Emergency Solution:**
```bash
# 1. Stop services
bench --site site1 disable-scheduler
sudo supervisorctl stop frappe-bench-frappe:

# 2. Create backup
bench --site site1 backup --with-files

# 3. Delete old monitoring records
mysql -u root -p << EOF
USE your_database_name;
DELETE FROM \`tabServer Monitoring\`
WHERE timestamp < DATE_SUB(NOW(), INTERVAL 7 DAY)
LIMIT 10000;
OPTIMIZE TABLE \`tabServer Monitoring\`;
EOF

# 4. Clean up logs
find ~/frappe-bench/sites/site1/logs -name "*.log" -mtime +7 -delete

# 5. Clean up backups
find ~/frappe-bench/sites/site1/private/backups -mtime +3 -delete

# 6. Restart services
sudo supervisorctl start frappe-bench-frappe:
bench --site site1 enable-scheduler
```

---

## Grafana Issues

### Issue 17: "Grafana showing 'No Data'"

**Diagnosis:**
```bash
# Check if Prometheus is running
sudo systemctl status prometheus

# Check if exporters are running
sudo systemctl status node_exporter
sudo systemctl status mysqld_exporter

# Test exporter endpoints
curl http://localhost:9100/metrics | head
curl http://localhost:9104/metrics | head

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq
```

**Solution 1: Restart services**
```bash
sudo systemctl restart node_exporter
sudo systemctl restart mysqld_exporter
sudo systemctl restart prometheus
sudo systemctl restart grafana-server
```

**Solution 2: Check Prometheus config**
```bash
# View config
cat /usr/local/prometheus/prometheus.yml

# Validate config
/usr/local/prometheus/promtool check config /usr/local/prometheus/prometheus.yml

# If invalid, fix and reload
sudo systemctl reload prometheus
```

**Solution 3: Check firewall**
```bash
# Allow Prometheus ports
sudo ufw allow 9090/tcp
sudo ufw allow 9100/tcp
sudo ufw allow 9104/tcp
sudo ufw allow 3000/tcp
```

---

### Issue 18: "MySQL exporter not working"

**Error in logs:**
```
Error 1045: Access denied for user 'exporter'@'localhost'
```

**Solution:**
```bash
# Recreate MySQL user
mysql -u root -p << EOF
DROP USER IF EXISTS 'exporter'@'localhost';
CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'NewStrongPassword123!';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
FLUSH PRIVILEGES;
EOF

# Update config
sudo nano /etc/mysqld_exporter/.my.cnf

# Change password:
[client]
user=exporter
password=NewStrongPassword123!

# Restart exporter
sudo systemctl restart mysqld_exporter
```

---

## Cleanup Issues

### Issue 19: "Cleanup not removing files"

**Diagnosis:**
```bash
# Check if cleanup is enabled
bench --site site1 console
```
```python
import frappe
settings = frappe.get_single('Server Monitoring Settings')
print(f"Log Cleanup: {settings.enable_log_cleanup}")
print(f"Backup Cleanup: {settings.enable_backup_cleanup}")
exit()
```

**Solution 1: Check file permissions**
```bash
# Check ownership
ls -la ~/frappe-bench/sites/site1/private/backups/
ls -la ~/frappe-bench/sites/site1/logs/

# Fix permissions
cd ~/frappe-bench
sudo chown -R $USER:$USER sites/site1/private/
sudo chown -R $USER:$USER sites/site1/logs/
chmod -R 755 sites/site1/private/
```

**Solution 2: Manual cleanup**
```bash
# Delete old logs manually
find ~/frappe-bench/sites/site1/logs -name "*.log" -mtime +30 -delete
find ~/frappe-bench/sites/site1/logs -name "*.log.*" -mtime +30 -delete

# Delete old backups manually
find ~/frappe-bench/sites/site1/private/backups -mtime +7 -delete
```

**Solution 3: Run cleanup manually**
```bash
bench --site site1 execute monitoring_system.monitoring_system.tasks.disk_cleanup.cleanup_old_files
```

---

### Issue 20: "Cleanup runs but disk still full"

**Diagnosis:**
```bash
# Find large files
du -sh ~/frappe-bench/sites/site1/* | sort -h
du -sh ~/frappe-bench/sites/site1/private/* | sort -h
du -sh ~/frappe-bench/sites/site1/public/* | sort -h

# Find largest directories
du -h ~/frappe-bench/sites/site1 | sort -h | tail -20
```

**Solution:**
```bash
# Clean up file uploads
cd ~/frappe-bench/sites/site1/public/files
find . -type f -mtime +90 -size +10M -exec ls -lh {} \;

# Clean up error snapshots
rm -rf ~/frappe-bench/sites/site1/private/error-snapshots/*

# Clean up temp files
rm -rf ~/frappe-bench/sites/site1/private/temp/*
rm -rf /tmp/frappe-*

# Optimize database
mysql -u root -p << EOF
USE your_database_name;
OPTIMIZE TABLE \`tabServer Monitoring\`;
OPTIMIZE TABLE \`tabError Log\`;
EOF
```

---

## Common Error Messages

### Error 21: "ImportError: cannot import name 'X'"

**Solution:**
```bash
# Clear Python cache
find ~/frappe-bench/apps/monitoring_system -type d -name __pycache__ -exec rm -rf {} +
find ~/frappe-bench/apps/monitoring_system -name "*.pyc" -delete

# Restart
bench restart
```

---

### Error 22: "OperationalError: (2006, 'MySQL server has gone away')"

**Solution:**
```bash
# Increase packet size
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# Add:
max_allowed_packet = 256M

sudo systemctl restart mysql
bench restart
```

---

### Error 23: "OSError: [Errno 28] No space left on device"

**Emergency Solution:**
```bash
# Free up space immediately
sudo apt-get clean
sudo apt-get autoclean
sudo journalctl --vacuum-time=3d

# Find and remove large files
find /tmp -type f -size +100M -delete
find ~/frappe-bench/sites/*/private/backups -mtime +1 -delete

# Clean Docker if installed
docker system prune -a -f

# Clean up old kernels
sudo apt-get autoremove --purge
```

---

## Emergency Procedures

### Emergency 1: System Completely Down
```bash
# 1. Check disk space
df -h

# 2. Check memory
free -h

# 3. Check processes
top

# 4. Stop non-essential services
bench --site site1 disable-scheduler
sudo supervisorctl stop frappe-bench-frappe:frappe-bench-frappe-worker*

# 5. Free up space
find ~/frappe-bench/sites/*/private/backups -mtime +0 -delete
find /tmp -type f -delete

# 6. Restart essential services
sudo systemctl restart mysql
sudo supervisorctl start frappe-bench-frappe:frappe-bench-frappe-web*

# 7. Check status
bench --site site1 doctor
```

---

### Emergency 2: Database Crash
```bash
# 1. Stop all services
sudo supervisorctl stop frappe-bench-frappe:

# 2. Check database status
sudo systemctl status mysql

# 3. Check error log
sudo tail -100 /var/log/mysql/error.log

# 4. Try to start MySQL
sudo systemctl start mysql

# 5. If MySQL won't start, recover
sudo mysqld --skip-grant-tables &
mysql -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'your-password';
FLUSH PRIVILEGES;
EOF
sudo killall mysqld
sudo systemctl start mysql

# 6. Restart services
sudo supervisorctl start frappe-bench-frappe:
bench --site site1 migrate
```

---

### Emergency 3: Monitoring Causing System Issues
```bash
# 1. Disable monitoring immediately
bench --site site1 set-value "Server Monitoring Settings" None monitoring_enabled 0

# 2. Disable scheduler
bench --site site1 disable-scheduler

# 3. Kill any running monitoring processes
ps aux | grep "collect_server_metrics" | awk '{print $2}' | xargs kill -9

# 4. Restart services
bench restart

# 5. Re-enable gradually
bench --site site1 enable-scheduler
# Wait 10 minutes
bench --site site1 set-value "Server Monitoring Settings" None monitoring_enabled 1
```

---

## Getting Help

### Before Contacting Support

1. **Collect information:**
```bash
# System info
uname -a
df -h
free -h
uptime

# Frappe info
bench version
bench --site site1 doctor

# Recent logs
tail -100 ~/frappe-bench/sites/site1/logs/frappe.log
tail -100 ~/frappe-bench/sites/site1/logs/schedule.log
```

2. **Document the issue:**
- What were you trying to do?
- What happened instead?
- Error messages (exact text)
- Steps to reproduce

3. **Try basic fixes:**
- Restart services: `bench restart`
- Clear cache: `bench --site site1 clear-cache`
- Check logs for errors

### Contact Information

- 📧 Email: support@company.com
- 📱 Phone: +91-XXX-XXXX-XXXX
- 🔗 Create ticket: https://support.company.com
- 💬 Slack: #monitoring-support

---

## Useful Diagnostic Commands
```bash
# Quick health check
bench --site site1 doctor

# Check all services
sudo supervisorctl status

# View real-time logs
tail -f ~/frappe-bench/sites/site1/logs/frappe.log

# Check disk usage by directory
du -sh ~/frappe-bench/sites/site1/* | sort -h

# Check database size
mysql -u root -p -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY table_schema;"

# Check running processes
ps aux | grep frappe

# Check open files
lsof | grep frappe

# Check network connections
netstat -tlnp | grep python

# System resource usage
htop
iotop
nethogs
```

---

**Troubleshooting Guide Version:** 1.0
**Last Updated:** December 23, 2025
**For:** Server Monitoring System v1.0

---

*If your issue is not covered here, please refer to the main documentation or contact support.*
