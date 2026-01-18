# Google Sheet Entries - Field Mapping Update

## Changes Made

### 1. New Column Added: ENTRY NO
- **Purpose**: Replace auto-generated naming (DEAL-2026-70264) with user-defined Entry Number from Google Sheet
- **Field Name**: `entry_no`
- **Field Type**: Data (string)
- **Requirements**: Required, Unique
- **Usage**: This field will be used as the document name/ID in the database

### 2. Column Position Change: CHAIN INDICATOR
- The CHAIN INDICATOR column position has been changed in the Google Sheet

### 3. Additional Columns in Google Sheet
- Several columns exist in the Google Sheet that are NOT imported to Frappe:
  - **DIFFERENCE, DEAL, DTD, DTM** - For display and reference only
  - **BROKERAGE, DISTBN** - Auto-calculated by Frappe system (sheet values are ignored)

### 4. Change Tracking with Hash Values
- A unique hash is generated for each row based on: ENTRY NO, DATE, PARTICULARS, DIFFERENCE, DEAL, TIME, BROKER, CHAIN INDICATOR, and REMARKS
- When syncing, the system compares the current hash with the stored hash to detect changes
- **Date normalization**: The system recognizes equivalent dates in different formats (e.g., "2026-01-01" and "1-Jan" are treated as the same)
- If changes are detected, you'll be notified with a dialog showing which fields changed
- You can choose to update or ignore specific changed records

## New Google Sheet Column Order

The columns in your Google Sheet should now be in this order:

1. **ENTRY NO** - The unique ID for the deal (e.g., "2601001", "2601002") → **Imported to Frappe**
2. **DATE** - Trade date → **Imported to Frappe**
3. **PARTICULARS** - Deal details → **Imported to Frappe**
4. **DIFFERENCE** - Price difference → **Not imported** (display only in sheet)
5. **DEAL** - Deal rate → **Not imported** (display only in sheet)
6. **TIME** - Deal time → **Imported to Frappe**
7. **BROKER** - Broker name → **Imported to Frappe**
8. **CHAIN INDICATOR** - Chain indicator (M, blank, etc.) → **Imported to Frappe**
9. **REMARKS** - Additional remarks → **Imported to Frappe**
10. **BROKERAGE** - Brokerage amount → **Not imported** (auto-calculated in Frappe system)
11. **DISTBN** - Distribution amount → **Not imported** (auto-calculated in Frappe system)
12. **DTD** - Deal to Date → **Not imported** (display only in sheet)
13. **DTM** - Deal to Month → **Not imported** (display only in sheet)
14. **BANK DEALER** - Bank dealer name → **Imported to Frappe**

## Field Mapping Configuration

To configure the field mapping in **Google Integration Settings**, use the following JSON in the **Field Mapping** field:

```json
{
  "ENTRY NO": "entry_no",
  "DATE": "trade_date",
  "PARTICULARS": "particulars",
  "TIME": "deal_time",
  "BROKER": "broker",
  "CHAIN INDICATOR": "chain_indicator",
  "REMARKS": "remarks",
  "BANK DEALER": "bank_dealer"
}
```

### Columns NOT Included in Mapping (Not Imported)

The following columns exist in your Google Sheet but are **not imported** to Frappe:

- **DIFFERENCE** - Price difference (calculation/display only in sheet)
- **DEAL** - Deal rate (calculation/display only in sheet)
- **BROKERAGE** - Brokerage amount (auto-calculated by Frappe system)
- **DISTBN** - Distribution amount (auto-calculated by Frappe system)
- **DTD** - Deal to Date (display only in sheet)
- **DTM** - Deal to Month (display only in sheet)

These columns can remain in your Google Sheet for reference and calculations, but they will be ignored during the import process.

## Important Notes

1. **ENTRY NO is now required**: Every row in your Google Sheet must have a unique ENTRY NO value

2. **The ENTRY NO will be the document name**: Instead of auto-generated "DEAL-2026-70264", the document will be named with the ENTRY NO value (e.g., "2601001")

3. **Duplicate detection based on ENTRY NO only**:
   - The system now uses ONLY the ENTRY NO field to check for duplicates
   - PARTICULARS can be duplicate - this is allowed
   - Only records with the same ENTRY NO will be skipped during import
   - This means you can import all records without worrying about duplicate PARTICULARS

4. **Columns not in mapping are ignored**: The following columns are not imported to Frappe:
   - DIFFERENCE, DEAL, DTD, DTM (for display/calculation in sheet only)
   - BROKERAGE, DISTBN (auto-calculated by Frappe system)

