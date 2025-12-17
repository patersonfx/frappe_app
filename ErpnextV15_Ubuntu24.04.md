# ERPNext Version 15 Installation Guide - Ubuntu 24.04

A comprehensive, production-ready installation guide for ERPNext v15 on Ubuntu 24.04.

---

## System Requirements

### Hardware
- **RAM**: 4GB minimum
- **Storage**: 40GB minimum

### Software
- Ubuntu 24.04 (updated)
- Python 3.11+
- Node.js 18
- MariaDB 10.3.x
- Redis Server
- pip 20+
- Yarn 1.12+

---

## Installation Steps

### 1. System Preparation

Update system packages:

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install build-essential dkms linux-headers-$(uname -r) -y
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
```

---

### 2. Create Frappe User

Create a dedicated user for Frappe Bench (recommended for security):

```bash
sudo adduser frappe
sudo usermod -aG sudo frappe
su - frappe
```

**Note**: All subsequent commands should be run as the `frappe` user.

---

### 3. Install Core Dependencies

#### Git
```bash
sudo apt-get install git -y
```

#### Python Environment
```bash
sudo apt-get install python3-dev python3-setuptools python3-pip -y
sudo apt install python3.12-venv -y
```

#### Redis
```bash
sudo apt-get install redis-server -y
```

#### Essential Tools
```bash
sudo apt install curl software-properties-common -y
```

---

### 4. Configure MariaDB

#### Install MariaDB
```bash
sudo apt install mariadb-server -y
```

#### Secure Installation
```bash
sudo mysql_secure_installation
```

**Configuration prompts:**
- Current password for root: *(Press Enter)*
- Switch to unix_socket authentication: **Y**
- Change root password: **Y** *(Set a strong password)*
- Remove anonymous users: **Y**
- Disallow root login remotely: **N**
- Remove test database: **Y**
- Reload privilege tables: **Y**

#### Configure Character Set
```bash
sudo nano /etc/mysql/my.cnf
```

Add at the end:

```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

Restart MariaDB:

```bash
sudo service mysql restart
```

---

### 5. Install Node.js and Package Managers

#### Node.js (via NVM)
```bash
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
nvm install 18
```

#### NPM and Yarn
```bash
sudo apt-get install npm -y
sudo npm install -g yarn
```

---

### 6. Install wkhtmltopdf

Required for PDF generation:

```bash
sudo apt-get install xvfb libfontconfig wkhtmltopdf -y
```

---

### 7. Install Frappe Bench

```bash
sudo -H pip3 install frappe-bench --break-system-packages
```

**Optional but recommended** (for production setup):
```bash
sudo -H pip3 install ansible --break-system-packages
```

---

### 8. Initialize Frappe Bench

```bash
bench init frappe-bench --frappe-branch version-15
cd frappe-bench
```

Set proper permissions:

```bash
chmod -R o+rx /home/frappe
```

---

### 9. Create Site

```bash
bench new-site [site-name]
```

**Note**: Replace `[site-name]` with your preferred site name (e.g., `mycompany.local` or `erp.example.com`). Save the Administrator password provided.

---

### 10. Install ERPNext

#### Get Required Apps
```bash
bench get-app payments
bench get-app --branch version-15 erpnext
```

#### Install Apps on Site
```bash
bench --site [site-name] install-app payments
bench --site [site-name] install-app erpnext
```

#### Optional: Install HRMS
```bash
bench get-app hrms
bench --site [site-name] install-app hrms
```

---

### 11. Start Development Server

#### Enable Developer Mode (Optional)

For development purposes, enable developer mode:

```bash
bench set-config -g developer_mode 1
```

#### Start the Server

```bash
bench start
```

#### Configure Git
```bash
# Set your Git username globally
git config --global user.name "[Your Name]"

# Set your Git email globally
git config --global user.email "[your.email@example.com]"

# Verify Git configuration
git config --list
```

**Note**: Replace `[Your Name]` and `[your.email@example.com]` with your actual name and email address.

Access ERPNext at: `http://your-server-ip:8000`

**Login Credentials:**
- Username: `Administrator`
- Password: *(Password set during site creation)*

---

## Production Setup

