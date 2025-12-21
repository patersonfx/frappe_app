# Frappe Fixtures Documentation

## Table of Contents
- [Introduction](#introduction)
- [What are Fixtures?](#what-are-fixtures)
- [Configuration](#configuration)
- [Export Commands](#export-commands)
- [Import Commands](#import-commands)
- [Common Use Cases](#common-use-cases)
- [Advanced Filtering](#advanced-filtering)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Introduction

Fixtures in Frappe are a mechanism to export and import master data and configurations that should be consistent across different instances of your application. They are particularly useful for deploying customizations, configurations, and reference data across multiple sites.

## What are Fixtures?

Fixtures are JSON files that contain data for specific DocTypes. They are used to:
- Export customizations (Custom Fields, Property Setters, Custom Scripts)
- Share master data across sites
- Version control configurations
- Deploy standard configurations during app installation
- Maintain consistency across development, staging, and production environments

## Configuration

### Setting up Fixtures in hooks.py

Add the `fixtures` list to your app's `hooks.py` file:
```python
# apps/[your_app]/[your_app]/hooks.py

fixtures = [
    # Export entire DocType
    "Custom Field",
    "Property Setter",
    "Custom Script",
    "Workflow",
    "Workflow State",
    "Workflow Action Master",

    # Export with filters
    {
        "dt": "Role",
        "filters": [
            ["name", "in", ["Custom Role 1", "Custom Role 2", "Custom Role 3"]]
        ]
    },

    # Export specific document
    {
        "dt": "Print Format",
        "filters": [
            ["name", "=", "My Custom Print Format"]
        ]
    },
]
```

### Fixture File Location

Exported fixtures are stored in:
```
apps/[your_app]/[your_app]/fixtures/[doctype_name].json
```

## Export Commands

### Export All Configured Fixtures
```bash
bench --site [site-name] export-fixtures
```

This command exports all DocTypes defined in the `fixtures` list in `hooks.py`.

### Export Specific DocType
```bash
bench --site [site-name] export-doc "DocType Name" "document-name"
```

**Example:**
```bash
bench --site mysite.local export-doc "Custom Field" "Sales Order-custom_field_name"
```

### Export to Custom Path
```bash
bench --site [site-name] export-doc "DocType Name" "document-name" --path="/custom/path/"
```

## Import Commands

### Automatic Import (Recommended)

Fixtures are automatically imported when you:

1. Install the app:
```bash
bench --site [site-name] install-app [app-name]
```

2. Run migrate:
```bash
bench --site [site-name] migrate
```

### Manual Import
```bash
bench --site [site-name] import-doc [path-to-json-file]
```

**Example:**
```bash
bench --site mysite.local import-doc apps/my_app/my_app/fixtures/custom_field.json
```

## Common Use Cases

### 1. Custom Fields
```python
fixtures = [
    "Custom Field",
]
```

Export all custom fields created in your app.

### 2. Workflows
```python
fixtures = [
    "Workflow",
    "Workflow State",
    "Workflow Action Master",
    {
        "dt": "Workflow",
        "filters": [
            ["document_type", "in", ["Sales Order", "Purchase Order"]]
        ]
    }
]
```

### 3. Custom Scripts
```python
fixtures = [
    {
        "dt": "Client Script",
        "filters": [
            ["dt", "in", ["Sales Invoice", "Purchase Invoice"]]
        ]
    },
    {
        "dt": "Server Script",
        "filters": [
            ["script_type", "=", "DocType Event"]
        ]
    }
]
```

### 4. Print Formats
```python
fixtures = [
    {
        "dt": "Print Format",
        "filters": [
            ["standard", "=", "No"]
        ]
    }
]
```

### 5. Roles and Permissions
```python
fixtures = [
    {
        "dt": "Role",
        "filters": [
            ["name", "like", "Custom%"]
        ]
    },
    {
        "dt": "Custom DocPerm",
        "filters": [
            ["role", "like", "Custom%"]
        ]
    }
]
```

### 6. Email Templates
```python
fixtures = [
    {
        "dt": "Email Template",
        "filters": [
            ["name", "in", ["Welcome Email", "Invoice Reminder"]]
        ]
    }
]
```

### 7. Property Setters
```python
fixtures = [
    {
        "dt": "Property Setter",
        "filters": [
            ["doc_type", "in", ["Sales Order", "Sales Invoice"]]
        ]
    }
]
```

## Advanced Filtering

### Multiple Conditions
```python
fixtures = [
    {
        "dt": "Custom Field",
        "filters": [
            ["dt", "in", ["Sales Order", "Sales Invoice"]],
            ["fieldtype", "=", "Data"]
        ]
    }
]
```

### Using LIKE Operator
```python
fixtures = [
    {
        "dt": "Role",
        "filters": [
            ["name", "like", "Custom%"]
        ]
    }
]
```

### Using IN Operator
```python
fixtures = [
    {
        "dt": "Workspace",
        "filters": [
            ["module", "in", ["Selling", "Buying"]]
        ]
    }
]
```

### Complex Filters
```python
fixtures = [
    {
        "dt": "Report",
        "filters": [
            ["is_standard", "=", "No"],
            ["disabled", "=", 0],
            ["module", "in", ["Accounts", "Stock"]]
        ]
    }
]
```

## Best Practices

### 1. Version Control
- Always commit fixture files to Git
- Review changes in fixtures before committing
- Use meaningful commit messages when fixtures change

### 2. Naming Conventions
- Prefix custom items with your app name or "Custom"
- Example: "Custom Role - Sales Manager", "MyApp Custom Field"

### 3. Selective Export
- Only export what's necessary for your app
- Avoid exporting standard Frappe/ERPNext data
- Use filters to be specific

### 4. Dependencies
- Export dependent DocTypes together
- Example: Export Workflow States with Workflows

### 5. Testing
- Test fixture import on a fresh site
- Verify all dependencies are included
- Check for naming conflicts

### 6. Documentation
- Document what each fixture contains
- Maintain a changelog for fixture modifications

### 7. Environment-Specific Data
- Don't include site-specific data in fixtures
- Avoid exporting user credentials or sensitive data
- Use filters to exclude production-only records

## Troubleshooting

### Issue: Fixtures Not Importing

**Solution:**
1. Ensure fixtures are defined in `hooks.py`
2. Run `bench --site [site-name] migrate`
3. Check file permissions on fixture files
4. Verify JSON syntax in fixture files

### Issue: Duplicate Entry Errors

**Solution:**
- Fixtures with the same name will update existing records
- Check for naming conflicts
- Use `amended_from` field if applicable

### Issue: Missing Dependencies

**Solution:**
```bash
# Check app dependencies in hooks.py
app_include_js = [...]
app_include_css = [...]

# Ensure required apps are installed
bench --site [site-name] list-apps
```

### Issue: Outdated Fixtures

**Solution:**
```bash
# Re-export fixtures
bench --site [site-name] export-fixtures

# Commit changes
git add apps/[your_app]/[your_app]/fixtures/
git commit -m "Update fixtures"
```

### Issue: Selective Import

If you need to import only specific fixtures:
```bash
# Import specific DocType
bench --site [site-name] import-doc apps/my_app/my_app/fixtures/custom_field.json
```

## Example: Complete Setup

### Step 1: Define in hooks.py
```python
# apps/custom_app/custom_app/hooks.py

fixtures = [
    "Custom Field",
    "Property Setter",
    {
        "dt": "Client Script",
        "filters": [["dt", "in", ["Sales Order", "Sales Invoice"]]]
    },
    {
        "dt": "Workflow",
        "filters": [["name", "like", "Custom%"]]
    },
    {
        "dt": "Role",
        "filters": [["name", "in", ["Custom Manager", "Custom User"]]]
    }
]
```

### Step 2: Export Fixtures
```bash
bench --site development.local export-fixtures
```

### Step 3: Verify Files
```bash
ls apps/custom_app/custom_app/fixtures/
# Output:
# client_script.json
# custom_field.json
# property_setter.json
# role.json
# workflow.json
```

### Step 4: Commit to Git
```bash
git add apps/custom_app/custom_app/fixtures/
git commit -m "Add initial fixtures for custom app"
git push origin develop
```

### Step 5: Deploy to Production
```bash
cd /path/to/frappe-bench
git pull
bench --site production.local migrate
```

## Additional Resources

- [Frappe Documentation](https://frappeframework.com/docs)
- [ERPNext Documentation](https://docs.erpnext.com)
- [Frappe Forum](https://discuss.frappe.io)

---

**Note:** Always test fixture imports on a development/staging environment before deploying to production.
