# Bench Commands Reference Guide

A comprehensive guide to Bench commands for Frappe Framework and ERPNext development.

---

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [Site Management](#site-management)
3. [App Management](#app-management)
4. [Database Operations](#database-operations)
5. [Development Commands](#development-commands)
6. [Production & Deployment](#production--deployment)
7. [Maintenance & Troubleshooting](#maintenance--troubleshooting)
8. [Configuration & Settings](#configuration--settings)
9. [Backup & Restore](#backup--restore)
10. [Advanced Commands](#advanced-commands)

---

## Installation & Setup

### Initialize a new bench

```bash
bench init [bench-name]
```

**Explanation:** Creates a new bench directory with the Frappe framework installed.

**Options:**
- `--frappe-branch [branch]` - Specify Frappe branch (default: version-15)
- `--python [path]` - Specify Python executable path
- `--apps_path [path]` - Path to apps directory

**Example:**
```bash
bench init frappe-bench --frappe-branch version-15
```

---

## Site Management

### Create a new site

```bash
bench new-site [site-name]
```

**Explanation:** Creates a new site with its own database and site_config.json file.

**Options:**
- `--db-name [name]` - Specify database name
- `--db-password [password]` - Set database password
- `--admin-password [password]` - Set Administrator password
- `--mariadb-root-username [username]` - MariaDB root username
- `--mariadb-root-password [password]` - MariaDB root password
- `--install-app [app]` - Install app during site creation

**Example:**
```bash
bench new-site mysite.local --admin-password admin123 --install-app erpnext
```

### List all sites

```bash
bench --site [site-name] list-apps
```

**Explanation:** Lists all installed apps on a specific site.

**Example:**
```bash
bench --site mysite.local list-apps
```

### Use a specific site

```bash
bench use [site-name]
```

**Explanation:** Sets the default site for subsequent bench commands.

**Example:**
```bash
bench use mysite.local
```

### Drop/Delete a site

```bash
bench drop-site [site-name]
```

**Explanation:** Completely removes a site including its database.

**Options:**
- `--root-password [password]` - MariaDB root password
- `--force` - Skip confirmation prompt

**Example:**
```bash
bench drop-site old-site.local --force
```

### Archive a site

```bash
bench archive-site [site-name]
```

**Explanation:** Archives a site (moves it to archived_sites directory).

**Example:**
```bash
bench archive-site unused-site.local
```

### Restore archived site

```bash
bench restore-site [site-name]
```

**Explanation:** Restores a previously archived site.

---

## App Management

### Get a new app

```bash
bench get-app [app-name]
```

**Explanation:** Downloads and installs a Frappe app from a Git repository.

**Options:**
- `--branch [branch]` - Specify branch to pull
- `--skip-assets` - Skip building assets
- `[git-url]` - Direct Git repository URL

**Example:**
```bash
bench get-app erpnext --branch version-15
bench get-app https://github.com/username/custom-app.git
```

### Install app on site

```bash
bench --site [site-name] install-app [app-name]
```

**Explanation:** Installs an app on a specific site.

**Example:**
```bash
bench --site mysite.local install-app erpnext
```

### Uninstall app from site

```bash
bench --site [site-name] uninstall-app [app-name]
```

**Explanation:** Removes an app from a specific site.

**Options:**
- `--yes` - Skip confirmation
- `--dry-run` - Show what would be removed without actually removing

**Example:**
```bash
bench --site mysite.local uninstall-app custom_app
```

### Remove app from bench

```bash
bench remove-app [app-name]
```

**Explanation:** Completely removes an app from the bench (all sites).

**Example:**
```bash
bench remove-app unused_app
```

### Update apps

```bash
bench update
```

**Explanation:** Updates all apps and runs migrations, patches, and builds assets.

**Options:**
- `--pull` - Pull updates from remote
- `--patch` - Run patches
- `--build` - Build assets
- `--requirements` - Update Python dependencies
- `--restart-supervisor` - Restart supervisor processes
- `--no-backup` - Skip automatic backup

**Example:**
```bash
bench update --pull --patch --build
```

### Update specific app

```bash
bench update --app [app-name]
```

**Explanation:** Updates only a specific app.

**Example:**
```bash
bench update --app frappe
```

---

## Database Operations

### Run migrations

```bash
bench --site [site-name] migrate
```

**Explanation:** Runs database migrations and patches for all installed apps.

**Options:**
- `--skip-failing` - Skip failing patches
- `--skip-search-index` - Skip search index updates

**Example:**
```bash
bench --site mysite.local migrate
```

### Access MariaDB console

```bash
bench --site [site-name] mariadb
```

**Explanation:** Opens MariaDB console for the site's database.

**Example:**
```bash
bench --site mysite.local mariadb
```

### Execute SQL query

```bash
bench --site [site-name] mariadb --execute "[SQL Query]"
```

**Explanation:** Executes SQL query directly on site database.

**Example:**
```bash
bench --site mysite.local mariadb --execute "SELECT name FROM tabUser LIMIT 5;"
```

### Import SQL file

```bash
bench --site [site-name] mariadb < [file.sql]
```

**Explanation:** Imports SQL file into site database.

**Example:**
```bash
bench --site mysite.local mariadb < custom_data.sql
```

---

## Development Commands

### Start development server

```bash
bench start
```

**Explanation:** Starts all bench processes (web, socketio, worker, etc.) in development mode.

**Example:**
```bash
bench start
```

### Build assets

```bash
bench build
```

**Explanation:** Builds frontend assets (JS, CSS) for all apps.

**Options:**
- `--app [app-name]` - Build for specific app
- `--force` - Force rebuild all assets
- `--production` - Build for production

**Example:**
```bash
bench build --app custom_app
bench build --production
```

### Watch assets (auto-rebuild)

```bash
bench watch
```

**Explanation:** Watches for file changes and automatically rebuilds assets.

**Example:**
```bash
bench watch
```

### Clear cache

```bash
bench --site [site-name] clear-cache
```

**Explanation:** Clears Redis cache for the site.

**Example:**
```bash
bench --site mysite.local clear-cache
```

### Clear website cache

```bash
bench --site [site-name] clear-website-cache
```

**Explanation:** Clears only website route cache.

---

## Console Commands

### Open Python console

```bash
bench --site [site-name] console
```

**Explanation:** Opens an IPython console with Frappe context loaded.

**Example:**
```bash
bench --site mysite.local console
```

**Usage in console:**
```python
# Access frappe methods
frappe.get_all('User', fields=['name', 'email'])

# Get a document
doc = frappe.get_doc('User', 'Administrator')

# Execute database queries
frappe.db.sql("SELECT * FROM tabUser LIMIT 5", as_dict=True)
```

### Execute Python script

```bash
bench --site [site-name] execute [module.function]
```

**Explanation:** Executes a specific Python function in Frappe context.

**Example:**
```bash
bench --site mysite.local execute frappe.utils.scheduler.enqueue_all
```

### Run Python command

```bash
bench --site [site-name] run-tests --module [module]
```

**Explanation:** Runs unit tests for specified module.

**Example:**
```bash
bench --site mysite.local run-tests --module frappe.tests.test_db
```

---

## Production & Deployment

### Setup production

```bash
bench setup production [user]
```

**Explanation:** Sets up bench for production with Nginx and Supervisor.

**Example:**
```bash
sudo bench setup production frappe
```

### Restart bench

```bash
bench restart
```

**Explanation:** Restarts all bench processes in production.

**Example:**
```bash
bench restart
```

### Reload Nginx

```bash
bench setup nginx
sudo service nginx reload
```

**Explanation:** Regenerates Nginx config and reloads Nginx service.

---

## Maintenance & Troubleshooting

### Enable/Disable maintenance mode

```bash
bench --site [site-name] set-maintenance-mode on
bench --site [site-name] set-maintenance-mode off
```

**Explanation:** Enables or disables maintenance mode for a site.

**Example:**
```bash
bench --site mysite.local set-maintenance-mode on
```

### Check bench version

```bash
bench version
```

**Explanation:** Displays versions of all installed apps.

### Doctor (health check)

```bash
bench doctor
```

**Explanation:** Runs diagnostic checks on bench setup.

### Show bench config

```bash
bench config
```

**Explanation:** Displays current bench configuration.

---

## Configuration & Settings

### Set config value

```bash
bench --site [site-name] set-config [key] [value]
```

**Explanation:** Sets a configuration value in site_config.json.

**Example:**
```bash
bench --site mysite.local set-config developer_mode 1
bench --site mysite.local set-config mail_server "smtp.gmail.com"
```

### Enable/Disable developer mode

```bash
bench --site [site-name] set-config developer_mode 1
bench --site [site-name] set-config developer_mode 0
```

**Explanation:** Enables or disables developer mode.

### Add to hosts file

```bash
bench --site [site-name] add-to-hosts
```

**Explanation:** Adds site to system hosts file.

---

## Backup & Restore

### Backup site

```bash
bench --site [site-name] backup
```

**Explanation:** Creates a backup of database and files.

**Options:**
- `--with-files` - Include private and public files
- `--backup-path [path]` - Specify backup directory
- `--compress` - Compress backup files

**Example:**
```bash
bench --site mysite.local backup --with-files
```

### Restore backup

```bash
bench --site [site-name] restore [backup-file]
```

**Explanation:** Restores site from a backup file.

**Options:**
- `--with-public-files [file]` - Restore public files
- `--with-private-files [file]` - Restore private files
- `--mariadb-root-password [password]` - MariaDB root password

**Example:**
```bash
bench --site mysite.local restore ~/frappe-bench/sites/mysite.local/private/backups/20231215_140530-mysite_local-database.sql.gz
```

### List backups

```bash
bench --site [site-name] list-backups
```

**Explanation:** Lists all available backups for a site.

---

## Advanced Commands

### New app

```bash
bench new-app [app-name]
```

**Explanation:** Creates a new Frappe app with boilerplate code.

**Example:**
```bash
bench new-app custom_inventory
```

### Reinstall site

```bash
bench --site [site-name] reinstall
```

**Explanation:** Drops and recreates the site with fresh installation.

**Options:**
- `--yes` - Skip confirmation

**Example:**
```bash
bench --site mysite.local reinstall --yes
```

### Execute scheduled tasks

```bash
bench --site [site-name] trigger-scheduler-event [event]
```

**Explanation:** Manually triggers a specific scheduled event.

**Events:** `all`, `daily`, `weekly`, `monthly`, `hourly`, `cron`

**Example:**
```bash
bench --site mysite.local trigger-scheduler-event daily
```

### Rebuild search index

```bash
bench --site [site-name] build-search-index
```

**Explanation:** Rebuilds the search index for better search performance.

### Run scheduler

```bash
bench --site [site-name] scheduler enable
bench --site [site-name] scheduler disable
```

**Explanation:** Enables or disables the background scheduler.

### Add system user

```bash
bench setup user --user [username]
```

**Explanation:** Adds a system user and sets proper permissions.

### Switch branch

```bash
bench switch-to-branch [branch] [app1] [app2]...
```

**Explanation:** Switches specified apps to a different branch.

**Example:**
```bash
bench switch-to-branch version-15 frappe erpnext
```

### Bench commands with sudo

Some commands require sudo privileges:

```bash
sudo bench setup production [user]
sudo bench setup supervisor
sudo bench setup nginx
sudo supervisorctl restart all
```

---

## Common Command Combinations

### Complete site setup workflow

```bash
# Create new site
bench new-site mysite.local --admin-password admin

# Install apps
bench --site mysite.local install-app erpnext

# Set as default site
bench use mysite.local

# Enable developer mode
bench set-config developer_mode 1

# Start development server
bench start
```

### Production update workflow

```bash
# Backup before update
bench --site mysite.local backup --with-files

# Pull updates
bench update --pull

# Run migrations
bench --site mysite.local migrate

# Build assets
bench build --production

# Restart services
bench restart
```

### Debugging workflow

```bash
# Check bench status
bench doctor

# Clear all caches
bench --site mysite.local clear-cache
bench --site mysite.local clear-website-cache

# Check logs
tail -f ~/frappe-bench/logs/web.error.log
tail -f ~/frappe-bench/logs/worker.error.log

# Open console for debugging
bench --site mysite.local console
```

---

## Tips & Best Practices

1. **Always backup before major operations:**
   ```bash
   bench --site mysite.local backup --with-files
   ```

2. **Use `bench use` to set default site:**
   ```bash
   bench use mysite.local
   # Now you can omit --site flag
   bench migrate
   bench clear-cache
   ```

3. **Check logs for troubleshooting:**
   ```bash
   cd ~/frappe-bench/logs
   tail -f web.error.log
   ```

4. **Enable developer mode during development:**
   ```bash
   bench set-config developer_mode 1
   ```

5. **Use `bench watch` for frontend development:**
   ```bash
   bench watch
   ```

6. **Regular maintenance:**
   ```bash
   bench update
   bench --site all migrate
   bench build
   ```

---

## Environment Variables

Set these in `common_site_config.json` or `site_config.json`:

```json
{
  "developer_mode": 1,
  "db_name": "custom_db_name",
  "db_password": "strong_password",
  "redis_cache": "redis://localhost:13000",
  "redis_queue": "redis://localhost:11000",
  "mail_server": "smtp.gmail.com",
  "mail_port": 587,
  "use_ssl": 1,
  "mail_login": "your_email@gmail.com",
  "mail_password": "your_password"
}
```

---

## Quick Reference Table

| Command | Description |
|---------|-------------|
| `bench init` | Initialize new bench |
| `bench new-site` | Create new site |
| `bench get-app` | Download app |
| `bench install-app` | Install app on site |
| `bench start` | Start development server |
| `bench migrate` | Run migrations |
| `bench build` | Build assets |
| `bench update` | Update all apps |
| `bench console` | Open Python console |
| `bench backup` | Backup site |
| `bench restore` | Restore from backup |
| `bench restart` | Restart production |
| `bench clear-cache` | Clear Redis cache |

---

**Note:** Replace `[site-name]`, `[app-name]`, and other placeholders with actual values when executing commands.

For more information, visit: [Frappe Framework Documentation](https://frappeframework.com/docs)