### 1. Enable Scheduler and Disable Maintenance Mode

```bash
bench --site [site-name] enable-scheduler
bench --site [site-name] set-maintenance-mode off
```

---

### 2. Configure Production Environment

#### Install Supervisor
```bash
sudo apt install supervisor -y
```

#### Setup Production
```bash
sudo bench setup production frappe
```

This command will:
- Configure NGINX as reverse proxy
- Set up Supervisor for process management
- Enable auto-start on server reboot

---

### 3. Setup NGINX

```bash
bench config dns_multitenant on
bench setup nginx
sudo service nginx reload
bench restart
```

---

### 4. Configure System Settings

#### Set Timezone
```bash
sudo timedatectl set-timezone Asia/Kolkata
```
*Adjust timezone as needed*

#### Add Site to Hosts
```bash
bench --site [site-name] add-to-hosts
```

---

### 5. Restart Services

```bash
sudo supervisorctl restart all
sudo service nginx reload
```

---

## Optional: SSL Configuration

For production environments, configure SSL using Let's Encrypt:

```bash
sudo bench setup lets-encrypt [site-name]
```

Follow the prompts to complete SSL setup.

---

## Crontab Configuration

Configure automated tasks using crontab for the frappe user:

```bash
EDITOR=nano crontab -e
```

Add the following entries (adjust paths and site names as needed):

```cron
# Auto-start bench on reboot
@reboot cd /home/frappe/frappe-bench && /usr/local/bin/bench start >> /home/frappe/frappe-bench/logs/bench_start.log 2>&1

# Daily backup at 2 AM
0 2 * * * cd /home/frappe/frappe-bench && /usr/local/bin/bench --site [site-name] backup --backup-path /home/frappe/backups >> /home/frappe/frappe-bench/logs/backup.log 2>&1

# Weekly database optimization at 3 AM on Sundays
0 3 * * 0 cd /home/frappe/frappe-bench && /usr/local/bin/bench --site [site-name] mariadb --execute "OPTIMIZE TABLE \`tabSingles\`;" >> /home/frappe/frappe-bench/logs/optimize.log 2>&1

# Clear cache daily at 4 AM
0 4 * * * cd /home/frappe/frappe-bench && /usr/local/bin/bench --site [site-name] clear-cache >> /home/frappe/frappe-bench/logs/cache.log 2>&1
```

**Create log directory:**
```bash
mkdir -p /home/frappe/frappe-bench/logs
mkdir -p /home/frappe/backups
```

**Note**: Replace `[site-name]` with your actual site name. Adjust timing and tasks according to your requirements.

---

## Useful Commands

### Bench Management
```bash
# Activate virtual environment
source env/bin/activate

# De-activate virtual environment
deactivate

# Create a new virtual environment manually (outside bench)
# python3: invokes Python 3 interpreter
# -m venv: runs the venv module to create a virtual environment
# myenv: directory name where the virtual environment will be created
python3 -m venv myenv

# Setup requirements for all apps
bench setup requirements

# Install requirements for specific app (manual method)
pip install -r apps/[app-name]/requirements.txt

# Upgrade pip
bench pip install --upgrade pip

# Upgrade frappe-bench
bench pip install --upgrade frappe-bench

# Update bench
bench update

# Backup site
bench --site [site-name] backup

# Restore backup
bench --site [site-name] restore /path/to/backup.sql

# Migrate site
bench --site [site-name] migrate

# Clear cache
bench --site [site-name] clear-cache

# Restart bench
bench restart

# Check bench status
bench --site [site-name] doctor
```

### App Management
```bash
# List installed apps
bench --site [site-name] list-apps

# Install custom app
bench get-app [app-name] [git-repo-url]
bench --site [site-name] install-app [app-name]

# Uninstall app
bench --site [site-name] uninstall-app [app-name]

# Update apps from git
cd apps/frappe
git pull
cd ../erpnext
git pull
cd ../hrms
git pull
cd ../..

# Update Python dependencies
bench setup requirements frappe erpnext hrms

# Build and compile assets
bench build --app frappe,erpnext,hrms

# Migrate database (applies schema changes)
bench --site [site-name] migrate

# Restart all bench processes
bench restart

# Clear all caches
bench --site [site-name] clear-cache
bench --site [site-name] clear-website-cache

# Alternative one-liner approach for updating apps
cd apps/frappe && git pull && cd ../.. && cd apps/erpnext && git pull && cd ../.. && cd apps/hrms && git pull && cd ../.. && bench setup requirements && bench build && bench --site [site-name] migrate && bench restart && bench --site [site-name] clear-cache && bench --site [site-name] clear-website-cache
```

