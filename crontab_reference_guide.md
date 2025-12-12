# Crontab Configuration Reference Guide

## Overview

Crontab (CRON TABLE) is a time-based job scheduler in Unix-like operating systems. It allows users to schedule commands or scripts to run automatically at specified times and intervals.

---

## Cron Format Syntax

```
* * * * * command_to_execute
│ │ │ │ │
│ │ │ │ └─── Day of Week (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of Month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

### Field Values

| Field | Values | Description |
|-------|--------|-------------|
| Minute | 0-59 | Minute of the hour |
| Hour | 0-23 | Hour of the day (24-hour format) |
| Day of Month | 1-31 | Day of the month |
| Month | 1-12 | Month of the year (1=Jan, 12=Dec) |
| Day of Week | 0-7 | Day of the week (0 or 7=Sunday, 1=Monday, etc.) |
| Command | Any valid shell command | The command or script to execute |

---

## Special Characters

| Character | Description | Example |
|-----------|-------------|---------|
| `*` | Any value (every) | `* * * * *` = Every minute |
| `,` | List separator | `0,30 * * * *` = At 0 and 30 minutes |
| `-` | Range of values | `0 9-17 * * *` = Every hour from 9 AM to 5 PM |
| `/` | Step values | `*/5 * * * *` = Every 5 minutes |
| `?` | No specific value | Used in some cron implementations |

---

## Special Time Strings

Some cron implementations support these shortcuts:

| String | Equivalent | Description |
|--------|------------|-------------|
| `@reboot` | - | Run once at startup |
| `@yearly` or `@annually` | `0 0 1 1 *` | Run once a year (Jan 1, midnight) |
| `@monthly` | `0 0 1 * *` | Run once a month (1st, midnight) |
| `@weekly` | `0 0 * * 0` | Run once a week (Sunday, midnight) |
| `@daily` or `@midnight` | `0 0 * * *` | Run once a day (midnight) |
| `@hourly` | `0 * * * *` | Run once an hour (top of hour) |

---

## Common Crontab Commands

### View Current Crontab

```bash
crontab -l
```

### Edit Crontab

```bash
crontab -e
```

### Remove All Cron Jobs

```bash
crontab -r
```

### Install Crontab from File

```bash
crontab filename.cron
```

### View Another User's Crontab (requires root)

```bash
sudo crontab -u username -l
```

### Edit Another User's Crontab (requires root)

```bash
sudo crontab -u username -e
```

---

## Common Scheduling Examples

### Every Minute

```bash
* * * * * /path/to/script.sh
```

### Every 5 Minutes

```bash
*/5 * * * * /path/to/script.sh
```

### Every 15 Minutes

```bash
*/15 * * * * /path/to/script.sh
# OR
0,15,30,45 * * * * /path/to/script.sh
```

### Every 30 Minutes

```bash
*/30 * * * * /path/to/script.sh
# OR
0,30 * * * * /path/to/script.sh
```

### Every Hour (at minute 0)

```bash
0 * * * * /path/to/script.sh
```

### Every Hour at Minute 15

```bash
15 * * * * /path/to/script.sh
```

### Every 2 Hours

```bash
0 */2 * * * /path/to/script.sh
```

### Every Day at Midnight

```bash
0 0 * * * /path/to/script.sh
# OR
@daily /path/to/script.sh
```

### Every Day at 3:30 AM

```bash
30 3 * * * /path/to/script.sh
```

### Every Day at 6:00 AM and 6:00 PM

```bash
0 6,18 * * * /path/to/script.sh
```

### Every Weekday (Mon-Fri) at 9:00 AM

```bash
0 9 * * 1-5 /path/to/script.sh
```

### Every Weekend (Sat-Sun) at 10:00 AM

```bash
0 10 * * 6-7 /path/to/script.sh
# OR
0 10 * * 6,0 /path/to/script.sh
```

### Every Monday at 8:00 AM

```bash
0 8 * * 1 /path/to/script.sh
```

### Every Sunday at 11:00 PM

```bash
0 23 * * 0 /path/to/script.sh
```

### First Day of Every Month at Midnight

```bash
0 0 1 * * /path/to/script.sh
# OR
@monthly /path/to/script.sh
```

### Last Day of Every Month

```bash
# This requires a script that checks if tomorrow is the 1st
0 0 28-31 * * [ $(date -d tomorrow +\%d) -eq 1 ] && /path/to/script.sh
```

### Every Quarter (Jan 1, Apr 1, Jul 1, Oct 1)

```bash
0 0 1 1,4,7,10 * /path/to/script.sh
```

### Twice a Day (6 AM and 6 PM)

```bash
0 6,18 * * * /path/to/script.sh
```

### Business Hours (9 AM - 5 PM, Mon-Fri)

```bash
0 9-17 * * 1-5 /path/to/script.sh
```

### Every 10 Minutes During Business Hours

```bash
*/10 9-17 * * 1-5 /path/to/script.sh
```

### Every 6 Hours

```bash
0 */6 * * * /path/to/script.sh
```

### At System Startup

```bash
@reboot /path/to/script.sh
```

---

## Advanced Examples

### Multiple Times Per Day

```bash
# At 8:00 AM, 12:00 PM, and 6:00 PM
0 8,12,18 * * * /path/to/script.sh
```

### Specific Days of Week

```bash
# Every Tuesday and Thursday at 3:30 PM
30 15 * * 2,4 /path/to/script.sh
```

### Range with Step

```bash
# Every 2 hours between 9 AM and 5 PM
0 9-17/2 * * * /path/to/script.sh
# Runs at: 9:00, 11:00, 13:00, 15:00, 17:00
```

### Complex Schedule

```bash
# Every 15 minutes during work hours on weekdays
*/15 9-17 * * 1-5 /path/to/script.sh

