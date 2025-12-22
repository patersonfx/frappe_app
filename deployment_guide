# Frappe Compliance App - Deployment Guide

## Overview
This document outlines the complete deployment process for the **Frappe Bench & Compliance App** on {COMPANY_NAME} network infrastructure.

---

## Prerequisites Checklist

### Infrastructure Requirements
- **Server**: Ubuntu 24.04.x LTS VM
- **Hardware Specs**:
  - 16 GB RAM
  - 100 GB HDD
  - Intel(R) Xeon(R) Gold 6342 CPU @ 2.80GHz (2 Cores)
- **Network**: {COMPANY_NAME} network access
- **Database**: MariaDB (installed with Frappe)
- **Cache**: Redis (installed with Frappe)

### Access Requirements
- SSH access to Ubuntu VM
- Write access to GIT repository (GOCS deployed in {COMPANY_NAME} network)
- Domain configuration access (e.g., compliance.{COMPANY_DOMAIN})
- SSL certificate for HTTPS
- SMTP credentials for email notifications
- Microsoft Azure AD access for SSO setup
- Firewall configuration access

---

## Deployment Steps

### 1. Provision Ubuntu Linux VM in {COMPANY_NAME} Network
**Responsibility**: {COMPANY_NAME} IT

**Specifications**:
- OS: Ubuntu 22.04.5 LTS
- RAM: 16 GB
- Storage: 100 GB HDD
- CPU: Intel(R) Xeon(R) Gold 6342 @ 2.80GHz (2 Cores)

**Verification**:
```bash
# Check system info
lsb_release -a
free -h
df -h
lscpu
```

---

### 2. Provide SSN Access
**Responsibility**: {COMPANY_NAME} IT

Ensure SSH access is configured for authorized personnel.

**Verification**:
```bash
ssh username@server-ip
```

---

### 3. Setup GIT Repository and Provide Write Access
**Responsibility**: {COMPANY_NAME} IT

**Note**: GIT repository (GOCS) is deployed in {COMPANY_NAME} network

**Setup Git Configuration**:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@{COMPANY_DOMAIN}"

# Generate SSH key for Git access
ssh-keygen -t rsa -b 4096 -C "your.email@{COMPANY_DOMAIN}"
cat ~/.ssh/id_rsa.pub
# Add this public key to your Git repository settings
```

**Clone Repository**:
```bash
cd /home/frappe/frappe-bench/apps/
git clone git@your-git-server:namespace/compliance_app.git
```

---

### 4. Setup Sub-domain and Configure DNS Entry
**Responsibility**: {COMPANY_NAME} IT

**Example**: compliance.{COMPANY_DOMAIN}

**DNS Configuration**:
- Create A record pointing to VM IP address
- Configure reverse DNS if required
- Update TTL as per organization policy

**Verification**:
```bash
nslookup compliance.{COMPANY_DOMAIN}
ping compliance.{COMPANY_DOMAIN}
```

---

### 5. Arrange SSL Certificate for the Hostname
**Responsibility**: {COMPANY_NAME} IT

**Purpose**: Enable HTTPS for secure communication

**Implementation Options**:

#### Option A: Let's Encrypt (Free)
```bash
sudo apt-get install certbot python3-certbot-nginx -y
sudo certbot --nginx -d compliance.{COMPANY_DOMAIN}
```

#### Option B: Organization Certificate
```bash
# Copy certificate files to server
sudo mkdir -p /etc/ssl/compliance
sudo cp your-cert.crt /etc/ssl/compliance/
sudo cp your-cert.key /etc/ssl/compliance/
sudo chmod 600 /etc/ssl/compliance/your-cert.key
```

---

### 6. SMTP Credentials for Email Notifications
**Responsibility**: {COMPANY_NAME} IT

**Required Information**:
- SMTP Server: `smtp.{COMPANY_DOMAIN}` (or relevant server)
- SMTP Port: 587 (TLS) or 465 (SSL)
- Username: `notifications@{COMPANY_DOMAIN}`
- Password: `<secure-password>`
- From Email: `compliance@{COMPANY_DOMAIN}`

**Configuration in ERPNext**:
1. Go to: **Setup > Email > Email Account**
2. Create new Email Account
3. Enter SMTP details
4. Test email sending

---

### 7. Setup App Registration in Microsoft Azure AD
**Responsibility**: {COMPANY_NAME} IT

**Purpose**: Enable Single Sign-On (SSO) for the application

**Steps**:
1. Login to Azure Portal
2. Navigate to Azure Active Directory > App Registrations
3. Click "New Registration"
4. Configure:
   - Name: "{COMPANY_NAME} Compliance App"
   - Redirect URI: `https://compliance.{COMPANY_DOMAIN}/api/method/frappe.integrations.oauth2_logins.custom`
