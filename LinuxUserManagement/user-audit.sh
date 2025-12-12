#!/bin/bash

###############################################################################
# Linux User Audit Script
# Purpose: Comprehensive user account audit for system administration
# Useful for: ERPNext/Frappe server management and security audits
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Main execution
clear
echo -e "${GREEN}Linux User Account Audit Report${NC}"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname: $(hostname)"
echo ""

# 1. System Overview
print_header "SYSTEM OVERVIEW"
TOTAL_USERS=$(wc -l < /etc/passwd)
REAL_USERS=$(awk -F: '($3>=1000)&&($7!~/nologin/)&&($7!~/false/){count++} END{print count}' /etc/passwd)
SYSTEM_USERS=$(awk -F: '$3<1000{count++} END{print count}' /etc/passwd)
LOGIN_USERS=$(awk -F: '$7!~/nologin|false/{count++} END{print count}' /etc/passwd)

echo "Total user accounts: $TOTAL_USERS"
echo "Real user accounts (UID >= 1000): $REAL_USERS"
echo "System accounts (UID < 1000): $SYSTEM_USERS"
echo "Users with login shells: $LOGIN_USERS"

# 2. Root Account Check
print_header "ROOT ACCOUNT"
ROOT_INFO=$(grep "^root:" /etc/passwd)
if [ -n "$ROOT_INFO" ]; then
    print_success "Root account found"
    echo "$ROOT_INFO" | awk -F: '{printf "  UID: %s | Home: %s | Shell: %s\n", $3, $6, $7}'
else
    print_error "Root account NOT found (system error!)"
fi

# 3. Frappe User Check (for ERPNext deployments)
print_header "FRAPPE USER CHECK"
FRAPPE_USER="frappe"
if getent passwd "$FRAPPE_USER" > /dev/null 2>&1; then
    print_success "Frappe user exists"
    FRAPPE_INFO=$(getent passwd "$FRAPPE_USER")
    echo "$FRAPPE_INFO" | awk -F: '{printf "  Username: %s\n  UID: %s\n  GID: %s\n  Home: %s\n  Shell: %s\n", $1, $3, $4, $6, $7}'
    
    # Check home directory
    FRAPPE_HOME=$(echo "$FRAPPE_INFO" | cut -d: -f6)
    if [ -d "$FRAPPE_HOME" ]; then
        print_success "Home directory exists: $FRAPPE_HOME"
        ls -ld "$FRAPPE_HOME" | awk '{printf "  Permissions: %s | Owner: %s:%s\n", $1, $3, $4}'
    else
        print_error "Home directory missing: $FRAPPE_HOME"
    fi
    
    # Check shell
    FRAPPE_SHELL=$(echo "$FRAPPE_INFO" | cut -d: -f7)
    if [ "$FRAPPE_SHELL" == "/bin/bash" ]; then
        print_success "Shell is bash"
    else
        print_warning "Shell is $FRAPPE_SHELL (expected /bin/bash)"
    fi
else
    print_warning "Frappe user not found (skip if not running ERPNext)"
fi

# 4. Real User Accounts
print_header "REAL USER ACCOUNTS (UID >= 1000)"
REAL_USER_LIST=$(awk -F: '($3>=1000)&&($1!="nobody")&&($7!~/nologin/)&&($7!~/false/){print $0}' /etc/passwd)

if [ -z "$REAL_USER_LIST" ]; then
    print_warning "No real user accounts found"
else
    echo "$REAL_USER_LIST" | while IFS=: read username x uid gid comment home shell; do
        echo ""
        echo "User: $username"
        printf "  ├─ UID: %s\n" "$uid"
        printf "  ├─ GID: %s\n" "$gid"
        printf "  ├─ Home: %s " "$home"
        if [ -d "$home" ]; then
            echo -e "${GREEN}(exists)${NC}"
        else
            echo -e "${RED}(missing)${NC}"
        fi
        printf "  └─ Shell: %s\n" "$shell"
    done
fi

# 5. Users with Login Shells
print_header "USERS WITH LOGIN SHELLS"
awk -F: '$7!~/nologin|false/{printf "%-15s | UID: %-5s | Shell: %s\n", $1, $3, $7}' /etc/passwd

# 6. Currently Logged-In Users
print_header "CURRENTLY LOGGED-IN USERS"
if command -v w &> /dev/null; then
    LOGGED_IN=$(w -h | wc -l)
    if [ "$LOGGED_IN" -gt 0 ]; then
        print_success "$LOGGED_IN user(s) currently logged in"
        echo ""
        w
    else
        print_warning "No users currently logged in"
    fi
