# Linux User Management Commands Guide

## Overview
This guide covers essential Linux commands for identifying and filtering user accounts on a system, particularly useful for system administrators managing ERPNext/Frappe deployments.

---

## Table of Contents
1. [Basic User Information Commands](#basic-user-information-commands)
2. [Understanding /etc/passwd](#understanding-etcpasswd)
3. [Filtering Real User Accounts](#filtering-real-user-accounts)
4. [Practical Examples](#practical-examples)
5. [Common Use Cases for Frappe/ERPNext](#common-use-cases-for-frappeerpnext)

---

## Basic User Information Commands

### Command: `w`
Shows currently logged-in users and their activity.

```bash
w
```

**Output includes:**
- Username
- Terminal
- Login time
- Idle time
- Current process

### Command: `who`
Displays currently logged-in users (simpler output than `w`).

```bash
who
```

---

## Understanding /etc/passwd

The `/etc/passwd` file contains user account information. Each line represents one user account.

### File Structure
```
username:x:UID:GID:comment:home_directory:shell
```

**Field Breakdown:**
1. **Username** - Login name
2. **Password** - `x` indicates password is in `/etc/shadow`
3. **UID** - User ID number
4. **GID** - Primary group ID
5. **Comment/GECOS** - User description (full name, etc.)
6. **Home Directory** - User's home directory path
7. **Shell** - Default shell for the user

### Example Entry
```
frappe:x:1001:1001:Frappe User:/home/frappe:/bin/bash
```

---

## Filtering Real User Accounts

### Method 1: Exclude Nologin and False Shells

**Basic Filtering:**
```bash
grep -v '/nologin\|/false' /etc/passwd | cut -d: -f1
```

**Explanation:**
- `grep -v` - Inverts match (excludes lines containing pattern)
- `/nologin\|/false` - Pattern to exclude system accounts
- `cut -d: -f1` - Extracts first field (username)

**Enhanced Output with Details:**
```bash
grep -v '/nologin\|/false' /etc/passwd | awk -F: '{print $1, "UID:"$3, "Shell:"$7}'
```

### Method 2: Filter by UID (Recommended)

**Filter Users with UID ≥ 1000:**
```bash
awk -F: '($3>=1000)&&($7!="/usr/sbin/nologin")&&($7!="/bin/false"){print $1}' /etc/passwd
```

**Explanation:**
- `-F:` - Set field separator to colon
- `$3>=1000` - UID greater than or equal to 1000 (real users)
- `$7!="/usr/sbin/nologin"` - Exclude nologin shell
- `$7!="/bin/false"` - Exclude false shell
- `print $1` - Print username

**Detailed User Information:**
```bash
awk -F: '($3>=1000)&&($7!="/usr/sbin/nologin")&&($7!="/bin/false"){print "User:", $1, "| UID:", $3, "| Home:", $6, "| Shell:", $7}' /etc/passwd
```

### Method 3: Using getent (Preferred for NSS databases)

**More robust approach using getent:**
```bash
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){print $1}'
```

**Advantages:**
- Works with LDAP, NIS, and other NSS sources
- Not limited to local `/etc/passwd` file
- Better for networked environments

### Method 4: Exclude Nobody User

**Filter out 'nobody' user:**
```bash
awk -F: '($3>=1000)&&($1!="nobody")&&($7!~/nologin/)&&($7!~/false/){print $1}' /etc/passwd
```

---

## Practical Examples

### Example 1: Find Specific User (frappe)
```bash
grep "^frappe:" /etc/passwd
```

**Output:**
```
frappe:x:1001:1001:Frappe User:/home/frappe:/bin/bash
```

### Example 2: Find Root User
```bash
grep "^root:" /etc/passwd
```

**Output:**
```
root:x:0:0:root:/root:/bin/bash
```

### Example 3: List All Real Users with Full Details
```bash
awk -F: '($3>=1000)&&($1!="nobody")&&($7!~/nologin/)&&($7!~/false/){
    printf "%-15s | UID: %-5s | Home: %-25s | Shell: %s\n", $1, $3, $6, $7
}' /etc/passwd
```

### Example 4: Count Real User Accounts
```bash
awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){count++} END{print count}' /etc/passwd
```

---

## Common Use Cases for Frappe/ERPNext

### 1. Verify Frappe User Exists
```bash
grep "^frappe:" /etc/passwd && echo "Frappe user exists" || echo "Frappe user not found"
```

### 2. Check User Shell for Frappe
```bash
awk -F: '$1=="frappe"{print "Shell:", $7}' /etc/passwd
```

### 3. List All Non-System Users for Security Audit
```bash
echo "=== Real User Accounts on System ==="
awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){
    printf "User: %-15s UID: %-5s Home: %s\n", $1, $3, $6
}' /etc/passwd
```

### 4. Find Users Who Can Login
```bash
awk -F: '($7=="/bin/bash")||($7=="/bin/sh"){print $1}' /etc/passwd
```

### 5. Create User Audit Report
```bash
#!/bin/bash
echo "User Account Audit Report - $(date)"
echo "=================================="
echo ""
echo "Root User:"
grep "^root:" /etc/passwd
echo ""
echo "Frappe User:"
grep "^frappe:" /etc/passwd
echo ""
echo "All Real Users (UID >= 1000):"
awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){
    printf "%-15s | UID: %-5s | Shell: %s\n", $1, $3, $7
}' /etc/passwd
```

---

## UID Ranges Explained

| UID Range | Description |
|-----------|-------------|
| 0 | Root user (superuser) |
| 1-99 | System users (statically allocated) |
| 100-999 | System users (dynamically allocated) |
| 1000+ | Regular users |

**Note:** On some distributions (like older Debian), regular users start at UID 500.

---

## Security Best Practices

### 1. Regular User Audits
```bash
# Weekly user audit
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/){print $1}' > /tmp/active_users.txt
```

### 2. Check for Users Without Password
```bash
awk -F: '($2==""){print "Warning: User", $1, "has no password!"}' /etc/shadow
```
*(Requires root privileges)*

### 3. Find Users with Bash Shell
```bash
awk -F: '($7=="/bin/bash"){print $1}' /etc/passwd
```

### 4. Monitor New User Creation
```bash
# Check recently modified /etc/passwd
ls -l /etc/passwd
stat /etc/passwd
```

---

## Troubleshooting Tips

### Issue: User Not Found
```bash
# Check with getent (searches all NSS sources)
getent passwd frappe

# Check /etc/passwd directly
grep frappe /etc/passwd

# Check if user exists in LDAP/AD
id frappe
```

### Issue: Cannot Login Despite User Existing
```bash
# Check shell
awk -F: '$1=="frappe"{print $7}' /etc/passwd

# Verify home directory exists
awk -F: '$1=="frappe"{print $6}' /etc/passwd | xargs ls -ld

# Check account status
passwd -S frappe  # Requires root
```

### Issue: Permission Denied
```bash
# Check current user
whoami

# Check user groups
groups frappe

# Verify sudo access
sudo -l -U frappe  # Requires root
```

---

## Quick Reference Commands

```bash
# List all real users
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/){print $1}'

# Find specific user
grep "^username:" /etc/passwd

# Count real users
awk -F: '($3>=1000)&&($7!~/nologin/){count++} END{print count}' /etc/passwd

# List users with bash shell
awk -F: '$7=="/bin/bash"{print $1}' /etc/passwd

# Show user details
id username
finger username  # If finger is installed
```

---

## Additional Resources

### Related Commands
- `useradd` - Create new user
- `usermod` - Modify user account
- `userdel` - Delete user account
- `passwd` - Change user password
- `chsh` - Change user shell
- `id` - Display user/group IDs
- `groups` - Display group memberships

### Important Files
- `/etc/passwd` - User account information
- `/etc/shadow` - Encrypted passwords
- `/etc/group` - Group information
- `/etc/gshadow` - Secure group information
- `/etc/login.defs` - Login configuration

---

## Conclusion

Understanding user management commands is essential for:
- System security audits
- User access management
- Troubleshooting login issues
- ERPNext/Frappe deployment management
- Compliance and documentation

Regular user audits help maintain system security and ensure only authorized users have access to your Frappe/ERPNext servers.
