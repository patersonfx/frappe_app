# Business Requirements Document (BRD)
# Forex Brokerage Management Application

**Version:** 1.0
**Date:** 2026-03-15
**Publisher:** Sant Bharat Agarwal (sant.bharat.agarwal@gmail.com)
**License:** MIT
**Framework:** Frappe Framework (Python/JavaScript)
**Database:** MariaDB/MySQL

---

## TABLE OF CONTENTS

1. [Application Overview](#1-application-overview)
2. [Complete Data Model](#2-complete-data-model)
3. [Business Rules & Validations](#3-business-rules--validations)
4. [Workflows & Processes](#4-workflows--processes)
5. [UI/UX Logic](#5-uiux-logic)
6. [Print Formats & Reports](#6-print-formats--reports)
7. [Integrations](#7-integrations)
8. [Settings & Configurations](#8-settings--configurations)
9. [Hooks & Event Handlers](#9-hooks--event-handlers)
10. [Calculations & Formulas](#10-calculations--formulas)
11. [Edge Cases & Special Handling](#11-edge-cases--special-handling)
12. [Data Fixtures & Seed Data](#12-data-fixtures--seed-data)
13. [Security & Access Control](#13-security--access-control)
14. [Error Handling](#14-error-handling)

---

## 1. APPLICATION OVERVIEW

### 1.1 Purpose

This application manages the complete lifecycle of **inter-bank foreign exchange (forex) brokerage operations** in India. It facilitates the recording, tracking, confirmation, and billing of USD/INR currency deals brokered between banks and financial institutions. The company acts as an intermediary (broker) connecting sellers and buyers of foreign currency, earning brokerage fees on each transaction.

### 1.2 Industry Context

- **Domain:** Foreign Exchange (Forex) Brokerage in India
- **Regulatory Context:** Transactions are governed by RBI (Reserve Bank of India) regulations. Deals settle through CCIL (Clearing Corporation of India Ltd) or via RTGS (Real Time Gross Settlement).
- **Currency Pair:** Primarily USD/INR (US Dollar vs Indian Rupee)
- **Market:** The Indian inter-bank forex market operates Monday-Friday, excluding Maharashtra state holidays and, for settlement purposes, New York holidays.
- **Settlement:** Deals settle at T+0 (CASH), T+1 (TOM), T+2 (SPOT), or forward dates. New York holiday schedules affect SPOT date calculations because USD settlements require New York banks to be open.
- **GST:** Indian Goods & Services Tax applies to brokerage income — CGST+SGST for intrastate (within Maharashtra), IGST for interstate transactions.

### 1.3 Key Stakeholders and User Roles

| Role | Description | Permissions |
|------|-------------|-------------|
| **System Manager** | Full access to all doctypes — create, read, write, delete, export, print, email, share, report | All Deal Entry, Forex Contracts, Deal Confirmation, Client, Dealer, Forex Broker, Deal Type, Brokerage, Discount, Forex Settings, Google Integration, E-Invoice, GST Rate |
| **Sales Manager** | Read-only access to Dealer hierarchy | Read, Email, Print, Report on Dealer |
| **Sales User** | Read-only access to Dealer hierarchy | Read, Email, Print, Report on Dealer |
| **Sales Master Manager** | Full dealer management | Create, Read, Write, Delete, Email, Print, Report, Share on Dealer |

### 1.4 Core Business Functions

1. **Deal Entry** — Record forex deals between a selling bank and a buying bank
2. **Deal Confirmation** — Generate confirmation messages sent to clients
3. **Forex Contracts** — Create formal contract notes for each deal leg
4. **Brokerage Calculation** — Compute fees based on client-specific slab rates
5. **Discount Management** — Apply periodic discounts on brokerage
6. **Contract Printing** — Generate PDF contract notes on pre-printed stationery
7. **Reporting** — Brokerage bills, volume summaries, dealer performance
8. **Google Sheets Integration** — Import/export deals from/to Google Spreadsheets
9. **E-Invoice Management** — Generate monthly e-invoice numbers for clients

---

## 2. COMPLETE DATA MODEL

### 2.1 Deal Entry (`tabDeal Entry`)

**Purpose:** The central transaction record. Each Deal Entry represents a forex deal where one bank sells USD and another buys USD at an agreed rate.

**Naming Rule:** `field:deal_entry_no` — auto-generated as `YYMMDD` + 3-digit serial (e.g., `260315001` for the first deal on March 15, 2026)

**Auto-name Generation Algorithm:**
```
1. Parse deal_date to get prefix: datetime.strptime(deal_date, '%Y-%m-%d').strftime('%y%m%d')
2. Query: SELECT MAX(deal_entry_no) FROM tabDeal Entry WHERE deal_entry_no LIKE '{prefix}%' FOR UPDATE
3. Extract last 3 digits from max, increment by 1
4. Pad to 3 digits with zfill(3)
5. Result: {prefix}{serial} (e.g., "260315001")
```

**Fields:**

| Field Name | Type | Required | Options/Default | Description |
|---|---|---|---|---|
| `deal_entry_no` | Int | Yes | Read-only, unique | Auto-generated deal number (YYMMDD###) |
| `deal_entryno` | Int | No | Virtual, read-only | Display copy of deal_entry_no |
| `deal_type` | Select | No | "Swap\nOutright" | Whether deal is Swap (near+far legs) or Outright (single leg) |
| `deal_date` | Date | Yes | Search indexed | The date the deal was made |
| `amount` | Currency | Yes | Precision 6, non-negative | Deal amount in millions of USD |
| `amount_in_words_mn` | Data | No | Virtual | Amount converted to English words (e.g., "Five Million") |
| `amount_in_words` | Data | No | | Stored amount in words |
| `near_tenor` | Select | No | Default "SPOT" | Near leg tenor code |
| `near_rate` | Currency | Yes | Precision 4, non-negative | Near leg exchange rate (INR per USD) |
| `near_date` | Date | Yes | Search indexed | Near leg settlement/delivery date |
| `far_tenor` | Select | No | Depends on deal_type=="Swap" | Far leg tenor code |
| `far_rate` | Currency | No | Precision 4, non-negative | Far leg rate (visible only for Swap) |
| `far_date` | Date | No | Search indexed | Far leg settlement date (visible only for Swap) |
| `difference` | Float | No | Precision 4 | Swap points = far_rate - near_rate |
| **Near Leg (Seller Side)** |
| `seller` | Link → Client | Yes | Search indexed | Selling bank (near leg) |
| `seller_status` | Select | No | "\nOpen\nClose", hidden, read-only | Multi-counterparty matching status |
| `seller_time` | Time | No | | Time of seller's deal |
| `seller_dealer` | Link → Dealer | No | | Dealer handling seller side |
| `seller_broker` | Link → Forex Broker | Yes | | Broker for seller side |
| `seller_deal_type` | Link → Deal Type | Yes | Search indexed | Swap type (SS/LS/OR) for seller |
| `seller_brokerage` | Currency | No | Default 0, precision 2 | Brokerage earned from seller |
| `seller_agent` | Select | No | "CCIL Settlement\nRTGS" | Settlement agent for seller |
| **Near Leg (Buyer Side)** |
| `buyer` | Link → Client | Yes | Search indexed | Buying bank (near leg) |
| `buyer_status` | Select | No | "\nOpen\nClose", hidden, read-only | Multi-counterparty matching status |
| `buyer_time` | Time | No | | Time of buyer's deal |
| `buyer_dealer` | Link → Dealer | No | | Dealer handling buyer side |
| `buyer_broker` | Link → Forex Broker | Yes | | Broker for buyer side |
| `buyer_deal_type` | Link → Deal Type | Yes | Search indexed | Swap type for buyer |
| `buyer_brokerage` | Currency | No | Default 0, precision 2 | Brokerage earned from buyer |
| `buyer_agent` | Select | No | "CCIL Settlement\nRTGS" | Settlement agent for buyer |
| **Far Leg (visible only for multi-counterparty Swap)** |
| `seller_fl` | Link → Client | Conditional | Search indexed | Far leg seller (mandatory if deal_type != "Outright") |
| `buyer_fl` | Link → Client | Conditional | Search indexed | Far leg buyer |
| `seller_status_fl` | Select | No | "\nOpen\nClose", hidden, read-only | Far leg seller status |
| `buyer_status_fl` | Select | No | "\nOpen\nClose", hidden, read-only | Far leg buyer status |
| `seller_time_fl` | Time | No | | Far leg seller time |
| `buyer_time_fl` | Time | No | | Far leg buyer time |
| `seller_broker_fl` | Link → Forex Broker | Conditional | | Far leg seller broker |
| `buyer_broker_fl` | Link → Forex Broker | Conditional | | Far leg buyer broker |
| `seller_deal_type_fl` | Link → Deal Type | Conditional | Search indexed | Far leg seller swap type |
| `buyer_deal_type_fl` | Link → Deal Type | Conditional | Search indexed | Far leg buyer swap type |
| `seller_brokerage_fl` | Currency | No | Default 0, precision 2, read-only | Far leg seller brokerage |
| `buyer_brokerage_fl` | Currency | No | Default 0, precision 2, read-only | Far leg buyer brokerage |
| **Multi-Counterparty** |
| `multi_counterparty` | Check | No | Default 0 | Whether this is a multi-counterparty deal |
| `multi_deal_group` | Data | Conditional | | Group identifier linking multi-counterparty deals together |
| `sb` | Check | No | Default 0, depends on multi_counterparty | S/B direction flag (Sell near, Buy far) |
| `bs` | Check | No | Default 0, depends on multi_counterparty | B/S direction flag (Buy near, Sell far) |
| **Brokerage Overrides** |
| `ex_seller_brokerage` | Currency | No | Hidden, read-only, precision 2 | External broker brokerage (seller near) |
| `ex_buyer_brokerage` | Currency | No | Hidden, read-only, precision 2 | External broker brokerage (buyer near) |
| `ex_seller_brokerage_fl` | Currency | No | Hidden, read-only, precision 2 | External broker brokerage (seller far) |
| `ex_buyer_brokerage_fl` | Currency | No | Hidden, read-only, precision 2 | External broker brokerage (buyer far) |
| `virtual_seller_brokerage` | Currency | No | Hidden, virtual, precision 2 | Calculated brokerage before broker assignment |
| `virtual_buyer_brokerage` | Currency | No | Hidden, virtual, precision 2 | Calculated brokerage before broker assignment |
| `virtual_seller_brokerage_fl` | Currency | No | Hidden, virtual, precision 2 | Far leg virtual brokerage |
| `virtual_buyer_brokerage_fl` | Currency | No | Hidden, virtual, precision 2 | Far leg virtual brokerage |
| **Cross-Match** |
| `seller_close_ref` | Data | No | Read-only | Reference to matched deal (seller near) |
| `buyer_close_ref` | Data | No | Read-only | Reference to matched deal (buyer near) |
| `seller_close_ref_fl` | Data | No | Read-only | Reference to matched deal (seller far) |
| `buyer_close_ref_fl` | Data | No | Read-only | Reference to matched deal (buyer far) |
| `cross_match` | HTML | No | Virtual | Cross-match status display |
| **Deal Confirmation References** |
| `seller_deal_no` | Data | No | Hidden, read-only | Seller confirmation document name |
| `buyer_deal_no` | Data | No | Hidden, read-only | Buyer confirmation document name |
| `seller_deal_confirm` | Small Text | No | Virtual, read-only | Seller confirmation text |
| `buyer_deal_confirm` | Small Text | No | Virtual, read-only | Buyer confirmation text |
| `seller_html` | HTML | No | Virtual | Seller action buttons (PDF/Print/Email) |
| `buyer_html` | HTML | No | Virtual | Buyer action buttons |
| **Contract References** |
| `near_contract_no` | Data | No | Hidden, read-only | Near leg contract number |
| `far_contract_no` | Data | No | Hidden, read-only | Far leg contract number |
| `near_create_forex_contract` | Check | No | Default 0, hidden, read-only | Flag for multi-counterparty near contract creation |
| `far_create_forex_contract` | Check | No | Default 0, hidden, read-only | Flag for multi-counterparty far contract creation |
| **Remarks** |
| `remarks` | Data | No | | Free-text remarks |

**Near Tenor Options:** `(blank), CASH, CASH / TOM, CASH / SPOT, TOM, TOM / SPOT, SPOT, SPOT / NEXT, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC, JAN, FEB, MAR, 1M, 2M, 3M, 6M, 1Y, 2Y`

**Permissions:** System Manager — full CRUD, export, print, email, share, report

**Settings:** `default_view: Report`, `sort_field: deal_entry_no ASC`, `hide_toolbar: 1`, `track_changes: 1`, `track_seen: 1`, `force_re_route_to_default_view: 1`

---

### 2.2 Forex Contracts (`tabForex Contracts`)

**Purpose:** Formal contract notes generated for each leg of a deal. One per leg — Outright creates 1, Swap creates 2 (Near + Far).

**Naming Rule:** By script (`autoname` method). Format: `YYMMDD###` (e.g., `260315001`).

**Auto-name Algorithm:**
```
1. If contract_no is pre-assigned → use it directly
2. Parse contract_date → prefix = YYMMDD
3. Query: SELECT MAX(CAST(SUBSTRING(name, 7) AS UNSIGNED)) FROM tabForex Contracts WHERE name LIKE '{prefix}%' FOR UPDATE
4. Next serial = max + 1 (or 1 if none exist)
5. Result: {prefix}{serial.zfill(3)}
```

**Fields:**

| Field Name | Type | Required | Description |
|---|---|---|---|
| `contract_no` | Int | No | Contract number |
| `contract_date` | Date | No | Contract date (= deal_date), search indexed |
| `seller_time` | Time | No | Seller's deal time |
| `buyer_time` | Time | No | Buyer's deal time |
| `leg_type` | Select | No | "Near\nFar", read-only, search indexed |
| `deal_entry_no` | Link → Deal Entry | No | Back-reference, read-only, search indexed |
| `delivery` | Date | No | Settlement/delivery date, search indexed |
| `rate` | Float | No | Exchange rate, precision 6, search indexed |
| `amount` | Currency | No | Deal amount, precision 6, search indexed |
| `amount_in_words` | Data | No | Amount in English words, read-only |
| `printed` | Check | No | Default 0, read-only — overlay print flag |
| `printed_pdf` | Check | No | Default 0, read-only — PNG template print flag |
| `seller` | Link → Client | No | Selling bank, search indexed |
| `seller_broker` | Link → Forex Broker | No | Seller's broker |
| `sell_brokerage` | Currency | No | Seller brokerage, precision 2, search indexed |
| `seller_agent` | Select | No | "CCIL Settlement\nRTGS" |
| `seller_deal_type` | Link → Deal Type | No | Seller's swap type |
| `buyer` | Link → Client | No | Buying bank, search indexed |
| `buyer_broker` | Link → Forex Broker | No | Buyer's broker |
| `buy_brokerage` | Currency | No | Buyer brokerage, precision 2, search indexed |
| `buyer_agent` | Select | No | "CCIL Settlement\nRTGS" |
| `buyer_deal_type` | Link → Deal Type | No | Buyer's swap type |

**Permissions:** System Manager — full CRUD

---

### 2.3 Deal Confirmation (`tabDeal Confirmation`)

**Purpose:** Textual confirmation of a deal sent to each client (seller and buyer separately).

**Naming Rule:** By script. Format: `YYMMDD###` where ### is sequential per deal_date.

**Auto-name Algorithm:**
```
1. If name is pre-assigned (not starting with "new-deal-confirmation") → keep it
2. Parse deal_date → prefix = YYMMDD
3. Query: SELECT COALESCE(COUNT(*) + 1, 1) FROM tabDeal Confirmation WHERE deal_date = %s FOR UPDATE
4. Result: {prefix}{serial.zfill(3)}
```

**Fields:**

| Field Name | Type | Description |
|---|---|---|
| `deal_date` | Date | Deal date, search indexed |
| `deal_confirm_no` | Int | Sequential number per date+client, read-only, search indexed |
| `deal_entry_no` | Data | Reference to Deal Entry, read-only, search indexed |
| `contract_no` | Int | Reference to Forex Contract |
| `client` | Link → Client | The client this confirmation is for, read-only, search indexed |
| `client_type` | Select | "Seller\nBuyer", read-only |
| `broker` | Link → Forex Broker | Broker, search indexed |
| `deal_confirmation` | Small Text | The full confirmation text, read-only |

---

### 2.4 Client (`tabClient`)

**Purpose:** Banks and financial institutions that trade forex through the brokerage.

**Naming Rule:** Set by user (prompt). The `name` field is typically a short code.

**Fields:**

| Field Name | Type | Required | Options/Default | Description |
|---|---|---|---|---|
| `bank_name` | Data | Yes | Search indexed | Full name of the bank/institution |
| `client_code` | Data | No | Search field | Short code for the client |
| `client_centre` | Link → Client Centre | Yes | | Geographic center (e.g., "Mumbai") |
| `client_type` | Select | Yes | "Nationalized\nPrivate\nForeign\nCo-Operative" | Type of banking institution |
| `confirmation_type` | Select | Yes | "Combine\nSeparate" | How deal confirmations are grouped |
| `default_deal_type` | Link → Deal Type | Yes | Search indexed | Default swap type for this client |
| `discount_type` | Select | Yes | "Brokerage\nVolume" | How discounts are calculated |
| `print_time_on_contract_note` | Check | No | Default 1 | Whether to print deal time on contract notes |
| `holiday_list` | Link → Holiday List | No | | Holiday list for working day calculations (shown when brokerage_basis = "Working Days") |
| **Address & Contact** |
| `client_primary_address` | Link → Address | No | | Primary address link |
| `primary_address` | Text | No | Read-only | Formatted address display |
| `client_primary_contact` | Link → Contact | No | | Primary contact link |
| `mobile_no` | Read Only | No | Fetch from contact | Mobile number |
| `email_id` | Read Only | No | Fetch from contact | Email address |
| **Child Tables** |
| `brokerage` | Table → Brokerage | No | | Brokerage rate slabs |
| `discount` | Table → Discount | No | | Discount configuration |
| `client_dealer` | Table → Client Dealer | No | | Client's own dealers |
| `co_dealer` | Table → Dealer Team | No | | Company dealers assigned to this client |

**Title Field:** `bank_name`
**Search Fields:** `client_code`

---

### 2.5 Brokerage (`tabBrokerage`) — Child Table of Client

**Purpose:** Defines brokerage rate slabs per client. Each row specifies the brokerage rate for a given deal type and tenor range, effective from a specific date.

| Field Name | Type | Default | Description |
|---|---|---|---|
| `from_date` | Date | Today | Effective date for this rate |
| `deal_type` | Link → Deal Type | | Which deal type this rate applies to (SS, LS, OR) |
| `range_type` | Select | "Days" | "Days\nMonths" — unit for from_days/to_days |
| `from_days` | Int | | Start of tenor range (inclusive) |
| `to_days` | Int | | End of tenor range (inclusive) |
| `brokerage` | Currency | | Rate per million (INR per million USD) |
| `brokerage_basis` | Select | | "Calendar Days\nWorking Days" — how days are counted |
| `brokerage_cap` | Currency | 999999999 | Maximum brokerage amount per deal |

---

### 2.6 Discount (`tabDiscount`) — Child Table of Client

**Purpose:** Defines discount slabs applied to brokerage, calculated monthly (M), half-yearly (H), or yearly (Y).

| Field Name | Type | Default | Description |
|---|---|---|---|
| `mhy` | Select | "M" | Period type: M (Monthly), H (Half-yearly), Y (Yearly) |
| `if` | Select | "I" | I (Individual) / F (Full) — whether discount applies to incremental slab or full amount |
| `from_date` | Date | 2020-04-01 | Effective date |
| `disc_on` | Select | "Brokerage" | "Brokerage\nVolume" — discount basis |
| `from_slab` | Currency | | Minimum brokerage/volume threshold for this slab |
| `pct` | Percent | | Discount percentage |
| `disc_deal_type` | Link → DealType | | Which deal type this discount applies to |

---

### 2.7 Forex Broker (`tabForex Broker`)

**Purpose:** Brokerage firms. The company itself is one broker (the "house broker"); external brokers participate when deals are intermediated through third parties.

**Naming Rule:** `field:broker_code`

| Field Name | Type | Required | Description |
|---|---|---|---|
| `broker_name` | Data | Yes | Full broker company name (unique) |
| `broker_code` | Data | Yes | Short code (unique) |
| `broker_center` | Data | No | Geographic location |
| `broker_contact_no` | Data | No | Contact number |
| `broker_primary_address` | Link → Address | No | Primary address |
| `primary_address` | Text | No | Formatted address (read-only) |
| `broker_primary_contact` | Link → Contact | No | Primary contact |
| `mobile_no` | Read Only | No | Fetched from contact |
| `email_id` | Read Only | No | Fetched from contact |

**House Broker Concept:** The broker whose `broker_name` matches the user's default Company is the "house broker." Brokerage is earned only when the house broker handles a side of the deal. When an external broker handles a side, brokerage for that side is zero (moved to `ex_*_brokerage` fields).

---

### 2.8 Deal Type (`tabDeal Type`)

**Purpose:** Categorizes deal tenor types for brokerage calculation.

**Naming Rule:** Set by user (prompt)

| Field Name | Type | Description |
|---|---|---|
| `deal_type` | Data | Type name — required, unique. Standard values: "Short Swap", "Long Swap", "Outright" |

**Standard Abbreviations in the system:**
- **SS** = Short Swap (short-tenor swaps)
- **LS** = Long Swap (long-tenor swaps)
- **OR** = Outright (spot/forward transactions, no swap)

---

### 2.9 DealType (`tabDealType`)

**Purpose:** Secondary deal type classification used specifically in the Discount table.

**Naming Rule:** `field:deal_type`

| Field Name | Type | Description |
|---|---|---|
| `deal_type` | Data | Type name — required, unique |

---

### 2.10 Dealer (`tabDealer`)

**Purpose:** Company employees who handle deals. Organized as a tree (nested set model) with parent-child relationships.

**Naming Rule:** `field:dealer_name`
**Structure:** Tree (NestedSet) with `parent_dealer` field, `lft`/`rgt` for tree traversal.

| Field Name | Type | Description |
|---|---|---|
| `dealer_name` | Data | Full name — required, unique |
| `parent_dealer` | Link → Dealer | Parent in hierarchy |
| `is_group` | Check | Whether this is a group node (default 0) |
| `enabled` | Check | Whether active (default 1), search indexed |
| `employee` | Link → Employee | Linked employee record |
| `department` | Link → Department | Fetched from employee (read-only) |
| `lft` | Int | Left value for nested set |
| `rgt` | Int | Right value for nested set |

**Permissions:** Sales Manager (read), Sales User (read), Sales Master Manager (full CRUD)

---

### 2.11 Dealer Team (`tabDealer Team`) — Child Table

**Purpose:** Associates company dealers with a client. The first row is the primary dealer.

| Field Name | Type | Description |
|---|---|---|
| `dealer_name` | Link → Dealer | The assigned dealer (required, search indexed) |
| `contact_no` | Data | Contact number (hidden) |

---

### 2.12 Client Dealer (`tabClient Dealer`) — Child Table

**Purpose:** Records the client's own dealer names (not company dealers).

| Field Name | Type | Description |
|---|---|---|
| `client_dealer_name` | Data | Name of the client's dealer |

---

### 2.13 Client Centre (`tabClient Centre`)

**Purpose:** Geographic centers where clients operate.

**Naming Rule:** `field:client_centre`

| Field Name | Type | Description |
|---|---|---|
| `client_centre` | Data | Centre name — required, unique (e.g., "Mumbai", "Delhi") |

---

### 2.14 Company Dealer (`tabCompany Dealer`)

**Purpose:** Legacy doctype mapping dealers to bank parties.

| Field Name | Type | Description |
|---|---|---|
| `dealer_name` | Data | Dealer name |
| `bank_name` | Link → Bank Party | Bank reference |

---

### 2.15 Forex Settings (`tabForex Settings`)

**Purpose:** Singleton settings document controlling application behavior.

**Type:** Single (issingle = 1), Name: "Forex"

| Field Name | Type | Default | Description |
|---|---|---|---|
| `igst_rate` | Float | 18 | IGST rate percentage (interstate) |
| `cgst_rate` | Float | 9 | CGST rate percentage (intrastate) |
| `sgst_rate` | Float | 9 | SGST rate percentage (intrastate) |
| `restrict_weekend_holiday_entries` | Check | 1 | Block deal entry on weekends/holidays |
| `restrict_backdated_deals` | Check | 1 | Block deal entry with past dates |
| `contract_print_paper_size` | Select | "A4 Portrait" | "A4 Portrait\nA5 Landscape" |
| `print_other_brokers_contract_notes` | Check | 0 | Include external broker contracts in prints |

---

### 2.16 GST Rate (`tabGST Rate`)

**Purpose:** Manages GST rate history with date-based validity periods.

| Field Name | Type | Description |
|---|---|---|
| `is_active` | Check | Whether this rate is currently active |
| `from_date` | Date | Start date of validity |
| `to_date` | Date | End date of validity |
| `cgst_rate` | Float | CGST percentage |
| `sgst_rate` | Float | SGST percentage |
| `igst_rate` | Float | IGST percentage |
| `total_gst_rate` | Float | Auto-calculated: CGST + SGST |
| `remarks` | Small Text | Notes |

**Validations:**
- `from_date` must be before `to_date`
- No overlapping active date ranges allowed
- Rates cannot be negative or exceed 100%
- Total GST = CGST + SGST (auto-calculated)

---

### 2.17 E-Invoice (`tabE-Invoice`)

**Purpose:** Monthly e-invoice number assignment for clients.

**Naming Rule:** By script — format `YYYYMM` (e.g., "202603")

**Auto-name:** `getdate(month_year).strftime("%Y%m")`

| Field Name | Type | Description |
|---|---|---|
| `month_year` | Date | Month and year (unique) |
| `e_invoice_items` | Table → E-Invoice Item | Client e-invoice assignments |

**Validations:**
- `month_year` is required and must be unique
- Duplicate clients within the same e-invoice are not allowed
- Client query filters: only clients who have forex contracts with the house broker in the selected month

---

### 2.18 E-Invoice Item (`tabE-Invoice Item`) — Child Table

| Field Name | Type | Description |
|---|---|---|
| `client` | Link → Client | The client |
| `e_invoice_no` | Data | Assigned e-invoice number |

---

### 2.19 Google Integration Settings (`tabGoogle Integration Settings`)

**Purpose:** Singleton for Google Sheets integration configuration.

| Field Name | Type | Description |
|---|---|---|
| `enabled` | Check | Master on/off |
| `authentication_method` | Select | "Service Account\nOAuth 2.0" |
| `service_account_json` | Code | Service account credentials JSON |
| `upload_service_account_file` | Attach | File upload for credentials |
| `spreadsheet_configs` | Table → Google Spreadsheet Config | Configuration for each connected sheet |
| `auto_sync_enabled` | Check | Enable automated sync |
| `sync_frequency` | Select | How often to auto-sync |

---

### 2.20 Google Spreadsheet Config (`tabGoogle Spreadsheet Config`) — Child Table

| Field Name | Type | Description |
|---|---|---|
| `enabled` | Check | Whether this config is active |
| `config_name` | Data | Descriptive name |
| `sync_direction` | Select | "Import\nExport\nBi-directional" |
| `spreadsheet_id` | Data | Google Spreadsheet ID |
| `spreadsheet_url` | Data | Full URL (auto-extracts ID) |
| `worksheet_name` | Data | Tab/sheet name |
| `doctype_name` | Data | Target Frappe DocType |
| `filters_json` | Code | JSON filters for data selection |
| `field_mapping` | Code | Field-to-column mapping |

---

### 2.21 Google Sheet Entries (`tabGoogle Sheet Entries`)

**Purpose:** Staging table for imported Google Sheet rows before conversion to Deal Entries.

| Field Name | Type | Description |
|---|---|---|
| `entry_no` | Data | Unique entry number |
| `trade_date` | Data | Trade date as string |
| `particulars` | Data | Deal description text |
| `chain_indicator` | Data | Chain/grouping indicator |
| `deal_time` | Data | Time of deal |
| `broker` | Data | Broker reference |
| `bank_dealer` | Data | Dealer reference |
| `row_hash` | Data | MD5 hash for change detection |
| `last_synced` | Datetime | Last sync timestamp |
| `deal_entry_created` | Check | Whether Deal Entry was created |
| `deal_entry_ref` | Data | Reference to created Deal Entry |
| `has_error` | Check | Error flag |
| `error_message` | Small Text | Error details |

---

## 3. BUSINESS RULES & VALIDATIONS

### 3.1 Deal Entry Date Validations

#### 3.1.1 Future Date Restriction
```
IF deal_date > today() THEN
    THROW "Deal Date cannot be in the future."
```

#### 3.1.2 Backdated Deal Restriction
```
IF Forex Settings.restrict_backdated_deals == 1 THEN
    IF deal_date < today() THEN
        THROW "Backdated entries are not allowed. The date cannot be earlier than today."
```

#### 3.1.3 Weekend Restriction
```
IF Forex Settings.restrict_weekend_holiday_entries == 1 THEN
    IF deal_date.weekday() IN [5, 6] THEN  // Saturday, Sunday
        THROW "New entries cannot be created on weekends (Saturday or Sunday)."
```

#### 3.1.4 Holiday Restriction
```
IF Forex Settings.restrict_weekend_holiday_entries == 1 THEN
    IF deal_date IN Maharashtra_holiday_list THEN
        THROW "New entries cannot be created on holidays."
```

#### 3.1.5 Date Sequence Validation
```
IF near_date < deal_date THEN
    THROW "Settlement Date Near cannot be earlier than Contract Date."

IF far_date < near_date THEN
    THROW "Settlement Date Far cannot be earlier than Settlement Date Near."
```

#### 3.1.6 CASH Tenor NY Holiday Check
```
IF near_tenor starts with "CASH" AND deal_date is a New York weekday holiday THEN
    THROW "Cannot use CASH tenor on {date} as it is a New York holiday.
           Settlement cannot be done when New York is closed."
```

#### 3.1.7 TOM/SPOT Overlap Check
```
IF near_tenor == "TOM / SPOT" AND near_date == far_date THEN
    THROW "Cannot use TOM / SPOT tenor on {date} as a New York holiday causes
           both TOM and SPOT to fall on the same date."
```

### 3.2 Tenor Calculation Logic

Tenors determine settlement dates based on the deal date. All calculations skip weekends (Sat/Sun) and holidays from the "Maharashtra + New York" combined holiday list.

#### 3.2.1 Simple Tenors

| Tenor | Calculation | Description |
|-------|------------|-------------|
| **CASH** | `deal_date` (same day) | Same-day settlement |
| **TOM** | `deal_date + 1 working day` | Tomorrow settlement |
| **SPOT** | `deal_date + 2 working days` (with NY adjustment) | Standard T+2 settlement |
| **1M** | `SPOT date + 1 month`, adjusted to next working day | 1-month forward |
| **2M** | `SPOT date + 2 months`, adjusted to next working day | 2-month forward |
| **3M** | `SPOT date + 3 months`, adjusted to next working day | 3-month forward |
| **6M** | `SPOT date + 6 months`, adjusted to next working day | 6-month forward |
| **1Y** | `SPOT date + 12 months`, adjusted to next working day | 1-year forward |
| **2Y** | `SPOT date + 24 months`, adjusted to next working day | 2-year forward |
| **JAN-DEC** | Last working day of that month in current/next year | Month-end forward |

**SPOT Date NY Holiday Adjustment:**
```
1. Calculate TOM = deal_date + 1 working day
2. Calculate raw SPOT = deal_date + 2 working days
3. IF (TOM - deal_date) >= 2 calendar days THEN
    // There's a gap — check if a NY holiday caused it
    IF New York has a weekday holiday between deal_date and TOM THEN
        SPOT = TOM  // Collapse SPOT to TOM
4. RETURN SPOT
```

**Rationale:** When a NY holiday falls between deal date and TOM date, USD settlement for SPOT cannot happen on the expected day, so SPOT collapses to TOM.

#### 3.2.2 Compound Tenors

| Tenor | Near Date | Far Date |
|-------|-----------|----------|
| **CASH / TOM** | CASH (deal_date) | TOM (deal_date + 1 working day) |
| **CASH / SPOT** | CASH | SPOT (with NY adjustment) |
| **TOM / SPOT** | TOM | SPOT (with NY adjustment; uses special check) |
| **SPOT / NEXT** | SPOT | SPOT + 1 working day |

#### 3.2.3 Month Name Tenors (JAN through DEC)

For month-name tenors (e.g., "APR", "SEP"):
```
target_month = month number (APR=4, SEP=9, etc.)
IF target_month < deal_date.month THEN
    target_year = deal_date.year + 1
ELSE
    target_year = deal_date.year

near_date = last_working_day_of(target_year, target_month)
```

Where `last_working_day_of(year, month)`:
```
1. Get last calendar day of month
2. While date is Saturday, Sunday, or holiday:
    Move back one day
3. Return date
```

### 3.3 SPOT Date Calculation — Detailed Algorithm

```python
def calculate_spot_date(deal_date):
    """
    SPOT = T+2 working days from deal_date
    Working days skip: weekends + Maharashtra + New York holidays

    NY Holiday Adjustment:
    If a NY holiday between deal_date and TOM causes calendar gap >= 2 days,
    SPOT collapses to TOM.
    """
    tom = add_working_days(deal_date, 1)  # T+1
    spot = add_working_days(deal_date, 2)  # T+2

    calendar_gap = (tom - deal_date).days
    if calendar_gap >= 2:
        if has_ny_weekday_holiday_between(deal_date, tom):
            spot = tom  # Collapse

    return spot

def add_working_days(start_date, n):
    """Add n working days, skipping weekends and combined MH+NY holidays."""
    date = start_date
    count = 0
    while count < n:
        date += 1 day
        if date.weekday() not in [SAT, SUN] and date not in holidays:
            count += 1
    return date
```

### 3.4 Brokerage Calculation Logic

#### 3.4.1 Core Formula

```
brokerage = LEAST(
    ROUND((brokerage_rate * amount) / 1,000,000, 2),
    brokerage_cap
)
```

Where:
- `brokerage_rate` = rate from the Brokerage child table matching the client, deal type, day range, and date range
- `amount` = deal amount in USD (already in millions)
- `brokerage_cap` = maximum brokerage per deal (from slab config)
- Result is rounded to 2 decimal places
- Cannot exceed the cap

#### 3.4.2 Brokerage Lookup Algorithm (SQL)

```sql
WITH RECURSIVE date_range AS (
    SELECT near_date AS date_val
    UNION ALL
    SELECT DATE_ADD(date_val, INTERVAL 1 DAY)
    FROM date_range WHERE date_val < far_date
),
non_working_days AS (
    -- Count holidays from client's holiday list
    SELECT COUNT(*) as count_val FROM tabHoliday
    WHERE parent IN (SELECT holiday_list FROM tabClient WHERE name = client)
    AND holiday_date BETWEEN near_date AND far_date
    UNION ALL
    -- Count weekends
    SELECT COUNT(*) FROM date_range WHERE DAYOFWEEK(date_val) IN (1, 7)
),
brokerage_calculations AS (
    SELECT
        LEAST(ROUND((brokerage * amount) / 1000000, 2), brokerage_cap) AS calculated_brokerage,
        from_date,
        -- Calculate effective to_date using LEAD window function
        IFNULL(DATE_SUB(LEAD(from_date) OVER (...), INTERVAL 1 DAY), CURDATE()) AS to_date,
        -- Apply range_type multiplier (Months = 30 days)
        (from_days * CASE WHEN range_type = 'Months' THEN 30 ELSE 1 END) AS calculated_from_days,
        -- For Working Days basis, add non-working days to extend range
        (CASE WHEN brokerage_basis = 'Working Days' THEN
            (to_days + SUM(non_working_days))
        ELSE to_days END * CASE WHEN range_type = 'Months' THEN 30 ELSE 1 END) AS calculated_to_days
    FROM tabBrokerage
    WHERE parent = client AND deal_type = deal_type
)
SELECT calculated_brokerage
WHERE difference_in_days BETWEEN calculated_from_days AND calculated_to_days
AND from_date <= deal_date AND deal_date <= to_date
ORDER BY from_date DESC LIMIT 1
```

#### 3.4.3 Key Rules

- **Calendar Days vs Working Days:** When `brokerage_basis` = "Working Days", the system adds non-working days (weekends + holidays) to the `to_days` threshold, effectively expanding the range to account for non-trading days.
- **Range Type:** When `range_type` = "Months", the `from_days` and `to_days` are multiplied by 30 to convert to day equivalents.
- **OR (Outright) Bypass:** For deal type "OR", the day range check is skipped — all Outright deals use the same rate regardless of tenor.
- **Date Range:** Brokerage slabs have an effective `from_date`. The `to_date` is inferred as the day before the next slab's `from_date` (using SQL LEAD function).

#### 3.4.4 Worked Example

**Given:**
- Client: "ABC Bank"
- Deal Type: SS (Short Swap)
- Amount: 5 million USD
- Brokerage rate (from slab): 150 per million
- Brokerage cap: 999999999

**Calculation:**
```
brokerage = LEAST(ROUND((150 * 5000000) / 1000000, 2), 999999999)
          = LEAST(ROUND(750.00, 2), 999999999)
          = 750.00
```

**With Cap Example:**
- Same deal but brokerage_cap = 500

```
brokerage = LEAST(750.00, 500)
          = 500.00
```

#### 3.4.5 External Broker Brokerage Logic

```
IF broker is house_broker THEN
    seller_brokerage = calculated_brokerage
    ex_seller_brokerage = 0
ELSE (external broker)
    seller_brokerage = 0  // Company earns nothing
    ex_seller_brokerage = calculated_brokerage  // Track for reference
```

The `virtual_*_brokerage` fields always store the full calculated value regardless of broker assignment, serving as the "expected" brokerage before broker-based adjustments.

### 3.5 Deal Type Determination Logic

The system automatically determines the deal type (SS/LS/OR) based on:

```sql
-- Same CTE structure as brokerage calculation
-- but returns deal_type instead of brokerage amount
SELECT deal_type
FROM brokerage_with_adjustments
WHERE difference_in_days BETWEEN from_days AND to_days
AND from_date <= deal_date AND deal_date <= to_date
ORDER BY deal_type DESC LIMIT 1

-- Fallback: If no matching slab found, use client's default_deal_type
```

### 3.6 Discount Calculation Logic

Discounts are applied during report generation (not at deal entry time). The discount reduces the brokerage on the brokerage bill.

#### 3.6.1 Discount Types

| `mhy` Value | Period | Description |
|---|---|---|
| **M** (Monthly) | Calendar month | Discount calculated per month |
| **H** (Half-yearly) | April-September or October-March | Two 6-month periods per financial year |
| **Y** (Yearly) | April to March | Full Indian financial year |

| `if` Value | Method | Description |
|---|---|---|
| **I** (Individual/Incremental) | Only the amount above the slab threshold gets discounted | Marginal discount |
| **F** (Full) | Entire amount is discounted at the slab rate | Flat discount |

| `disc_on` Value | Basis | Description |
|---|---|---|
| **Brokerage** | Total brokerage amount in the period | Discount based on accumulated brokerage |
| **Volume** | Total deal volume in the period | Discount based on accumulated deal volume |

#### 3.6.2 Discount Calculation Algorithm

```python
def calculate_discount(client, period_start, period_end, total_brokerage, total_volume):
    discount_config = get_discount_slabs(client, deal_type, period)

    # Sort slabs by from_slab ascending
    for slab in discount_config:
        basis_amount = total_brokerage if slab.disc_on == "Brokerage" else total_volume

        if basis_amount >= slab.from_slab:
            if slab.if == "I":  # Incremental
                # Only discount the amount above the slab threshold
                discountable = basis_amount - slab.from_slab
                discount = discountable * slab.pct / 100
            else:  # F = Full
                # Discount the entire brokerage amount
                discount = total_brokerage * slab.pct / 100
```

### 3.7 Swap Deal Logic

#### 3.7.1 Standard Swap (non-multi-counterparty)

- **Near Leg:** Seller sells USD to Buyer at `near_rate` on `near_date`
- **Far Leg:** Roles reverse — the near-leg Buyer becomes the far-leg Seller, and vice versa
- **Difference (Swap Points):** `far_rate - near_rate` (always positive for standard swaps as far_rate >= near_rate)

**Far Leg Role Reversal:**
```
Far Leg Contract:
    seller = near_leg.buyer
    buyer = near_leg.seller
    seller_broker = near_leg.buyer_broker
    buyer_broker = near_leg.seller_broker
    sell_brokerage = near_leg.buyer_brokerage
    buy_brokerage = near_leg.seller_brokerage
    seller_agent = near_leg.buyer_agent
    buyer_agent = near_leg.seller_agent
```

#### 3.7.2 Multi-Counterparty Swap

In a multi-counterparty deal, the near and far legs can involve different counterparties (banks). The `_fl` (far leg) fields hold the far leg's seller and buyer independently.

**S/B Direction (Sell/Buy):**
- Near leg: Company's client is the **Seller**
- Far leg: Company's client is the **Buyer**
- `seller_status` = "Open", `buyer_status` = "Close"
- `seller_status_fl` = "Close", `buyer_status_fl` = "Open"

**B/S Direction (Buy/Sell):**
- Near leg: Company's client is the **Buyer**
- Far leg: Company's client is the **Seller**
- `buyer_status` = "Open", `seller_status` = "Close"
- `buyer_status_fl` = "Open", `seller_status_fl` = "Close"

**Contract Creation Rules for Multi-Counterparty:**
```
FOR each leg (Near/Far):
    IF direction is S/B:
        Near: only print seller copy (not buyer)
        Far: only print buyer copy (not seller)
    IF direction is B/S:
        Near: only print buyer copy (not seller)
        Far: only print seller copy (not buyer)
```

### 3.8 Deal Confirmation Text Generation

The confirmation text is a standardized message describing the deal, formatted as:

```
[Time] [Party Action] [Counterparty]
USD [Amount] Mn AT [Rate]
VALUE [Settlement Date]
```

**For Seller (near leg):**
```
{seller_time} SOLD TO {buyer_bank_name}
USD {amount} Mn AT {near_rate}
VALUE {near_date_formatted}
```

**For Buyer (near leg):**
```
{buyer_time} BOT FROM {seller_bank_name}
USD {amount} Mn AT {near_rate}
VALUE {near_date_formatted}
```

**For Swap deals, append far leg:**
```
[Seller Near Confirmation]
{seller_time} BOT FROM {seller_fl_bank_name}
USD {amount} Mn AT {far_rate}
VALUE {far_date_formatted}
```

**External Broker Prefix:** When the broker is not the house broker, the confirmation is prefixed with the broker's name.

**Multi-counterparty:** Only the relevant side's confirmation is set:
- S/B: Only seller confirmation
- B/S: Only buyer confirmation

### 3.9 Contract Number Generation

Contract numbers are sequential per date:
```
Format: YYMMDD###
- Outright: 1 contract number
- Swap: 2 consecutive numbers (N, N+1 for near and far legs)
- Generated atomically using SELECT MAX ... FOR UPDATE to prevent race conditions
```

### 3.10 Rate and Difference Calculations

```javascript
// Three-way rate calculation (any two determine the third):
IF near_rate AND far_rate THEN
    difference = far_rate - near_rate  // Can be negative

IF near_rate AND difference THEN
    far_rate = near_rate + difference

IF far_rate AND difference THEN
    near_rate = far_rate - difference
```

### 3.11 Amount in Words Conversion

The `amount` field represents millions of USD. The system converts this to English words:

```javascript
// Algorithm: Standard Western number-to-words
// Input: numeric value (e.g., 5.5)
// Output: "Five Point 50"

// Uses scales: '', 'Thousand', 'Million', 'Billion'
// Handles decimals as "Point XX"
```

### 3.12 GST Calculation Rules

```
IF client's state == Maharashtra (intrastate) THEN
    CGST = brokerage * cgst_rate / 100  (default 9%)
    SGST = brokerage * sgst_rate / 100  (default 9%)
    Total GST = CGST + SGST
ELSE (interstate)
    IGST = brokerage * igst_rate / 100  (default 18%)
    Total GST = IGST
```

**Validation in Forex Settings:**
- GST rates cannot be negative
- GST rates cannot exceed 100%
- Warning if IGST != CGST + SGST

### 3.13 Seller/Buyer Status Tracking

For multi-counterparty deals, each party side has an "Open" or "Close" status:

- **Open:** The position is unmatched — waiting for a counterparty deal
- **Close:** The position is matched with another deal

When deals are matched (via the multi-counterparty dialog), the corresponding status fields update and close references are set pointing to the matched deal.

### 3.14 Broker Reassignment Logic

After multi-counterparty deals are matched:

```python
def reassign_broker(deal_date):
    """
    For each matched pair (Open→Close):
    1. Get house broker
    2. If one deal uses house broker and the matched deal uses an external broker:
       Replace house broker with external broker on the relevant fields
    3. Handles both NEAR and FAR leg field mapping
    """
    for each matched_pair:
        deal_name_broker = get_broker(deal)
        match_broker = get_broker(matched_deal)

        if deal_name_broker == house_broker and match_broker != house_broker:
            update deal's broker to match_broker
        elif match_broker == house_broker and deal_name_broker != house_broker:
            update matched_deal's broker to deal_name_broker
```

### 3.15 Far Leg Field Auto-Population (Non-Multi-Counterparty Swap)

```javascript
// When seller is set and deal_type is not Outright:
frm.set_value('buyer_fl', seller)  // Far leg buyer = near leg seller

// When buyer is set and deal_type is not Outright:
frm.set_value('seller_fl', buyer)  // Far leg seller = near leg buyer

// Broker mirroring for non-multi-counterparty:
buyer_broker_fl = seller_broker  // Far leg buyer broker = near leg seller broker
seller_broker_fl = buyer_broker  // Far leg seller broker = near leg buyer broker
```

---

## 4. WORKFLOWS & PROCESSES

### 4.1 Deal Entry Creation Flow

```
1. User opens Deal Entry list (default: Report view)
2. System auto-fetches next deal_entry_no for today's date
3. User sets deal_date (defaults to today, validated against restrictions)
4. System calculates near_date from near_tenor (default: SPOT)
5. User enters amount (in millions, multiplied by 1,000,000 for storage)
6. User enters near_rate (and far_rate for Swap)
7. System auto-calculates difference (swap points) and amount_in_words
8. User selects seller and buyer (Client links)
9. System auto-fetches:
   - seller_deal_type / buyer_deal_type (from brokerage slabs)
   - seller_dealer / buyer_dealer (from Dealer Team)
   - seller_brokerage / buyer_brokerage (calculated)
10. User selects brokers (defaults to house broker)
11. System generates deal confirmation text
12. On Save:
    a. Validate all dates, restrictions, rates
    b. Generate deal_entry_no
    c. Create Deal Confirmation documents (seller + buyer)
    d. Create Forex Contract documents (near leg + far leg for Swap)
    e. Store contract_no references on Deal Entry
```

### 4.2 Deal Entry → Forex Contracts

```
AFTER INSERT of Deal Entry:
    IF NOT multi_counterparty:
        Generate contract numbers:
            Outright → 1 number
            Swap → 2 numbers (consecutive)

        Create Forex Contract for NEAR leg:
            contract_no = first number
            contract_date = deal_date
            delivery = near_date
            rate = near_rate
            seller, buyer = from Deal Entry near leg
            leg_type = "Near"

        IF deal_type == "Swap":
            Create Forex Contract for FAR leg:
                contract_no = second number
                contract_date = deal_date
                delivery = far_date
                rate = far_rate
                IF multi_counterparty:
                    seller = seller_fl, buyer = buyer_fl
                ELSE:
                    seller = buyer (reversed), buyer = seller (reversed)
                leg_type = "Far"

    IF multi_counterparty:
        Contracts are created later during broker reassignment
```

### 4.3 Deal Confirmation Creation

```
FOR each side (Seller, Buyer):
    IF multi_counterparty:
        IF S/B and client_type == Buyer → SKIP
        IF B/S and client_type == Seller → SKIP

    IF confirmation text is blank → SKIP

    Generate deal_confirm_no:
        Query: MAX(deal_confirm_no) + 1 WHERE deal_date = X AND client = Y

    Create Deal Confirmation:
        deal_date, deal_confirm_no, deal_entry_no, contract_no
        client, client_type, broker, deal_confirmation (text)
```

### 4.4 Multi-Counterparty Deal Workflow

```
1. User creates Deal Entry with multi_counterparty = 1
2. User selects S/B or B/S direction
3. System opens dialog showing existing Open deals for the date
4. User selects a matching deal from the dialog
5. System populates counterparty fields from matched deal
6. On Save:
   - Deal Entry is created
   - Statuses update (Open/Close)
   - Close references are set
7. "Re-assign Broker" button (on list view):
   - Syncs brokers between matched pairs
   - Creates Forex Contracts with correct broker assignments
   - Syncs deal types across linked deals
```

### 4.5 Contract Printing Process

Two printing methods:

**A4 Portrait (Overlay on pre-printed forms):**
```
1. Select contracts from Forex Contracts list view
2. Click "Print Contracts"
3. System generates PDF using ReportLab:
   - Two copies per A4 page (seller copy top, buyer copy bottom)
   - Text positioned at exact coordinates on blank page
   - Overlaid on pre-printed contract note paper
4. Each contract marked as printed (printed = 1)
```

**A5 Landscape / PNG Template:**
```
1. Select contracts from list view
2. Click "Print Contracts (PDF)"
3. System loads Blank-Contract-Note.png template
4. Uses PIL/Pillow to overlay text at pixel coordinates
5. Converts images to PDF using img2pdf
6. Each contract marked as printed_pdf = 1
```

**Print Copy Rules:**
- Seller's copy shows seller time (if `print_time_on_contract_note` enabled)
- Buyer's copy shows buyer time
- Copy label: "Seller's Copy" / "Buyer's Copy" for house broker deals
- For external broker deals, the copy label shows the external broker's name
- A4 Portrait always prints both copies; A5 respects the `print_other_brokers_contract_notes` setting

### 4.6 Google Sheet Sync Workflow

```
1. Google Sheets Integration Settings configured with:
   - Service Account JSON credentials
   - Spreadsheet ID, worksheet name
   - Sync direction (Import/Export/Bi-directional)

2. IMPORT flow:
   a. Connect to Google Sheets API via service account
   b. Read all rows from configured worksheet
   c. For each row:
      - Parse: trade_date, particulars, chain_indicator, deal_time, broker
      - Calculate row_hash (MD5) for change detection
      - Create/update Google Sheet Entries record
   d. For new entries (not yet converted to Deal Entry):
      - Parse deal details from 'particulars' column
      - Calculate tenor, dates, brokerage
      - Build and insert Deal Entry
      - Generate confirmation text
      - Mark entry as deal_entry_created = 1

3. EXPORT flow:
   a. Query Deal Entries matching filters
   b. Map fields to spreadsheet columns
   c. Write to Google Sheet

4. AUTO-SYNC:
   - Every 15 minutes (cron)
   - Hourly, daily, weekly (scheduler_events)
   - On document update/submit (doc_events hooks)
```

---

## 5. UI/UX LOGIC

### 5.1 Deal Entry Form (`deal_entry.js`)

#### 5.1.1 Field Change Handlers

| Field | On Change | Action |
|-------|-----------|--------|
| `deal_date` | Validate | Check future date, backdated restriction, weekend/holiday. Store preference in localStorage. Fetch next deal_entry_no. Recalculate tenor dates. |
| `deal_type` | Change to Outright | Clear far_rate, far_date, far_tenor, difference. Set seller/buyer deal_type to OR. Recalculate brokerage. |
| `deal_type` | Change to Swap | Remove read-only from deal type fields. Reset deal types. Calculate far date. |
| `near_tenor` | Change | Calculate near_date (and far_date/far_tenor for compound tenors). Validate CASH NY holiday, TOM/SPOT overlap. |
| `near_date` | Change | Auto-adjust far_date if near >= far. Recalculate far tenor. |
| `far_date` | Change | Determine if last working day of month → set far_tenor month picker. Validate dates. Refresh client selections. |
| `amount` | Change | Multiply by 1,000,000. Calculate amount_in_words. Refresh client selections (recalculate brokerage). |
| `near_rate` | Change | Update difference/far_rate. Validate far >= near for Swap. |
| `far_rate` | Change | Update difference/near_rate. Validate far >= near for Swap. |
| `difference` | Change | Calculate far_rate from near_rate + difference, or near_rate from far_rate - difference. |
| `seller` | Change | For Swap: set buyer_fl = seller. Fetch deal type, dealer, brokerage. Update confirmation. |
| `buyer` | Change | For Swap: set seller_fl = buyer. Fetch deal type, dealer, brokerage. Update confirmation. |
| `seller_fl` / `buyer_fl` | Change | Update confirmation for non-Outright deals. |
| `seller_broker` | Change | If external broker: clear dealer, set brokerage to 0, move to ex_brokerage. Sync _fl broker for Swap. |
| `buyer_broker` | Change | Same as seller_broker but for buyer side. |
| `seller_deal_type` | Change | Calculate brokerage for OR deal type. Sync _fl deal type. |
| `buyer_deal_type` | Change | Same as seller_deal_type. |
| `multi_counterparty` | Check | Open multi-counterparty dialog showing open deals. Adjust field navigation. |
| `sb` | Check | Mutually exclusive with bs. Set Open/Close statuses. S/B: seller_status=Open, buyer_status=Close. |
| `bs` | Check | Mutually exclusive with sb. B/S: buyer_status=Open, seller_status=Close. |
| `seller_time` / `buyer_time` | Change | Update deal confirmation text. |
| `seller_agent` / `buyer_agent` | Change | Update deal confirmation text. |
| `seller_brokerage` | Change | Sync buyer_brokerage_fl for Swap. |
| `buyer_brokerage` | Change | Sync seller_brokerage_fl for Swap. |

#### 5.1.2 Keyboard Navigation

The form supports **Enter key navigation** between fields in a defined sequence:

**Swap Default:** `amount → near_rate → far_rate → near_tenor → near_date → far_tenor → far_date → multi_counterparty → seller → buyer → seller_time → buyer_time → seller_broker → buyer_broker`

**Outright:** `deal_type → near_rate → multi_counterparty → seller → buyer → seller_time → buyer_time → seller_broker → buyer_broker`

**Multi S/B:** `amount → near_rate → far_rate → difference → near_tenor → far_tenor → multi_counterparty → sb → seller → buyer → seller_fl → seller_broker → buyer_broker → seller_time → buyer_time`

**Multi B/S:** `amount → near_rate → far_rate → difference → near_tenor → near_date → far_tenor → far_date → multi_counterparty → bs → buyer → seller → buyer_fl → seller_broker → buyer_broker → seller_time → buyer_time`

- **Enter:** Move to next field
- **Shift+Enter:** Move to previous field
- Special handling for `far_tenor` which uses a month picker HTML input

#### 5.1.3 Dynamic Field Visibility (depends_on)

| Field/Section | Visible When |
|---|---|
| `far_rate` | `deal_type == 'Swap'` |
| `far_date` | `deal_type == 'Swap'` |
| `far_tenor` | `deal_type == 'Swap'` |
| `difference` | `deal_type == 'Swap'` |
| `far_contract_no` | `deal_type == 'Swap'` |
| `far_leg_section` | `multi_counterparty == 1 && deal_type === 'Swap'` |
| `sb` | `multi_counterparty == 1` |
| `bs` | `multi_counterparty == 1` |
| `multi_deal_group` | `multi_counterparty == 1` |
| `near_create_forex_contract` | `multi_counterparty == 1` |
| `far_create_forex_contract` | `multi_counterparty == 1 && deal_type == 'Swap'` |
| `seller_fl` / `buyer_fl` | Mandatory when `deal_type != 'Outright'` |
| `seller_broker_fl` / `buyer_broker_fl` | Mandatory when `multi_counterparty == 1 && deal_type == 'Swap'` |
| `seller_deal_type_fl` / `buyer_deal_type_fl` | `deal_type == 'Swap'` and mandatory when multi_counterparty Swap |
| `cross_match_section` | `seller != buyer_fl || buyer != seller_fl` |

#### 5.1.4 Number Format Configuration

```javascript
// Amount field: Western format (#,###.##) — e.g., 1,234,567.89
frappe.meta.get_field("Deal Entry", "amount").number_format = "#,###.##"

// Brokerage fields: Indian format (#,##,###.##) — e.g., 12,34,567.89
// Applied to all *_brokerage* fields
frappe.meta.get_field("Deal Entry", "seller_brokerage").number_format = "#,##,###.##"
```

#### 5.1.5 Custom Buttons and Actions

| Button | Location | Action |
|--------|----------|--------|
| "Show Linked Contracts" | Form toolbar | Opens dialog showing all contracts from `vwDealMultiCounterparty` view |
| "New Deal Entry" | Form (after save) | Clears form for new entry, restores deal_date preference |
| PDF button (seller/buyer) | In seller_html/buyer_html | Generates deal confirmation PDF with letterhead |
| Print button (seller/buyer) | In seller_html/buyer_html | Opens print preview in new window |
| Email button (seller/buyer) | In seller_html/buyer_html | Opens CommunicationComposer with pre-filled recipient, subject, body |

#### 5.1.6 Far Tenor Month Picker

The `far_tenor` field is replaced with a custom HTML month picker (`<input type="month">`) that:
- Shows year-month selector
- On change: calculates last working day of selected month
- On Enter: validates and navigates to next field
- Resets to empty when far_date is not the last working day of its month

#### 5.1.7 Brokerage Mismatch Checker

After save, the system compares saved brokerage values with freshly calculated expected values:
```
For each client (seller, buyer):
    For each leg (near, far if Swap):
        expected = call get_brokerage API
        actual = saved brokerage value
        IF |expected - actual| > 0.01 THEN
            Flag as mismatch

IF mismatches found:
    Show modal with comparison table
    Primary action: "Update to Expected Brokerage" → calls update_brokerage_values API
    Secondary action: "No Changes Required"
```

### 5.2 Deal Entry List View (`deal_entry_list.js`)

#### 5.2.1 Action Buttons

| Button | Action |
|--------|--------|
| "Deal Confirmation" | Opens dialog to select date range → loads clients → loads deal confirmations → allows emailing selected confirmations |
| "Re-assign Broker" | Reassigns brokers for multi-counterparty deals on selected date |
| "Today" | Filters to today's deals |
| "This Week" | Filters to current week (Mon-Sun) |
| "This Month" | Filters to current month |
| "This Year" | Filters to current year |
| "Clear Date Filter" | Removes all date filters |

#### 5.2.2 Persistent Date Filter

- A date field is added to the page header
- Selected date is stored in localStorage (`deal_entry_last_date`)
- Resets to today on a new calendar day

### 5.3 Forex Contracts List View (`forex_contracts_list.js`)

#### 5.3.1 Filters and Actions

| Feature | Description |
|---------|-------------|
| Date filter | Contract date filter with localStorage persistence |
| Client filter | Dynamic query showing clients with contracts on selected date |
| Print status tabs | "All", "Printed", "Not Printed" tabs filtering by `printed` field |
| "Print Contracts" button | Bulk generates overlay PDF for selected contracts |
| "Print Contracts (PDF)" button | Bulk generates PNG template PDF for selected contracts |

### 5.4 Client Form (`client.js`)

#### 5.4.1 Default Values on Load

- `client_centre` → defaults to "Mumbai"
- `default_deal_type` → defaults to "Long Swap"

#### 5.4.2 Custom Buttons

| Button | Group | Action |
|--------|-------|--------|
| "Accounts Receivable" | View | Navigate to Accounts Receivable report filtered by client |
| "Accounting Ledger" | View | Navigate to General Ledger filtered by client |
| "Export Profile to PDF" | Actions | Generate PDF with all client details |

#### 5.4.3 Brokerage Validations (Client-Side)

```javascript
// In validate handler:
FOR each brokerage row:
    IF to_days < from_days THEN
        SHOW "To Days must be greater than From Days in row {idx}"
        BLOCK save

    IF brokerage == 0 THEN
        SHOW "Brokerage cannot be 0 in row {idx}"
        BLOCK save
```

#### 5.4.4 Holiday List Visibility

The `holiday_list` field is shown only when any brokerage row has `brokerage_basis = "Working Days"`. Default value: Holiday List where `country = 'IN'` and `subdivision = 'MH'` (Maharashtra).

#### 5.4.5 Dealer Filter

In the co_dealer table, the dealer_name filter excludes already-selected dealers to prevent duplicates.

### 5.5 Client List View (`client_list.js`)

| Button | Action |
|--------|--------|
| "Without Brokerage" | Filters to show clients without brokerage configuration |
| "Export to Excel" | Downloads all clients as Excel file |
| "Export All Profiles to PDF" | Downloads all client profiles as single PDF |

### 5.6 Forex Broker List View (`forex_broker_list.js`)

| Button | Action |
|--------|--------|
| "Export to Excel" | Downloads all brokers as Excel file |
| "Export All Profiles to PDF" | Downloads all broker profiles as single PDF |

---

## 6. PRINT FORMATS & REPORTS

### 6.1 Brokerage Bill Report

**Type:** Script Report
**Ref DocType:** Forex Contracts

**Filters:**
- Month (Select: January-December)
- Year (Data)
- Client (Link → Client)

**Logic:**
1. Query all Forex Contracts for the selected month/year
2. Group by client
3. For each client, calculate:
   - Total brokerage (sum of sell_brokerage + buy_brokerage where broker is house broker)
   - Apply discount based on client's discount configuration
   - Calculate GST (CGST+SGST or IGST based on client location)
   - Net payable = Brokerage - Discount + GST

**Export Options:**
- PDF (using `brokerage_bill_pdf.html` template with letterhead)
- Excel Summary
- Excel Bill (detailed per-client tabs)

### 6.2 Deal Type Brokerage Summary Report

**Filters:** Date range, Client

**Logic:**
1. Group contracts by deal type (SS, LS, OR)
2. For each deal type: count, total volume, total brokerage
3. Apply discount calculations per deal type
4. Support single-month and multi-month views
5. Detailed view with expandable rows per bank

**Export Options:** Excel, PDF

### 6.3 Volume and Brokerage Summary Report

**Filters:** Date range, Broker, Show Brokerage toggle

**Logic:**
1. Group contracts by client
2. Show: deal count, total volume, total brokerage (optional)
3. Single and multi-month views
4. Filter by specific broker

**Export Options:** Excel, PDF (using `volume_and_brokerage_summary_pdf.html`)

### 6.4 Deal Confirmation Report

**Filters:** Date range, Broker, Client

**Logic:**
1. Query deal confirmations matching filters
2. Group by client
3. Display confirmation text

**Export Options:** PDF, Word (DOCX), Email (as body or attachment)

### 6.5 Contract Bankwise Report

**Filters:** Date

**Logic:**
1. UNION query: seller-side + buyer-side contracts
2. Group by bank name
3. Show contract details per bank

**Export:** PDF (using `contract_bankwise_pdf.html`)

### 6.6 Forex Contracts Report

**Filters:** Date

**Logic:**
1. Query all contracts for date
2. Show: contract_no, seller, buyer, amount, rate, delivery, brokerage
3. Summary row with totals

**Export:** CSV/Excel

### 6.7 Dealer Performance Report

**Filters:** Date range, Dealer, Hide Deal Type toggle

**Logic:**
1. Query deals grouped by dealer
2. Calculate: deal count, volume, brokerage per dealer
3. Apply discount calculations
4. Support multi-month analysis
5. Detailed view with bank breakdowns

**Export Options:** Excel, PDF

### 6.8 Contract Note PDF Generation

**Two formats:**

**A4 Portrait (overlay):**
- Uses ReportLab canvas drawing
- Two copies per page (seller top half, buyer bottom half)
- Text positioned at exact mm coordinates on blank page
- Fields: time, number, date, seller name, seller agent, buyer name, buyer agent, amount, currency (USD), payment type (T.T), settlement currency (INR), payment location (NEW YORK), rate, delivery date, delivery location (MUMBAI), amount in words
- Copy label at bottom: "Seller's Copy" / "Buyer's Copy" or broker name

**A5 Landscape (PNG template):**
- Uses PIL/Pillow to overlay on PNG template image
- One copy per page
- Converts to PDF using img2pdf
- Same fields positioned at pixel coordinates

### 6.9 PDF Templates (Jinja HTML)

**brokerage_bill_pdf.html:** Company header, bill recipient, period, contract table (date, seller, buyer, amount, rate, brokerage), subtotals, GST breakdown, grand total.

**brokerage_summary_pdf.html:** Simple table with deal type columns and totals.

**contract_bankwise_pdf.html:** Grouped by bank with subtotals per bank and grand totals.

**volume_and_brokerage_summary_pdf.html:** Company header, period, client rows with deal count/volume/brokerage, totals row.

---

## 7. INTEGRATIONS

### 7.1 Google Sheets Integration

#### 7.1.1 Authentication

- **Method:** Service Account (primary)
- Service Account JSON credentials stored in `google_integration_settings`
- Uses `gspread` library with `google.oauth2.service_account.Credentials`
- Scopes: `https://spreadsheets.google.com/feeds`, `https://www.googleapis.com/auth/drive`

#### 7.1.2 Sync Directions

- **Import:** Google Sheet → Google Sheet Entries → Deal Entry
- **Export:** Deal Entry → Google Sheet
- **Bi-directional:** Both import and export

#### 7.1.3 Import Field Mapping

Google Sheet columns are parsed from the `particulars` field, which contains deal description text. The parsing extracts:
- Trade date, deal time
- Broker name → mapped to Forex Broker
- Bank/client names → mapped to Client
- Amount, rate, tenor
- Deal type (Swap/Outright)

#### 7.1.4 Change Detection

Each row gets an MD5 `row_hash`. On re-sync, changed rows are detected by comparing hashes.

#### 7.1.5 Auto-Sync Schedule

| Frequency | Trigger |
|-----------|---------|
| Every 15 minutes | Cron: `*/15 * * * *` |
| Hourly | Frappe scheduler |
| Daily | Frappe scheduler |
| Weekly | Frappe scheduler |
| On document update | `doc_events.*.on_update` hook |
| On document submit | `doc_events.*.on_submit` hook |

### 7.2 Email Integration

- Deal confirmations can be emailed via `frappe.sendmail`
- Uses Frappe's built-in `CommunicationComposer` for interactive email composition
- Email content includes formatted deal confirmation text with HTML styling

---

## 8. SETTINGS & CONFIGURATIONS

### 8.1 Forex Settings (Singleton)

| Setting | Default | Impact |
|---------|---------|--------|
| `igst_rate` | 18% | Interstate GST on brokerage bills |
| `cgst_rate` | 9% | Central GST (intrastate) |
| `sgst_rate` | 9% | State GST (intrastate) |
| `restrict_weekend_holiday_entries` | Enabled | Blocks deal entry on weekends/holidays |
| `restrict_backdated_deals` | Enabled | Blocks deal entry with past dates |
| `contract_print_paper_size` | A4 Portrait | PDF layout: "A4 Portrait" (2-up) or "A5 Landscape" (1-up) |
| `print_other_brokers_contract_notes` | Disabled | Include external broker contracts in print jobs (read-only for A4) |

### 8.2 Fixtures (Pre-loaded Data)

The application pre-loads the following via fixtures:

| Fixture | Source |
|---------|--------|
| Forex Settings | `fixtures_/forex_settings.json` |
| Google Integration Settings | `fixtures_/google_integration_settings.json` |
| Client | `fixtures_/client.json` |
| Dealer | `fixtures_/dealer.json` |
| Forex Broker | `fixtures_/forex_broker.json` |
| Deal Type | `fixtures_/deal_type.json` |
| DealType | `fixtures_/dealtype.json` |
| Brokerage | `fixtures_/brokerage.json` |
| Discount | `fixtures_/discount.json` |
| Client Centre | `fixtures_/client_centre.json` |
| Address | `fixtures_/address.json` |
| Dynamic Link | `fixtures_/dynamic_link.json` |
| List View Settings (Forex Contracts) | `fixtures/list_view_settings.json` |
| Custom Field (Company) | `fixtures_/custom_field.json` |
| Property Setter (Company, Address) | `fixtures/property_setter.json` |

---

## 9. HOOKS & EVENT HANDLERS

### 9.1 hooks.py Configuration

```python
# CSS included in web pages
web_include_css = "/assets/forex/css/backoffice_login.css"

# After migrate hook
after_migrate = ["forex.tasks.migrate.after_migrate_hook"]

# Document events — fires on EVERY doctype
doc_events = {
    "*": {
        "on_update": "forex.forex.doctype.google_integration_settings.tasks.on_doc_update",
        "on_submit": "forex.forex.doctype.google_integration_settings.tasks.on_doc_submit"
    }
}

# Scheduled tasks
scheduler_events = {
    "cron": {
        "*/15 * * * *": ["...tasks.auto_sync_every_15_minutes"],
        "0 10 * * *": ["...forex_contracts.cleanup_old_contract_pdfs"]
    },
    "hourly": ["...tasks.auto_sync_hourly"],
    "daily": ["...tasks.auto_sync_daily"],
    "weekly": ["...tasks.auto_sync_weekly"]
}

# Fixtures
fixtures = [
    "Forex Settings", "Google Integration Settings", "Client", "Dealer",
    "Forex Broker", "Deal Type", "DealType", "Brokerage", "Discount",
    "Client Centre", "Address", "Dynamic Link",
    {"dt": "List View Settings", "filters": [["name", "=", "Forex Contracts"]]},
    {"dt": "Custom Field", "filters": [["dt", "=", "Company"]]},
    {"dt": "Property Setter", "filters": [["doc_type", "in", ["Company", "Address"]]]}
]
```

### 9.2 After Migrate Hook

`forex.tasks.migrate.after_migrate_hook` syncs:
1. Workspace configuration (`forex/workspace/forex/forex.json`)
2. DocType definitions for all forex doctypes
3. Report configurations
4. Uses JSON file comparison to detect changes

### 9.3 Scheduled Tasks

| Task | Schedule | Description |
|------|----------|-------------|
| `auto_sync_every_15_minutes` | Every 15 min | Google Sheets incremental sync |
| `auto_sync_hourly` | Hourly | Google Sheets sync |
| `auto_sync_daily` | Daily | Google Sheets full sync |
| `auto_sync_weekly` | Weekly | Google Sheets full sync |
| `cleanup_old_contract_pdfs` | Daily at 10 AM | Delete forex_contracts_*.pdf files older than 1 day |

---

## 10. CALCULATIONS & FORMULAS

### 10.1 Summary of All Formulas

| Calculation | Formula | Example |
|---|---|---|
| **Brokerage** | `MIN(ROUND(rate × amount / 1,000,000, 2), cap)` | MIN(ROUND(150 × 5,000,000 / 1,000,000, 2), 999999999) = 750.00 |
| **Swap Difference** | `far_rate - near_rate` | 84.5500 - 84.2000 = 0.3500 |
| **Far Rate from Difference** | `near_rate + difference` | 84.2000 + 0.3500 = 84.5500 |
| **Near Rate from Difference** | `far_rate - difference` | 84.5500 - 0.3500 = 84.2000 |
| **Days Between** | `(far_date - near_date).days` | (2026-06-15 - 2026-03-15) = 92 days |
| **CGST** | `brokerage × cgst_rate / 100` | 750 × 9 / 100 = 67.50 |
| **SGST** | `brokerage × sgst_rate / 100` | 750 × 9 / 100 = 67.50 |
| **IGST** | `brokerage × igst_rate / 100` | 750 × 18 / 100 = 135.00 |
| **Net Bill (Intrastate)** | `brokerage - discount + CGST + SGST` | 750 - 37.50 + 64.13 + 64.13 = 840.76 |
| **Net Bill (Interstate)** | `brokerage - discount + IGST` | 750 - 37.50 + 128.25 = 840.75 |
| **Working Days Adjustment** | `to_days + weekends_count + holidays_count` | 30 + 8 + 2 = 40 calendar days |
| **Month Tenor** | `SPOT_date + N months → adjust to next working day` | SPOT=Mar 17 + 1M = Apr 17 → Apr 17 (if working day) |
| **Contract Number** | `YYMMDD + zero-padded serial` | 260315 + 001 = 260315001 |
| **Deal Entry Number** | `YYMMDD + zero-padded serial` | 260315 + 001 = 260315001 |
| **Discount (Incremental)** | `(total_brokerage - slab_threshold) × pct / 100` | (10000 - 5000) × 5 / 100 = 250.00 |
| **Discount (Full)** | `total_brokerage × pct / 100` | 10000 × 5 / 100 = 500.00 |

### 10.2 Amount Handling

- User enters amount in **millions** (e.g., user types "5" for 5 million USD)
- System stores as full value: `5 × 1,000,000 = 5,000,000`
- Display uses Western format: `5,000,000.00`
- Amount in words: "Five Million"

---

## 11. EDGE CASES & SPECIAL HANDLING

### 11.1 Seller == Buyer

The system does not explicitly prevent seller and buyer from being the same entity. However, the client filter logic (`setClientFilters`) prevents selecting the same client on both sides of the **same leg** by excluding the already-selected client from the opposite field's dropdown.

### 11.2 Same-Day Deals (CASH Tenor)

- CASH tenor sets near_date = deal_date
- Blocked if deal_date is a New York weekday holiday (USD cannot settle)
- No far leg for CASH Outright deals

### 11.3 Weekend/Holiday Boundary Handling

- Working day calculations skip both weekends and holidays
- When a calculated date falls on a weekend: Saturday → advance to Monday; Sunday → advance to Monday
- When a calculated date falls on a holiday: advance to next non-holiday working day (recursive check)
- For last working day of month: move backward from last calendar day, skipping weekends and holidays

### 11.4 Multi-Counterparty with Different Brokers on Near vs Far Leg

The broker reassignment logic handles this:
1. After deals are matched, the system checks if one deal has house broker and the other has external broker
2. The external broker replaces the house broker on the appropriate fields
3. Far leg broker fields (`seller_broker_fl`, `buyer_broker_fl`) can differ from near leg brokers

### 11.5 Contract Printing Restrictions for Multi-Counterparty

```python
IF multi_counterparty AND S/B:
    Near leg: print seller copy only (skip buyer)
    Far leg: print buyer copy only (skip seller)

IF multi_counterparty AND B/S:
    Near leg: print buyer copy only (skip seller)
    Far leg: print seller copy only (skip buyer)
```

### 11.6 Backdated Deal Restrictions

When `restrict_backdated_deals` is enabled:
- New deals with `deal_date < today()` are blocked
- The check uses IST timezone (`moment().utcOffset('+05:30')` on client side)
- Error: "Backdated entries are not allowed. The date cannot be earlier than today."

### 11.7 Deal Type Syncing Across Grouped Deals

For multi-counterparty deals, the `sync_multi_counterparty_deal_types` function:
1. Identifies the "anchor" client based on direction (S/B or B/S)
2. The anchor client's deal type is the authoritative source
3. Syncs deal type from source deal to target deal for both near and far legs

### 11.8 New York Holiday Impact on SPOT

When a New York holiday falls between deal_date and TOM date:
- SPOT collapses to equal TOM (T+1 instead of T+2)
- This is because USD settlement requires NY banks to be open
- The system checks: `has_ny_weekday_holiday_between(deal_date, tom_date)`

### 11.9 Time Field Filtering

Auto-set time fields from Frappe contain microseconds (e.g., "12:30:00.123456"). The system distinguishes user-entered times from auto-set times by checking for the presence of a decimal point in the time string. Only times without decimals are considered valid user inputs.

### 11.10 Deal Entry Recreation (Update Flow)

When a Deal Entry is updated:
1. Old confirmation and contract references are saved
2. The Deal Entry is deleted and re-created with the same deal_entry_no
3. Old contract numbers and confirmation numbers are reused
4. This preserves reference integrity across the system

---

## 12. DATA FIXTURES & SEED DATA

### 12.1 Pre-loaded Deal Types

Standard deal types (from `deal_type.json`):
- **SS** — Short Swap
- **LS** — Long Swap
- **OR** — Outright

### 12.2 Pre-loaded DealTypes (for Discount)

From `dealtype.json` — similar classification used in discount tables.

### 12.3 Client Centres

From `client_centre.json`:
- Mumbai (default)
- Other regional centers as configured

### 12.4 Holiday Lists Required

The system expects these Holiday Lists to exist:
- **Maharashtra** — State holidays for deal date validation
- **New York** — US holidays for SPOT date calculation
- **Maharashtra + New York** — Combined list for working day calculations

### 12.5 Database Views (Created by Patches)

**vwDealMultiCounterparty:**
- Shows multi-counterparty deals with near/far leg details
- Includes deal_status (Open/Close), match_with_dealname
- Uses window functions for cross-referencing

**vwCrossMatchStatus / vwCrossMatchDetailedStatus:**
- Shows cross-match status across multi-counterparty deals
- Used by the Cross Match section on Deal Entry form

---

## 13. SECURITY & ACCESS CONTROL

### 13.1 Role-Based Permissions Matrix

| DocType | System Manager | Sales Manager | Sales User | Sales Master Manager |
|---------|---------------|---------------|------------|---------------------|
| Deal Entry | CRUD + Export + Print + Email + Share | - | - | - |
| Forex Contracts | CRUD + Export + Print + Email + Share | - | - | - |
| Deal Confirmation | CRUD + Export + Print + Email + Share | - | - | - |
| Client | CRUD + Export + Print + Email + Share | - | - | - |
| Forex Broker | CRUD + Export + Print + Email + Share | - | - | - |
| Deal Type | CRUD + Export + Print + Email + Share | - | - | - |
| Forex Settings | CRD + Print + Email + Share + Write | - | - | - |
| Dealer | - | Read + Email + Print + Report | Read + Email + Print + Report | CRUD + Email + Print + Report + Share |
| GST Rate | CRUD + Export + Print + Email + Share | - | - | - |
| E-Invoice | CRUD + Export + Print + Email + Share | - | - | - |

### 13.2 API Endpoint Security

All public API endpoints use `@frappe.whitelist()` decorator, which requires:
- Valid user session (logged in)
- CSRF token validation

Search endpoints additionally use `@frappe.validate_and_sanitize_search_inputs` for input sanitization.

**Whitelisted Methods:**

| Method | Module | Purpose |
|--------|--------|---------|
| `get_deal_type` | utils | Fetch deal type for client |
| `get_brokerage` | utils | Calculate brokerage |
| `get_dealers` | utils | Get enabled dealers for client |
| `send_email` | utils | Send email |
| `is_holiday` | utils | Check if date is holiday |
| `get_holidays_for_date` | utils | Get holidays for date |
| `get_next_deal_entry_no` | deal_entry | Generate next deal number |
| `get_filtered_dealers` | deal_entry | Get dealers for parent |
| `get_deal_values` | deal_entry | Get deal references |
| `get_mh_holidays_for_date` | deal_entry | Maharashtra holidays |
| `get_upcoming_mh_ny_holidays` | deal_entry | Combined upcoming holidays |
| `get_past_mh_ny_holidays` | deal_entry | Combined past holidays |
| `check_new_york_holiday_between_dates` | deal_entry | NY holiday range check |
| `check_new_york_holiday_on_date` | deal_entry | NY holiday date check |
| `get_holidays_list` | deal_entry | Month holidays |
| `get_cross_match_status` | deal_entry | Cross-match data |
| `get_multi_counterparty_deals` | deal_entry | Open multi-counterparty deals |
| `get_linked_contracts` | deal_entry | Linked contracts |
| `reassign_broker` | deal_entry | Broker reassignment |
| `create_deal_entries` | deal_entry | Bulk creation |
| `generate_deal_confirmation_pdf` | deal_entry | PDF generation |
| `get_print_html_with_letterhead` | deal_entry | HTML for printing |
| `update_brokerage_values` | deal_entry | Update brokerage fields |
| `bulk_print_contracts` | forex_contracts | Overlay PDF generation |
| `bulk_print_contracts_on_png` | forex_contracts | PNG template PDF |
| `get_clients_for_date` | forex_contracts | Client search filter |
| `send_deal_confirmation_email` | deal_confirmation | Email confirmations |
| `get_client_primary_contact` | client | Contact search |
| `get_sorted_deal_types` | client | Sorted deal type list |
| `get_clients_without_brokerage` | client | Count clients without brokerage |
| `export_all_clients_to_excel` | client | Excel export |
| `export_client_profile_to_pdf` | client | PDF export |
| `export_all_clients_profile_to_pdf` | client | Bulk PDF export |
| `get_broker_primary_contact` | forex_broker | Broker contact search |
| `export_all_forex_brokers_to_excel` | forex_broker | Excel export |
| `export_forex_broker_profile_to_pdf` | forex_broker | PDF export |

### 13.3 Row-Level Locking

Critical number generation operations use `FOR UPDATE` SQL clause to prevent race conditions:
- `deal_entry_no` generation
- `contract_no` generation
- `deal_confirm_no` generation

---

## 14. ERROR HANDLING

### 14.1 Validation Error Messages (frappe.throw)

| Condition | Error Message |
|-----------|---------------|
| Deal date in future | "Deal Date cannot be in the future." |
| Backdated deal | "Backdated entries are not allowed. The date cannot be earlier than today." |
| Weekend entry | "New entries cannot be created on weekends (Saturday or Sunday)." |
| Holiday entry | "New entries cannot be created on holidays." |
| Near date < deal date | "Settlement Date Near cannot be earlier than Contract Date." |
| Far date < near date | "Settlement Date Far cannot be earlier than Settlement Date Near." |
| CASH tenor on NY holiday | "Cannot use CASH tenor on {date} as it is a New York holiday. Settlement cannot be done when New York is closed. Please use a different tenor instead." |
| TOM/SPOT overlap | "Cannot use TOM / SPOT tenor on {date} as a New York holiday causes both TOM and SPOT to fall on the same date ({date}). Please use a different tenor." |
| Invalid GST number | "Invalid GST Number: {number}" |
| Missing deal date for naming | "Deal Date is required for naming." |
| No permission to create contracts | "You don't have permission to create Forex Contracts. Please contact your administrator." |
| No permission to create confirmations | "You don't have permission to create Deal Confirmations. Please contact your administrator." |
| Invalid contract names JSON | "Invalid JSON format for contract names" |
| Empty contract names | "Contract names must be a non-empty list" |
| Missing ReportLab | "ReportLab library is required for PDF generation. Please install it using: pip install reportlab" |
| Missing PIL/img2pdf | "Required libraries not found. Please install: pip install Pillow img2pdf" |
| PNG template not found | "PNG template not found at: {path}" |
| GST rates negative | "GST rates cannot be negative." |
| GST rates > 100% | "GST rates cannot exceed 100%." |
| Brokerage = 0 | "Brokerage cannot be 0 in row {idx}" |
| to_days < from_days | "To Days must be greater than From Days in row {idx}" |
| Default deal type not set | "Field 'Default Deal Type' not set for {client}." |
| Missing address fields | "Following fields are mandatory to create address: City, Country" |

### 14.2 Warning Messages (frappe.msgprint)

| Condition | Message | Indicator |
|-----------|---------|-----------|
| Holiday list not found | "Holiday list for Maharashtra not found." | - |
| Brokerage fetch failed | "Warning: Could not fetch brokerage for client '{client}'. Setting to 0." | Orange |
| Unicode fonts missing | "Unicode fonts not found. Rupees symbol may not display correctly." | Orange |
| GST rate mismatch | "IGST Rate ({0}%) does not equal CGST ({1}%) + SGST ({2}%). Please verify the rates." | Orange |
| No deal confirmations selected | "Please select at least one deal confirmation to email" | - |
| No valid client selected | "Please select a valid client" | - |
| No date range selected | "Please select a date range" | - |

### 14.3 Retry Logic

**Deal Confirmation Creation:** Up to 5 retries with exponential backoff (starting at 100ms) for duplicate key errors caused by race conditions.

**Deal Confirmation Number Generation:** Up to 3 retries with exponential backoff (starting at 50ms).

**Error Logging:** All errors are logged to Frappe's Error Log with descriptive titles for debugging.

---

## APPENDIX A: DATABASE INDEXES

The following indexes are created by migration patches for performance optimization:

**Deal Entry:**
- `deal_date`, `seller`, `buyer`, `seller_broker`, `buyer_broker`, `deal_type`, `near_date`, `far_date`
- Composite: `(deal_date, seller)`, `(deal_date, buyer)`, `(deal_date, multi_counterparty)`

**Forex Contracts:**
- `contract_date`, `seller`, `buyer`, `delivery`, `leg_type`, `deal_entry_no`, `seller_broker`, `buyer_broker`
- Composite: `(contract_date, seller)`, `(contract_date, buyer)`, `(contract_date, leg_type)`

**Deal Confirmation:**
- Composite: `(deal_date, client, client_type)`

**Brokerage (child table):**
- `parent`, `deal_type`, `from_date`
- Composite: `(parent, deal_type, from_date)`

**Holiday:**
- `(parent, holiday_date)`

**Dealer Team:**
- `parent`

---

## APPENDIX B: SQL VIEWS

### vwDealMultiCounterparty

Shows multi-counterparty deals with near/far legs, including window functions for cross-referencing matched deals, deal status, and direction indicators.

### vwCrossMatchStatus / vwCrossMatchDetailedStatus

Provides cross-match information for the Deal Entry form's cross-match section, showing how deals are paired and their matching status.

---

*End of Business Requirements Document*