5. Note down:
   - **Client ID**: `<client-id>`
   - **Client Secret**: `<client-secret>`
   - **Tenant ID**: `<tenant-id>`

**ERPNext Social Login Configuration**:
```bash
bench --site compliance.{COMPANY_DOMAIN} set-config azure_client_id <client-id>
bench --site compliance.{COMPANY_DOMAIN} set-config azure_client_secret <client-secret>
bench --site compliance.{COMPANY_DOMAIN} set-config azure_tenant_id <tenant-id>
```

---

### 8. Setup Firewall Configuration
**Responsibility**: {COMPANY_NAME} IT

**Purpose**: Allow Ubuntu updates and Python package installations from within VM

**Required Ports & Access**:

**Outbound Rules**:
```bash
# HTTP/HTTPS for package downloads
80/tcp (HTTP)
443/tcp (HTTPS)

# DNS
53/tcp, 53/udp

# Ubuntu repositories
archive.ubuntu.com
security.ubuntu.com

# Python PyPI
pypi.org
files.pythonhosted.org
```

**Inbound Rules**:
```bash
# SSH
22/tcp (from specific IP ranges only)

# HTTP/HTTPS
80/tcp
443/tcp

# MariaDB (if external access needed)
3306/tcp (restrict to specific IPs)

# Redis (if external access needed)
6379/tcp (restrict to specific IPs)
```

**UFW Configuration**:
```bash
# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status verbose
```

---

### 9. Provide Access for Web Application Testing
**Responsibility**: {COMPANY_NAME} IT

**Access Methods**:

#### Option A: RDP/AnyDesk to Test PC (if VM is in Cloud/AWS)
- Not required if VM is accessible from anywhere

#### Option B: Direct Access (Preferred)
- VM accessible at: `https://compliance.{COMPANY_DOMAIN}`
- Testing accounts to be created by {VENDOR_NAME} IT

**Testing Checklist**:
- [ ] Application loads successfully
- [ ] SSL certificate valid
- [ ] Login functionality works
- [ ] Email notifications sent
- [ ] SSO authentication works
- [ ] Database connectivity verified
- [ ] File upload/download works

---

### 10. Install Frappe Bench & Compliance App
**Responsibility**: {VENDOR_NAME} IT

**Dependencies**:
Python, MariaDB, Redis installations are part of Frappe Bench installation

#### Step 10.1: Install Prerequisites
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Python and dependencies
sudo apt-get install -y python3-dev python3-pip python3-setuptools python3-venv

# Install build dependencies
sudo apt-get install -y git build-essential python3-setuptools python3-dev libffi-dev \
    libssl-dev redis-server libmysqlclient-dev curl

# Install Node.js (v18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Yarn
sudo npm install -g yarn

# Install wkhtmltopdf (for PDF generation)
sudo apt-get install -y xvfb libfontconfig wkhtmltopdf
```

#### Step 10.2: Install MariaDB
```bash
sudo apt-get install -y mariadb-server mariadb-client

# Secure MariaDB installation
sudo mysql_secure_installation

# Configure MariaDB for Frappe
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

**Add to MariaDB configuration**:
```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

**Restart MariaDB**:
```bash
sudo systemctl restart mariadb
sudo systemctl enable mariadb
```

#### Step 10.3: Install Frappe Bench
```bash
# Install bench CLI
sudo pip3 install frappe-bench

# Create bench user (optional but recommended)
sudo adduser frappe
sudo usermod -aG sudo frappe
su - frappe

# Initialize bench
cd /home/frappe
bench init frappe-bench --frappe-branch version-15

# Navigate to bench directory
cd frappe-bench
```

#### Step 10.4: Create New Site
```bash
# Create site
bench new-site compliance.{COMPANY_DOMAIN} \
    --db-name compliance_db \
    --mariadb-root-password <your-mysql-root-password> \
    --admin-password <strong-admin-password>

# Set site as current
bench use compliance.{COMPANY_DOMAIN}
```

#### Step 10.5: Install Compliance App
```bash
# Navigate to apps directory
cd /home/frappe/frappe-bench/apps/

# Clone the compliance app from your Git repository
git clone git@your-git-server:namespace/compliance_app.git

# Install app to site
cd /home/frappe/frappe-bench
bench --site compliance.{COMPANY_DOMAIN} install-app compliance_app

# Build assets
bench build --app compliance_app

# Migrate database
bench --site compliance.{COMPANY_DOMAIN} migrate

# Clear cache
bench --site compliance.{COMPANY_DOMAIN} clear-cache
```

#### Step 10.6: Setup Production
```bash
# Install nginx and supervisor
sudo apt-get install -y nginx supervisor

# Setup production configuration
sudo bench setup production frappe