5. **Auto-calculated fields in Frappe**:
   - **BROKERAGE** is automatically calculated by the Frappe system based on deal details
   - **DISTBN** is automatically calculated by the Frappe system based on deal details
   - Do not rely on the Google Sheet values for these fields; use the Frappe-calculated values

6. **Unique constraint**: The ENTRY NO field has a unique constraint at the database level, so duplicate ENTRY NO values will cause import errors

7. **BANK DEALER field**: This field is now imported from the Google Sheet and stored in Frappe

## Steps to Update Your Configuration

1. Open **Google Integration Settings** in Frappe
2. Find your spreadsheet configuration for "Google Sheet Entries"
3. Update the **Field Mapping** field with the JSON above
4. Save the configuration
5. Run database migration: `bench --site <your-site-name> migrate`
6. Test the import with a few sample rows to verify the mapping works correctly

## How to Use Change Detection

### Checking for Changes

1. **Option 1: Using Console**
   ```javascript
   frappe.call({
       method: 'forex.forex.doctype.google_sheet_entries.google_sheet_entries.check_for_changes',
       callback: function(r) {
           if (r.message.success) {
               console.log('Changed records:', r.message.changed_count);
               console.log('New records:', r.message.new_count);
               console.log('Details:', r.message.changed_records);
           }
       }
   });
   ```

2. **Option 2: Create a Custom Button (Recommended)**
   - You can add a custom button in the Google Sheet Entries list view
   - The button will call `check_for_changes` API
   - Display results in a dialog with checkboxes for each changed record
   - Show old vs new values for changed fields
   - Allow users to select which records to update

### Understanding Change Detection Results

When you check for changes, you'll get:

1. **Changed Records**: Existing entries where data has been modified in the Google Sheet
   - Shows Entry No
   - Lists all changed fields with old and new values
   - Example: "Trade Date: 2026-01-01 → 2026-01-02"

2. **New Records**: Entries that exist in Google Sheet but not in Frappe
   - Can be imported normally using the standard sync

3. **Unchanged Records**: Count of records that match (no action needed)

### Applying Selected Changes

After reviewing the changes, you can apply selected updates:

```javascript
frappe.call({
    method: 'forex.forex.doctype.google_sheet_entries.google_sheet_entries.apply_changes',
    args: {
        changes_json: JSON.stringify([
            {
                entry_no: '2601001',
                new_data: {...},  // New field values
                new_hash: '...'    // New hash value
            }
        ])
    },
    callback: function(r) {
        if (r.message.success) {
            frappe.msgprint(`Updated ${r.message.updated_count} records`);
        }
    }
});
```

### Best Practices

1. **Regular Sync**: Check for changes regularly (daily or weekly)
2. **Review Changes**: Always review what changed before applying updates
3. **Backup**: Consider backing up data before bulk updates
4. **Hash Generation**: The hash is automatically generated on import/sync - no manual action needed
5. **DIFFERENCE and DEAL columns**: These are included in hash calculation even though they're not imported, so changes to these columns will be detected
6. **Date formats**: The system automatically normalizes dates, so "2026-01-01" and "1-Jan" are treated as equivalent (not flagged as changes)

## Migration of Existing Data

If you have existing Google Sheet Entries with the old auto-generated names:
- They will continue to work as-is
- New imports will use the ENTRY NO field
- You may need to manually update or delete old records if needed

## Example

**Google Sheet Row:**
```
ENTRY NO: 2601001
DATE: 2026-01-01
PARTICULARS: $ 20 mio Spot / Jan AXIS s/b to BOIB @ 89.9500 / 90.1150
DIFFERENCE: 16.5
DEAL: AXIS : 10.08
TIME: AXIS : 10.08
BROKER: Icap : BOI
CHAIN INDICATOR:
REMARKS:
BROKERAGE: 20,000
DISTBN: 8,000
DTD: 0
DTM: 0
BANK DEALER: KHUSHRU
```

**Fields Imported to Frappe:**
- Name: `2601001` (from ENTRY NO)
- Entry No: `2601001`
- Trade Date: `2026-01-01`
- Particulars: `$ 20 mio Spot / Jan AXIS s/b to BOIB @ 89.9500 / 90.1150`
- Deal Time: `AXIS : 10.08`
- Broker: `Icap : BOI`
- Chain Indicator: `` (empty)
- Remarks: `` (empty)
- Bank Dealer: `KHUSHRU`

**Fields NOT Imported (Ignored):**
- DIFFERENCE: `16.5` - Display only in sheet
- DEAL: `AXIS : 10.08` - Display only in sheet
- BROKERAGE: `20,000` - Will be auto-calculated by Frappe
- DISTBN: `8,000` - Will be auto-calculated by Frappe
- DTD: `0` - Display only in sheet
- DTM: `0` - Display only in sheet