# Every hour on the hour, except during midnight-6am
0 6-23 * * * /path/to/script.sh
```

---

## Environment Variables in Crontab

You can set environment variables at the top of your crontab file:

```bash
# Set shell
SHELL=/bin/bash

# Set PATH
PATH=/usr/local/bin:/usr/bin:/bin

# Set MAILTO for error notifications
MAILTO=admin@example.com

# Set HOME directory
HOME=/home/username

# Your cron jobs
0 2 * * * /path/to/backup.sh
```

---

## Output Redirection and Logging

### Redirect Output to a File

```bash
# Redirect stdout to log file
0 2 * * * /path/to/script.sh > /var/log/script.log

# Redirect both stdout and stderr
0 2 * * * /path/to/script.sh > /var/log/script.log 2>&1

# Append to log file
0 2 * * * /path/to/script.sh >> /var/log/script.log 2>&1
```

### Discard All Output

```bash
0 2 * * * /path/to/script.sh > /dev/null 2>&1
```

### Log with Timestamp

```bash
0 2 * * * echo "$(date): Starting backup" >> /var/log/backup.log && /path/to/backup.sh >> /var/log/backup.log 2>&1
```

---

## Best Practices

### 1. Use Absolute Paths

```bash
# BAD
0 2 * * * backup.sh

# GOOD
0 2 * * * /home/user/scripts/backup.sh
```

### 2. Set PATH Variable

```bash
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

0 2 * * * backup.sh
```

### 3. Log Output

```bash
# Always log important cron jobs
0 2 * * * /path/to/script.sh >> /var/log/cronlog/script.log 2>&1
```

### 4. Add Comments

```bash
# Backup database daily at 2 AM
0 2 * * * /home/user/scripts/db_backup.sh

# Clean temp files every Sunday at midnight
0 0 * * 0 /home/user/scripts/cleanup_temp.sh
```

### 5. Test Your Scripts First

```bash
# Test the script manually before adding to cron
/path/to/script.sh

# Check the exit code
echo $?
```

### 6. Use Locking for Long-Running Tasks

```bash
# Prevent concurrent execution
0 2 * * * flock -n /tmp/backup.lock /path/to/backup.sh
```

### 7. Set MAILTO for Error Notifications

```bash
MAILTO=admin@example.com

# Cron will email errors to this address
0 2 * * * /path/to/script.sh
```

---

## Common Pitfalls and Solutions

### Problem: Script Works Manually but Not in Cron

**Solution:** Check the environment variables and PATH

```bash
# Add this to your crontab
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/home/username

# Or source your profile in the command
0 2 * * * source ~/.bashrc && /path/to/script.sh
```

### Problem: Cron Not Executing

**Solution:** Check cron service status

```bash
# Check if cron is running
sudo systemctl status cron

# Start cron service
sudo systemctl start cron

# Enable cron to start at boot
sudo systemctl enable cron
```

### Problem: Percentage Signs (%) in Cron

**Solution:** Escape them with backslash

```bash
# BAD
0 2 * * * /usr/bin/date +%Y-%m-%d

# GOOD
0 2 * * * /usr/bin/date +\%Y-\%m-\%d
```

### Problem: Not Receiving Email Notifications

**Solution:** Ensure mail system is configured

```bash
# Install mail utilities
sudo apt-get install mailutils

# Test email
echo "Test" | mail -s "Test Subject" user@example.com
```

---

## Debugging Cron Jobs

### 1. Check Cron Logs

```bash
# On Ubuntu/Debian
grep CRON /var/log/syslog

# On CentOS/RHEL
grep CRON /var/log/cron
```

### 2. Add Verbose Logging to Your Script

```bash
#!/bin/bash
set -x  # Enable debug mode
exec 1>> /var/log/script.log 2>&1  # Redirect all output

echo "Script started at $(date)"
# Your commands here
echo "Script completed at $(date)"
```

### 3. Run Cron Job Manually with Same Environment

```bash
# Create a test script that mimics cron environment
env -i HOME=/home/user PATH=/usr/bin:/bin SHELL=/bin/bash /path/to/script.sh
```

---

## Example: NSE CM Trade Data Deletion Schedules

```bash
# Crontab Configuration for NSE CM Trade Data Deletion

