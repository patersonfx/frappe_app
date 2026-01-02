# Deleting Large Database Tables Safely

A comprehensive guide for safely removing large tables in MySQL/MariaDB and Frappe Framework environments.

## Table of Contents

- [Overview](#overview)
- [Quick Reference](#quick-reference)
- [Pre-Deletion Checklist](#pre-deletion-checklist)
- [SQL-Based Methods (Recommended)](#sql-based-methods-recommended)
- [Frappe Framework Methods](#frappe-framework-methods)
- [Handling Locked Tables](#handling-locked-tables)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [Best Practices](#best-practices)
- [File System Approach (Emergency Only)](#file-system-approach-emergency-only)
- [Quick Command Reference](#quick-command-reference)

## Overview

Deleting large database tables requires careful consideration to avoid:

- Database corruption
- Application downtime
- Foreign key constraint violations
- Data loss
- Performance issues during deletion

**Golden Rule:** Always use SQL-based methods unless in emergency recovery scenarios.

## Quick Reference

### Standard MySQL/MariaDB Tables

```sql
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
DROP TABLE IF EXISTS `your_table_name`;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
```

### Frappe DocType Tables

```bash
bench --site your-site console
```

```python
frappe.delete_doc('DocType', 'YourDocType', force=1, ignore_permissions=True, delete_permanently=True)
frappe.db.commit()
```

### Very Large Tables (Optimize Performance)

```sql
-- Rename first (instant operation)
RENAME TABLE your_table_name TO your_table_name_old;

-- Drop in background session
DROP TABLE your_table_name_old;
```

## Pre-Deletion Checklist

Before deleting any table, ensure you complete these steps:

- [ ] **Backup completed and verified**
- [ ] **Checked table dependencies** (foreign keys)
- [ ] **Verified table size** and estimated deletion time
- [ ] **Confirmed off-peak hours** or scheduled maintenance window
- [ ] **Tested in development environment**
- [ ] **Notified team/users** if applicable
- [ ] **Prepared rollback plan**
- [ ] **Documented the reason** for deletion
- [ ] **Database credentials ready**
- [ ] **Monitoring tools in place**

## SQL-Based Methods (Recommended)

### Method 1: Standard DROP with Disabled Checks

**Best for:** Most scenarios, including tables with foreign keys

```sql
-- Disable constraint checks temporarily
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- Drop the table
DROP TABLE IF EXISTS `your_table_name`;

-- Re-enable checks
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
```

**Advantages:**
- Safe and maintains database integrity
- Handles foreign key constraints
- Faster execution
- Logs the operation

### Method 2: TRUNCATE Then DROP

**Best for:** Very large tables where you want to free space incrementally

```sql
-- First, remove all data
TRUNCATE TABLE your_table_name;

-- Then drop the structure
DROP TABLE your_table_name;
```

**Advantages:**
- TRUNCATE is faster than DELETE for large datasets
- Frees disk space before final drop
- Less lock time on DROP operation

### Method 3: Accessing MySQL/MariaDB

```bash
# Using root
sudo mysql -u root -p

# Using specific user and database
mysql -u username -ppassword database_name

# For Frappe sites (get credentials from site_config.json)
mysql -u [db_user] -p[db_password] [db_name]
```

### Method 4: Check Table Size Before Deletion

**Best practice:** Always check what you're deleting

```sql
-- View all tables with sizes
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    ROUND((data_length / 1024 / 1024), 2) AS 'Data (MB)',
    ROUND((index_length / 1024 / 1024), 2) AS 'Index (MB)',
    table_rows AS 'Rows'
FROM information_schema.TABLES
WHERE table_schema = 'your_database_name'
ORDER BY (data_length + index_length) DESC
LIMIT 20;

-- Then drop specific table
DROP TABLE IF EXISTS `table_name`;
```

## Frappe Framework Methods

### Method 1: Using Frappe Console (Recommended for DocTypes)

```bash
cd ~/frappe-bench
bench --site your-site-name console
```

**In Python console:**

```python
# Delete a DocType completely
frappe.delete_doc('DocType', 'YourDocType',
                  force=1,
                  ignore_permissions=True,
                  delete_permanently=True)
frappe.db.commit()
```

**This method automatically:**

- Removes DocType metadata
- Removes associated DocFields
- Drops the database table
- Cleans up permissions and customizations
- Updates schema cache

### Method 2: Direct SQL via Frappe Console

```python
# Check table sizes
tables = frappe.db.sql("""
    SELECT
        table_name,
        ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size_MB',
        table_rows AS 'Rows'
    FROM information_schema.TABLES
    WHERE table_schema = DATABASE()
    ORDER BY (data_length + index_length) DESC
    LIMIT 10
""", as_dict=1)

print(tables)

# Drop specific table
frappe.db.sql("SET FOREIGN_KEY_CHECKS = 0")
frappe.db.sql("DROP TABLE IF EXISTS `tabYourTableName`")
frappe.db.sql("SET FOREIGN_KEY_CHECKS = 1")
frappe.db.commit()
```

### Method 3: Using Bench Commands

```bash
# Migrate to remove DocType (if it's defined in app)
bench --site your-site migrate

# Clear cache after deletion
bench --site your-site clear-cache
bench --site your-site clear-website-cache

# Rebuild search index if needed
bench --site your-site build-search-index
```

### Method 4: Cleanup After Table Deletion

```python
# In Frappe console - clean up orphaned records
frappe.db.sql("""
    DELETE FROM `tabDocType`
    WHERE name = 'YourDocType'
""")

frappe.db.sql("""
    DELETE FROM `tabDocField`
    WHERE parent = 'YourDocType'
""")

frappe.db.sql("""
    DELETE FROM `tabCustom Field`
    WHERE dt = 'YourDocType'
""")

frappe.db.commit()

# Clear all caches
frappe.clear_cache()
```

## Handling Locked Tables

### Check for Locks

```sql
-- View current processes
SHOW PROCESSLIST;

-- View specific table locks
SHOW OPEN TABLES WHERE In_use > 0;

-- Check InnoDB status for deadlocks
SHOW ENGINE INNODB STATUS\G
```

### Kill Blocking Process

```sql
-- Identify process ID from SHOW PROCESSLIST
KILL <process_id>;

-- Then attempt drop again
DROP TABLE your_table_name;
```

### Alternative: Wait for Lock Timeout

```sql
-- Set longer timeout if needed
SET SESSION lock_wait_timeout = 300;

-- Then drop
DROP TABLE your_table_name;
```

## Common Issues and Solutions

### Issue 1: Foreign Key Constraints

**Error:**

```
ERROR 1217 (23000): Cannot delete or update a parent row: a foreign key constraint fails
```

**Solution:**

```sql
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE your_table_name;
SET FOREIGN_KEY_CHECKS = 1;
```

### Issue 2: Table is Locked

**Error:**

```
ERROR 1100 (HY000): Table 'your_table' was not locked with LOCK TABLES
```

**Solution:**

```sql
-- Check locks
SHOW OPEN TABLES WHERE In_use > 0;

-- Kill blocking process
SHOW PROCESSLIST;
KILL <process_id>;

-- Or restart MariaDB
sudo systemctl restart mariadb
```

### Issue 3: Disk Space Full During DROP

**Error:**

```
ERROR 3 (HY000): Error writing file (Errcode: 28 - No space left on device)
```

**Solution:**

```bash
# Check disk space
df -h

# Free up space or use TRUNCATE first
TRUNCATE TABLE your_table_name;
DROP TABLE your_table_name;
```

### Issue 4: Table Doesn't Exist but DocType Does (Frappe)

**Error in Frappe:**

```
pymysql.err.ProgrammingError: (1146, "Table 'database.tabYourDocType' doesn't exist")
```

**Solution:**

```python
# In Frappe console
frappe.db.sql("""
    DELETE FROM `tabDocType` WHERE name = 'YourDocType'
""")
frappe.db.sql("""
    DELETE FROM `tabDocField` WHERE parent = 'YourDocType'
""")
frappe.db.commit()
frappe.clear_cache()
```

### Issue 5: Very Large Table Takes Too Long

**Solution - Rename and Drop:**

```sql
-- Instant rename
RENAME TABLE huge_table TO huge_table_delete;

-- Application continues working

-- Drop in background (can take hours)
DROP TABLE huge_table_delete;
```

### Issue 6: InnoDB Buffer Pool Issues

**Error:**

```
ERROR 1205 (HY000): Lock wait timeout exceeded
```

**Solution:**

```sql
-- Increase timeout
SET SESSION innodb_lock_wait_timeout = 600;

-- Or restart MariaDB
sudo systemctl restart mariadb
```

## Best Practices

### 1. Always Backup First

```bash
# Full database backup
mysqldump -u root -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql

# Specific table backup
mysqldump -u root -p database_name table_name > table_backup_$(date +%Y%m%d).sql

# Frappe bench backup
bench --site your-site backup --with-files
```

### 2. Check Dependencies

```sql
-- Find foreign key relationships
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'your_table_name'
    AND TABLE_SCHEMA = 'your_database';
```

### 3. Verify Table Size and Row Count

```sql
SELECT
    table_name,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS 'Data_MB',
    ROUND(index_length / 1024 / 1024, 2) AS 'Index_MB',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Total_MB'
FROM information_schema.TABLES
WHERE table_schema = 'your_database'
    AND table_name = 'your_table';
```

### 4. Schedule During Off-Peak Hours

- Delete large tables during low-traffic periods
- Monitor server load during deletion
- Have rollback plan ready

### 5. Monitor the Process

```bash
# In another terminal, monitor MySQL
watch -n 2 'mysqladmin -u root -p processlist'

# Monitor disk space
watch -n 5 'df -h'

# Monitor MariaDB logs
tail -f /var/log/mysql/error.log
```

### 6. Clear Caches After Deletion (Frappe)

```bash
bench --site your-site clear-cache
bench --site your-site clear-website-cache
bench restart
```

### 7. Document Your Actions

```bash
# Keep a log of what you're doing
echo "$(date): Dropping table your_table_name" >> ~/db_operations.log
```

### 8. Test in Development First

- Always test the deletion process in dev/staging environment
- Verify application still works after table removal
- Check for any orphaned references

## File System Approach (Emergency Only)

### ⚠️ WARNING: Use Only in Absolute Emergency

**This approach should ONLY be used when:**

- Database won't start due to corrupted table
- Table is already broken beyond repair
- You have a recent backup to restore from
- All SQL methods have failed

### Risks of File System Deletion

1. **Database Corruption**
   - Internal metadata becomes inconsistent
   - Can corrupt other tables
   - InnoDB dictionary gets out of sync

2. **Foreign Key Violations**
   - Related tables break
   - Application errors cascade
   - Data integrity lost

3. **Frappe Framework Issues**
   - DocType metadata remains in database
   - Schema cache doesn't update
   - Application crashes with "Table doesn't exist" errors
   - Users see 500 errors

4. **No Rollback**
   - Permanent deletion
   - Cannot undo
   - Backups may not restore cleanly

### If You Must Use File System Method

```bash
# 1. TAKE FULL BACKUP FIRST
sudo mysqldump -u root -p --all-databases > /backup/full_backup_$(date +%Y%m%d).sql

# 2. Stop MariaDB
sudo systemctl stop mariadb

# 3. Navigate to data directory
sudo -i
cd /var/lib/mysql/your_database_name/

# 4. List files to verify
ls -lh | grep your_table_name

# 5. Remove table files
rm -f your_table_name.*

# 6. Start MariaDB
sudo systemctl start mariadb

# 7. Check status
sudo systemctl status mariadb

# 8. Verify database
mysql -u root -p
USE your_database_name;
SHOW TABLES;
```

### Understanding `ls -lh` Output

```bash
sudo ls -lh /var/lib/mysql/_2bce0719411d1b2e/
```

**Output example:**

```
-rw-rw---- 1 mysql mysql 1.2G Jan 02 09:00 tabYourTable.ibd
-rw-rw---- 1 mysql mysql  16K Jan 02 09:00 tabYourTable.frm
-rw-rw---- 1 mysql mysql 4.0K Jan 02 09:00 tabYourTable.cfg
```

**Column explanation:**

1. `-rw-rw----` - Permissions (file type and access rights)
2. `1` - Number of hard links
3. `mysql` - Owner
4. `mysql` - Group
5. `1.2G` - File size (human-readable with `-h` flag)
6. `Jan 02 09:00` - Last modification date/time
7. `tabYourTable.ibd` - Filename

**File types:**

- `.ibd` - InnoDB data file (contains actual table data)
- `.frm` - Table structure definition
- `.cfg` - InnoDB configuration metadata

### Handling Permission Denied Errors

```bash
# Wrong - will fail
cd /var/lib/mysql/_2bce0719411d1b2e/
# bash: cd: Permission denied

# Correct - use sudo
sudo ls -lh /var/lib/mysql/_2bce0719411d1b2e/

# Or switch to root
sudo -i
cd /var/lib/mysql/_2bce0719411d1b2e/
```

## Quick Command Reference

### Check Table Information

```sql
SHOW CREATE TABLE your_table_name;
SELECT COUNT(*) FROM your_table_name;
```

### Drop Table Safely

```sql
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `your_table_name`;
SET FOREIGN_KEY_CHECKS = 1;
```

### Frappe Console

```bash
bench --site site-name console
```

```python
frappe.delete_doc('DocType', 'Name', force=1, ignore_permissions=True)
frappe.db.commit()
```

### Check Disk Space

```bash
df -h
du -sh /var/lib/mysql/database_name/
```

### View MySQL Processes

```sql
SHOW PROCESSLIST;
SHOW OPEN TABLES WHERE In_use > 0;
```

## Key Takeaways

1. **Always use SQL-based methods** - They're safe and maintain database integrity
2. **Never use file system deletion** unless in absolute emergency with backups
3. **For Frappe DocTypes**, use `frappe.delete_doc()` to maintain application consistency
4. **Always backup** before any destructive operation
5. **Test in development** before production changes
6. **Monitor the process** to catch issues early

Remember: A few extra minutes of preparation can save hours of recovery work.

## Additional Resources

- [MySQL DROP TABLE Documentation](https://dev.mysql.com/doc/refman/8.0/en/drop-table.html)
- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [MariaDB Documentation](https://mariadb.com/kb/en/drop-table/)

---

**Last Updated:** January 2026
**Version:** 1.0
