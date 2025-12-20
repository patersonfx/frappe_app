# Data Import Error Investigation - Forex Trading System

## Overview
This document outlines the systematic approach to troubleshooting failed Data Import records in the Frappe-based Forex ERP system, specifically for Google Sheet Entries imports.

## Issue Context
**Import Session**: Google Sheet Entries Import on 2025-12-18 22:51:44.075786
**System**: erp.forex
**Source**: Google Sheets integration for forex trading data
**DocTypes Involved**: Data Import, Data Import Log

---

## Investigation Workflow

### Step 1: Identify Latest Data Import Session
```bash
bench --site erp.forex mariadb -e "SELECT name, creation FROM \`tabData Import\` ORDER BY creation DESC LIMIT 1"
```

**Purpose**: Locate the most recent import operation to investigate
**Returns**:
- `name`: Import session identifier
- `creation`: Timestamp of import initiation

**Use Case**: When you need to quickly identify which import session failed without navigating the UI.

---

### Step 2: Extract Exception Message Previews
```bash
bench --site erp.forex mariadb -N -e "SELECT SUBSTRING(exception, LOCATE('frappe.exceptions', exception), 300) FROM \`tabData Import Log\` WHERE data_import='Google Sheet Entries Import on 2025-12-18 22:51:44.075786' AND success=0 LIMIT 20"
```

**Purpose**: Get truncated error messages to understand failure patterns
**Parameters**:
- `-N`: No column headers (cleaner output)
- `LOCATE('frappe.exceptions', exception)`: Find start position of actual exception
- `SUBSTRING(..., 300)`: Extract first 300 characters from that position
- `success=0`: Only failed records

**Returns**: First 20 exception message snippets
**Use Case**: Quick scan of error types without overwhelming output

---

### Step 3: Analyze Missing Client References
```bash
bench --site erp.forex mariadb -e "SELECT CASE WHEN exception LIKE '%Client with code%not found%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(exception, 'Client with code \\'', -1), '\\' not found', 1) ELSE 'Other' END as missing_client, COUNT(*) as count FROM \`tabData Import Log\` WHERE data_import='Google Sheet Entries Import on 2025-12-18 22:51:44.075786' AND success=0 AND exception LIKE '%Client with code%' GROUP BY missing_client ORDER BY count DESC"
```

**Purpose**: Extract and quantify which specific client codes are missing from the Client master
**Logic**:
1. Filter for "Client with code X not found" errors
2. Parse client code from error message using nested `SUBSTRING_INDEX`
3. Group by extracted client code
4. Count occurrences

**Returns**: List of missing client codes with frequency count
**Example Output**:
```
missing_client | count
---------------|------
ABC123         | 45
XYZ789         | 32
DEF456         | 18
```

**Action Items**: Create missing Client master records before re-importing

---

### Step 4: Categorize Error Types
```bash
bench --site erp.forex mariadb -e "SELECT CASE WHEN exception LIKE '%Client with code%not found%' THEN 'Client Not Found' WHEN exception LIKE '%Settlement Date Far cannot be earlier%' THEN 'Date Validation' WHEN exception LIKE '%Failed to parse deal details%' THEN 'Parse Error' ELSE 'Other' END as error_type, COUNT(*) as count FROM \`tabData Import Log\` WHERE data_import='Google Sheet Entries Import on 2025-12-18 22:51:44.075786' AND success=0 GROUP BY error_type ORDER BY count DESC"
```

**Purpose**: Get high-level distribution of error categories
**Error Categories**:

| Category | Description | Typical Cause |
|----------|-------------|---------------|
| **Client Not Found** | Referenced client code doesn't exist in Client master | Missing master data |
| **Date Validation** | Settlement Date Far is earlier than allowed | Business logic validation failure |
| **Parse Error** | Failed to parse deal details from source data | Malformed data format |
| **Other** | Uncategorized errors | Various validation/permission issues |