# Daily at 2:00 AM (Recommended for production)
0 2 * * * /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1

# Daily at midnight
0 0 * * * /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1

# Every Sunday at 3:00 AM (Weekly cleanup)
0 3 * * 0 /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1

# First day of every month at 1:00 AM (Monthly cleanup)
0 1 1 * * /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1

# Every 6 hours (for frequent cleanup)
0 */6 * * * /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1

# Weekdays at 6:00 PM (After market close)
0 18 * * 1-5 /usr/local/bin/delete_nse_trade_data.sh >> /var/log/nse_deletion.log 2>&1
```

---

## Crontab Template

```bash
# ============================================================
# Crontab Configuration File
# ============================================================
# User: username
# Last Modified: YYYY-MM-DD
# Description: Automated task scheduler
# ============================================================

# Environment Variables
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
HOME=/home/username
MAILTO=admin@example.com

# ============================================================
# SCHEDULED TASKS
# ============================================================

# Daily Backups - 2:00 AM
0 2 * * * /home/user/scripts/daily_backup.sh >> /var/log/backup.log 2>&1

# Weekly Database Optimization - Sunday 3:00 AM
0 3 * * 0 /home/user/scripts/optimize_db.sh >> /var/log/db_optimize.log 2>&1

# Clean Temporary Files - Every Hour
0 * * * * /home/user/scripts/clean_temp.sh > /dev/null 2>&1

# Health Check - Every 5 Minutes
*/5 * * * * /home/user/scripts/health_check.sh >> /var/log/health.log 2>&1

# Generate Reports - Weekdays 6:00 AM
0 6 * * 1-5 /home/user/scripts/generate_reports.sh >> /var/log/reports.log 2>&1

# ============================================================
# END OF CRONTAB
# ============================================================
```

---

## Online Tools and Resources

### Crontab Generators

- **Crontab.guru**: <https://crontab.guru/> - Interactive cron schedule expression editor
- **Crontab Generator**: <https://crontab-generator.org/> - Visual cron job generator
- **Corntab**: <https://corntab.com/> - Cron expression generator with examples

### Testing Tools

- **Cronitor**: <https://cronitor.io/> - Cron job monitoring
- **Cron Checker**: Online tools to validate cron expressions

---

## System-Specific Notes

### Ubuntu/Debian

```bash
# Cron daemon: cron
sudo systemctl status cron
sudo systemctl restart cron

# User crontabs: /var/spool/cron/crontabs/
# System crontab: /etc/crontab
# System cron directories: /etc/cron.{hourly,daily,weekly,monthly}/
```

### CentOS/RHEL

```bash
# Cron daemon: crond
sudo systemctl status crond
sudo systemctl restart crond

# User crontabs: /var/spool/cron/
# System crontab: /etc/crontab
```

### macOS

```bash
# Cron daemon: cron (managed by launchd)
# User crontabs: /usr/lib/cron/tabs/
```

---

## Security Considerations

1. **Limit crontab permissions**: Only the owner should read/write their crontab
2. **Use absolute paths**: Avoid PATH injection attacks
3. **Validate input**: If scripts accept parameters
4. **Run with minimal privileges**: Use specific user accounts
5. **Audit cron jobs regularly**: Review scheduled tasks periodically
6. **Protect sensitive data**: Don't expose passwords in cron commands
7. **Use environment restrictions**: Set restrictive PATH and environment variables

---

## Troubleshooting Checklist

- [ ] Is the cron daemon running?
- [ ] Is the script executable? (`chmod +x script.sh`)
- [ ] Are absolute paths used?
- [ ] Is the PATH variable set correctly?
- [ ] Are there syntax errors in the crontab?
- [ ] Is the script working when run manually?
- [ ] Are there permission issues?
- [ ] Is output being logged somewhere?
- [ ] Are percentage signs escaped?
- [ ] Is the mail system configured for error notifications?

---

## Quick Reference Card

```
┌───────────── minute (0-59)
│ ┌─────────── hour (0-23)
│ │ ┌───────── day of month (1-31)
│ │ │ ┌─────── month (1-12)
│ │ │ │ ┌───── day of week (0-7, 0 or 7=Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command to execute

Special Characters:
*  - Any value
,  - List of values (1,3,5)
-  - Range of values (1-5)
/  - Step values (*/5)

Common Patterns:
*/5 * * * *    - Every 5 minutes
0 * * * *      - Every hour
0 0 * * *      - Every day at midnight
0 0 * * 0      - Every Sunday at midnight
0 0 1 * *      - First day of every month
@reboot        - At system startup
```

---

## Version Information

This reference guide covers standard cron implementations found in:
- **Unix/Linux systems** (cron, vixie-cron, cronie)
- **BSD systems**
- **macOS**

**Note:** Some implementations may have additional features or slight variations.

---

**Last Updated:** December 2024

**Maintained by:** System Administration Team
