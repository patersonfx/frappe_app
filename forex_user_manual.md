# Forex Brokerage Management Application — User Manual

**Version:** 1.0
**Date:** March 2026
**Application:** Forex Brokerage Management Application (Frappe-based)

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Requirements](#2-system-requirements)
3. [Login to the Application](#3-login-to-the-application)
4. [Workspace Overview](#4-workspace-overview)
5. [Master Data Setup](#5-master-data-setup)
6. [Forex Settings (System Configuration)](#6-forex-settings-system-configuration)
7. [Google Integration Settings](#7-google-integration-settings)
8. [Google Sheet Entries](#8-google-sheet-entries)
9. [Deal Entry (Core Transaction)](#9-deal-entry-core-transaction)
10. [Forex Contracts (Auto-Generated)](#10-forex-contracts-auto-generated)
11. [Deal Confirmation](#11-deal-confirmation)
12. [E-Invoice](#12-e-invoice)
13. [Reports](#13-reports)
14. [User Roles and Permissions](#14-user-roles-and-permissions)
15. [Scheduled and Automated Tasks](#15-scheduled-and-automated-tasks)
16. [Troubleshooting](#16-troubleshooting)
17. [Frequently Asked Questions (FAQ)](#17-frequently-asked-questions-faq)
18. [Best Practices](#18-best-practices)
19. [Glossary](#19-glossary)

---

## 1. Introduction

### 1.1 Overview

The Forex Brokerage Management Application is a web-based system built on the Frappe Framework. It is designed for forex broking firms to manage their daily operations — from deal entry and contract generation to brokerage calculation, invoicing, and reporting.

### 1.2 Purpose

The application handles the complete workflow of a forex broking operation:

- **Deal Entry** — Recording forex deals (Swaps and Outrights) between counterparties (banks/clients)
- **Contract Generation** — Automatically creating forex contracts when deals are submitted
- **Brokerage Calculation** — Computing brokerage commissions based on configurable rate tables, day ranges, and caps
- **Discount Management** — Applying slab-based discounts by period (monthly, half-yearly, yearly)
- **Reporting** — Generating brokerage bills, volume summaries, dealer performance reports, and more
- **E-Invoicing** — Creating e-invoices for brokerage billing
- **Google Sheets Integration** — Importing deal data from Google Sheets used by relationship managers

### 1.3 Target Users

| User Role | Responsibilities |
|-----------|-----------------|
| **Dealers** | Enter and manage forex deals |
| **Operations / Back Office Team** | Generate contracts, deal confirmations, brokerage bills, and e-invoices |
| **System Manager / Admin** | Configure system settings, manage master data, assign user permissions |

### 1.4 Key Benefits

- Automated contract generation upon deal submission
- Configurable brokerage calculation with calendar/working day basis and caps
- Real-time Google Sheets sync for deal data import
- Comprehensive reporting suite with Excel and PDF export
- Multi-counterparty deal support for complex transactions
- Holiday and weekend deal restriction enforcement
- Role-based access control

---

## 2. System Requirements

### 2.1 Supported Browsers

The application runs in any modern web browser that supports the Frappe Framework:

- Google Chrome (recommended)
- Mozilla Firefox
- Microsoft Edge

### 2.2 Internet Connectivity

A stable internet connection is required to access the application. The Google Sheets integration also requires internet access for syncing data.

### 2.3 Login Credentials

Your login credentials (username and password) are provided by the System Manager. Contact your administrator if you do not have credentials.

---

## 3. Login to the Application

### 3.1 Step-by-Step Login

1. Open your web browser and navigate to the application URL provided by your administrator.
2. On the login page, enter your **Email Address** in the email field.
3. Enter your **Password** in the password field.
4. Click the **Login** button.
5. Upon successful login, you will be directed to the Forex Workspace or your default home page.

### 3.2 Password Rules

- Passwords must meet the minimum length and complexity requirements configured by the System Manager.
- Frappe enforces password policies including minimum length and character requirements.

### 3.3 Forgot Password

1. On the login page, click the **Forgot Password** link below the password field.
2. Enter your registered email address.
3. Click **Send Reset Link**.
4. Check your email for a password reset link and follow the instructions to set a new password.

---

## 4. Workspace Overview

### 4.1 The Forex Workspace

The **Forex** Workspace is the main navigation hub of the application. It organizes all features into four sections for easy access.

### 4.2 Workspace Sections

#### Master Data Management
| Item | Description |
|------|-------------|
| Clients | Manage counterparty/bank records with brokerage and discount configurations |
| Dealer | Manage dealer hierarchy (tree structure) |
| Brokers | Manage forex broker records |
| Deal Type | Configure deal types (SS, LS, OR) |
| Holiday | Manage holiday lists for deal date validation |

#### Trading Operations
| Item | Description |
|------|-------------|
| Google Sheet Entries | View entries imported from Google Sheets |
| Deal Entry | Create and manage forex deals |
| Forex Contract | View auto-generated forex contracts |
| E-Invoice | Create e-invoices for brokerage billing |

#### Reports & Analytics
| Report | Description |
|--------|-------------|
| Deal Confirmation | Generate and send deal confirmations |
| Daily Forex Contracts | Daily listing of all forex contracts |
| Brokerage Bill | Generate brokerage billing statements |
| Deal Type Brokerage Summary | Brokerage breakdown by deal type |
| Volume and Brokerage Summary | Trading volume and brokerage analysis |
| Contract Bankwise | Contracts grouped by bank/client |
| Dealer Performance | Dealer performance analysis with discount calculations |

#### System Configuration
| Item | Description |
|------|-------------|
| Forex Settings | GST rates, deal restrictions, contract printing preferences |
| Google Integration Settings | Google Sheets API configuration and sync settings |

### 4.3 Navigation

- **Sidebar** — Use the left sidebar to navigate between modules and doctypes.
- **Awesome Bar** — Press `Ctrl+K` (or click the search bar at the top) to quickly search for any page, record, or report by typing its name.

---

## 5. Master Data Setup

### 5.1 Client (Counterparty / Bank)

The Client doctype represents a counterparty — typically a bank or financial institution — that participates in forex deals.

#### Creating a New Client

1. Navigate to **Forex Workspace > Master Data Management > Clients**.
2. Click **+ Add Client**.
3. Enter the client name when prompted (this becomes the record ID).
4. Fill in the required fields:

| Field | Description | Required |
|-------|-------------|----------|
| Client Name | Full name of the client/bank | Yes |
| Client Code | Short code for the client | No |
| Client Center | Centre/region grouping (link to Client Centre) | Yes |
| Client Type | Category: Nationalized, Private, Foreign, or Co-Operative | Yes |
| Confirmation Type | How deal confirmations are handled: Combine or Separate | Yes |
| Default Deal Type | The default deal type for this client | Yes |
| Discount Type | Discount basis: Brokerage or Volume | Yes |
| Print Time on Contract Note | Whether to print time on contract notes (enabled by default) | No |

#### Brokerage Tab — Configuring Brokerage Rates

The **Brokerage** child table defines brokerage rates per deal type and day range.

Click **Add Row** in the Brokerage table and configure:

| Field | Description |
|-------|-------------|
| From Date | Effective start date for this brokerage rate |
| Deal Type | Link to Deal Type (e.g., SS, LS, OR) |
| Range Type | The type of range classification |
| From Days | Start of the day range |
| To Days | End of the day range |
| Brokerage | Brokerage rate per unit |
| Brokerage Basis | How days are counted: **Calendar Days** or **Working Days** |
| Brokerage Cap | Maximum brokerage amount per deal |

> **Note:** The system uses the day range and basis to look up the applicable brokerage rate when a deal is entered. If Working Days basis is selected, weekends and holidays from the Holiday List are excluded from the day count.

#### Discount Tab — Configuring Discounts

The **Discount** child table defines slab-based discounts.

| Field | Description |
|-------|-------------|
| M/H/Y | Period type: **M** (Month), **H** (Half-year), **Y** (Year) |
| I/F | Discount stage: **I** (Incremental) or **F** (Flat) |
| From Date | Effective start date |
| Disc On | Discount basis: Brokerage or Volume |
| From Slab | Starting slab threshold |
| Pct | Discount percentage |
| Disc Deal Type | Deal type this discount applies to |

#### Client Dealer Tab

The **Client Dealer** table lists the dealer names associated with this client. Add rows with the dealer name for each dealer who handles this client.

#### Company Dealer Tab (Dealer Team)

The **Dealer Team** table assigns company dealers to the client.

| Field | Description |
|-------|-------------|
| Dealer Name | Link to Dealer record |
| Contact No | Contact number for the dealer |

#### Address and Contact Tab

- **Primary Address** — Link to an Address record for the client's primary address
- **Primary Contact** — Link to a Contact record; automatically fetches Mobile No and Email Id

#### Custom Buttons

On the Client form, the following buttons are available:

- **View > Accounts Receivable** — Opens the Accounts Receivable report filtered for this client
- **View > Accounting Ledger** — Opens the General Ledger report filtered for this client
- **Actions > Export Profile to PDF** — Downloads the client profile as a PDF document

### 5.2 Dealer

Dealers are organized in a **tree hierarchy** with parent-child groups.

#### Creating a Dealer

1. Navigate to **Forex Workspace > Master Data Management > Dealer**.
2. The dealer list displays as a tree view. Click **Add Child** or **Add Multiple** to create dealers.
3. Fill in:

| Field | Description |
|-------|-------------|
| Dealer Name | Name of the dealer |
| Parent Dealer | Parent node in the tree hierarchy |
| Is Group | Check if this is a group node (can have child dealers) |
| Enabled | Whether the dealer is active |
| Employee | Link to the HR Employee record |
| Department | Department the dealer belongs to |

### 5.3 Forex Broker

Represents the brokerage firm or broker involved in deals.

#### Creating a Broker

1. Navigate to **Forex Workspace > Master Data Management > Brokers**.
2. Click **+ Add Forex Broker**.
3. Fill in:

| Field | Description | Required |
|-------|-------------|----------|
| Broker Name | Name of the broker | Yes |
| Broker Code | Unique code (used as record name) | Yes |
| Broker Center | Centre/region of the broker | No |
| Broker Contact No | Contact number | No |

4. Use the Address & Contact tab to add address and contact details.

### 5.4 Deal Type

Standard deal types used in the application:

| Code | Description |
|------|-------------|
| **SS** | Short Swap — Swap deal with shorter duration |
| **LS** | Long Swap — Swap deal with longer duration |
| **OR** | Outright — Single-leg deal for future settlement |

#### Managing Deal Types

1. Navigate to **Forex Workspace > Master Data Management > Deal Type**.
2. Click **+ Add Deal Type** to create a new type.
3. Enter the deal type code.

### 5.5 Client Centre

Groups clients by centre or region.

1. Navigate to the Client Centre list.
2. Click **+ Add Client Centre**.
3. Enter the centre name (auto-named based on the field value).

---

## 6. Forex Settings (System Configuration)

Forex Settings is a **single document** — there is only one record that applies system-wide.

**Access:** Forex Workspace > System Configuration > Forex Settings

> **Note:** Only users with the **System Manager** role can modify Forex Settings.

### 6.1 GST Rates

| Field | Description | Default |
|-------|-------------|---------|
| IGST Rate | Integrated GST percentage | 18% |
| CGST Rate | Central GST percentage | 9% |
| SGST Rate | State GST percentage | 9% |

These rates are used when calculating GST on brokerage bills.

### 6.2 Deal Restrictions

| Field | Description | Default |
|-------|-------------|---------|
| Restrict Weekend/Holiday Entries | Prevents deal entry on weekends and holidays (based on Maharashtra holiday list) | Enabled |
| Restrict Backdated Deals | Prevents entry of deals with past dates | Enabled |

### 6.3 Contract Printing Settings

| Field | Description | Options |
|-------|-------------|---------|
| Contract Print Paper Size | Paper size for bulk contract printing | A4 Portrait (2 copies per page) or A5 Landscape (1 copy per page) |
| Print Other Brokers Contract Notes | Whether to include contracts involving other brokers | Check |

---

## 7. Google Integration Settings

Google Integration Settings configures the connection between the application and Google Sheets for importing deal data.

**Access:** Forex Workspace > System Configuration > Google Integration Settings

> **Note:** Only users with the **System Manager** role can modify these settings.

### 7.1 Authentication Setup

| Field | Description |
|-------|-------------|
| Enabled | Master toggle to enable/disable Google integration |
| Authentication Method | Method used for API authentication |
| Service Account JSON | The Google Cloud service account credentials in JSON format |
| Upload JSON File | Upload the service account credentials file |

#### Setting Up Google API Access

1. Create a Google Cloud project and enable the Google Sheets API.
2. Create a service account and download the JSON credentials file.
3. Share your Google Sheets with the service account email address.
4. Upload the credentials JSON file in the **Upload JSON File** field.

### 7.2 Spreadsheet Configurations

The **Spreadsheet Configurations** child table defines which Google Sheets to sync and how.

| Field | Description |
|-------|-------------|
| Enabled | Enable/disable this specific spreadsheet sync |
| Config Name | A descriptive name for this configuration |
| Sync Direction | Import (Google → Frappe), Export (Frappe → Google), or Bi-directional |
| Spreadsheet ID | The unique ID from the Google Sheet URL |
| Spreadsheet URL | Full URL of the Google Sheet (auto-generated) |
| Worksheet Name | Name of the specific worksheet/tab to sync |
| Doctype Name | The Frappe doctype to sync data with |
| Filters JSON | JSON filters to limit which records are synced |
| Field Mapping | Mapping between Google Sheet columns and Frappe fields |

### 7.3 Sync Settings

| Field | Description |
|-------|-------------|
| Auto Sync Enabled | Enable automatic background syncing |
| Sync Frequency | How often to auto-sync: Every 15 Minutes, Hourly, Daily, or Weekly |
| Sync on Save | Trigger export sync when any document is saved |
| Sync on Submit | Trigger export sync when any document is submitted |
| Last Sync | Timestamp of the last successful sync |

### 7.4 Manual Sync

To trigger a manual sync:

1. Open Google Integration Settings.
2. Click the **Sync Now** button.
3. The system will display real-time progress of the sync operation.
4. Check the **Last Sync** field to verify the sync completed successfully.

### 7.5 Test Connection

Click the **Test Connection** button to verify that the application can connect to the Google Sheets API using the configured credentials. The result is displayed in the **Test Result** field.

---

## 8. Google Sheet Entries

Google Sheet Entries are records automatically created when data is imported from Google Sheets. These represent deal data entered by Relationship Managers (RMs) in external spreadsheets.

### 8.1 Viewing Synced Entries

1. Navigate to **Forex Workspace > Trading Operations > Google Sheet Entries**.
2. The list shows all imported entries with their sync status.

### 8.2 Entry Fields

| Field | Description |
|-------|-------------|
| Entry No | Unique entry number from the source sheet |
| Trade Date | Date of the trade |
| Particulars | Deal details/description |
| Chain Indicator | Chain/sequence indicator |
| Deal Time | Time of the deal |
| Broker | Broker involved in the deal |
| Bank Dealer | Dealer at the bank/client |
| Row Hash | Hash value for detecting changes (used for incremental sync) |
| Last Synced | Timestamp of the last sync for this entry |

### 8.3 Deal Entry Creation

| Field | Description |
|-------|-------------|
| Deal Entry Created | Whether a Deal Entry has been created from this entry |
| Deal Entry Ref | Link to the Deal Entry record (if created) |

### 8.4 Error Tracking

| Field | Description |
|-------|-------------|
| Has Error | Indicates if an error occurred during processing |
| Error Message | Description of the error |

When errors occur during sync, an error banner is displayed on the entry. Review the error message to identify and resolve issues such as invalid data or missing field mappings.

> **Note:** Users with the **Accounts Manager** role also have access to Google Sheet Entries (with read, write, create, and export permissions).

---

## 9. Deal Entry (Core Transaction)

Deal Entry is the core transaction document in the application. It records a forex deal between a seller (client/bank) and a buyer (client/bank).

### 9.1 Creating a New Deal

1. Navigate to **Forex Workspace > Trading Operations > Deal Entry**.
2. Click **+ Add Deal Entry** or use the **New Deal Entry** button on an existing deal form.

### 9.2 Header Fields

| Field | Description | Notes |
|-------|-------------|-------|
| Deal Entry No. | Unique sequential number | Auto-generated (format: YYMMDD###); read-only |
| Deal Date | Date of the deal | Required; validated against weekends and holidays |
| Deal Type | Type of deal | Select: **Swap** or **Outright** |
| Amount | Deal amount (in USD or other currency) | Required; precision up to 6 decimal places |
| Amount In Words (mn) | Amount expressed in words (millions) | Auto-calculated |

### 9.3 Rate and Tenor Fields

| Field | Description | Notes |
|-------|-------------|-------|
| Near Rate | Exchange rate for the near leg | Required; precision up to 4 decimal places |
| Far Rate | Exchange rate for the far leg | Swap only; precision up to 4 decimal places |
| Difference (Swap Points) | Difference between far and near rates | Swap only; auto-calculated |
| Near Tenor | Tenor for the near leg | Options: CASH, TOM, SPOT, JAN–DEC, 1M–2Y |
| Far Tenor | Tenor for the far leg | Swap only |
| Near Date | Settlement date for the near leg | Required; auto-calculated based on tenor |
| Far Date | Settlement date for the far leg | Swap only |

> **Tip:** The system validates that dates follow the correct sequence: Deal Date ≤ Near Date ≤ Far Date. Future deal dates are not allowed.

### 9.4 Seller Side

| Field | Description |
|-------|-------------|
| Seller | Select the selling client/bank (link to Client) |
| Seller Time | Time of the seller's deal |
| Dealer | Dealer handling the seller side (link to Dealer; filtered by client's Dealer Team) |
| Broker | Broker on the seller side (link to Forex Broker; required) |
| Swap Type | Deal type classification (link to Deal Type; required for Swap deals) |
| Agent | Settlement agent: **CCIL Settlement** or **RTGS** |

### 9.5 Buyer Side

| Field | Description |
|-------|-------------|
| Buyer | Select the buying client/bank (link to Client) |
| Buyer Time | Time of the buyer's deal |
| Dealer | Dealer handling the buyer side (link to Dealer) |
| Broker | Broker on the buyer side (link to Forex Broker; required) |
| Swap Type | Deal type classification (required for Swap deals) |
| Agent | Settlement agent: **CCIL Settlement** or **RTGS** |

### 9.6 Brokerage Calculation

Brokerage is **automatically calculated** when a deal is saved, based on:

1. **Client's Brokerage Table** — The brokerage rate is looked up from the client's Brokerage child table.
2. **Deal Type** — The applicable rate is matched by deal type (SS, LS, or OR).
3. **Duration in Days** — The number of days between the near date and far date (or deal date and near date for outrights).
4. **Day Basis** — Calendar Days counts all days; Working Days excludes weekends and holidays.
5. **Cap** — If the calculated brokerage exceeds the cap configured for that rate slab, the cap amount is used instead.

| Field | Description |
|-------|-------------|
| Seller Brokerage | Brokerage amount for the seller side (precision 2 decimals) |
| Buyer Brokerage | Brokerage amount for the buyer side (precision 2 decimals) |

### 9.7 Multi-Counterparty Deals

For complex deals involving multiple counterparties:

1. Check the **Multi Counterparty** checkbox.
2. Enter a **Multi Deal Group** identifier to link related deals together.
3. Use the **S/B** and **B/S** checkboxes to indicate the deal direction.
4. When Multi Counterparty is enabled with a Swap deal, additional Far Leg fields appear for a separate seller/buyer on the far leg:
   - Seller (Far Leg), Buyer (Far Leg)
   - Broker (Far Leg), Swap Type (Far Leg)
   - Seller Brokerage (Far Leg), Buyer Brokerage (Far Leg)

### 9.8 Deal Confirmation Section

The Deal Confirmation section (collapsible) shows:

- **Seller Deal Confirmation** — Confirmation details for the seller side
- **Buyer Deal Confirmation** — Confirmation details for the buyer side
- **Near Contract No.** — The contract number for the near leg (populated after submission)
- **Far Contract No.** — The contract number for the far leg (Swap deals only)

### 9.9 Cross Match Section

The Cross Match section displays cross-matching information for deals involving multiple counterparties, helping verify that all legs of complex deals are properly matched.

### 9.10 Saving and Submitting

1. **Save as Draft** — Click **Save** (`Ctrl+S`) to save the deal without generating contracts. The deal remains editable.
2. **Submit** — Click **Submit** to finalize the deal. This action:
   - Generates Forex Contract records automatically (Near Leg, and Far Leg for Swaps)
   - Creates Deal Confirmation records
   - Sets the seller and buyer status to **Open**
3. **Amend** — To modify a submitted deal, click **Amend**. This creates an amended copy that can be edited and re-submitted.
4. **Cancel** — To cancel a submitted deal, click **Cancel**. This reverses the deal and marks it as cancelled.

### 9.11 Custom Buttons on Deal Entry

- **Show Linked Contracts** — Opens a dialog showing all Forex Contracts linked to this deal entry
- **New Deal Entry** — Quickly opens a blank Deal Entry form for entering the next deal

### 9.12 Status Tracking

| Field | Description |
|-------|-------------|
| Seller Status | Open or Close — tracks the seller side status |
| Buyer Status | Open or Close — tracks the buyer side status |
| Seller Close Ref | Reference to the closing transaction |
| Buyer Close Ref | Reference to the closing transaction |

---

## 10. Forex Contracts (Auto-Generated)

Forex Contracts are automatically created when a Deal Entry is submitted. They represent the individual legs of a deal.

### 10.1 How Contracts Are Generated

- **Outright Deal** — One contract is created (Near Leg).
- **Swap Deal** — Two contracts are created: a Near Leg contract and a Far Leg contract.
- **Multi-Counterparty Swap** — Additional contracts may be created for far leg counterparties.

### 10.2 Contract Fields

| Field | Description |
|-------|-------------|
| Contract No | Auto-generated number (format: YYMMDD###) |
| Contract Date | Date the contract was created |
| Leg Type | **Near** or **Far** |
| Deal Entry No | Link back to the originating Deal Entry |
| Seller | Selling client/bank |
| Buyer | Buying client/bank |
| Seller Time / Buyer Time | Timestamps from the deal |
| Delivery | Settlement/delivery date |
| Rate | Exchange rate |
| Amount | Deal amount |
| Amount In Words | Amount expressed in words |
| Seller Broker / Buyer Broker | Brokers involved |
| Sell Brokerage / Buy Brokerage | Brokerage amounts |
| Seller Agent / Buyer Agent | Settlement agents |
| Seller Deal Type / Buyer Deal Type | Deal type classification |
| Printed | Whether the contract has been printed |
| Printed PDF | Link to the generated PDF file |

### 10.3 Viewing Contracts

1. Navigate to **Forex Workspace > Trading Operations > Forex Contract**.
2. Use the list filters to narrow results by client, date, deal type, or other fields.
3. Click on a contract number to view the full contract details.

### 10.4 Printing Contracts

Contracts can be printed in bulk using the bulk print functionality. The paper size and layout are controlled by the **Contract Print Paper Size** setting in Forex Settings:

- **A4 Portrait** — Prints 2 copies per page
- **A5 Landscape** — Prints 1 copy per page

The system generates PDF files by overlaying deal information on pre-formatted templates.

> **Note:** Generated PDFs are automatically cleaned up daily at 10:00 AM to manage storage.

---

## 11. Deal Confirmation

Deal Confirmations are records that verify and confirm deals with counterparties.

### 11.1 How Confirmations Are Generated

Deal Confirmation records are automatically created when a Deal Entry is submitted. The system determines whether to create confirmations based on the client's **Confirmation Type** setting (Combine or Separate).

### 11.2 Confirmation Fields

| Field | Description |
|-------|-------------|
| Deal Date | Date of the deal |
| Deal Confirm No | Confirmation number |
| Deal Entry No | Link to the originating Deal Entry |
| Contract No | Associated contract number |
| Client | The counterparty client |
| Client Type | Type of the client |
| Broker | Broker involved |
| Deal Confirmation | Confirmation details |

### 11.3 Deal Confirmation Report

To generate and send deal confirmations, use the **Deal Confirmation** report (see [Section 13.5](#135-deal-confirmation-report)). The report supports PDF, Word, and email export options.

---

## 12. E-Invoice

E-Invoice is used to generate electronic invoices for brokerage billing.

### 12.1 Creating an E-Invoice

1. Navigate to **Forex Workspace > Trading Operations > E-Invoice**.
2. Click **+ Add E-Invoice**.
3. Enter the **Month Year** in the required format. The record is auto-named based on the month and year (format: YYYYMM, e.g., "202603").

### 12.2 E-Invoice Items

The **E-Invoice Items** child table lists the clients for whom e-invoices are being generated.

| Field | Description |
|-------|-------------|
| Client | Link to the Client record |
| E-Invoice No | The e-invoice number assigned to this client |

### 12.3 Client Filtering

When adding clients to an E-Invoice:

- The system filters to show only clients who have forex contracts in the selected month where the house broker is involved.
- Clients already added to the current E-Invoice are excluded from the selection list to prevent duplicates.

### 12.4 Validation

The system validates:
- The month format is correct
- No duplicate months exist across E-Invoice records
- No duplicate clients within the same E-Invoice

### 12.5 E-Invoice in Brokerage Billing

When generating brokerage bills, the system retrieves the E-Invoice number for each client from the corresponding E-Invoice record. This number is included on the brokerage bill for reference.

---

## 13. Reports

All reports are accessible from **Forex Workspace > Reports & Analytics**.

### 13.1 Brokerage Bill Report

**Purpose:** Generate brokerage billing statements for clients with GST calculations.

**Reference Doctype:** Forex Contracts

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| Month | Select | Billing month (January–December); required |
| Year | Integer | Billing year; required |
| Client Name | Link to Client | Filter by specific client (optional; dynamically filtered to clients with contracts in the selected month/year) |

#### Report Content

The report shows:
- Deal-wise brokerage details (Short Swap, Long Swap, Outright)
- Gross brokerage amounts
- Discount calculations (based on client discount configuration)
- GST calculations (IGST, CGST, SGST based on Forex Settings rates)
- Net brokerage payable

#### Export Options

Under the **Export** button group:

| Button | Description |
|--------|-------------|
| **Brokerage Bill Summary (Excel)** | Downloads a summary Excel file for all clients |
| **Brokerage Bill (PDF)** | Downloads individual brokerage bills as PDF |
| **Brokerage Bill (Excel)** | Downloads detailed brokerage bill data in Excel format |

> **See Also:** Configure GST rates in [Forex Settings (Section 6)](#6-forex-settings-system-configuration) and brokerage rates in [Client setup (Section 5.1)](#51-client-counterparty--bank).

### 13.2 Volume and Brokerage Summary Report

**Purpose:** Analyze trading volume (in USD millions) and brokerage commissions with single-month or multi-month views.

**Reference Doctype:** Deal Entry

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| From Date | Date | Start of the reporting period; required |
| To Date | Date | End of the reporting period; required |
| Broker | Link to Forex Broker | Filter by specific broker (optional; dynamically filtered to brokers with deals in the date range) |
| Show Brokerage | Checkbox | Toggle brokerage column visibility (enabled by default) |

#### Report Content

- Bank/client-wise volume breakdown
- Monthly aggregation when date range spans multiple months (columns per month)
- Brokerage amounts (toggled by the Show Brokerage filter)
- Totals and subtotals

#### Export Options

Under the **Export** button group:

| Button | Description |
|--------|-------------|
| **Excel** | Downloads the report in Excel format |
| **PDF** | Downloads the report as a PDF |

### 13.3 Dealer Performance Report

**Purpose:** Comprehensive dealer-level analysis with performance metrics and discount calculations.

**Reference Doctype:** Deal Entry

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| Dealer | Link to Dealer | Filter by specific dealer |
| Date Range | Date range | Reporting period |
| Deal Type | Link to Deal Type | Filter by deal type |

#### Report Content

- Dealer-wise deal volume and count
- Brokerage earned per dealer
- Bank-level breakdown within each dealer
- Discount calculations
- Performance metrics

#### Export Options

Multiple export formats are available including Excel, PDF, and HTML.

### 13.4 Deal Type Brokerage Summary Report

**Purpose:** Brokerage breakdown by deal type (Short Swap, Long Swap, Outright).

**Reference Doctype:** Deal Entry

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| Date Range | Date range | Reporting period |
| Deal Type | Link to Deal Type | Filter by specific deal type |

#### Report Content

- Summary of brokerage by deal type category
- Supports single-period and multi-month views
- Excel export available

### 13.5 Deal Confirmation Report

**Purpose:** Generate deal confirmation documents for sending to counterparties.

**Reference Doctype:** Deal Confirmation

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| From Date | Date | Start date; required |
| To Date | Date | End date; required |
| Broker | Link to Forex Broker | Required; filtered to brokers with transactions in the date range |
| Client | Link to Client | Optional; filtered to clients with transactions for the selected broker and dates |
| Clear Filters | Button | Resets broker and client filters |

#### Export Options

Under the **Export** button group:

| Button | Description |
|--------|-------------|
| **PDF** | Downloads the deal confirmation as a PDF document |
| **Word** | Downloads the deal confirmation as a Word document |

#### Email Options

When a client is selected and data exists, the **Email** button group appears:

| Button | Description |
|--------|-------------|
| **Email As Body** | Sends the deal confirmation as HTML content in the email body |
| **Email As Attachment** | Sends the deal confirmation as a PDF attachment |

### 13.6 Contract Bankwise Report

**Purpose:** View contracts organized and grouped by bank/client.

**Reference Doctype:** Forex Contracts

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| Date Range | Date range | Reporting period |
| Client/Bank | Link to Client | Filter by specific client |

#### Report Content

- Contracts grouped by client/bank
- Shows buy/sell direction, amount (in lakhs), rate, delivery date, deal type, and brokerage

#### Export Options

- **PDF** — Downloads the report using the Contract Bankwise PDF template

### 13.7 Daily Forex Contracts Report

**Purpose:** Daily listing of all forex contracts for a specific date.

**Reference Doctype:** Forex Contracts

**Workspace Label:** "Daily Forex Contracts"

#### Filters

| Filter | Type | Description |
|--------|------|-------------|
| Date | Date | The date to view contracts for |

#### Report Content

- Contract number
- Seller and buyer details
- Amount and rate
- Deal type
- Delivery date
- Seller and buyer brokerage

---

## 14. User Roles and Permissions

### 14.1 Role Summary

| Role | Access |
|------|--------|
| **System Manager** | Full access (read, write, create, delete, export, print, email, report, share) on all doctypes. Can configure Forex Settings and Google Integration Settings. |
| **Accounts Manager** | Read, write, create, export access to Google Sheet Entries and GST Rate. Full CRUD on GST Rate. |
| **Accounts User** | Read-only access to GST Rate (with export, print, email, report, share). |
| **Sales Master Manager** | Full access (read, write, create, delete, print, email, report, share) to the Dealer tree. |
| **Sales Manager** | Read-only access to Dealer records (with print, email, report). |
| **Sales User** | Read-only access to Dealer records (with print, email, report). |

### 14.2 Detailed Permissions by Doctype

| Doctype | System Manager | Accounts Manager | Sales Master Manager | Sales Manager | Sales User | Accounts User |
|---------|:-:|:-:|:-:|:-:|:-:|:-:|
| Deal Entry | Full | — | — | — | — | — |
| Forex Contracts | Full | — | — | — | — | — |
| Client | Full | — | — | — | — | — |
| Dealer | — | — | Full | Read | Read | — |
| Forex Broker | Full | — | — | — | — | — |
| Deal Type | Full | — | — | — | — | — |
| Forex Settings | Full* | — | — | — | — | — |
| Google Integration Settings | Full* | — | — | — | — | — |
| Deal Confirmation | Full | — | — | — | — | — |
| Google Sheet Entries | Full | Read/Write/Create | — | — | — | — |
| E-Invoice | Full | — | — | — | — | — |
| GST Rate | Full | Full | — | — | — | Read |

*Single doctypes (no export/report permissions)

---

## 15. Scheduled and Automated Tasks

The application runs several background tasks automatically:

### 15.1 Google Sheets Auto-Sync

| Schedule | Description |
|----------|-------------|
| Every 15 Minutes | Syncs spreadsheets configured with "Every 15 Minutes" frequency |
| Hourly | Syncs spreadsheets configured with "Hourly" frequency |
| Daily | Syncs spreadsheets configured with "Daily" frequency |
| Weekly | Syncs spreadsheets configured with "Weekly" frequency |

### 15.2 Contract PDF Cleanup

**Schedule:** Daily at 10:00 AM

Automatically deletes generated contract PDFs that are older than 1 day to manage storage space.

### 15.3 Document Event Hooks

When any document in the system is saved or submitted:

- **On Save** — If export-type Google Integration configurations exist, the system triggers a sync to update the corresponding Google Sheet.
- **On Submit** — Same as above, triggered upon document submission.

---

## 16. Troubleshooting

### 16.1 Google Sheets Sync Errors

| Issue | Solution |
|-------|----------|
| Authentication failure | Verify the service account JSON credentials in Google Integration Settings. Use the **Test Connection** button to check connectivity. |
| Permission denied | Ensure the Google Sheet is shared with the service account email address. |
| Field mapping errors | Check that the column names in the Google Sheet match the field mapping configuration. |
| Entries not syncing | Verify that auto-sync is enabled and the sync frequency is set. Check the **Last Sync** timestamp. |

### 16.2 Deal Entry Errors

| Issue | Solution |
|-------|----------|
| "Cannot enter deals on weekends/holidays" | The deal date falls on a weekend or holiday. Check the Maharashtra holiday list. This restriction can be disabled in Forex Settings. |
| "Cannot enter backdated deals" | The deal date is in the past. This restriction can be disabled in Forex Settings. |
| Date validation error | Ensure dates follow the sequence: Deal Date ≤ Near Date ≤ Far Date. Future deal dates are not allowed. |

### 16.3 Brokerage Calculation Issues

| Issue | Solution |
|-------|----------|
| Brokerage showing as zero | Check the client's Brokerage table — ensure a rate is configured for the applicable deal type and day range. Verify the effective date (From Date). |
| Unexpected brokerage amount | Verify the **Brokerage Basis** (Calendar Days vs Working Days). Check if a **Brokerage Cap** is limiting the amount. |
| Day count mismatch | If using Working Days basis, the system excludes weekends and holidays from the client's Holiday List. |

### 16.4 Contract Issues

| Issue | Solution |
|-------|----------|
| Contract not generated | Contracts are only generated when a Deal Entry is **submitted**, not when it is saved as a draft. Click **Submit** to generate contracts. |
| Missing far leg contract | Far leg contracts are only generated for **Swap** deals, not Outrights. |

### 16.5 Report Issues

| Issue | Solution |
|-------|----------|
| Report showing no data | Check the date filters — ensure the selected date range contains submitted deals or contracts. Verify the client/broker filter selection. |
| Export button not appearing | Some export buttons only appear when data is present in the report. Apply filters and refresh the report first. |

### 16.6 Permission Errors

| Issue | Solution |
|-------|----------|
| "Not permitted" error | You do not have the required role to access this feature. Contact the System Manager to assign the appropriate role. |

---

## 17. Frequently Asked Questions (FAQ)

**Q: How do I change brokerage rates for a client?**
A: Open the Client record, navigate to the **Brokerage** tab, and modify the rates in the Brokerage table. You can add new rows for different deal types, day ranges, or effective dates. Ensure the **From Date** is set correctly so the new rate applies from the desired date.

**Q: Why can't I enter a deal on a weekend or holiday?**
A: The system restricts deal entry on weekends and holidays when the **Restrict Weekend/Holiday Entries** option is enabled in Forex Settings. The system checks against the Maharashtra and New York holiday lists. Contact the System Manager if this restriction needs to be temporarily disabled.

**Q: How are contracts automatically created?**
A: When you **submit** a Deal Entry (not just save), the system automatically creates Forex Contract records. For an Outright deal, one contract (Near Leg) is created. For a Swap deal, two contracts are created — a Near Leg and a Far Leg. The contract numbers are auto-generated in the format YYMMDD### (e.g., 260315001).

**Q: How do I re-sync Google Sheet data?**
A: Go to **Google Integration Settings** and click the **Sync Now** button. This triggers an immediate sync of all enabled spreadsheet configurations. You can also wait for the automatic sync to run based on the configured frequency (every 15 minutes, hourly, daily, or weekly).

**Q: What is the difference between Calendar Days and Working Days basis?**
A: **Calendar Days** counts every day between two dates, including weekends and holidays. **Working Days** excludes weekends (Saturdays and Sundays) and holidays (from the client's Holiday List) from the count. This affects which brokerage rate slab applies and the resulting brokerage amount.

**Q: How do I generate an e-invoice?**
A: Navigate to **E-Invoice** from the Forex Workspace, click **+ Add E-Invoice**, enter the month and year, then add clients to the **E-Invoice Items** table. The system automatically filters to show only eligible clients (those with contracts in the selected month). Assign e-invoice numbers in the E-Invoice No field for each client.

**Q: Can I amend a submitted deal?**
A: Yes. Open the submitted Deal Entry and click the **Amend** button. This creates an amended copy of the deal that you can edit and re-submit. The original deal is marked as cancelled.

**Q: What is a Multi-Counterparty deal?**
A: A Multi-Counterparty deal involves different counterparties on the near leg and far leg of a Swap deal. For example, Bank A may be the seller on the near leg, but Bank B is the seller on the far leg. Enable the **Multi Counterparty** checkbox and use the **Multi Deal Group** field to link related deals.

---

## 18. Best Practices

1. **Verify client configuration before deal entry** — Always confirm that the client's brokerage rates, discount slabs, and holiday list are correctly configured before entering deals.

2. **Test Google Sheets connectivity** — Use the **Test Connection** button in Google Integration Settings before relying on automatic syncing to ensure credentials are valid.

3. **Submit deals promptly** — Do not leave deals in Draft status for extended periods. Submit deals to generate contracts and deal confirmations in a timely manner.

4. **Verify dates before submission** — For Swap deals, carefully check the Near Date and Far Date before submitting. Amendments require cancelling and re-creating the deal.

5. **Review brokerage reports regularly** — Use the Brokerage Bill and Volume and Brokerage Summary reports regularly for reconciliation and billing accuracy.

6. **Keep the Dealer hierarchy current** — Update the Dealer tree when dealers join, leave, or change departments to ensure accurate reporting and client assignment.

7. **Follow password security guidelines** — Use strong passwords, do not share credentials, and change passwords periodically as recommended by the System Manager.

8. **Monitor Google Sheet sync status** — Check for error banners on Google Sheet Entries and review the **Last Sync** timestamp in Google Integration Settings to ensure data is flowing correctly.

9. **Use the Awesome Bar for quick navigation** — Press `Ctrl+K` and type the name of any doctype, report, or record to navigate quickly instead of browsing through menus.

---

## 19. Glossary

| Term | Definition |
|------|------------|
| **CASH** | Same-day settlement (T+0) — the deal settles on the trade date |
| **TOM** | Tomorrow settlement (T+1) — the deal settles the next business day |
| **SPOT** | Standard settlement (T+2) — the deal settles two business days after the trade date |
| **Forward / Outright (OR)** | A single-leg deal for future settlement beyond the spot date |
| **Swap** | A two-leg deal (Near + Far) involving a simultaneous buy and sell of currency at two different dates |
| **Short Swap (SS)** | A swap deal with a shorter duration between the near and far legs |
| **Long Swap (LS)** | A swap deal with a longer duration between the near and far legs |
| **Tenor** | The duration or maturity period of the deal (e.g., 1M = 1 month, 2Y = 2 years) |
| **Near Leg** | The first settlement leg of a swap deal (earlier date) |
| **Far Leg** | The second settlement leg of a swap deal (later date) |
| **Counterparty** | The other party in a deal — typically a bank or financial institution (represented as a Client in the system) |
| **Settlement Date** | The date when the deal is settled and currency is exchanged (also called Delivery date) |
| **Brokerage** | Commission earned by the forex broker on each deal |
| **CCIL** | Clearing Corporation of India Limited — a settlement agent for forex transactions |
| **RTGS** | Real Time Gross Settlement — a settlement method for high-value transactions |
| **Calendar Days** | A method of counting all days (including weekends and holidays) for brokerage calculation |
| **Working Days** | A method of counting only business days (excluding weekends and holidays) for brokerage calculation |
| **Cap** | The maximum brokerage limit per deal — if the calculated brokerage exceeds the cap, the cap amount applies |
| **GST** | Goods and Services Tax — applied to brokerage amounts on billing |
| **IGST** | Integrated GST — applied for inter-state transactions |
| **CGST** | Central GST — applied for intra-state transactions (central portion) |
| **SGST** | State GST — applied for intra-state transactions (state portion) |
| **Deal Entry** | The core transaction record that captures all details of a forex deal |
| **Forex Contract** | An auto-generated record representing a single leg of a deal |
| **Deal Confirmation** | A verification document sent to counterparties to confirm deal terms |
| **E-Invoice** | Electronic invoice generated for brokerage billing purposes |
| **Frappe** | The web application framework on which this application is built |
| **Awesome Bar** | The search bar (Ctrl+K) in Frappe applications for quick navigation |
| **Doctype** | A Frappe term for a data model / form type (similar to a database table with a user interface) |

---

*End of User Manual*

*This document was generated for the Forex Brokerage Management Application built on Frappe Framework.*
