# Prompt: Generate a Detailed User Manual for the Forex App

Act as a professional Technical Documentation Writer.

Create a complete and detailed User Manual for the **Forex Brokerage Management Application** — a Frappe-based web application used by Forex Brokers, Dealers, and Back Office Operations teams to manage Forex Deals, Contracts, Brokerage Calculations, and Reporting.

The application is built on **Frappe Framework** and accessed via a web browser. The manual should be written in clear professional English so that a non-technical operations user can understand how to use the system.

---

## The User Manual must include the following sections:

### 1. Introduction
- Overview of the Forex Brokerage Management Application
- Purpose: Managing forex deal entry, contract generation, brokerage/discount calculations, and reporting for a forex broking firm
- Target users:
  - **Dealers** — Enter and manage deals
  - **Operations / Back Office Team** — Generate contracts, confirmations, brokerage bills, e-invoices
  - **System Manager / Admin** — Configure settings, manage masters, user permissions
- Key benefits of the application

### 2. System Requirements
- Supported browsers (Chrome, Firefox, Edge — Frappe-compatible)
- Internet connectivity requirements
- Login credentials (provided by System Manager)

### 3. Login to the Application
- Step-by-step instructions to log in via Frappe's login page
- Password rules
- Forgot password process (Frappe standard)

### 4. Workspace Overview
- Explanation of the **Forex Workspace** which is the main navigation hub
- Workspace sections:
  - **Master Data Management** — Clients, Dealers, Brokers, Deal Types, Holidays
  - **Trading Operations** — Google Sheet Entries, Deal Entry, Forex Contracts, E-Invoice
  - **Reports & Analytics** — Deal Confirmation, Daily Forex Contracts, Brokerage Bill, Volume & Brokerage Summary, Contract Bankwise, Dealer Performance, Deal Type Brokerage Summary
  - **System Configuration** — Forex Settings, Google Integration Settings
- How to navigate using the sidebar and Awesome Bar

### 5. Master Data Setup
Explain how to create and manage each master record:

#### a. Client (Counterparty / Bank)
- Creating a new Client record
- Fields: Client Name, Client Code, Centre, Type
- **Dealer Team** child table — assigning dealers to clients
- **Brokerage** child table — configuring brokerage rates per deal type with:
  - Deal Type (SS/LS/OR)
  - Day range (From Days / To Days)
  - Brokerage rate and cap
  - Basis: Calendar Days vs Working Days
  - Effective date ranges
- **Discount** child table — configuring discounts with:
  - Period type: M (Month) / H (Half-year) / Y (Year)
  - Type: I (Inception) / F (Final)
  - Slab-based discount rates
  - Deal type applicability
- Address and Contact information
- Custom buttons: AR Report, GL Report, Export to PDF

#### b. Dealer
- Tree-structured hierarchy (parent-child dealer groups)
- Creating dealers and linking to Employee records
- Department assignment

#### c. Forex Broker
- Creating broker records with Broker Code and Centre
- Address and Contact details

#### d. Deal Type
- Standard deal types:
  - **SS** — Short Swap
  - **LS** — Long Swap
  - **OR** — Outright
- Creating and managing deal types

#### e. Client Centre
- Grouping clients by centre/region

### 6. Forex Settings (System Configuration)
Explain the single-doc configuration:
- **GST Rates**: IGST, CGST, SGST percentages
- **Deal Restrictions**: Weekend/holiday deal restrictions, backdated entry restrictions
- **Contract Printing Settings**: Default letter head, print format preferences
- Who can modify these settings (System Manager role)

### 7. Google Integration Settings
- Purpose: Syncing deal data from Google Sheets into the application
- **Service Account Credentials** setup for Google Sheets API
- **Spreadsheet Configurations** (child table):
  - Spreadsheet ID, Sheet Name
  - Sync frequency: Every 15 Minutes / Hourly / Daily / Weekly
  - Enable/Disable toggle
- **Field Mapping**: Mapping Google Sheet columns to Frappe fields
- **Manual Sync**: How to trigger a manual sync using the "Sync Now" button
- **Test Connection**: Verifying Google API connectivity

