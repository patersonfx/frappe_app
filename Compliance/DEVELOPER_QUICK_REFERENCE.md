# Compliance App - Developer Quick Reference Guide

## 🚀 Quick Start

This guide provides quick access to the most commonly used utility functions in the Compliance App.

---

## 📅 Date Operations

### Import
```python
from compliance.utils.date_utils import (
    parse_date,
    get_financial_year_dates,
    add_business_days,
    is_weekend_or_holiday,
    get_days_until
)
```

### Common Tasks

#### Parse any date format
```python
# Handles multiple formats: YYYY-MM-DD, DD-MM-YYYY, DD/MM/YYYY, datetime objects
date = parse_date("2024-01-15")
date = parse_date("15-01-2024")
date = parse_date("15/01/2024")
```

#### Get financial year dates
```python
# Returns (start_date, end_date) for Indian FY (April 1 - March 31)
fy_start, fy_end = get_financial_year_dates("2024-01-15")
# fy_start = datetime.date(2023, 4, 1)
# fy_end = datetime.date(2024, 3, 31)
```

#### Add business days
```python
# Skips weekends and holidays
new_date = add_business_days(
    start_date="2024-01-15",
    days=5,
    holiday_list="NSE Holidays"
)
```

#### Check if date is weekend/holiday
```python
is_holiday = is_weekend_or_holiday(
    date="2024-01-15",
    holiday_list="NSE Holidays"
)
```

#### Calculate days until date
```python
days_left = get_days_until("2024-12-31")
# Returns integer (can be negative if date is in past)
```

---

## 👥 Employee Operations

### Import
```python
from compliance.utils.query_utils import (
    get_employee_by_user,
    get_active_employees,
    get_employee_compliance_summary
)
```

### Common Tasks

#### Get employee by user email
```python
employee = get_employee_by_user("user@example.com")
# Returns: {"name": "EMP-001", "employee_name": "John Doe", "department": "Sales", ...}
```

#### Get all active employees
```python
# All active employees
employees = get_active_employees()

# Filter by department
employees = get_active_employees(department="Sales")

# Filter by designation
employees = get_active_employees(designation="Manager")

# Custom fields
employees = get_active_employees(
    department="Sales",
    fields=["name", "employee_name", "email"]
)
```

#### Get employee compliance summary
```python
summary = get_employee_compliance_summary("EMP-001")
# Returns: {
#     "nism_certificates": [...],
#     "investment_declarations": [...],
#     "trade_permissions": [...],
#     "compliance_score": 95,
#     "pending_items": 2,
#     "expired_items": 0
# }
```

---

## ✉️ Email Operations

### Import
```python
from compliance.utils.email_utils import (
    send_compliance_email,
    get_employee_email,
    get_compliance_officer_emails,
    build_recipient_list
)
```

### Common Tasks

#### Send compliance email
```python
send_compliance_email(
    recipients=["user@example.com"],
    template="compliance_reminder",
    context={"employee_name": "John Doe"},
    subject="Compliance Reminder"
)
```

#### Get employee email
```python
email = get_employee_email("EMP-001")
```

#### Get compliance officer emails
```python
co_emails = get_compliance_officer_emails()
# Returns list of compliance officer emails
```

#### Build recipient list
```python
recipients = build_recipient_list(
    employees=["EMP-001", "EMP-002"],
    include_compliance_officers=True,
    cc=["manager@example.com"]
)
```

---

## ✅ Validation Operations

### Import
```python
from compliance.utils.validation_utils import (
    validate_employee,
    validate_required_fields,
    validate_date_not_future,
    validate_pan_number,
    validate_mobile_number,
    validate_email
)
```

### Common Tasks

#### Validate employee
```python
# Validates employee exists and is active
validate_employee("EMP-001")

# Skip active check
validate_employee("EMP-001", check_active=False)
```

#### Validate required fields
```python
validate_required_fields(
    doc,
    ["name", "email", "department", "designation"]
)
```

#### Validate date not in future
```python
validate_date_not_future("2024-01-15", field_name="Transaction Date")
```

#### Validate PAN number
```python
validate_pan_number("ABCDE1234F")
# Format: ABCDE1234F (5 letters, 4 digits, 1 letter)
```

#### Validate mobile number
```python
validate_mobile_number("9876543210")
# Accepts: 10 digits or 91 + 10 digits
```

#### Validate email
```python
validate_email("user@example.com")
```

---

## 🔐 Permission Operations

### Import
```python
from compliance.utils.permission_utils import (
    has_permission_for_doctype,
    is_compliance_officer,
    can_approve_compliance_doc,
    get_accessible_employees
)
```

### Common Tasks

#### Check permission for doctype
```python
has_perm = has_permission_for_doctype("Employee", "write")
```

#### Check if user is compliance officer
```python
is_co = is_compliance_officer()  # Current user
is_co = is_compliance_officer("user@example.com")  # Specific user
```

#### Check if user can approve document
```python
can_approve = can_approve_compliance_doc(
    "Investment Declaration",
    "INV-001"
)
```

#### Get employees user can access
```python
accessible = get_accessible_employees()
# Returns list of employee IDs user can view
```

---

## 📊 Status Operations

### Import
```python
from compliance.utils.status_utils import (
    update_status_with_validation,
    get_allowed_status_transitions,
    log_status_change,
    notify_on_status_change
)
```

### Common Tasks

#### Update status with validation
```python
doc = frappe.get_doc("Investment Declaration", "INV-001")
success = update_status_with_validation(
    doc,
    new_status="Approved",
    comment="Approved after review"
)
```