### Logs
```bash
# View bench logs
bench --site [site-name] console

# View supervisor logs
sudo tail -f /var/log/supervisor/supervisord.log

# View NGINX error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Troubleshooting

### Port 8000 Already in Use
```bash
bench use [site-name]
bench start
```

### Permission Issues
```bash
sudo chown -R frappe:frappe /home/frappe/frappe-bench
chmod -R o+rx /home/frappe
```

### MariaDB Connection Issues
```bash
sudo service mysql restart
bench restart
```

### Build/Asset Issues
```bash
bench build
bench clear-cache
```

### Git Repository Issues

If you encounter Git repository corruption or need to reset a custom app:

```bash
# Go to apps directory
cd ~/frappe-bench/apps

# Verify remote repository URLs (shows fetch and push URLs for all configured remotes)
git remote -v

# Backup current folder
mv [app-name] [app-name]_backup

# Clone fresh from repository
git clone [git-repo-url]

# Enter credentials when prompted
cd [app-name]
```

---

## Post-Installation

1. **Change Administrator Password**: Login and update from User profile
2. **Setup Company**: Complete the Setup Wizard
3. **Configure Email**: Setup email account in Email Account doctype
4. **Enable Two-Factor Authentication**: For enhanced security
5. **Schedule Backups**: Configure automatic backups in System Settings

---

## Notes

- Always run commands as the `frappe` user unless `sudo` is specified
- Keep your system and ERPNext updated regularly using `bench update`
- Monitor logs regularly for any issues
- Schedule regular backups for data safety
- Use SSL certificate in production environments

---

## Database Maintenance

### bench trim-tables

#### Command Overview

`bench trim-tables` is a Frappe Framework command used to clean up orphaned database columns that remain after DocFields are removed from DocTypes.

#### Syntax

```bash
bench --site {site} trim-tables [OPTIONS]
```

#### Purpose

When you remove DocFields from a DocType in Frappe, the corresponding columns in the database tables are **not automatically deleted**. This is intentional design to prevent premature data loss. However, over time, these lingering columns can cause issues.

#### Why Use This Command

##### Problems Caused by Orphaned Columns

1. **Database bloat** - Unused columns take up unnecessary space
2. **Backup inefficiency** - Larger backup files and slower backup operations
3. **Row size limits** - You may encounter errors like "row size limit reached" when customizing DocTypes
4. **Query performance** - `SELECT *` queries retrieve unnecessary data
5. **Database clutter** - Hidden or redundant data makes maintenance difficult

##### Benefits of Regular Table Trimming

- **Smaller backup sizes** - Reduced storage requirements
- **Faster backup operations** - Less data to process
- **Reduced database usage** - Lower storage costs
- **Optimized queries** - Improved performance for `SELECT *` operations
- **Clean database schema** - No hidden or redundant data

#### Safety Features

##### Automatic Backup

By default, `bench trim-tables` creates a **full backup** of your entire database before making any schema modifications. This ensures you can restore your site to its original state if needed using the `bench restore` command.

⚠️ **WARNING**: This is a destructive operation. Always ensure you have a valid backup before proceeding.

#### Options

##### `--format`, `-f`

Sets the output format for the command results.

**Available values:**
- `JSON` - Machine-readable JSON format
- `TEXT` - Human-readable text format (default)

**Example:**
```bash
bench --site mysite.local trim-tables --format JSON
```

#### Flags

##### `--dry-run`

Performs a simulation without making actual changes to the database. Shows what would be deleted.

**Use case:** Always run with `--dry-run` first to preview changes before executing the actual operation.

**Example:**
```bash
bench --site mysite.local trim-tables --dry-run
```

##### `--no-backup`

Skips the automatic backup step before modifying tables.

⚠️ **NOT RECOMMENDED**: This flag is dangerous and should only be used if you have already created a manual backup and understand the risks.

**Example:**
```bash
bench --site mysite.local trim-tables --no-backup
```

#### Usage Examples

##### Example 1: Check for Orphaned Columns (Safe)

Before making any changes, check what columns would be removed:

```bash
bench --site mysite.local trim-tables --dry-run
```

**Output (TEXT format):**
```
Checking for orphaned columns...
Found 15 orphaned columns across 8 tables:
  - tabUser: old_field_1, old_field_2
  - tabCustomer: legacy_column
  - tabSales Order: removed_field
