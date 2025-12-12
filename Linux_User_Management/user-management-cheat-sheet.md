# Linux User Management - Quick Reference Cheat Sheet

## Essential Commands

### View Logged-In Users
```bash
w                    # Detailed: shows users, activity, load
who                  # Simple: just logged-in users
whoami               # Current user
id                   # Current user ID and groups
```

### List All Users
```bash
# All users
cut -d: -f1 /etc/passwd

# Real users only (UID >= 1000, with login shell)
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){print $1}'

# With details
awk -F: '($3>=1000)&&($7!~/nologin/){printf "%-15s UID:%-5s Shell:%s\n",$1,$3,$7}' /etc/passwd
```

### Find Specific User
```bash
grep "^frappe:" /etc/passwd
grep "^root:" /etc/passwd
getent passwd frappe
id frappe
```

### Filter Users by Shell
```bash
# Users with bash
awk -F: '$7=="/bin/bash"{print $1}' /etc/passwd

# Users with login shells
awk -F: '$7!~/nologin|false/{print $1}' /etc/passwd
```

### Count Users
```bash
# Total users
wc -l /etc/passwd

# Real users only
awk -F: '($3>=1000)&&($7!~/nologin/){count++} END{print count}' /etc/passwd
```

---

## /etc/passwd Field Reference

```
username:password:UID:GID:comment:home:shell
    1       2       3   4     5      6    7
```

**Access fields with awk:**
```bash
awk -F: '{print $1}' /etc/passwd    # Field 1: username
awk -F: '{print $3}' /etc/passwd    # Field 3: UID
awk -F: '{print $6}' /etc/passwd    # Field 6: home directory
awk -F: '{print $7}' /etc/passwd    # Field 7: shell
```

---

## Common Filters

### By UID
```bash
# System users (UID < 1000)
awk -F: '$3<1000{print $1}' /etc/passwd

# Regular users (UID >= 1000)
awk -F: '$3>=1000{print $1}' /etc/passwd

# Root only (UID = 0)
awk -F: '$3==0{print $1}' /etc/passwd
```

### By Shell
```bash
# Exclude nologin/false
awk -F: '$7!~/nologin|false/{print $1}' /etc/passwd

# Only bash users
awk -F: '$7=="/bin/bash"{print $1}' /etc/passwd

# Only nologin users (system accounts)
awk -F: '$7~/nologin/{print $1}' /etc/passwd
```

### Combined Filters
```bash
# Real users: UID >= 1000 AND login shell
awk -F: '($3>=1000)&&($7!~/nologin|false/){print $1}' /etc/passwd

# Exclude nobody
awk -F: '($3>=1000)&&($1!="nobody")&&($7!~/nologin/){print $1}' /etc/passwd
```

---

## Useful One-Liners

### List Users with Details
```bash
# Formatted output
awk -F: '($3>=1000)&&($7!~/nologin/){printf "User: %-15s | UID: %-5s | Home: %-25s | Shell: %s\n",$1,$3,$6,$7}' /etc/passwd

# CSV format
awk -F: '($3>=1000)&&($7!~/nologin/){print $1","$3","$6","$7}' /etc/passwd
```

### Check User Existence
```bash
# Single check
grep -q "^frappe:" /etc/passwd && echo "exists" || echo "not found"

# Multiple users
for user in frappe root ubuntu; do
    grep -q "^$user:" /etc/passwd && echo "$user: exists" || echo "$user: not found"
done
```

### Home Directory Check
```bash
# List users with their home directories
awk -F: '($3>=1000)&&($7!~/nologin/){print $1, $6}' /etc/passwd

# Check if home directories exist
awk -F: '($3>=1000)&&($7!~/nologin/){system("ls -ld "$6" 2>/dev/null || echo Missing: "$6)}' /etc/passwd
```

---

## Frappe/ERPNext Specific

### Check Frappe User Configuration
```bash
# Full frappe user info
grep "^frappe:" /etc/passwd

# Just shell
awk -F: '$1=="frappe"{print $7}' /etc/passwd

# Just home directory
awk -F: '$1=="frappe"{print $6}' /etc/passwd

# Just UID
awk -F: '$1=="frappe"{print $3}' /etc/passwd
```

### Verify ERPNext Setup
```bash
# Check frappe user exists
getent passwd frappe > /dev/null && echo "✓ Frappe user exists" || echo "✗ Frappe user missing"

# Check frappe home directory
ls -ld /home/frappe 2>/dev/null && echo "✓ Home directory exists" || echo "✗ Home directory missing"

# Check frappe shell
awk -F: '$1=="frappe"&&$7=="/bin/bash"{print "✓ Bash shell configured"}' /etc/passwd
```

