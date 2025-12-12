# Frappe DocType Controllers - Reference Guide

## Overview

A Controller is a Python class that extends from `frappe.model.Document` base class. This base class handles the core logic of a DocType, managing how values are loaded from the database, parsed, and saved back to the database.

---

## Basic Controller Structure

When you create a DocType named `Person`, a Python file `person.py` is automatically created with this structure:

```python
import frappe
from frappe.model.document import Document

class Person(Document):
    pass
```

All DocType fields are available as attributes on the class instance.

---

## Controller Methods

You can add custom methods to your Controller that are callable using the `doc` object.

**Example:**

```python
# Controller class
class Person(Document):
    def get_full_name(self):
        """Returns the person's full name"""
        return f"{self.first_name} {self.last_name}"

# Usage in code
>>> doc = frappe.get_doc("Person", "000001")
>>> doc.get_full_name()
'John Doe'
```

---

## Controller Hooks (Lifecycle Methods)

Controller hooks allow you to add custom behavior during the document lifecycle.

### Complete Hook Reference Table

| Method Name | Description | Insert | Save | Submit | Cancel | Update After Submit |
|-------------|-------------|:------:|:----:|:------:|:------:|:------------------:|
| `before_insert` | Called before document is prepared for insertion | ✓ | | | | |
| `before_naming` | Called before the `name` property is set | ✓ | | | | |
| `autoname` | Custom method to set document `name` | ✓ | | | | |
| `before_validate` | Called before validation (use for auto-setting values) | ✓ | ✓ | ✓ | | |
| `validate` | Throw validation errors to prevent saving | ✓ | ✓ | ✓ | | |
| `before_save` | Called before document is saved | ✓ | ✓ | | | |
| `before_submit` | Called before document is submitted | ✓ | | ✓ | | |
| `before_cancel` | Called before document is cancelled | | | | ✓ | |
| `before_update_after_submit` | Called when submitted doc fields are updated | | | | | ✓ |
| `db_insert` | Inserts document in database (override for virtual DocTypes) | ✓ | | | | |
| `after_insert` | Called after document is inserted into database | ✓ | | | | |
| `db_update` | Updates document in database (override for virtual DocTypes) | | ✓ | ✓ | ✓ | ✓ |
| `on_update` | Called when existing document values are updated | ✓ | ✓ | ✓ | | |
| `on_submit` | Called when document is submitted | | | ✓ | | |
| `on_cancel` | Called when submitted document is cancelled | | | | ✓ | |
| `on_update_after_submit` | Called when submitted document values are updated | | | | | ✓ |
| `on_change` | Called when document values change (including `db_set`) | ✓ | ✓ | ✓ | ✓ | ✓ |

### Additional Action Hooks

| Method Name | Description |
|-------------|-------------|
| `before_rename` | Called before document is renamed |
| `after_rename` | Called after document is renamed |
| `on_trash` | Called when document is being deleted |
| `after_delete` | Called after document has been deleted |

---

## Hook Implementation Examples

### Validation Hook

```python
class Person(Document):
    def validate(self):
        if self.age <= 18:
            frappe.throw("Person's age must be at least 18")
```

### After Insert Hook

```python
class Person(Document):
    def after_insert(self):
        frappe.sendmail(
            recipients=[self.email], 
            message="Thank you for registering!"
        )
```

### Custom Naming Hook

```python
class Person(Document):
    def autoname(self):
        # Custom naming: PERSON-YYYY-####
        self.name = frappe.model.naming.make_autoname("PERSON-.YYYY.-.####")
```

### Before Save Hook

```python
class Person(Document):
    def before_save(self):
        # Auto-calculate full name before saving
        self.full_name = f"{self.first_name} {self.last_name}".strip()
```

---

## Overriding Default Methods

You can override pre-defined document methods to add custom behavior:

```python
class Person(Document):
    def save(self, *args, **kwargs):
        # Call the base save method
        super().save(*args, **kwargs)
        
        # Custom behavior after save
        self.trigger_external_api()
        self.log_update_attempt()
```

---