**Returns**: Count per error category
**Use Case**: Prioritize fixes based on error volume

---

### Step 5: Deep Dive into Specific Errors
```bash
bench --site erp.forex mariadb -N -e "SELECT log_index, exception FROM \`tabData Import Log\` WHERE data_import='Google Sheet Entries Import on 2025-12-18 22:51:44.075786' AND success=0 AND exception LIKE '%Failed to parse deal details%' LIMIT 2" | tail -50
```

**Purpose**: Get full exception details for specific error types
**Parameters**:
- `log_index`: Row number in import that failed
- `exception`: Complete error message and stack trace
- `LIMIT 2`: Sample size (adjust as needed)
- `| tail -50`: Show last 50 lines (handles multi-line exceptions)

**Use Case**: Understand exact failure reason and locate problematic rows in source data

---

## Common Error Patterns & Solutions

### 1. Client Not Found Errors
**Symptom**: `Client with code 'XXXXX' not found`

**Root Cause**: Import data references client codes that don't exist in the Client DocType

**Solution**:
1. Extract all missing client codes using Step 3 query
2. Create Client master records manually or via separate import
3. Re-run the data import

**Prevention**: Implement pre-import validation to check client code existence

---

### 2. Date Validation Errors
**Symptom**: `Settlement Date Far cannot be earlier than Settlement Date Near`

**Root Cause**: Business logic requires Settlement Date Far >= Settlement Date Near

**Solution**:
1. Identify affected rows using log_index
2. Correct dates in source Google Sheet
3. Re-import corrected data

**Prevention**: Add data validation rules in Google Sheet

---

### 3. Parse Errors
**Symptom**: `Failed to parse deal details from row X`

**Root Cause**: Data format doesn't match expected structure

**Solution**:
1. Review full exception message for parsing details
2. Check source data format against expected schema
3. Correct data formatting issues
4. May require code fixes if parser logic is flawed

**Prevention**: Implement format validation before import

---

## Best Practices

### Investigation Approach
1. ✅ Always start with error categorization (Step 4) to understand scope
2. ✅ Use specific error queries (Steps 3 & 5) to get actionable details
3. ✅ Document error patterns for future reference
4. ✅ Fix systemic issues (missing masters) before row-level issues

### Query Optimization
- Use `LIMIT` to avoid overwhelming output
- Add `log_index` to trace back to source data
- Filter by specific import session to isolate issues
- Use `-N` flag when piping output to other tools

### Data Quality
- Implement pre-import validation scripts
- Maintain clean master data (Client, Currency, etc.)
- Use consistent data formats in source systems
- Set up automated alerts for import failures

---

## Troubleshooting Checklist

Before re-importing:
- [ ] All referenced master records exist (Clients, Accounts, etc.)
- [ ] Date fields follow business logic rules
- [ ] Data formats match import template expectations
- [ ] No duplicate entries in source data
- [ ] User permissions allow import operations
- [ ] Source Google Sheet is accessible and not modified during import

---

## Related Resources

### Frappe Documentation
- [Data Import Tool](https://docs.erpnext.com/docs/user/manual/en/setting-up/data/data-import)
- [Data Import API](https://frappeframework.com/docs/user/en/api/data-import)

### Custom Scripts Location
- Import validation hooks: `forex_app/forex_app/doctype/[doctype]/[doctype].py`
- Google Sheets integration: `forex_app/forex_app/integrations/google_sheets.py`

### Database Tables
- `tabData Import`: Import session metadata
- `tabData Import Log`: Individual row import logs
- Target DocType tables (e.g., `tabForex Deal`, `tabClient`)

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| 2025-12-20 | Sant | Initial documentation of investigation workflow |

---

## Notes
- Always backup database before bulk re-imports
- Consider implementing idempotent imports to handle re-runs safely
- Monitor Data Import Log table size and implement cleanup policies
- Use Background Jobs for large imports to avoid timeout issues