else
    echo "Command 'w' not available, using 'who'"
    who
fi

# 7. Shell Distribution
print_header "SHELL DISTRIBUTION"
echo "Real users by shell type:"
awk -F: '($3>=1000)&&($7!~/nologin|false/){shells[$7]++} END{for(s in shells) printf "  %s: %d\n", s, shells[s]}' /etc/passwd

# 8. Users Without Login Shells (System Accounts)
print_header "SYSTEM ACCOUNTS (No Login Shell)"
NOLOGIN_COUNT=$(awk -F: '$7~/nologin|false/{count++} END{print count}' /etc/passwd)
echo "Total system accounts with nologin/false: $NOLOGIN_COUNT"
echo ""
echo "Sample (first 10):"
awk -F: '$7~/nologin|false/{print "  " $1}' /etc/passwd | head -10
if [ "$NOLOGIN_COUNT" -gt 10 ]; then
    echo "  ... and $((NOLOGIN_COUNT - 10)) more"
fi

# 9. UID Analysis
print_header "UID DISTRIBUTION"
echo "Users by UID range:"
echo "  UID 0 (root): $(awk -F: '$3==0{count++} END{print count+0}' /etc/passwd)"
echo "  UID 1-99 (system - static): $(awk -F: '($3>=1)&&($3<=99){count++} END{print count+0}' /etc/passwd)"
echo "  UID 100-999 (system - dynamic): $(awk -F: '($3>=100)&&($3<=999){count++} END{print count+0}' /etc/passwd)"
echo "  UID 1000+ (real users): $(awk -F: '$3>=1000{count++} END{print count+0}' /etc/passwd)"

# 10. Home Directory Validation
print_header "HOME DIRECTORY VALIDATION"
MISSING_HOMES=0
echo "Checking home directories for real users..."
awk -F: '($3>=1000)&&($7!~/nologin|false/){print $1":"$6}' /etc/passwd | while IFS=: read username home; do
    if [ ! -d "$home" ]; then
        print_error "Missing: $username -> $home"
        ((MISSING_HOMES++))
    fi
done

if [ "$MISSING_HOMES" -eq 0 ]; then
    print_success "All home directories exist"
fi

# 11. Security Recommendations
print_header "SECURITY RECOMMENDATIONS"

# Check for users with UID 0 (besides root)
UID_ZERO_COUNT=$(awk -F: '($3==0)&&($1!="root"){count++} END{print count+0}' /etc/passwd)
if [ "$UID_ZERO_COUNT" -gt 0 ]; then
    print_error "Found $UID_ZERO_COUNT non-root user(s) with UID 0 (security risk!)"
    awk -F: '($3==0)&&($1!="root"){print "  - " $1}' /etc/passwd
else
    print_success "No unauthorized UID 0 accounts found"
fi

# Check last modification of passwd file
PASSWD_MTIME=$(stat -c %Y /etc/passwd)
CURRENT_TIME=$(date +%s)
DAYS_SINCE_CHANGE=$(( (CURRENT_TIME - PASSWD_MTIME) / 86400 ))
echo ""
echo "Last /etc/passwd modification: $DAYS_SINCE_CHANGE day(s) ago"
if [ "$DAYS_SINCE_CHANGE" -le 1 ]; then
    print_warning "Password file modified recently - review changes"
fi

# 12. Export Options
print_header "EXPORT DATA"
echo "To export user list to CSV:"
echo "  awk -F: '(\$3>=1000)&&(\$7!~/nologin/){print \$1\",\"\$3\",\"\$6\",\"\$7}' /etc/passwd > users.csv"
echo ""
echo "To export to JSON:"
echo "  awk -F: '(\$3>=1000)&&(\$7!~/nologin/){printf \"{\\\"username\\\":\\\"%s\\\",\\\"uid\\\":%s,\\\"home\\\":\\\"%s\\\",\\\"shell\\\":\\\"%s\\\"}\\n\", \$1,\$3,\$6,\$7}' /etc/passwd"

# 13. Summary
print_header "AUDIT SUMMARY"
echo "✓ Audit completed successfully"
echo "✓ Total accounts reviewed: $TOTAL_USERS"
echo "✓ Real user accounts: $REAL_USERS"
echo "✓ System accounts: $SYSTEM_USERS"
echo ""
echo "For detailed user information, run:"
echo "  getent passwd <username>"
echo "  id <username>"
echo ""
echo -e "${GREEN}End of Report${NC}"
echo ""