# Enable and start services
sudo systemctl enable nginx
sudo systemctl enable supervisor
sudo systemctl restart nginx
sudo systemctl restart supervisor

# Setup SSL (if using Let's Encrypt)
sudo bench setup lets-encrypt compliance.{COMPANY_DOMAIN}

# Or setup custom SSL
sudo bench setup nginx --yes
```

#### Step 10.7: Configure Scheduler
```bash
# Enable scheduler
bench --site compliance.{COMPANY_DOMAIN} enable-scheduler

# Check scheduler status
bench --site compliance.{COMPANY_DOMAIN} doctor
```

---

### 11. Setup Roles & Permissions
**Responsibility**: {VENDOR_NAME} IT

**Create User Roles**:
1. Compliance Administrator
2. Compliance Manager
3. Compliance Officer
4. Department Head
5. Employee

**Permission Setup**:
```bash
# Access via GUI
https://compliance.{COMPANY_DOMAIN}

# Navigate to: Setup > Permissions > Role Permissions Manager
```

**Role Configuration**:
- Define DocType-level permissions
- Setup workflow states and transitions
- Configure email alerts per role
- Set up custom permission queries if needed

---

### 12. Prepare Master Data in Excel
**Responsibility**: {COMPANY_NAME} IT/HR/Compliance

**Master Data Tables**:
1. **Employees**
   - Employee ID
   - Full Name
   - Email
   - Department
   - Designation
   - Reporting Manager
   - Join Date

2. **Departments**
   - Department Code
   - Department Name
   - HOD

3. **Compliance Requirements**
   - Requirement Code
   - Requirement Name
   - Regulatory Body
   - Frequency
   - Applicable Departments

4. **User Roles Mapping**
   - Employee ID
   - Role(s)
   - Site Access

**Excel Template Format**:
- First row: Column headers (exact field names)
- No merged cells
- Date format: YYYY-MM-DD
- No empty rows between data
- Save as .xlsx or .csv

---

### 13. Upload Master Data
**Responsibility**: {VENDOR_NAME} IT

**Using Data Import Tool**:
```bash
# Via GUI
https://compliance.{COMPANY_DOMAIN}

# Steps:
1. Navigate to: Setup > Data > Data Import
2. Select DocType
3. Download template
4. Fill data in template
5. Upload file
6. Map columns
7. Validate and import
```

**Using Bench Command** (Alternative):
```bash
# Import from CSV
bench --site compliance.{COMPANY_DOMAIN} data-import \
    --doctype "Employee" \
    --file /path/to/employees.csv

bench --site compliance.{COMPANY_DOMAIN} data-import \
    --doctype "Department" \
    --file /path/to/departments.csv
```

**Verification**:
```sql
# Check imported records
bench --site compliance.{COMPANY_DOMAIN} mariadb

USE compliance_db;
SELECT COUNT(*) FROM `tabEmployee`;
SELECT COUNT(*) FROM `tabDepartment`;
```

---

### 14. Setup Talend Job to Sync Scripts Master
**Responsibility**: {VENDOR_NAME} IT

**Purpose**: Sync scripts master data from NSE/BSE

**Requirements**:
- Windows Server with minimum 8 GB RAM
- Talend Open Studio installed
- Windows Task Scheduler access

**Talend Job Configuration**:

1. **Create ETL Job**:
   - Source: NSE/BSE data feeds/APIs
   - Transformation: Data cleansing and mapping
   - Target: Frappe Compliance App (via API)

2. **API Integration**:
```python
# Frappe API endpoint for scripts master
POST https://compliance.{COMPANY_DOMAIN}/api/resource/Scripts Master

# Authentication
Headers:
  Authorization: token <api-key>:<api-secret>
  Content-Type: application/json

