# Linux User Management Documentation Suite

Complete documentation for Linux user management commands, specifically tailored for Frappe/ERPNext system administrators.

## 📚 Documentation Files

### 1. [Linux User Management Guide](./linux-user-management-guide.md)
**Comprehensive guide covering:**
- Basic user information commands (`w`, `who`, `whoami`)
- Understanding `/etc/passwd` file structure
- Filtering real user accounts using various methods
- Practical examples and use cases
- Frappe/ERPNext specific scenarios
- Security best practices
- Troubleshooting tips

**Best for:** In-depth understanding of user management concepts

---

### 2. [User Management Cheat Sheet](./user-management-cheat-sheet.md)
**Quick reference including:**
- Essential commands at a glance
- `/etc/passwd` field reference
- Common filter patterns
- One-liner solutions
- awk pattern matching guide
- Performance tips
- Common mistakes to avoid

**Best for:** Quick lookups and daily reference

---

### 3. [User Audit Script](./user-audit.sh)
**Automated audit script featuring:**
- System overview and statistics
- Root account verification
- Frappe user validation
- Real user account listing
- Currently logged-in users
- Shell distribution analysis
- Security recommendations
- Home directory validation

**Usage:**
```bash
chmod +x user-audit.sh
./user-audit.sh
```

**Best for:** Regular system audits and security checks

---

### 4. [Frappe User Management Examples](./frappe-user-management-examples.md)
**Real-world scenarios including:**
- Initial server setup checks
- Frappe user validation scripts
- Security audit procedures
- Troubleshooting login issues
- Automation scripts
- Multi-server management
- Export formats (CSV, JSON, HTML)

**Best for:** Practical implementation and automation

---

## 🚀 Quick Start

### For First-Time Users
1. Start with the **[Linux User Management Guide](./linux-user-management-guide.md)** for foundational knowledge
2. Keep the **[Cheat Sheet](./user-management-cheat-sheet.md)** handy for quick reference
3. Run the **[User Audit Script](./user-audit.sh)** to get a baseline of your system

### For Frappe/ERPNext Administrators
1. Run the user audit script: `./user-audit.sh`
2. Check Frappe-specific examples in **[Frappe User Management Examples](./frappe-user-management-examples.md)**
3. Implement automated audits from the examples document

### For Security Audits
1. Run: `./user-audit.sh > audit-report-$(date +%Y%m%d).txt`
2. Review security recommendations section
3. Check for unauthorized UID 0 accounts
4. Validate all user home directories exist

---

## 🎯 Common Tasks