---

## Security Checks

### Users with Login Access
```bash
# Count users who can login
awk -F: '$7!~/nologin|false/{count++} END{print count, "users can login"}' /etc/passwd

# List them
awk -F: '$7!~/nologin|false/{print $1}' /etc/passwd
```

### Root and Sudo Users
```bash
# Show root account
grep "^root:" /etc/passwd

# Check sudo group members (requires sudo)
getent group sudo | cut -d: -f4
```

### Recently Modified Accounts
```bash
# Check when /etc/passwd was last modified
stat -c "%y %n" /etc/passwd

# Check when /etc/shadow was last modified (requires root)
sudo stat -c "%y %n" /etc/shadow
```

---

## awk Pattern Matching Reference

### Operators
```bash
$3>=1000           # UID greater than or equal to 1000
$3<1000            # UID less than 1000
$3==0              # UID exactly 0
$1=="frappe"       # Username exactly "frappe"
$7!~/nologin/      # Shell doesn't contain "nologin"
$7=="/bin/bash"    # Shell exactly "/bin/bash"
```

### Logical Operators
```bash
&&                 # AND
||                 # OR
!                  # NOT

# Example: UID >= 1000 AND shell is NOT nologin
($3>=1000)&&($7!~/nologin/)
```

---

## Common Mistakes to Avoid

❌ **Wrong:**
```bash
cat /etc/passwd | grep frappe    # Unnecessary cat
```
✅ **Correct:**
```bash
grep "^frappe:" /etc/passwd      # Direct grep with anchor
```

❌ **Wrong:**
```bash
grep frappe /etc/passwd          # May match usernames containing 'frappe'
```
✅ **Correct:**
```bash
grep "^frappe:" /etc/passwd      # Anchored to start, exact match
```

❌ **Wrong:**
```bash
awk -F: '$3>1000' /etc/passwd    # Misses UID 1000
```
✅ **Correct:**
```bash
awk -F: '$3>=1000' /etc/passwd   # Includes UID 1000
```

---

## Performance Tips

### Use getent for Large Systems
```bash
# Better for LDAP/NIS environments
getent passwd | awk -F: '...'

# Instead of just
awk -F: '...' /etc/passwd
```

### Minimize Tool Chains
```bash
# Less efficient (multiple processes)
cat /etc/passwd | grep -v nologin | cut -d: -f1

# More efficient (single awk)
awk -F: '$7!~/nologin/{print $1}' /etc/passwd
```

---

## Quick Scripts

### User Audit Script
```bash
#!/bin/bash
echo "=== User Audit ==="
echo "Total users: $(wc -l < /etc/passwd)"
echo "Real users: $(awk -F: '($3>=1000)&&($7!~/nologin/){count++} END{print count}' /etc/passwd)"
echo "System users: $(awk -F: '$3<1000{count++} END{print count}' /etc/passwd)"
echo ""
echo "Users with login shells:"
awk -F: '$7!~/nologin|false/{print "  -", $1}' /etc/passwd
```

### Frappe User Check Script
```bash
#!/bin/bash
FRAPPE_USER="frappe"
echo "Checking $FRAPPE_USER user..."

if getent passwd "$FRAPPE_USER" > /dev/null; then
    echo "✓ User exists"
    USER_INFO=$(getent passwd "$FRAPPE_USER")
    echo "  UID: $(echo $USER_INFO | cut -d: -f3)"
    echo "  Home: $(echo $USER_INFO | cut -d: -f6)"
    echo "  Shell: $(echo $USER_INFO | cut -d: -f7)"
else
    echo "✗ User does not exist"
fi
```

---

## Reference Table

| Command | Purpose |
|---------|---------|
| `w` | Show logged-in users with activity |
| `who` | Show logged-in users (simple) |
| `whoami` | Show current username |
| `id [user]` | Show user/group IDs |
| `getent passwd` | Get all users (NSS-aware) |
| `grep "^user:" /etc/passwd` | Find specific user |
| `awk -F: '...' /etc/passwd` | Filter/parse users |

---

## Getting Help

```bash
man passwd              # /etc/passwd file format
man 5 passwd            # passwd file documentation
man getent              # getent command
man awk                 # awk command
info awk                # detailed awk info
```

---

**Last Updated:** December 2024  
**For:** Linux System Administration / Frappe ERPNext Deployments