...
```

##### Example 2: Check with JSON Output

For programmatic processing or integration with scripts:

```bash
bench --site mysite.local trim-tables --dry-run --format JSON
```

**Output (JSON format):**
```json
{
  "orphaned_columns": [
    {
      "table": "tabUser",
      "columns": ["old_field_1", "old_field_2"]
    },
    {
      "table": "tabCustomer",
      "columns": ["legacy_column"]
    }
  ],
  "total_columns": 15,
  "total_tables": 8
}
```

##### Example 3: Execute Table Trimming (With Backup)

After reviewing the dry-run output and confirming the changes are safe:

```bash
bench --site mysite.local trim-tables
```

**Process:**
1. Creates full database backup
2. Identifies orphaned columns
3. Removes orphaned columns from tables
4. Reports completion

**Output:**
```
Creating backup before trimming tables...
Backup saved to: ~/frappe-bench/sites/mysite.local/private/backups/
Trimming tables...
Removed 15 orphaned columns from 8 tables
Operation completed successfully
```

##### Example 4: Execute Without Backup (Not Recommended)

Only use this if you have a recent manual backup:

```bash
bench --site mysite.local trim-tables --no-backup
```

#### Common Use Cases

##### Scenario 1: Row Size Limit Error

**Problem:** You get an error while customizing a DocType:
```
Error: MySQL row size limit (65,535 bytes) exceeded
```

**Solution:**
```bash
# Check for orphaned columns
bench --site mysite.local trim-tables --dry-run

# If you see many orphaned columns, remove them
bench --site mysite.local trim-tables
```

##### Scenario 2: Large Backup Files

**Problem:** Your database backups are taking too long and consuming too much space.

**Solution:**
```bash
# Identify space-wasting columns
bench --site mysite.local trim-tables --dry-run --format TEXT

# Clean up the database
bench --site mysite.local trim-tables
```

##### Scenario 3: After Major Customization Changes

**Problem:** You've made extensive DocType customizations and removed many fields.

**Solution:**
```bash
# Periodic maintenance after customizations
bench --site mysite.local trim-tables --dry-run
bench --site mysite.local trim-tables
```

#### Best Practices

##### 1. Always Start with Dry Run

```bash
# ALWAYS run this first
bench --site mysite.local trim-tables --dry-run
```

Review the output carefully to ensure no critical columns will be removed.

##### 2. Verify Current Backup

Before running the actual command, verify you have a recent backup:

```bash
# Check backup directory
ls -lh ~/frappe-bench/sites/mysite.local/private/backups/
```

##### 3. Run During Maintenance Window

Schedule this operation during off-peak hours or planned maintenance windows since it modifies the database schema.

##### 4. Test on Staging First

If you have a staging environment, run the command there first to identify any issues.

```bash
# On staging site
bench --site staging.local trim-tables --dry-run
bench --site staging.local trim-tables
```

##### 5. Regular Maintenance Schedule

Consider running this command periodically:
- After major version upgrades
- After extensive customizations
- Quarterly or semi-annually as part of database maintenance

#### Recovery Process

If something goes wrong after trimming tables, you can restore from the automatic backup:

```bash
# List available backups
ls ~/frappe-bench/sites/mysite.local/private/backups/