### Task: Check if Frappe User Exists
```bash
grep "^frappe:" /etc/passwd && echo "Found" || echo "Not found"
```
📖 See: [Quick Start](#for-frappeerppnext-administrators)

### Task: List All Real Users
```bash
getent passwd | awk -F: '($3>=1000)&&($7!~/nologin/){print $1}'
```
📖 See: [User Management Cheat Sheet](./user-management-cheat-sheet.md)

### Task: Full System Audit
```bash
./user-audit.sh
```
📖 See: [User Audit Script](./user-audit.sh)

### Task: Troubleshoot Frappe Login
📖 See: [Troubleshooting Section](./frappe-user-management-examples.md#troubleshooting-user-issues)

---

## 📋 Command Reference Summary

| Command | Purpose | Example |
|---------|---------|---------|
| `w` | Show logged-in users | `w` |
| `who` | Simple logged-in list | `who` |
| `getent passwd` | Get all users (NSS) | `getent passwd frappe` |
| `grep "^user:" /etc/passwd` | Find specific user | `grep "^frappe:" /etc/passwd` |
| `awk -F: '...' /etc/passwd` | Filter users | `awk -F: '$3>=1000{print $1}' /etc/passwd` |
| `id username` | User details | `id frappe` |
| `groups username` | User groups | `groups frappe` |

---

## 🔒 Security Checklist

Use these commands to perform security checks:

- [ ] **Verify only root has UID 0**
  ```bash
  awk -F: '$3==0{print $1}' /etc/passwd
  ```
  Expected output: `root` only

- [ ] **Check users with login shells**
  ```bash
  awk -F: '$7!~/nologin|false/{print $1}' /etc/passwd
  ```
  Review the list for unauthorized accounts

- [ ] **Verify frappe user configuration**
  ```bash
  grep "^frappe:" /etc/passwd
  ```
  Verify UID >= 1000 and shell is `/bin/bash`

- [ ] **Check home directories exist**
  ```bash
  ./user-audit.sh | grep -A 5 "HOME DIRECTORY"
  ```
  All directories should exist

- [ ] **Review recent /etc/passwd changes**
  ```bash
  stat /etc/passwd
  ```
  Check modification date

---

## 🔧 File Structure

```
/etc/passwd format:
username:x:UID:GID:comment:home:shell
   1     2  3   4     5      6    7

Example:
frappe:x:1001:1001:Frappe User:/home/frappe:/bin/bash
```

### UID Ranges
- `0` - Root (superuser)
- `1-99` - System users (static)
- `100-999` - System users (dynamic)
- `1000+` - Real users

---

## 🤖 Automation

### Setup Daily Audit Cron Job
```bash
# 1. Copy audit script
sudo cp user-audit.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/user-audit.sh

# 2. Create log directory
sudo mkdir -p /var/log/user-audits

# 3. Add to crontab
sudo crontab -e

# Add this line (runs daily at 2 AM):
0 2 * * * /usr/local/bin/user-audit.sh > /var/log/user-audits/audit-$(date +\%Y\%m\%d).log 2>&1
```

### Setup Weekly Email Reports
```bash
# Add to crontab (runs Sunday at 6 AM)
0 6 * * 0 /usr/local/bin/user-audit.sh | mail -s "Weekly User Audit Report" admin@example.com
```

---

## 📊 Use Cases

### For ERPNext Deployment
- ✅ Verify frappe user is correctly configured
- ✅ Check bench directory permissions
- ✅ Validate user groups and sudo access
- ✅ Monitor login attempts

### For Security Compliance
- ✅ Regular user account audits
- ✅ Detect unauthorized accounts
- ✅ Verify password policies
- ✅ Track account modifications

### For Troubleshooting
- ✅ Debug login failures
- ✅ Check shell configurations
- ✅ Validate home directories
- ✅ Review account status

### For Multi-Server Management
- ✅ Compare user lists across servers
- ✅ Sync user configurations
- ✅ Centralized audit reporting
- ✅ Standardize user setup

---

## 🐛 Troubleshooting

### Issue: "Permission denied" when running audit script
**Solution:**
```bash
chmod +x user-audit.sh
./user-audit.sh
```

### Issue: Frappe user not found
**Check:**
```bash
# Verify user exists
getent passwd frappe

# Check all sources (local + LDAP/NIS)
id frappe

# Search in passwd file
grep frappe /etc/passwd
```

### Issue: Cannot read /etc/shadow
**Note:** `/etc/shadow` requires root privileges
```bash
sudo awk -F: '($2==""){print $1}' /etc/shadow
```

### Issue: Home directory missing
**Fix:**
```bash
# Check current home
awk -F: '$1=="frappe"{print $6}' /etc/passwd

# Create if missing
sudo mkdir -p /home/frappe
sudo chown frappe:frappe /home/frappe
sudo chmod 755 /home/frappe
```

---

## 📖 Additional Resources

### Related Commands
- `useradd` - Create new user
- `usermod` - Modify user
- `userdel` - Delete user
- `passwd` - Change password
- `chsh` - Change shell

### Important Files
- `/etc/passwd` - User accounts
- `/etc/shadow` - Passwords (requires root)
- `/etc/group` - Groups
- `/etc/sudoers` - Sudo configuration

### Man Pages
```bash
man passwd      # passwd file format
man 5 passwd    # detailed passwd documentation
man getent      # getent command
man awk         # awk programming
```

---

## 🎓 Learning Path

1. **Beginner**
   - Read: [Linux User Management Guide](./linux-user-management-guide.md) sections 1-3
   - Practice: Basic grep and awk commands
   - Run: `./user-audit.sh`

2. **Intermediate**
   - Study: [Cheat Sheet](./user-management-cheat-sheet.md) awk patterns
   - Practice: Creating custom filters
   - Implement: Automated audits

3. **Advanced**
   - Study: [Frappe Examples](./frappe-user-management-examples.md)
   - Create: Custom audit scripts
   - Implement: Multi-server management

---

## 📝 Notes

- Always use `getent passwd` instead of `cat /etc/passwd` for NSS compatibility
- Regular user UIDs typically start at 1000 (some systems use 500)
- Scripts should handle both `/bin/bash` and `/bin/sh` as valid shells
- The `frappe` user should have UID >= 1000 and shell `/bin/bash`
- Always test scripts in development before production use

---

## 🔄 Updates and Maintenance

This documentation is based on your bash history commands from December 2024. To keep it current:

1. Review scripts quarterly
2. Update for new Ubuntu/Debian releases
3. Add new use cases as they arise
4. Test all scripts after system updates

---

## 📞 Getting Help

- Check the specific guide for detailed explanations
- Review examples in the Frappe examples document
- Use `man` pages for command reference
- Test commands in a development environment first

---

## ⚠️ Important Warnings

- **NEVER** manually edit `/etc/passwd` unless absolutely necessary
- **ALWAYS** use `useradd`, `usermod`, `userdel` for user management
- **BACKUP** user files before making bulk changes
- **TEST** scripts in development before running on production
- **VERIFY** UID 0 accounts - only root should have UID 0

---

## 📌 Quick Links

- [Full Guide](./linux-user-management-guide.md) - Complete documentation
- [Cheat Sheet](./user-management-cheat-sheet.md) - Quick reference
- [Audit Script](./user-audit.sh) - Automated checks
- [Frappe Examples](./frappe-user-management-examples.md) - Real-world scenarios

---

**Last Updated:** December 2024  
**Version:** 1.0  
**For:** Frappe/ERPNext System Administrators

---

## 🌟 Best Practices Summary

1. ✅ Use `getent` instead of directly reading `/etc/passwd`
2. ✅ Regular automated audits via cron
3. ✅ Document all manual user changes
4. ✅ Keep audit logs for compliance
5. ✅ Test changes in development first
6. ✅ Verify frappe user after ERPNext installation
7. ✅ Monitor for unauthorized UID 0 accounts
8. ✅ Validate home directories exist and have correct permissions
9. ✅ Use version control for your audit scripts
10. ✅ Regular security reviews of user accounts

---

**Happy System Administrating! 🚀**
