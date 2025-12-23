# Workspace Update Issue After Migration

## Problem Description

After running the migration command on Frappe/ERPNext sites, workspaces are not updating properly in the database or frontend. While the migration updates the modification datetime, it fails to update the workspace content, resulting in the frontend not reflecting the latest changes.

## Symptoms

- Workspace JSON files contain the correct, updated code
- Migration command only updates the `modified` datetime field
- The `content` column in the database remains unchanged
- Frontend displays outdated workspace configuration

## Standard Migration Commands

```bash
# For any Frappe site
bench --site <site-name> migrate
```

**Example:**
```bash
bench --site mysite.example.com migrate
```

**Note:** These commands are currently insufficient for updating workspace content.

---

## Solution: Manual Workspace Reload

To force workspace updates from JSON files to the database, follow this step-by-step procedure:

### Step 1: Open Frappe Console

```bash
bench --site <site-name> console
```

### Step 2: Execute Workspace Reload Script

```python
import frappe

# Define the module containing your workspaces
module = "<your_app_name>"  # Replace with your custom app name (e.g., "custom_app", "erpnext")

# List all workspaces that need updating
workspaces = [
    "<workspace_name_1>",  # Replace with actual workspace names
    "<workspace_name_2>",
    # Add more workspace names as needed
]

# Reload each workspace with force flag
for workspace in workspaces:
    try:
        frappe.reload_doc(module, 'workspace', workspace, force=True)
        print(f"Successfully reloaded: {workspace}")
    except Exception as e:
        print(f"Error reloading {workspace}: {str(e)}")

# Commit changes to database
frappe.db.commit()

print("\nAll workspaces updated from files to database!")
```

### Step 3: Exit Console

```python
exit()
```

### Step 4: Clear Cache

```bash
bench --site <site-name> clear-cache
```

### Step 5: Restart Bench

```bash
bench restart
```

---

## Usage Instructions

1. **Replace placeholders:**
   - `<site-name>` → Your actual site name (e.g., `mysite.example.com`, `production.local`)
   - `<your_app_name>` → Your custom app's module name (e.g., `custom_app`, `erpnext`, `hrms`)
   - `<workspace_name_1>`, `<workspace_name_2>` → Your actual workspace names (e.g., `reports`, `invoice`, `sales`)

2. **Find your workspace names:**
   - Navigate to: `<bench-path>/apps/<your-app>/your_app/workspace/`
   - Workspace names are the JSON filenames without the `.json` extension

3. **Execute the commands** in sequence from Step 1 to Step 5

4. **Verify the update** by checking the workspace in the frontend

---

## Practical Examples

### Example 1: Updating ERPNext Workspaces

```python
import frappe

module = "erpnext"

workspaces = [
    "accounting",
    "selling",
    "buying",
    "stock"
]

for workspace in workspaces:
    try:
        frappe.reload_doc(module, 'workspace', workspace, force=True)
        print(f"Successfully reloaded: {workspace}")
    except Exception as e:
        print(f"Error reloading {workspace}: {str(e)}")

frappe.db.commit()
print("\nAll workspaces updated!")
```

### Example 2: Updating Custom App Workspaces

```python
import frappe

module = "custom_compliance"

workspaces = [
    "compliance_dashboard",
    "audit_reports",
    "regulatory_filings"
]

for workspace in workspaces:
    try:
        frappe.reload_doc(module, 'workspace', workspace, force=True)
        print(f"Successfully reloaded: {workspace}")
    except Exception as e:
        print(f"Error reloading {workspace}: {str(e)}")

frappe.db.commit()
print("\nAll workspaces updated!")
```

---

## Technical Notes

- The `force=True` parameter ensures the workspace is reloaded even if timestamps haven't changed
- `frappe.db.commit()` persists the changes to the database
- Cache clearing and bench restart are essential for frontend updates to take effect
- This procedure can be adapted for other DocTypes experiencing similar migration issues

---

## Related Issue

This workaround addresses a known limitation where the standard `bench migrate` command doesn't properly update workspace content fields during migration.
