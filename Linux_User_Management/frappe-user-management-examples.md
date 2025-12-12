# Practical User Management Examples for Frappe/ERPNext

## Overview
Real-world examples and scripts for managing users on Frappe/ERPNext servers. These examples are based on common system administration tasks.

---

## Table of Contents
1. [Initial Server Setup Checks](#initial-server-setup-checks)
2. [Frappe User Validation](#frappe-user-validation)
3. [Security Audits](#security-audits)
4. [Troubleshooting User Issues](#troubleshooting-user-issues)
5. [Automation Scripts](#automation-scripts)
6. [Multi-Server Management](#multi-server-management)

---

## Initial Server Setup Checks

### Post-Installation Verification

After installing ERPNext, verify the frappe user is correctly configured:

```bash
#!/bin/bash
# frappe-setup-check.sh

echo "=== Frappe User Setup Verification ==="

# 1. Check if frappe user exists
if getent passwd frappe > /dev/null; then
    echo "✓ Frappe user exists"
else
    echo "✗ Frappe user does not exist"
    exit 1
fi

# 2. Get frappe user details
FRAPPE_INFO=$(getent passwd frappe)
FRAPPE_UID=$(echo "$FRAPPE_INFO" | cut -d: -f3)
FRAPPE_GID=$(echo "$FRAPPE_INFO" | cut -d: -f4)
FRAPPE_HOME=$(echo "$FRAPPE_INFO" | cut -d: -f6)
FRAPPE_SHELL=$(echo "$FRAPPE_INFO" | cut -d: -f7)

echo "  UID: $FRAPPE_UID"
echo "  GID: $FRAPPE_GID"
echo "  Home: $FRAPPE_HOME"
echo "  Shell: $FRAPPE_SHELL"

# 3. Verify UID is >= 1000 (real user, not system)
if [ "$FRAPPE_UID" -ge 1000 ]; then
    echo "✓ UID is valid for real user"
else
    echo "✗ Warning: UID < 1000 (system user range)"
fi

# 4. Verify shell is bash
if [ "$FRAPPE_SHELL" = "/bin/bash" ]; then
    echo "✓ Shell is bash"
else
    echo "✗ Shell is not bash: $FRAPPE_SHELL"
fi

# 5. Check home directory exists and permissions
if [ -d "$FRAPPE_HOME" ]; then
    echo "✓ Home directory exists"
    PERMS=$(stat -c %a "$FRAPPE_HOME")
    OWNER=$(stat -c %U "$FRAPPE_HOME")
    echo "  Permissions: $PERMS"
    echo "  Owner: $OWNER"
    
    if [ "$OWNER" = "frappe" ]; then
        echo "✓ Correct ownership"
    else
        echo "✗ Wrong owner (should be frappe)"
    fi
else
    echo "✗ Home directory does not exist: $FRAPPE_HOME"
fi

# 6. Check bench directory
BENCH_DIR="$FRAPPE_HOME/frappe-bench"
if [ -d "$BENCH_DIR" ]; then
    echo "✓ Bench directory exists: $BENCH_DIR"
else
    echo "⚠ Bench directory not found: $BENCH_DIR"
fi

echo ""
echo "Setup verification complete!"
```

### Run as:
```bash
chmod +x frappe-setup-check.sh
./frappe-setup-check.sh
```

---

## Frappe User Validation

### Quick Frappe User Check
```bash
# One-liner to check frappe user
grep "^frappe:" /etc/passwd && echo "Frappe user found" || echo "Frappe user not found"
```

### Detailed Frappe User Information
```bash
# Get all frappe user details
echo "=== Frappe User Details ==="
getent passwd frappe | awk -F: '
{
    print "Username:", $1
    print "UID:", $3
    print "GID:", $4
    print "Comment:", $5
    print "Home:", $6
    print "Shell:", $7
}'

# Check groups
echo ""
echo "=== Frappe User Groups ==="
groups frappe

# Check sudo access (requires sudo)
echo ""
echo "=== Sudo Privileges ==="
sudo -l -U frappe 2>/dev/null || echo "No sudo privileges or cannot check"
```

### Verify Frappe User in Specific Groups
```bash
#!/bin/bash
# Check if frappe user is in required groups

REQUIRED_GROUPS=("sudo" "frappe")

echo "Checking frappe user group membership..."
for group in "${REQUIRED_GROUPS[@]}"; do
    if groups frappe | grep -q "\b$group\b"; then
        echo "✓ frappe is in $group group"
    else
        echo "✗ frappe is NOT in $group group"
    fi
done
```

---

## Security Audits

### Find All Users Who Can Login
```bash
#!/bin/bash
# List all users with login capability

echo "=== Users with Login Access ==="
echo ""
echo "Username         UID   Shell"
echo "----------------------------------------"

awk -F: '($7!~/nologin/)&&($7!~/false/){
    printf "%-15s %-5s %s\n", $1, $3, $7
}' /etc/passwd

echo ""
echo "Total users with login access: $(awk -F: '($7!~/nologin/)&&($7!~/false/){count++} END{print count}' /etc/passwd)"
```

### Check for Suspicious UID 0 Accounts
```bash
#!/bin/bash
# Security check: Find all UID 0 accounts (should only be root)

echo "=== UID 0 Account Check ==="
UID_ZERO=$(awk -F: '$3==0{print $1}' /etc/passwd)

if [ "$UID_ZERO" = "root" ]; then
    echo "✓ Only root has UID 0 (secure)"
else
    echo "✗ WARNING: Multiple accounts with UID 0 found:"
    awk -F: '$3==0{print "  - " $1}' /etc/passwd
    echo ""
    echo "This is a SECURITY RISK!"
fi
```

### Audit User Account Changes
```bash
#!/bin/bash
# Check when user accounts were last modified

echo "=== User Account File Modification Times ==="
echo ""

for file in /etc/passwd /etc/shadow /etc/group; do
    if [ -r "$file" ]; then
        echo "$file:"
        stat "$file" | grep -E "Modify|Change"
        echo ""
    else
        echo "$file: Cannot read (requires root)"
        echo ""
    fi
done

# Calculate days since last passwd change
LAST_CHANGE=$(stat -c %Y /etc/passwd)
NOW=$(date +%s)
DAYS=$(( (NOW - LAST_CHANGE) / 86400 ))

echo "Days since /etc/passwd was modified: $DAYS"

if [ $DAYS -le 1 ]; then
    echo "⚠ Warning: Account changes within last 24 hours - review recommended"
elif [ $DAYS -le 7 ]; then
    echo "ℹ Recent changes within last week"
else
    echo "✓ No recent changes"
fi
```

### Find Users Without Passwords (requires root)
```bash
#!/bin/bash
# Check for accounts without passwords

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "=== Accounts Without Passwords ==="
awk -F: '($2==""){print $1}' /etc/shadow

NOPASS_COUNT=$(awk -F: '($2==""){count++} END{print count+0}' /etc/shadow)

if [ $NOPASS_COUNT -eq 0 ]; then
    echo "✓ No accounts without passwords found"
else
    echo "✗ Found $NOPASS_COUNT account(s) without passwords"
fi
```

---

## Troubleshooting User Issues

### Debug Frappe Login Issues
```bash
#!/bin/bash
# Troubleshoot frappe user login problems

USER="frappe"

echo "=== Troubleshooting $USER Login Issues ==="
echo ""

# 1. Check if user exists
echo "1. User Existence Check:"
if getent passwd "$USER" > /dev/null; then
    echo "   ✓ User exists"
else
    echo "   ✗ User does not exist"
    exit 1
fi

# 2. Check shell
echo ""
echo "2. Shell Check:"
SHELL=$(getent passwd "$USER" | cut -d: -f7)
echo "   Current shell: $SHELL"

if [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/bin/sh" ]; then
    echo "   ✓ Valid login shell"
else
    echo "   ✗ Invalid shell (nologin or false?)"
fi

# 3. Check home directory
echo ""
echo "3. Home Directory Check:"
HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
echo "   Home directory: $HOME_DIR"

if [ -d "$HOME_DIR" ]; then
    echo "   ✓ Home directory exists"
    ls -ld "$HOME_DIR"
else
    echo "   ✗ Home directory does not exist"
fi

# 4. Check account lock status (requires root)
echo ""
echo "4. Account Status:"
if [ "$(id -u)" -eq 0 ]; then
    passwd -S "$USER"
else
    echo "   (Run as root to check account lock status)"
fi

# 5. Check SSH access
echo ""
echo "5. SSH Configuration:"
if [ -f "$HOME_DIR/.ssh/authorized_keys" ]; then
    echo "   ✓ SSH keys present"
    wc -l "$HOME_DIR/.ssh/authorized_keys"
else
    echo "   ℹ No SSH authorized_keys file"
fi

# 6. Recent login attempts
echo ""
echo "6. Recent Login Attempts:"
if command -v last &> /dev/null; then
    last "$USER" | head -5
else
    echo "   'last' command not available"
fi

echo ""
echo "Troubleshooting complete!"
```

### Check User Permissions on Bench Directory
```bash
#!/bin/bash
# Verify frappe user has correct permissions on bench directory

FRAPPE_HOME="/home/frappe"
BENCH_DIR="$FRAPPE_HOME/frappe-bench"

echo "=== Bench Directory Permissions Check ==="

if [ ! -d "$BENCH_DIR" ]; then
    echo "✗ Bench directory not found: $BENCH_DIR"
    exit 1
fi

echo "Bench directory: $BENCH_DIR"
echo ""

# Check ownership
OWNER=$(stat -c %U "$BENCH_DIR")
GROUP=$(stat -c %G "$BENCH_DIR")
PERMS=$(stat -c %a "$BENCH_DIR")

echo "Owner: $OWNER"
echo "Group: $GROUP"
echo "Permissions: $PERMS"
echo ""

if [ "$OWNER" = "frappe" ]; then
    echo "✓ Correct owner"
else
    echo "✗ Wrong owner (should be frappe)"
fi

# Check key subdirectories
echo ""
echo "Key Subdirectories:"
for dir in apps sites logs config; do
    if [ -d "$BENCH_DIR/$dir" ]; then
        DIR_OWNER=$(stat -c %U "$BENCH_DIR/$dir")
        DIR_PERMS=$(stat -c %a "$BENCH_DIR/$dir")
        echo "  $dir: owner=$DIR_OWNER, perms=$DIR_PERMS"
    else
        echo "  $dir: NOT FOUND"
    fi
done
```

---

## Automation Scripts

### Daily User Audit Cron Job
```bash
#!/bin/bash
# daily-user-audit.sh
# Save to /usr/local/bin/ and add to cron

LOG_FILE="/var/log/user-audit.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

{
    echo "=== User Audit: $DATE ==="
    
    # Count users
    echo "Total users: $(wc -l < /etc/passwd)"
    echo "Real users: $(awk -F: '($3>=1000)&&($7!~/nologin/){count++} END{print count}' /etc/passwd)"
    
    # List users with login shells
    echo ""
    echo "Users with login access:"
    awk -F: '$7!~/nologin|false/{print "  - " $1}' /etc/passwd
    
    # Check frappe user
    echo ""
    if grep -q "^frappe:" /etc/passwd; then
        echo "✓ Frappe user exists"
    else
        echo "✗ WARNING: Frappe user not found!"
    fi
    
    # Check for UID 0 accounts
    echo ""
    UID_ZERO_COUNT=$(awk -F: '$3==0{count++} END{print count}' /etc/passwd)
    if [ "$UID_ZERO_COUNT" -eq 1 ]; then
        echo "✓ Only root has UID 0"
    else
        echo "✗ WARNING: Multiple UID 0 accounts!"
    fi
    
    echo "=== End of Audit ==="
    echo ""
    
} >> "$LOG_FILE"
```

**Add to cron:**
```bash
# Edit crontab
sudo crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * /usr/local/bin/daily-user-audit.sh
```

### User Comparison Script (Before/After Changes)
```bash
#!/bin/bash
# compare-users.sh
# Compare user lists before and after system changes

SNAPSHOT_DIR="/var/lib/user-snapshots"
mkdir -p "$SNAPSHOT_DIR"

SNAPSHOT_FILE="$SNAPSHOT_DIR/users-$(date +%Y%m%d-%H%M%S).txt"

# Take snapshot
awk -F: '{print $1":"$3":"$7}' /etc/passwd | sort > "$SNAPSHOT_FILE"

echo "Snapshot saved: $SNAPSHOT_FILE"
echo ""

# Compare with previous snapshot if exists
PREV_SNAPSHOT=$(ls -t "$SNAPSHOT_DIR"/users-*.txt 2>/dev/null | sed -n '2p')

if [ -n "$PREV_SNAPSHOT" ]; then
    echo "Comparing with previous snapshot: $(basename $PREV_SNAPSHOT)"
    echo ""
    
    echo "=== Added Users ==="
    comm -13 "$PREV_SNAPSHOT" "$SNAPSHOT_FILE"
    
    echo ""
    echo "=== Removed Users ==="
    comm -23 "$PREV_SNAPSHOT" "$SNAPSHOT_FILE"
    
    echo ""
    echo "=== Changed Users ==="
    comm -12 "$PREV_SNAPSHOT" "$SNAPSHOT_FILE" | while read line; do
        USER=$(echo "$line" | cut -d: -f1)
        PREV=$(grep "^$USER:" "$PREV_SNAPSHOT")
        CURR=$(grep "^$USER:" "$SNAPSHOT_FILE")
        
        if [ "$PREV" != "$CURR" ]; then
            echo "  $USER: $PREV => $CURR"
        fi
    done
else
    echo "No previous snapshot found. This is the first snapshot."
fi

# Keep only last 30 snapshots
ls -t "$SNAPSHOT_DIR"/users-*.txt | tail -n +31 | xargs -r rm
```

---

## Multi-Server Management

### Check Frappe User Across Multiple Servers
```bash
#!/bin/bash
# check-frappe-multi-server.sh

SERVERS=(
    "server1.example.com"
    "server2.example.com"
    "server3.example.com"
)

echo "=== Frappe User Check Across Servers ==="
echo ""

for server in "${SERVERS[@]}"; do
    echo "Server: $server"
    echo "----------------------------------------"
    
    # SSH and check frappe user
    ssh "$server" 'grep "^frappe:" /etc/passwd' 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Frappe user found"
    else
        echo "✗ Frappe user not found or connection failed"
    fi
    
    echo ""
done
```

### Sync User Lists from Remote Server
```bash
#!/bin/bash
# sync-user-list.sh
# Pull user list from remote server for comparison

REMOTE_SERVER="$1"

if [ -z "$REMOTE_SERVER" ]; then
    echo "Usage: $0 <remote-server>"
    exit 1
fi

echo "Fetching user list from $REMOTE_SERVER..."

ssh "$REMOTE_SERVER" "awk -F: '(\$3>=1000)&&(\$7!~/nologin/){print \$1}' /etc/passwd" > /tmp/remote-users.txt

echo "Local users:"
awk -F: '($3>=1000)&&($7!~/nologin/){print $1}' /etc/passwd | sort > /tmp/local-users.txt
cat /tmp/local-users.txt

echo ""
echo "Remote users:"
sort /tmp/remote-users.txt

echo ""
echo "=== Differences ==="
echo "Only on local:"
comm -23 /tmp/local-users.txt /tmp/remote-users.txt

echo ""
echo "Only on remote:"
comm -13 /tmp/local-users.txt /tmp/remote-users.txt

# Cleanup
rm /tmp/local-users.txt /tmp/remote-users.txt
```

---

## Export Formats

### Export to CSV
```bash
# Export real users to CSV
awk -F: '($3>=1000)&&($7!~/nologin/){
    print $1","$3","$4","$6","$7
}' /etc/passwd > users.csv

# With headers
echo "username,uid,gid,home,shell" > users.csv
awk -F: '($3>=1000)&&($7!~/nologin/){
    print $1","$3","$4","$6","$7
}' /etc/passwd >> users.csv
```

### Export to JSON
```bash
# Export real users to JSON array
echo "["
awk -F: '($3>=1000)&&($7!~/nologin/){
    printf "  {\"username\":\"%s\",\"uid\":%s,\"gid\":%s,\"home\":\"%s\",\"shell\":\"%s\"},\n", 
    $1, $3, $4, $6, $7
}' /etc/passwd | sed '$ s/,$//'
echo "]"
```

### Export to HTML Report
```bash
#!/bin/bash
# generate-user-report.html

cat > user-report.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>User Account Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .header { background-color: #333; color: white; padding: 10px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>User Account Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <h2>Real User Accounts</h2>
    <table>
        <tr>
            <th>Username</th>
            <th>UID</th>
            <th>Home Directory</th>
            <th>Shell</th>
        </tr>
EOF

awk -F: '($3>=1000)&&($7!~/nologin/){
    printf "        <tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", $1, $3, $6, $7
}' /etc/passwd >> user-report.html

cat >> user-report.html << 'EOF'
    </table>
</body>
</html>
EOF

echo "Report generated: user-report.html"
```

---

## Quick Commands Summary

```bash
# Check frappe user
grep "^frappe:" /etc/passwd

# List all real users
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/){print $1}'

# Count real users
awk -F: '($3>=1000)&&($7!~/nologin/){count++} END{print count}' /etc/passwd

# Find users with bash
awk -F: '$7=="/bin/bash"{print $1}' /etc/passwd

# Check user's groups
groups frappe

# Verify user home directory
awk -F: '$1=="frappe"{system("ls -ld "$6)}' /etc/passwd

# Check recent logins
last frappe | head

# User audit one-liner
awk -F: 'BEGIN{print "Username UID Shell"} ($3>=1000)&&($7!~/nologin/){printf "%-15s %-5s %s\n",$1,$3,$7}' /etc/passwd
```

---

**Best Practices:**
1. Always use `getent passwd` instead of directly reading `/etc/passwd` for NSS compatibility
2. Test scripts in development before running on production Frappe servers
3. Keep audit logs for compliance and troubleshooting
4. Automate regular user audits via cron
5. Document any manual user changes in your change log
6. Always verify user permissions after ERPNext installation or updates