### 8. Google Sheet Entries
- How RM (Relationship Manager) entries flow from Google Sheets into the system
- Viewing synced entries
- Error tracking and error banners for failed syncs
- Linking Google Sheet Entries to Deal Entry creation
- Sync status indicators

### 9. Deal Entry (Core Transaction)
Provide detailed step-by-step instructions for:

#### Creating a New Deal
- **Deal Entry Number**: Auto-generated sequential number
- **Deal Date and Time**: Date validation against holidays/weekends (controlled by Forex Settings)
- **Deal Type Selection**: Outright or Swap
- **Tenor Selection**: CASH, TOM, SPOT, 1M through 2Y, or Monthly tenors (JAN-DEC)

#### Seller Side
- Selecting the Seller (Client)
- Seller Dealer selection (filtered by client's dealer team)
- Entering Sell Amount (in USD or other currency)
- Entering the Deal Rate
- Near Date / Far Date (auto-calculated based on tenor)
- Agent selection: CCIL Settlement or RTGS

#### Buyer Side
- Selecting the Buyer (Client)
- Buyer Dealer selection
- Entering Buy Amount
- Entering the Deal Rate
- Near Date / Far Date
- Agent selection

#### Brokerage Calculation
- How brokerage is automatically calculated based on:
  - Client's brokerage table configuration
  - Deal type (SS/LS/OR)
  - Duration in days (calendar or working days basis)
  - Amount and cap limits
- Seller Brokerage and Buyer Brokerage fields
- Number-to-words conversion for amounts

#### Multi-Counterparty Deals
- Cross-matching support for complex deals with multiple counterparties

#### Saving and Submitting
- Save as Draft
- Submit the deal (triggers contract generation)
- Amend / Cancel workflow
- Open/Close status tracking for seller and buyer sides

### 10. Forex Contracts (Auto-Generated)
Explain:
- How contracts are **automatically generated** when a Deal Entry is submitted
- **Leg Types**: Near Leg and Far Leg contracts
- Key contract fields:
  - Contract Number (auto-generated)
  - Link back to Deal Entry
  - Client, Dealer, Amount, Rate
  - Settlement/Delivery Date
  - Brokerage details
- How to view contracts from the Forex Contracts list
- Filtering contracts by client, date, deal type
- Printing contracts (using configured letter head from Forex Settings)

### 11. Deal Confirmation
- How to generate deal confirmations
- Deal Confirmation fields: Deal Date, Contract Numbers, Parties
- Verification process
- Sending confirmations to counterparties

### 12. E-Invoice
- Purpose: Generating e-invoices for brokerage billing
- Creating E-Invoice by month and year (autonamed based on month/year)
- **E-Invoice Items** child table with line-item details
- Client filtering (excludes already-selected clients)
- Retrieving E-Invoice numbers for clients during brokerage bill generation

### 13. Reports Section
Explain how to generate, filter, and export each report:

#### a. Brokerage Bill Report
- **Purpose**: Generate brokerage billing statements for clients
- **Reference Doctype**: Forex Contracts
- **Filters**: Client, Date Range, Deal Type
- **Export**: Excel and PDF (using `brokerage_bill_pdf.html` template)
- **Letter Head**: Paterson-Letter-Head

#### b. Volume and Brokerage Summary Report
- **Purpose**: Analyze trading volume and brokerage commission — single-month or multi-month view
- **Reference Doctype**: Deal Entry
- **Filters**: Month/Year range, Bank/Client, Brokerage toggle (show/hide brokerage columns)
- **Export**: Excel (`download_excel` API) and PDF (`download_pdf` API, using `volume_and_brokerage_summary_pdf.html`)
- Monthly aggregation and bank-wise breakdown

#### c. Dealer Performance Report
- **Purpose**: Comprehensive dealer analysis with performance metrics and discount calculations
- **Reference Doctype**: Deal Entry
- **Filters**: Dealer, Date Range, Deal Type
- **Export**: Multiple format options

#### d. Deal Type Brokerage Summary Report
- **Purpose**: Brokerage breakdown by deal type (SS/LS/OR)
- **Reference Doctype**: Deal Entry
- **Filters**: Date Range, Deal Type

#### e. Deal Confirmation Report
- **Purpose**: List of deal confirmations for verification
- **Reference Doctype**: Deal Confirmation
- **Filters**: Date Range, Client

#### f. Contract Bankwise Report
- **Purpose**: Contracts organized and grouped by bank/client
- **Reference Doctype**: Forex Contracts
- **Filters**: Date Range, Client/Bank
- **Export**: PDF (using `contract_bankwise_pdf.html` template)

#### g. Daily Forex Contracts Report (Forex Contracts Report)
- **Purpose**: Daily listing of all forex contracts
- **Reference Doctype**: Forex Contracts
- **Filters**: Date

### 14. User Roles and Permissions
Explain each role and what it can access:

| Role | Access Level |
|------|-------------|
| **System Manager** | Full CRUD + all operations on all doctypes; configure Forex Settings, Google Integration |
| **Dealer** | Read-only access to Dealer tree |
| **Sales Manager / Sales User** | Read-only access to Dealer records |
| **Sales Master Manager** | Full access to Dealer management |
| **Accounts Manager / Accounts User** | Access to Dealer Performance report |

### 15. Scheduled / Automated Tasks
Explain background automation:
- **Google Sheets Auto-Sync**: Runs every 15 minutes, hourly, daily, or weekly based on spreadsheet config
- **Contract PDF Cleanup**: Runs daily at 10:00 AM to clean up old generated PDFs
- **Document Event Hooks**: On save/submit of any doctype, Google Integration sync is triggered

### 16. Troubleshooting
Common issues and solutions:
- Google Sheets sync errors (authentication, permissions, field mapping)
- Deal date validation errors (weekend/holiday restrictions)
- Backdated entry restrictions
- Brokerage calculation mismatches (check client brokerage table, day basis, caps)
- Contract not generating (ensure Deal Entry is submitted, not just saved)
- Report not showing data (check date filters, client selection)
- Permission errors (contact System Manager for role assignment)

### 17. Frequently Asked Questions (FAQ)
Cover questions such as:
- How do I change brokerage rates for a client?
- Why can't I enter a deal on a weekend/holiday?
- How are contracts automatically created?
- How do I re-sync Google Sheet data?
- What is the difference between Calendar Days and Working Days basis?
- How do I generate an e-invoice?
- Can I amend a submitted deal?

### 18. Best Practices
- Always verify client brokerage and discount configuration before deal entry
- Use the "Test Connection" button before relying on Google Sheets sync
- Submit deals promptly — do not leave deals in Draft status
- Verify Near/Far dates before submission (especially for Swap deals)
- Regularly review Brokerage Bills and Volume Summary reports for reconciliation
- Keep Dealer hierarchy up to date
- Follow Frappe's security guidelines for password management

### 19. Glossary
Define key terms as used in the application:
- **Spot** — Standard settlement (T+2)
- **TOM** — Tomorrow settlement (T+1)
- **CASH** — Same-day settlement (T+0)
- **Forward / Outright (OR)** — Single-leg deal for future settlement
- **Swap** — Two-leg deal (Near + Far) for simultaneous buy/sell
- **Short Swap (SS)** — Swap with shorter duration
- **Long Swap (LS)** — Swap with longer duration
- **Tenor** — Duration/maturity period of the deal
- **Near Leg** — First settlement leg of a swap deal
- **Far Leg** — Second settlement leg of a swap deal
- **Counterparty** — The other party in a deal (Client/Bank)
- **Settlement Date** — Date when the deal is settled/delivered
- **Brokerage** — Commission earned by the broker on each deal
- **CCIL** — Clearing Corporation of India Limited (settlement agent)
- **RTGS** — Real Time Gross Settlement (settlement agent)
- **Basis (Calendar/Working Days)** — Method for counting days in brokerage calculation
- **Cap** — Maximum brokerage limit per deal

---

## Formatting Instructions
- Use professional document formatting with numbered headings and sub-headings
- Include bullet points for step-by-step instructions
- Use tables where appropriate (permissions, field descriptions)
- Include notes/tips boxes for important information
- Add "See Also" cross-references between related sections
- Write for a non-technical operations user — avoid developer jargon
- Reference actual field names and button labels as they appear in the application