# Restore from backup
bench --site mysite.local restore /path/to/backup/database.sql.gz
```

For more details on restore, see the [`bench restore`](https://docs.frappe.io/framework/user/en/bench/reference/restore) documentation.

#### Related Commands

##### `bench trim-database`

Removes ghost tables (entire tables from deleted DocTypes) instead of just columns.

```bash
bench --site mysite.local trim-database --dry-run
```

**Key Difference:**
- `trim-tables` - Removes orphaned **columns** from existing tables
- `trim-database` - Removes entire orphaned **tables**

##### `bench backup`

Create a manual backup before trimming tables:

```bash
bench --site mysite.local backup
```

##### `bench restore`

Restore site from a backup after trimming:

```bash
bench --site mysite.local restore /path/to/backup.sql.gz
```

##### `bench transform-database`

Modify database table settings (engine, row_format):

```bash
bench --site mysite.local transform-database --help
```

#### Technical Details

##### What Gets Removed

The command identifies and removes columns that meet ALL of these criteria:

1. Column exists in the database table
2. No corresponding DocField exists in the DocType definition
3. Column is not a standard Frappe field (like `name`, `creation`, `modified`, etc.)

##### Database Schema Changes

The command executes `ALTER TABLE` statements to drop the identified columns:

```sql
ALTER TABLE `tabDocType` DROP COLUMN `old_field_name`;
```

##### Backup Location

Automatic backups are saved to:
```
~/frappe-bench/sites/{site}/private/backups/
```

Backup filename format:
```
{timestamp}-{site}-database.sql.gz
```

#### Troubleshooting

##### Issue: Command Takes Too Long

**Cause:** Large tables with many rows take time to alter.

**Solution:**
- Run during off-peak hours
- Consider running on individual tables if needed
- Check database server performance

##### Issue: "Table is locked" Error

**Cause:** Another process is using the table.

**Solution:**
- Stop all bench processes: `bench restart`
- Ensure no active user sessions
- Retry the operation

##### Issue: Backup Fails

**Cause:** Insufficient disk space or permissions.

**Solution:**
```bash
# Check disk space
df -h

# Check permissions
ls -la ~/frappe-bench/sites/{site}/private/backups/

# Manually create backup first
bench --site mysite.local backup
```

##### Issue: Cannot Find Orphaned Columns

**Cause:** Database schema is already clean or sync issue.

**Solution:**
```bash
# Run migrate to sync schema first
bench --site mysite.local migrate

# Then check for orphaned columns
bench --site mysite.local trim-tables --dry-run
```

#### Performance Considerations

##### Impact on Database

- **Small tables** (<10,000 rows): Minimal impact, completes in seconds
- **Medium tables** (10,000-1,000,000 rows): May take several minutes
- **Large tables** (>1,000,000 rows): Can take 10-30 minutes per table

##### Server Resources

- CPU usage increases during `ALTER TABLE` operations
- Database locks prevent concurrent writes to affected tables
- Disk I/O increases during backup creation

#### Security Considerations

1. **Backup encryption**: Use `--enable-backup-encryption` in site config
2. **Access control**: Only administrators should run this command
3. **Audit logging**: Operations are logged in Frappe's error log

#### Documentation Links

- **Official Documentation**: https://docs.frappe.io/framework/user/en/bench/reference/trim-tables
- **Frappe Commands**: https://docs.frappe.io/framework/user/en/bench/frappe-commands
- **Database Optimization**: https://docs.frappe.io/framework/user/en/database-optimization-hardware-and-configuration

#### Summary Checklist

Before running `bench trim-tables`:

- [ ] Run with `--dry-run` flag first
- [ ] Review the list of columns to be removed
- [ ] Verify recent backup exists
- [ ] Ensure no critical business processes are running
- [ ] Run during maintenance window if possible
- [ ] Test on staging environment first (if available)
- [ ] Have rollback plan ready
- [ ] Monitor disk space for backup creation

After running `bench trim-tables`:

- [ ] Verify application functionality
- [ ] Check database backup was created
- [ ] Monitor application logs for errors
- [ ] Document changes made
- [ ] Update any custom queries that might be affected

---

## Conclusion

Your ERPNext v15 instance is now ready for production use. The system will automatically start after server reboots, and you can access it via your domain name (if configured) or server IP address.

**Default Access URLs:**
- Development: `http://your-server-ip:8000`
- Production: `http://your-server-ip` or `http://your-domain.com`

**Security Reminder**: Change default passwords, enable firewall, and keep your system updated.
