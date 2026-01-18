# Compliance App - Complete Demo Guide

> **Enterprise-Grade Stock Broker Compliance Management System**
>
> Built for SEBI-compliant regulatory requirements including NISM certifications, employee investment declarations, trading permissions, and audit trail management.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Employee Onboarding - Welcome Email](#2-employee-onboarding---welcome-email)
3. [Demat Account Declaration](#3-demat-account-declaration)
4. [Trade Permission System](#4-trade-permission-system)
5. [NOTIS Integration - Auto Trade Ban](#5-notis-integration---auto-trade-ban)
6. [Investment Declaration](#6-investment-declaration)
7. [NISM Certificates & EUIN Tracking](#7-nism-certificates--euin-tracking)
8. [Automatic Certificate Verification](#8-automatic-certificate-verification)
9. [Reminder System](#9-reminder-system)
10. [Reminder Escalation](#10-reminder-escalation)
11. [Scheduled Tasks](#11-scheduled-tasks)
12. [Demo Script](#12-demo-script)
13. [Configuration Checklist](#13-configuration-checklist)

---

## 1. Overview

### What is the Compliance App?

The Compliance App is an enterprise-grade stock broker compliance management system designed for financial institutions to automate SEBI-compliant regulatory requirements.

### Key Features

| Feature | Description |
|---------|-------------|
| **Employee Onboarding** | Automated welcome emails with compliance policies |
| **Demat Account Declaration** | Track employee & dependent demat accounts |
| **Trade Permission** | Pre-trade approval with automated validation |
| **NOTIS Integration** | Real-time trade data from NSE with auto-ban |
| **Investment Declaration** | Periodic investment disclosure with workflow |
| **NISM Certificates** | PDF auto-extraction and expiry tracking |
| **EUIN Tracking** | Separate EUIN validity management |
| **Multi-Stage Reminders** | Escalating reminders with manager notification |
| **Audit Trail** | Complete logging of all compliance activities |

### Technical Details

| Attribute | Value |
|-----------|-------|
| **Version** | 0.0.1 (Alpha) |
| **Framework** | Frappe v14+ |
| **License** | MIT |
| **Author** | Sant Bharat Agarwal |

### Supported Issuers

- **NISM** - National Institute of Securities Markets
- **AMFI** - Association of Mutual Funds in India
- **APMI** - Association of Portfolio Managers in India
- **RERA** - Real Estate Regulatory Authority

---

## 2. Employee Onboarding - Welcome Email

### Overview

When a new employee is created in the system, an **automatic welcome email** is triggered containing compliance policies and portal access information.

### Trigger

```
Employee → after_insert → send_compliance_welcome_email()
```

### What's Included in Welcome Email

| Content | Description |
|---------|-------------|
| Login Credentials | Username/email for compliance portal |
| Office 365 SSO | Login instructions |
| Compliance Portal URL | Direct link to access |
| Investment Declaration | Requirements on joining |
| Trading Code of Conduct | Pre-clearance procedures |
| Family Member Definitions | Who is covered under compliance |
| Holding Period Rules | 180-day minimum holding requirement |
| F&O Trading Restrictions | Derivatives trading policies |

### Attachments Sent

- General company policy documents (configured in settings)
- Department-specific attachments (e.g., Research Analyst gets NISM-XV requirements)

### Configuration (Compliance Settings)

| Field | Purpose |
|-------|---------|
| `enable_welcome_email` | Master toggle |
| `send_welcome_email_on_employee_creation` | Auto-send on employee creation |
| `welcome_email_subject` | Email subject line |
| `welcome_attachments` | General policy documents |
| `enable_department_specific_emails` | Send extra email for specific departments |
| `department_email_subjects` | Custom subjects by department |
| `department_attachments` | Department-specific policy documents |

### Tracking

All welcome emails are logged in **Welcome Email Log** DocType with:
- Employee details
- Email type (Welcome/Department Specific)
- Status (Sent/Failed/Bounced)
- Timestamp

---

## 3. Demat Account Declaration

### Overview

Employees must declare **ALL demat accounts** - both their own AND their family members/dependents. This ensures complete transparency for trading compliance.

### Supported Relationships (20 Types)

| Category | Relationships |
|----------|---------------|
| **Self** | Self |
| **Spouse** | Spouse |
| **Parents** | Mother, Father, Mother-In-Law, Father-In-Law |
| **Children** | Son, Daughter |
| **Siblings** | Brother, Sister |
| **In-Laws** | Son-In-Law, Daughter-In-Law |
| **Extended** | Grandfather, Grandmother, Uncle, Aunt, Nephew, Niece, Cousin |
| **Other** | HUF (Hindu Undivided Family), Other |

### Demat Account Fields

| Field | Description |
|-------|-------------|
| `employee` | Link to employee (auto-filled) |
| `relationship` | Self, Spouse, Mother, etc. |
| `person_name` | Account holder name |
| `mobile_number` | 10-digit mobile (validated) |
| `demat_account_number` | Full DP ID + Client ID (16+ digits) |
| `dp_id` | Auto-extracted (first 8 chars) |
| `client_id` | Auto-extracted (chars 8-16) |
| `trading_account_number` | Optional |
| `broker_name` | Optional |
| `account_opening_date` | Optional |

### Supported Demat Formats

| Format | Example |
|--------|---------|
| **CDSL** | 16 digits (e.g., `1234567890123456`) |
| **NSDL** | IN + 14 digits (e.g., `IN12345678901234`) |

### Account Closure Workflow

```
Draft → Active → Pending Closure → Closed
                       ↓
               Closure Rejected → Pending Closure (resubmit)
```

| State | Action | By |
|-------|--------|-----|
| Draft | Submit | Employee |
| Active | Request Closure | Employee |
| Pending Closure | Approve/Reject | Compliance Officer |
| Closed | - | Final state |

### Closure Requirements

When requesting closure, employee must upload:
1. **Closure Document (CML Copy)** - PDF required
2. **Transaction-Cum-Holding Statement** - PDF required
3. **Closure Reason** - Text explanation

---

## 4. Trade Permission System

### Overview

After declaring Demat accounts, employees must get **pre-approval before trading** any securities. The system automatically validates against multiple rules and ban lists.

### Trade Permission Flow

```
Employee Request → Auto-Validation → Instant Approval/Rejection → Email Notification
```

### Key Fields

| Section | Field | Description |
|---------|-------|-------------|
| **Employee Info** | Employee | Auto-filled from logged-in user |
| **Transactions** | Scrip Name | Link to Corporate master |
| | ISIN Code | Auto-populated |
| | Transaction Type | Buy / Sell |
| | Quantity | Number of shares |
| | Approval Status | Pending → Approved/Rejected |
| | Rejection Reason | Auto-filled if rejected |

### Mandatory Compliance Confirmations

Employees must check these boxes before submitting:

| Checkbox | Confirmation |
|----------|-------------|
| ✓ | "I confirm I have no unpublished price sensitive information (UPSI) about the mentioned scrip" |
| ✓ | "I comply with the 180-day holding period for all market activities and transfers" |
| ✓ | "I will comply with all SEBI rules and regulations related to market activities" |
| ✓ (conditional) | "I confirm securities intended to sell were in my holdings before 1st April 2025" |

### Automatic Validation Engine

The system runs **5 types of checks** on each transaction:

| Check | Description | Result if Failed |
|-------|-------------|------------------|
| **Permanent Bans** | Initial Coverage, Merchant Banking, Others | ❌ "Permanently banned" |
| **Days-Based Bans** | 5/15/30 day restrictions | ❌ "Banned until DD-MM-YY" |
| **IPO Restrictions** | Listed today? Allotment check | ❌ "Restricted under Initial Coverage" |
| **Holding Period** | 180-day minimum holding | ❌ "No 180+ day holdings to sell" |
| **Buy-Back Rule** | Can't buy if sold recently | ❌ "Can't Buy - Sold in last X days" |

### Validation Scenarios

| Scenario | Expected Result |
|----------|-----------------|
| Stock in Ban List | ❌ Rejected - "Permanently banned" |
| IPO Listing Day | Special IPO rules apply |
| Sell more than holdings | ❌ Rejected - "Insufficient holdings" |
| Sell 100, only 60 available | ⚠️ "Partially Approved: 60, Rejected: 40" |
| Buy stock sold within 180 days | ❌ "Can't Buy - Sold in last X days" |

### Trading Ban List

| Field | Options |
|-------|---------|
| Scrip Name | Link to Corporate |
| Ban Type | Initial Coverage, Merchant Banking Mandate, 5 Days, 15 Days, 30 Days, Others, Permanent |
| Start Date | When ban begins |
| End Date | When ban ends (auto-removal for temporary bans) |
| Reason | Why stock is banned |

---

## 5. NOTIS Integration - Auto Trade Ban

### Overview

The **NOTIS (NSE Online Trading Information System)** integration automatically fetches real-time trade data from NSE and **auto-bans scrips** that have been traded during the day.

### Architecture

| Component | Location | Purpose |
|-----------|----------|---------|
| **Dealslip App** | `/apps/dealslip/` | Fetches trades from NSE NOTIS API |
| **Compliance App** | `/apps/compliance/` | Validates Trade Permissions against ban list |
| **Trading Ban List** | DocType | Stores all banned scrips (manual + auto) |

### NOTIS API Settings

| Field | Description |
|-------|-------------|
| `api_key` / `api_secret` | NSE NOTIS authentication |
| `broker_id` | Stock broker ID |
| `capital_market` | Enable CM trade fetching |
| `fo_market` | Enable F&O trade fetching |
| `pre_open_session` | 08:30:00 |
| `market_open_time` | 09:20:00 |
| `market_close_time` | 15:30:00 |
| `closing_session` | 16:00:00 |
| `market_open_frequency` | Polling interval (seconds) |
| `whitelisted_ip_addresses` | Allowed server IPs |

### Auto Trade Ban Flow

```
┌────────────────────────────────────────────────────────────────┐
│  NOTIS TRADE INQUIRY (runs continuously during market hours)   │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  1. Authenticate with NSE NOTIS API                           │
│     └─ POST https://www.connect2nse.com/token                 │
│                                                                │
│  2. Fetch Capital Market Trades                               │
│     └─ POST https://www.connect2nse.com/notis-cm/trades-inquiry│
│                                                                │
│  3. Fetch F&O Market Trades                                   │
│     └─ POST https://www.connect2nse.com/inquiry-fo-2/...      │
│                                                                │
│  4. Store trades in database                                  │
│     └─ tabNSE CM Trade / tabNSE FO Trade                      │
│                                                                │
│  5. AUTO-BAN SCRIPS                                           │
│     └─ insert_cm_daily_ban_data()                             │
│     └─ insert_fo_daily_ban_data()                             │
│     └─ Inserts into Trading Ban List with:                    │
│        - ban_type = 1 (Daily Ban)                             │
│        - start_date = TODAY                                   │
│        - end_date = TODAY                                     │
│        - is_ban = 1                                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Key Functions (dealslip/tasks.py)

| Function | Purpose |
|----------|---------|
| `nse_trade_inquiry()` | Main entry point - runs during market hours |
| `nse_cm_trade_inquiry()` | Fetch Capital Market trades |
| `nse_fo_trade_inquiry()` | Fetch F&O Market trades |
| `insert_cm_daily_ban_data()` | Auto-ban CM traded scrips |
| `insert_fo_daily_ban_data()` | Auto-ban F&O traded scrips |
| `get_daily_scrip_names()` | Get unique scrips traded today |

### Market Hours Validation

| Time | Status |
|------|--------|
| Before 09:20 | "Market Not Open" - form disabled |
| 09:20 - 15:30 | Market Open - can submit |
| After 15:30 | "Market Closed" - form disabled |

---

## 6. Investment Declaration

### Overview

Employees must periodically declare their **investments in securities** during each compliance period. This ensures transparency and helps identify potential conflicts of interest.

### Declaration Types

| Option | Description |
|--------|-------------|
| **No Investments Made** | Employee confirms no security transactions during the period |
| **Investments Made** | Employee uploads Transaction-Cum-Holding Statements for each demat account |

### Declaration Frequency (Configurable)

| Frequency | Periods |
|-----------|---------|
| **Quarterly** | Q1 (Apr-Jun), Q2 (Jul-Sep), Q3 (Oct-Dec), Q4 (Jan-Mar) |
| **Half-Yearly** | H1 (Apr-Sep), H2 (Oct-Mar) |
| **Annually** | Full Year (Apr-Mar) |

### Key Fields

| Section | Field | Description |
|---------|-------|-------------|
| **Period** | `from_date` | Period start date |
| | `to_date` | Period end date |
| | `extend_declaration_upto` | Extended deadline (if granted) |
| **Options** | `no_investments_made` | ✓ No investments in shares during period |
| | `investments_made` | ✓ Investments made - attach statements |

### Child Table (Investment Declaration Child)

| Field | Description |
|-------|-------------|
| `person_name` | Employee/Dependent name |
| `relationship` | Self, Spouse, etc. |
| `demat_account_number` | Demat account ID |
| `trn_cum_hold_statement` | **PDF attachment required** |
| `status` | Pending / Approved / Rejected |
| `reason_for_rejection` | If rejected, reason is mandatory |

### Workflow States

```
┌─────────┐     Submit      ┌──────────────┐     Approve     ┌──────────┐
│  Draft  │ ───────────────→│ Under Review │ ───────────────→│ Approved │
└─────────┘                 └──────────────┘                 └──────────┘
                                   │
                                   │ Reject
                                   ↓
                            ┌──────────┐     Resubmit    ┌──────────────┐
                            │ Rejected │ ───────────────→│ Under Review │
                            └──────────┘                 └──────────────┘
```

### Validation Rules

| Validation | Error Message |
|------------|---------------|
| Must select investment option | "Please select either 'No investments made' or 'Investments made'" |
| PDF only attachments | "Only PDF files are allowed in attachment" |
| No duplicate declarations | "An Investment Declaration already exists for this period" |
| Rejection reason required | "Please provide rejection reasons for: {names}" |
| Employee eligibility | Must have joined ON or BEFORE period end date |

### Undertaking (Employee Confirms)

1. ✓ Pre-clearance obtained for all transactions
2. ✓ Compliance with 180-day holding period
3. ✓ Securities purchased/sold only after pre-clearance
4. ✓ No trading in Commodity/Currency/Equity derivatives
5. ✓ No access to UPSI during transactions
6. ✓ No further dealings until information becomes public
7. ✓ Compliance with PIT Regulations 2015
8. ✓ Full and true disclosure

### Reminder System

| Setting | Default | Purpose |
|---------|---------|---------|
| Submission Deadline | 15 days | Days after period end to submit |
| Gentle Reminder Start | 7 days | Days after period end |
| Gentle Reminder Frequency | 1 day | How often to send |
| Final Reminder Start | 19 days | Days after period end (7+12) |
| Final Reminder Frequency | 1 day | How often to send |

### Reminder Types

| Type | When Sent | Tone |
|------|-----------|------|
| **Initial/First** | First day after period ends | Informative |
| **Gentle Reminder** | 7+ days after period | Friendly nudge |
| **Final Reminder** | 19+ days after period | Urgent warning |

### Deadline Extension

Compliance Officer can extend deadlines for specific employees:
1. Select employees needing extension
2. Set new deadline date
3. System sends **Extension Notification Email**
4. Declaration updated with new deadline

---

## 7. NISM Certificates & EUIN Tracking

### Overview

The system tracks **NISM (National Institute of Securities Markets) certifications** required for employees in the securities industry. It also manages **EUIN (Employee Unique Identification Number)** for mutual fund distributors.

### NISM Certificate Types

| Type | Description |
|------|-------------|
| **Certification Examination** | Initial NISM exam pass certificate |
| **Continuing Professional Education (CPE)** | Renewal/continuing education certificate |

### Supported NISM Modules

| Series | Description | EUIN Mapping |
|--------|-------------|--------------|
| NISM-Series-V-A | Mutual Fund Distributors | Mutual Fund EUIN |
| NISM-Series-VIII | Equity Derivatives | - |
| NISM-Series-XIII | SIF Distributors | SIF EUIN |
| NISM-Series-XV | Research Analyst | - |
| NISM-Series-XXI-A | PMS Distributors | PMS EUIN |

### NISM Certificate Fields

| Section | Field | Description |
|---------|-------|-------------|
| **Employee** | `employee` | Link to Employee (required) |
| | `employee_name` | Auto-fetched |
| | `department` | Auto-fetched |
| **Certificate** | `type` | Certification Examination / CPE |
| | `module_name` | NISM Series |
| | `name_as_per_certificate` | **Auto-extracted from PDF** |
| | `certificate_valid_till` | **Auto-extracted from PDF** |
| | `registration_no` | For Certification Exam type |
| | `enrolment_no` | For Certification Exam type |
| | `certification_no` | For CPE type (unique) |
| | `cpe_code` | For CPE type |
| **EUIN** | `euin` | Employee Unique Identification Number |
| | `euin_valid_till` | EUIN validity date |

### PDF Auto-Extraction

When employee uploads a certificate PDF, the system **automatically extracts**:

```
PDF UPLOAD
    ↓
PDF PROCESSOR (PyMuPDF/fitz)
• Extracts text from PDF
• Auto-unlocks password-protected PDFs (uses employee PAN)
    ↓
DATA EXTRACTOR (Regex Patterns)
• Employee name
• Module name (NISM-Series-XX)
• Certificate number
• Registration/Enrolment number
• Validity date
• CPE code (if CPE type)
• EUIN number (if present)
• EUIN validity date
• ARN number
    ↓
AUTO-POPULATE FIELDS
```

### EUIN Types

| EUIN Type | Linked NISM Module | ARN Source |
|-----------|-------------------|------------|
| **Mutual Fund Distributors EUIN** | NISM-Series-V-A | AMFI ARN |
| **SIF Distributors EUIN** | NISM-Series-XIII | AMFI ARN |
| **PMS Distributors EUIN** | NISM-Series-XXI-A | APMI APRN |

### NISM-EUIN Mapping

| Field | Description |
|-------|-------------|
| `nism_certificate` | Link to NISM module |
| `euin_certificate` | Link to corresponding EUIN type |
| `arn_number` | Expected ARN for validation |

### Workflow States

```
┌─────────┐     Submit      ┌──────────────┐     Approve     ┌──────────┐
│  Draft  │ ───────────────→│ Under Review │ ───────────────→│ Approved │
└─────────┘                 └──────────────┘                 └──────────┘
                                   │
                                   │ Reject
                                   ↓
                            ┌──────────┐     Resubmit    ┌──────────────┐
                            │ Rejected │ ───────────────→│ Under Review │
                            └──────────┘                 └──────────────┘
```

### Validation Rules

| Validation | Description |
|------------|-------------|
| **PDF Only** | Only PDF files allowed for upload |
| **Certificate Source** | Must be from cert.nism.ac.in |
| **Name Match** | Certificate name must match employee name |
| **Module Match** | Extracted module must match selected module |
| **Duplicate Check** | No duplicate certification_no, registration_no, etc. |
| **EUIN Type Match** | EUIN type must match NISM module mapping |
| **ARN Validation** | Extracted ARN must match expected ARN |

---

## 8. Automatic Certificate Verification

### Overview

The system **automatically verifies** NISM certificates after upload by extracting PDF data and comparing it against entered information.

### Verification Triggers

| Trigger | When |
|---------|------|
| **On Insert** | Immediately after certificate is uploaded |
| **Hourly Task** | Processes any pending certificates |

### Auto-Verification Flow

```
CERTIFICATE UPLOADED
        ↓
PDF EXTRACTION (PyMuPDF)
• Extract text
• Auto-unlock password-protected PDFs
        ↓
FIELD COMPARISON (compare_extracted_data)
• Employee name (normalized)
• Module name (with format variations)
• Certificate validity date
• Type-specific fields:
  - CPE: cpe_code, certification_no
  - EXAM: registration_no, enrolment_no
• Exam status (must be PASS)
        ↓
    ┌───┴───┐
    ↓       ↓
ALL MATCH   MISMATCH DETECTED
    ↓           ↓
✅ AUTO-    ❌ AUTO-
APPROVED    REJECTED
    ↓           ↓
• workflow_   • workflow_state
  state =       = "Rejected"
  "Approved"  • mismatches_found
• Approval      field populated
  email sent  • Rejection email
• Log entry     with details
  created     • Log entry created
```

### Conditions for Auto-APPROVAL ✅

| Condition | Validation Logic |
|-----------|------------------|
| **Employee Name Match** | Normalized comparison. Fallback: first AND last name match |
| **Module Name Match** | Case-insensitive, handles format variations |
| **Validity Date Match** | Converts to standard format, compares parsed dates |
| **CPE Type Fields** | CPE Code and Certification No. must match |
| **Exam Type Fields** | Registration No. and Enrolment No. must match |
| **Exam Status** | Must show "PASS" or "PASSED" in remarks |

### Conditions for Auto-REJECTION ❌

| Condition | Rejection Reason |
|-----------|------------------|
| **Name Mismatch** | "Employee name on certificate does not match system records" |
| **Module Mismatch** | "Module name extracted does not match selected module" |
| **Date Mismatch** | "Certificate validity date does not match extracted date" |
| **Number Mismatch** | "Registration/Enrolment/CPE number does not match" |
| **Exam Failed** | "Certificate shows non-PASS status" |
| **EUIN Type Mismatch** | "EUIN type does not match expected type for this module" |
| **ARN Mismatch** | "ARN on EUIN certificate does not match company ARN" |

### Name Matching Algorithm

```
1. NORMALIZE BOTH NAMES
   • Remove titles (Mr., Mrs., Dr., etc.)
   • Convert to titlecase
   • Strip extra whitespace

2. EXACT MATCH COMPARISON
   if normalized_cert_name == normalized_employee_name:
       return MATCH ✅

3. FALLBACK: FIRST + LAST NAME MATCH
   cert_parts = cert_name.split()
   emp_parts = employee_name.split()

   if cert_parts[0] in emp_parts AND cert_parts[-1] in emp_parts:
       return MATCH ✅

4. IF STILL NO MATCH
   return MISMATCH ❌

EXAMPLES:
• "JOHN SMITH" vs "John Smith" → ✅ MATCH
• "Mr. John Smith" vs "John Smith" → ✅ MATCH
• "John Kumar Smith" vs "John Smith" → ✅ MATCH
• "John Doe" vs "Jane Doe" → ❌ MISMATCH
```

---

## 9. Reminder System

### Overview

The system sends **multi-stage reminders** for expiring NISM certificates and EUIN, starting 60 days before expiry with escalating urgency.

### NISM Reminder Configuration

| Setting | Default | Purpose |
|---------|---------|---------|
| `certificate_expiry_threshold_days` | 60 days | When to start reminders |
| `enable_reminder_system` | Yes | Master toggle |
| `business_days_only` | Yes | Exclude weekends |

### Reminder Stages

| Field | Description |
|-------|-------------|
| `stage_name` | e.g., "60 Days Reminder", "Final Warning" |
| `stage_type` | GENTLE / STANDARD / URGENT / FINAL / ESCALATION |
| `min_days_before_expiry` | Start of reminder window |
| `max_days_before_expiry` | End of reminder window |
| `is_active` | Enable/disable this stage |
| `requires_escalation` | Send to reporting manager? |
| `include_employee` | Send to employee? |
| `include_head` | CC to department head? |
| `include_hr` | CC to HR? |
| `additional_recipients` | Extra email addresses |

### Example Reminder Schedule

| Stage | Days Before Expiry | Type | Recipients | Escalation |
|-------|-------------------|------|------------|------------|
| 1 | 60 days | GENTLE | Employee | No |
| 2 | 45 days | GENTLE | Employee | No |
| 3 | 30 days | STANDARD | Employee + Manager CC | No |
| 4 | 15 days | URGENT | Employee + Manager | Yes |
| 5 | 7 days | FINAL | Employee + Manager + HR | Yes |
| 6 | 0 days (expired) | ESCALATION | Manager + HR + Compliance | Yes |

### Urgency Color Coding

| Days Left | Color | Badge |
|-----------|-------|-------|
| ≤ 7 days | 🔴 Red `#d32f2f` | URGENT |
| 8-30 days | 🟠 Orange `#f57c00` | HIGH PRIORITY |
| > 30 days | 🟢 Green `#388e3c` | REMINDER |

### Duplicate Prevention

```
CHECK 1: Certificate Renewed?
  If certificate_valid_till > last_logged_expiry:
  → RENEWED, stop all reminders

CHECK 2: Already Sent Today?
  Query NISM Reminder Log for same certificate + stage + today
  If found: SKIP

CHECK 3: Stage Already Completed?
  Query NISM Reminder Log for same certificate + stage (ever)
  If found: SKIP (one reminder per stage)
```

### EUIN Reminder System

EUIN reminders track **TWO separate expiry dates**:

| Expiry Type | Tracking |
|-------------|----------|
| NISM Certificate Expiry | Tracked by NISM Reminder System |
| EUIN Expiry | Tracked by EUIN Reminder System (can be different date) |

---

## 10. Reminder Escalation

### Overview

The Reminder Escalation system ensures that expiring certificates don't go unnoticed by automatically escalating reminders to **managers, HR, and compliance officers**.

### Escalation Configuration (NISM Settings)

| Field | Default | Description |
|-------|---------|-------------|
| `enable_escalation` | No | Master toggle for escalation |
| `escalation_threshold_days` | 7 | Days after final reminder to escalate |
| `escalation_email_template` | - | Custom template for escalation emails |
| `escalation_hierarchy` | Table | Multi-level escalation configuration |

### Escalation Hierarchy

| Level | Recipient | Status |
|-------|-----------|--------|
| Level 1 | Reporting Manager | ✅ Fully Implemented |
| Level 2 | Department Head | 🔧 Infrastructure Exists |
| Level 3 | HR Department | 🔧 Infrastructure Exists |
| Level 4 | Compliance Officer | 🔧 Infrastructure Exists |

### Escalation Flow

```
CERTIFICATE EXPIRING
        ↓
MATCH REMINDER STAGE (by days_left)
        ↓
SEND EMPLOYEE REMINDER (if include_employee = 1)
        ↓
CHECK: requires_escalation OR include_head?
        ↓
    ┌───┴───┐
    ↓       ↓
requires_   include_head=1
escalation  requires_
=1          escalation=0
    ↓           ↓
FETCH       ADD MANAGER
MANAGER     TO CC
(reports_to)
    ↓
SEND SEPARATE ESCALATION EMAIL TO MANAGER
    ↓
CREATE REMINDER LOG
```

### Recipient Scenarios

| Scenario | include_employee | include_head | requires_escalation | What Happens |
|----------|-----------------|--------------|---------------------|--------------|
| **1** | ✓ | ✗ | ✗ | Employee receives direct email only |
| **2** | ✓ | ✓ | ✗ | Employee receives email, Manager in CC |
| **3** | ✓ | ✓ | ✓ | Employee receives email + Manager receives **separate escalation email** |
| **4** | ✓ | ✗ | ✓ | Employee receives email, escalation skipped (no manager configured) |

### Escalation Email Template

**Subject:**
```
Reminder: Certification Renewal Pending for Your Team Member - {employee_name}
```

**Content:**
```
Dear {Manager Name},

This is to bring to your attention that the NISM-Series-V-A certification
of John Smith is due to expire on 15-Mar-2026.

┌────────────────────────────────────────────┐
│  Employee Name    │  John Smith            │
│  Module           │  NISM-Series-V-A       │
│  Expiry Date      │  15-Mar-2026           │
│  Days Remaining   │  7                     │
└────────────────────────────────────────────┘

REQUEST YOUR INTERVENTION to ensure that John Smith completes the
renewal process at the earliest.

The employee can apply for recertification at:
https://certifications.nism.ac.in

Regards,
Compliance Team
```

### Complete Escalation Timeline

```
DAY -60: First Gentle Reminder
├─ Employee receives email
└─ Log entry created

DAY -45: Second Gentle Reminder
├─ Employee receives email
└─ Log entry created

DAY -30: Standard Reminder
├─ Employee receives email
├─ Manager CC'd on email
└─ Log entry created

DAY -15: Urgent Reminder + ESCALATION
├─ Employee receives email
├─ Manager receives SEPARATE escalation email
└─ Log entry created

DAY -7: Final Warning + ESCALATION
├─ Employee receives email (RED urgency)
├─ Manager receives escalation email
├─ HR CC'd (if configured)
└─ Log entry created

DAY 0: EXPIRED
├─ Employee receives expiry notice
├─ Manager receives escalation
├─ HR receives escalation
├─ Compliance Officer receives escalation
└─ Certificate marked for compliance action

═══════════════════════════════════════════

IF RENEWED AT ANY POINT:
└─ All reminders STOP automatically
```

---

## 11. Scheduled Tasks

### Cron Jobs (hooks.py)

| Time | Task | Function |
|------|------|----------|
| **Hourly** | Verify pending NISM certificates | `daily_verify_all_pending_nism_certificates()` |
| **Daily 5:00 AM** | Send NISM expiry reminders | `daily_nism_reminder_check()` |
| **Daily 5:30 AM** | Investment declaration reminders | `investment_declaration_reminder()` |
| **Daily 6:00 AM** | Remove expired trading bans | `auto_remove_expired_bans()` |
| **Jan 1, 12:30 AM** | Sync NSE holidays | `auto_sync_nse_holidays()` |

### Document Event Hooks

| DocType | Event | Action |
|---------|-------|--------|
| Employee | after_insert | Send compliance welcome email |
| NISM Certificates | on_update | Send rejection notifications |

---

## 12. Demo Script

### Complete Employee Compliance Journey

```
┌─────────────────────────────────────────────────────────────────┐
│  COMPLETE EMPLOYEE COMPLIANCE JOURNEY                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. ONBOARDING                                                  │
│     └─ Welcome Email with policies                              │
│                              ↓                                  │
│  2. DEMAT ACCOUNT DECLARATION                                   │
│     └─ Self + Dependents (20 relationship types)               │
│                              ↓                                  │
│  3. TRADE PERMISSION (with NOTIS)                               │
│     └─ Pre-approval with auto-ban integration                  │
│                              ↓                                  │
│  4. INVESTMENT DECLARATION                                      │
│     └─ Quarterly/periodic investment disclosure                │
│                              ↓                                  │
│  5. NISM CERTIFICATES & EUIN                                    │
│     └─ PDF auto-extraction                                     │
│     └─ EUIN tracking with ARN validation                       │
│     └─ Multi-stage expiry reminders                            │
│                              ↓                                  │
│  6. ONGOING COMPLIANCE                                          │
│     └─ Equity Holding Declaration                              │
│     └─ IPO Allotment Declaration                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Demo Script (20 minutes)

#### Part 1: Employee Onboarding (3 min)
1. Show **Compliance Settings** → Welcome email config
2. Create new **Employee**
3. Show auto-triggered welcome email
4. Check **Welcome Email Log**

#### Part 2: Demat Account Declaration (4 min)
1. Create **Demat Account** for Self
2. Create **Demat Account** for Spouse (dependent support)
3. Show DP ID/Client ID auto-extraction
4. Show closure workflow

#### Part 3: Trade Permission + NOTIS (5 min)
1. Show **NOTIS API Settings** - market timing, API config
2. Show **Trading Ban List** - filter today's auto-bans
3. Add a stock to ban list manually
4. Open **Trade Permission**:
   - Show market hours check
   - Add transactions
   - Show validation against ban list
   - Show instant approval/rejection
5. Show email notification

#### Part 4: Investment Declaration (3 min)
1. Create **Investment Declaration**
2. Show auto-populated demat accounts
3. Select "Investments Made"
4. Upload PDF statements
5. Submit → Show approval workflow
6. Show rejection with reason

#### Part 5: NISM Certificates (3 min)
1. Create **NISM Certificate**
2. Upload PDF → Show auto-extraction
3. Show name/module validation
4. Submit → Show auto-approval
5. Show EUIN upload with ARN validation

#### Part 6: Reminders & Escalation (2 min)
1. Show **NISM Settings** → Reminder stages
2. Show **NISM Reminder Log**
3. Show escalation email to manager

---

## 13. Configuration Checklist

### Pre-Demo Setup

- [ ] **Compliance Settings** configured:
  - [ ] Welcome email enabled with attachments
  - [ ] Company details filled (name, CIN, SEBI registration)
  - [ ] Compliance officer email set
  - [ ] `enable_approval_rejection_emails` = True

- [ ] **NISM Settings** configured:
  - [ ] System enabled
  - [ ] Reminder stages set up
  - [ ] NISM-EUIN mapping with ARN
  - [ ] Escalation enabled

- [ ] **NOTIS API Settings** configured:
  - [ ] API credentials
  - [ ] Market timing
  - [ ] Whitelisted IPs

- [ ] **Test Data** ready:
  - [ ] Sample employees created
  - [ ] Sample NISM certificate PDFs
  - [ ] At least one security in Trading Ban List
  - [ ] Corporate master with stock data

- [ ] **Email System** configured and working

---

## Key Talking Points

### For Management

1. **Regulatory Compliance:** "Built specifically for SEBI stock broker requirements"
2. **Automation:** "Reduces manual work through auto-extraction and validation"
3. **Audit Trail:** "Complete logging for regulatory audits"
4. **Escalation:** "Ensures nothing falls through the cracks"

### For Compliance Officers

1. **PDF Auto-Extraction:** "No manual data entry for certificates"
2. **Multi-Stage Reminders:** "Automatic follow-up with escalation"
3. **Trade Validation:** "Real-time ban list checking with NOTIS"
4. **Investment Tracking:** "Complete visibility into employee investments"

### For Employees

1. **Easy Uploads:** "Just upload PDF, system extracts everything"
2. **Instant Feedback:** "Know immediately if trade is approved"
3. **Clear Deadlines:** "Reminders before anything expires"
4. **Self-Service:** "Declare accounts and investments online"

---

## Support & Feedback

- **Issues:** https://github.com/anthropics/claude-code/issues
- **Documentation:** This file (`DEMO_GUIDE.md`)

---

*Last Updated: January 2026*