## Working with Documents

### 1. Create a Document

```python
doc = frappe.get_doc({
    'doctype': 'Person',
    'first_name': 'John',
    'last_name': 'Doe'
})
doc.insert()

print(doc.name)  # Output: 000001
```

### 2. Load an Existing Document

```python
doc = frappe.get_doc('Person', '000001')

# Access doctype fields
print(doc.first_name)  # John
print(doc.last_name)   # Doe

# Access standard fields
print(doc.creation)    # datetime.datetime(2018, 9, 20, 12, 39, 34, 236801)
print(doc.owner)       # john.doe@frappeframework.com
```

### 3. Document as Dictionary

```python
doc = frappe.get_doc("ToDo", "0000001")
doc_dict = doc.as_dict()

# Returns all fields including standard fields:
# {
#     'name': '0000001',
#     'owner': 'Administrator',
#     'creation': datetime.datetime(...),
#     'modified': datetime.datetime(...),
#     'modified_by': 'Administrator',
#     'docstatus': 0,
#     'idx': 0,
#     'status': 'Open',
#     'priority': 'Medium',
#     'description': 'Test',
#     ...
# }
```

---

## Standard Document Fields

Every document automatically includes these standard fields:

- `name` - Unique identifier
- `owner` - User who created the document
- `creation` - Creation timestamp
- `modified` - Last modification timestamp
- `modified_by` - User who last modified the document
- `docstatus` - Document status (0=Draft, 1=Submitted, 2=Cancelled)
- `idx` - Index/sort order

---

## Type Annotations (Version 15+)

Frappe supports auto-generated Python type annotations for better IDE support:

```python
class Person(Document):
    # begin: auto-generated types
    # This code is auto-generated. Do not modify anything in this block.

    from typing import TYPE_CHECKING

    if TYPE_CHECKING:
        from frappe.types import DF

        first_name: DF.Data
        last_name: DF.Data 
        user: DF.Link
    # end: auto-generated types
    
    pass
```

### Enable Type Annotations in Your App

Add to `hooks.py`:

```python
# hooks.py
export_python_type_annotations = True
```

**Note:** Type annotations are regenerated when creating or updating DocTypes. Manual modifications within the auto-generated block will be overridden.

---

## Best Practices

1. **Use `validate()` for validation logic** - Throw errors to prevent invalid data from being saved
2. **Use `before_save()` for auto-calculations** - Set computed fields before saving
3. **Use `after_insert()` for post-creation actions** - Send notifications, create related records
4. **Use `on_update()` for tracking changes** - Log updates, sync with external systems
5. **Keep hooks idempotent** - Especially for `on_change()` which is called on `db_set` operations
6. **Don't override `db_insert` or `db_update`** - Unless working with virtual DocTypes

---

## Common Patterns

### Validation Pattern

```python
def validate(self):
    self.validate_age()
    self.validate_email()
    self.set_full_name()

def validate_age(self):
    if self.age and self.age < 18:
        frappe.throw(_("Age must be at least 18"))

def validate_email(self):
    if not self.email or "@" not in self.email:
        frappe.throw(_("Please provide a valid email address"))

def set_full_name(self):
    self.full_name = f"{self.first_name or ''} {self.last_name or ''}".strip()
```

### Workflow Pattern

```python
def on_submit(self):
    # Create related documents
    self.create_ledger_entry()
    
    # Update linked documents
    self.update_stock_balance()
    
    # Send notifications
    self.notify_approvers()

def on_cancel(self):
    # Reverse operations
    self.cancel_ledger_entry()
    self.restore_stock_balance()
```

---

## Reference Links

- Complete Document API: `/framework/v14/user/en/api/document`
- Controller Tutorial: `/framework/v14/user/en/tutorial/controller-methods`
- Python Type Hints: <https://docs.python.org/3/library/typing.html>

---

## Version Information

This reference is based on **Frappe Framework v14** documentation.

**Last Updated:** December 2024

---

*Generated from: <https://docs.frappe.io/framework/v14/user/en/basics/doctypes/controllers>*