#### Get allowed status transitions
```python
allowed = get_allowed_status_transitions(
    current_status="Draft",
    doctype="Investment Declaration"
)
# Returns: ["Submitted"]
```

#### Log status change
```python
log_status_change(
    doctype="Investment Declaration",
    doc_name="INV-001",
    old_status="Draft",
    new_status="Submitted",
    comment="Submitted for approval"
)
```

---

## 🔍 Query Operations

### Import
```python
from compliance.utils.query_utils import (
    get_expiring_certificates,
    get_pending_approvals,
    get_documents_by_status,
    search_employees
)
```

### Common Tasks

#### Get expiring certificates
```python
expiring = get_expiring_certificates(
    days_threshold=30,
    certificate_doctype="NISM Module"
)
```

#### Get pending approvals
```python
pending = get_pending_approvals()  # All pending for current user
pending = get_pending_approvals(doctype="Trade Permission")  # Specific doctype
```

#### Get documents by status
```python
docs = get_documents_by_status(
    doctype="Investment Declaration",
    status="Pending",
    employee="EMP-001",  # Optional
    limit=100
)
```

#### Search employees
```python
employees = search_employees("John", limit=20)
# Searches in name, employee_name, and user_id
```

---

## 📝 Common Patterns

### Pattern 1: Report with Date Filtering
```python
from compliance.utils.date_utils import parse_date
import datetime

def execute(filters=None):
    """Standard report execution with date filtering"""
    # Parse dates
    from_date = parse_date(filters.get("from_date"))
    to_date = parse_date(filters.get("to_date"))

    if from_date and to_date:
        # Convert to datetime for SQL
        from_datetime = datetime.datetime.combine(from_date, datetime.time.min)
        to_datetime = datetime.datetime.combine(to_date, datetime.time.max)

        # Use in query
        data = frappe.db.sql("""
            SELECT * FROM tabMyTable
            WHERE date_field BETWEEN %(from_date)s AND %(to_date)s
        """, {"from_date": from_datetime, "to_date": to_datetime}, as_dict=True)

    return columns, data
```

### Pattern 2: Employee Validation in Doctype
```python
from compliance.utils.validation_utils import validate_employee, validate_required_fields

class MyDocType(Document):
    def validate(self):
        # Validate required fields
        validate_required_fields(self, ["employee", "date", "amount"])

        # Validate employee
        validate_employee(self.employee)

        # Your custom validation
        ...
```

### Pattern 3: Status Update with Notification
```python
from compliance.utils.status_utils import update_status_with_validation

@frappe.whitelist()
def approve_document(doc_name):
    """Approve a compliance document"""
    doc = frappe.get_doc("Investment Declaration", doc_name)

    # Update status (automatically logs and notifies)
    success = update_status_with_validation(
        doc,
        new_status="Approved",
        comment="Approved by compliance officer"
    )

    return {"success": success}
```

### Pattern 4: Scheduled Task with Date Operations
```python
from compliance.utils.date_utils import is_weekend_or_holiday, add_business_days
from compliance.utils.email_utils import send_compliance_email

def send_reminders():
    """Send reminders on business days only"""
    today = frappe.utils.nowdate()

    # Skip weekends and holidays
    if is_weekend_or_holiday(today, holiday_list="NSE Holidays"):
        return

    # Calculate deadline (5 business days from now)
    deadline = add_business_days(today, 5, holiday_list="NSE Holidays")

    # Send reminders
    send_compliance_email(
        recipients=get_recipients(),
        template="reminder",
        context={"deadline": deadline}
    )
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ Don't: Parse dates manually
```python
# Bad
date = datetime.strptime(date_str, "%Y-%m-%d")  # Fails on other formats
```

### ✅ Do: Use centralized date parsing
```python
# Good
from compliance.utils.date_utils import parse_date
date = parse_date(date_str)  # Handles multiple formats
```

### ❌ Don't: Duplicate employee queries
```python
# Bad
employee = frappe.db.get_value("Employee", {"user_id": email}, "employee_name")
```

### ✅ Do: Use centralized query
```python
# Good
from compliance.utils.query_utils import get_employee_by_user
employee = get_employee_by_user(email)
```

### ❌ Don't: Calculate financial year manually
```python
# Bad
if month <= 3:
    fy_start = f"{year-1}-04-01"
else:
    fy_start = f"{year}-04-01"
```

### ✅ Do: Use centralized FY calculation
```python
# Good
from compliance.utils.date_utils import get_financial_year_dates
fy_start, fy_end = get_financial_year_dates(date)
```

---

## 📚 Further Reading

- **[UTILITY_MODULES_SUMMARY.md](./UTILITY_MODULES_SUMMARY.md)** - Complete function reference
- **[DRY_REFACTORING_GUIDE.md](./DRY_REFACTORING_GUIDE.md)** - Refactoring best practices
- **[REFACTORING_COMPLETE_SUMMARY.md](./REFACTORING_COMPLETE_SUMMARY.md)** - Complete project summary

---

## 💡 Tips

1. **Always import at function level** to avoid circular dependencies
2. **Use type hints** for better IDE support
3. **Check docstrings** for detailed parameter information
4. **Reuse utilities** instead of writing duplicate code
5. **Update this guide** when adding new utility functions

---

## 🆘 Getting Help

1. Check utility module docstrings (`help(parse_date)`)
2. Look at existing code examples in refactored files
3. Review phase documentation for detailed examples
4. Ask senior developers
5. Update documentation with your learnings

---

**Version**: 1.0
**Last Updated**: December 13, 2024
**Maintained By**: Compliance App Development Team