# Payload
{
  "data": {
    "script_code": "RELIANCE",
    "script_name": "Reliance Industries Ltd",
    "isin": "INE002A01018",
    "exchange": "NSE"
  }
}
```

3. **Schedule Job**:
```bash
# Windows Task Scheduler
- Frequency: Daily at 8:00 AM
- Trigger: After market close
- Action: Run Talend job .bat file
```

4. **Error Handling**:
   - Log failed records
   - Email notifications on job failure
   - Retry mechanism for API failures

---

### 15. Provide User Training for {COMPANY_NAME} Compliance
**Responsibility**: {VENDOR_NAME} IT

**Training Modules**:

#### Module 1: Application Overview (30 mins)
- Introduction to compliance app
- Key features and benefits
- Navigation and UI walkthrough

#### Module 2: User Roles & Responsibilities (45 mins)
- Understanding different roles
- Permission structure
- Workflow overview

#### Module 3: Daily Operations (1 hour)
- Creating compliance records
- Document uploads
- Email notifications
- Reporting and dashboards

#### Module 4: Advanced Features (45 mins)
- Custom reports
- Bulk operations
- Data export
- Integration with other systems

**Training Deliverables**:
- User manual (PDF)
- Video tutorials
- Quick reference guide
- FAQ document

**Training Schedule**:
- Batch size: 10-15 users
- Multiple sessions for different departments
- Hands-on practice environment
- Post-training assessment

---

## Post-Deployment Checklist

### Security
- [ ] SSL certificate installed and verified
- [ ] Firewall rules configured
- [ ] SSH access restricted to specific IPs
- [ ] Database access secured
- [ ] Regular backups scheduled
- [ ] SSO configured and tested

### Performance
- [ ] Application response time < 2 seconds
- [ ] Database queries optimized
- [ ] Redis cache working
- [ ] Static files served via nginx
- [ ] CDN configured (if applicable)

### Monitoring
- [ ] Server monitoring setup (CPU, RAM, Disk)
- [ ] Application logs configured
- [ ] Error tracking enabled
- [ ] Uptime monitoring active
- [ ] Email alerts configured

### Backup & Recovery
- [ ] Automated daily backups
- [ ] Backup retention policy defined
- [ ] Disaster recovery plan documented
- [ ] Restore procedure tested

---

## Troubleshooting

### Common Issues

#### Issue 1: Site not accessible
```bash
# Check nginx status
sudo systemctl status nginx

# Check bench processes
bench --site compliance.{COMPANY_DOMAIN} doctor

# Check supervisor
sudo supervisorctl status all
```

#### Issue 2: Email not sending
```bash
# Test SMTP configuration
bench --site compliance.{COMPANY_DOMAIN} send-test-email user@example.com

# Check email queue
bench --site compliance.{COMPANY_DOMAIN} run-background-jobs
```

#### Issue 3: Scheduler not running
```bash
# Enable scheduler
bench --site compliance.{COMPANY_DOMAIN} enable-scheduler

# Check scheduler events
bench --site compliance.{COMPANY_DOMAIN} scheduler status

# Restart scheduler
sudo supervisorctl restart all
```

#### Issue 4: Database connection errors
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Verify database connection
bench --site compliance.{COMPANY_DOMAIN} mariadb

# Check site_config.json
cat sites/compliance.{COMPANY_DOMAIN}/site_config.json
```

---

## Maintenance

### Daily Tasks
- Monitor system resources
- Check application logs
- Verify backup completion

### Weekly Tasks
- Review error logs
- Update master data
- Performance analysis

### Monthly Tasks
- Security patches
- Database optimization
- Capacity planning review

### Quarterly Tasks
- Full security audit
- Disaster recovery drill
- User access review

---

## Support Contacts

### {COMPANY_NAME} IT Team
- **Infrastructure**: it-infra@{COMPANY_DOMAIN}
- **Network**: network-team@{COMPANY_DOMAIN}
- **Security**: security@{COMPANY_DOMAIN}

### {VENDOR_NAME} IT Team
- **Application Support**: support@{VENDOR_DOMAIN}
- **Development**: dev-team@{VENDOR_DOMAIN}
- **Training**: training@{VENDOR_DOMAIN}

---

## Appendix

### A. Useful Commands

```bash
# Bench commands
bench --site <site-name> migrate
bench --site <site-name> clear-cache
bench --site <site-name> rebuild-global-search
bench --site <site-name> backup --with-files
bench update --patch
bench restart

# System commands
sudo systemctl restart nginx
sudo supervisorctl restart all
sudo systemctl restart mariadb

# Logs
bench --site <site-name> watch
tail -f /var/log/nginx/error.log
tail -f /home/frappe/frappe-bench/logs/worker.log
```

### B. API Reference

**Authentication**:
```bash
# Generate API keys
https://compliance.{COMPANY_DOMAIN}/app/user/<username>
# Go to API Access section
```

**Common Endpoints**:
```bash
# Get all records
GET https://compliance.{COMPANY_DOMAIN}/api/resource/{doctype}

# Get specific record
GET https://compliance.{COMPANY_DOMAIN}/api/resource/{doctype}/{name}

# Create record
POST https://compliance.{COMPANY_DOMAIN}/api/resource/{doctype}

# Update record
PUT https://compliance.{COMPANY_DOMAIN}/api/resource/{doctype}/{name}

# Delete record
DELETE https://compliance.{COMPANY_DOMAIN}/api/resource/{doctype}/{name}
```

### C. Database Schema
Available in app documentation at `/apps/compliance_app/docs/`

### D. Change Log
Maintained in Git repository

---

**Document Version**: 1.0
**Last Updated**: December 2024
**Prepared By**: {VENDOR_NAME} IT Team
**Reviewed By**: {COMPANY_NAME} IT Team
