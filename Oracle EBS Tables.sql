
Oracle EBS  Apps Tables


ONT- Order Management
Table Name Description 
OE_ORDER_HEADERS_ALL stores header information for orders in Order Management. 
OE_ORDER_LINES_ALL stores information for all order lines in Oracle Order Management. 
OE_ORDER_SOURCES Feeder System Names that create orders in Order Management tables. 
OE_ORDER_HOLDS_ALL This table stores information of all the orders and lines that are on hold and the link to hold sources and hold releases. 
OE_SALES_CREDITS This table stores information about sales credits. 
OE_TRANSACTION_TYPES_ALL This table stores information about the order and line transaction types 
WSH_DELIVERY_ASSIGNMENTS Delivery Assignments 
WSH_DELIVERY_DETAILS Delivery Details 
WSH_NEW_DELIVERIES Deliveries 
WSH_TRIPS Trips 
WSH_TRIP_STOPS Trip Stops 


PO - Purchasing

Table Name Description 
PO_ACTION_HISTORY Document approval and control action history table 
PO_AGENTS Buyers table 
PO_DISTRIBUTIONS_ALL Purchase order distributions 
PO_HEADERS_ALL Document headers (for purchase orders, purchase agreements, quotations, RFQs) 
PO_LINES_ALL Purchase document lines (for purchase orders, purchase agreements, quotations, RFQs) 
PO_LINE_LOCATIONS_ALL Document shipment schedules (for purchase orders, purchase agreements, quotations, RFQs) 
PO_RELEASES_ALL Purchase order releases 
PO_LINES_ARCHIVE_ALL Archived purchase order lines 
PO_LINE_LOCATIONS_ARCHIVE_ALL Archived purchase order shipments 
PO_HEADERS_ARCHIVE_ALL Archived purchase orders 
PO_LINE_TYPES_B Line types 
PO_RELEASES_ARCHIVE_ALL Archived releases 
PO_REQUISITION_HEADERS_ALL Requisition headers 
PO_REQUISITION_LINES_ALL Requisition lines 
PO_REQ_DISTRIBUTIONS_ALL Requisition distributions 
RCV_TRANSACTIONS Receiving transactions 
RCV_SHIPMENT_HEADERS Shipment and receipt header information 
RCV_SHIPMENT_LINES Receiving shipment line information 


INV - Inventory

Table Name Description 
MTL_CATEGORIES_B Code combinations table for Item Category 
MTL_CATEGORY_SETS_B Category Sets 
MTL_CUSTOMER_ITEMS Customer item Information 
MTL_CUSTOMER_ITEM_XREFS Relationships between customer items and inventory items 
MTL_DEMAND Sales order demand and reservations 
MTL_DEMAND_HISTORIES Sales order demand and reservations 
MTL_ITEM_LOCATIONS Definitions for stock locators 
MTL_ITEM_REVISIONS_B Item revisions 
MTL_ITEM_TEMPLATES_B Item template definitions 
MTL_ITEM_TEMPL_ATTRIBUTES Item attributes and attribute values for a template 
MTL_LOT_NUMBERS Lot number definitions 
MTL_MATERIAL_TRANSACTIONS Material transaction table 
MTL_MATERIAL_TRANSACTIONS_TEMP Temporary table for processing material transactions 
MTL_ONHAND_QUANTITIES_DETAIL FIFO quantities by control level and receipt 
MTL_PARAMETERS Inventory control options and defaults 
MTL_RESERVATIONS Reservations 
MTL_SECONDARY_INVENTORIES Subinventory definitions 
MTL_SECONDARY_LOCATORS Item-subinventory-locator assignments 
MTL_SERIAL_NUMBERS Serial number definitions 
MTL_SYSTEM_ITEMS_B Inventory item definitions 
MTL_TRANSACTION_ACCOUNTS Material transaction distributions 
MTL_TRANSACTION_TYPES Inventory Transaction Types Table 
MTL_TXN_REQUEST_HEADERS Move Order headers table 
MTL_TXN_REQUEST_LINES Move order lines table 
MTL_UNIT_TRANSACTIONS Serial number transactions 


GL- General Ledger

Table Name Description 
GL_CODE_COMBINATIONS Stores valid account combinations 
GL_SETS_OF_BOOKS Stores information about the sets of books 
GL_IMPORT_REFERENCES Stores individual transactions from subledgers 
GL_DAILY_RATES Stores the daily conversion rates for foreign currency

Transactions 
GL_PERIODS Stores information about the accounting periods 
GL_JE_HEADERS Stores journal entries 
GL_JE_LINES Stores the journal entry lines that you enter in the Enter Journals form 
GL_JE_BATCHES Stores journal entry batches 
GL_BALANCES Stores actual, budget, and encumbrance balances for detail and summary accounts 
GL_BUDGETS Stores Budget definitions 
GL_INTERFACE Import journal entry batches 
GL_BUDGET_INTERFACE Upload budget data from external sources 
GL_DAILY_RATES_INTERFACE Import daily conversion rates 

AR- Accounts Receivables

Table Name Description 
RA_CUST_TRX_TYPES_ALL Transaction type for invoices, commitments and credit memos 
RA_CUSTOMER_TRX_ALL Header-level information about invoices, debit memos, chargebacks, commitments and credit memos 
RA_CUSTOMER_TRX_LINES_ALL Invoice, debit memo, chargeback, credit memo and commitment lines 
RA_CUST_TRX_LINE_GL_DIST_ALL Accounting records for revenue, unearned revenue and unbilled receivables 
RA_CUST_TRX_LINE_SALESREPS_ALL Sales credit assignments for transactions 
AR_ADJUSTMENTS_ALL Pending and approved invoice adjustments 
RA_BATCHES_ALL 
AR_CASH_RECEIPTS_ALL Detailed receipt information 
AR_CASH_RECEIPT_HISTORY_ALL History of actions and status changes in the life cycle of a receipt 
AR_PAYMENT_SCHEDULES_ALL All transactions except adjustments and miscellaneous cash receipts 
AR_RECEIVABLE_APPLICATIONS_ALL Accounting information for cash and credit memo applications 
AR_TRANSACTION_HISTORY_ALL Life cycle of a transaction 
HZ_CUST_ACCOUNTS Stores information about customer accounts. 
HZ_CUSTOMER_PROFILES Credit information for customer accounts and customer account sites 
HZ_CUST_ACCT_SITES_ALL Stores all customer account sites across all operating units 
HZ_CUST_ACCT_RELATE_ALL Relationships between customer accounts 
HZ_CUST_CONTACT_POINTS This table is no longer used 
HZ_CUST_PROF_CLASS_AMTS Customer profile class amount limits for each currency 
HZ_CUST_SITE_USES_ALL Stores business purposes assigned to customer account sites. 
HZ_LOCATIONS Physical addresses 
HZ_ORG_CONTACTS People as contacts for parties 
HZ_ORG_CONTACT_ROLES Roles played by organization contacts 
HZ_PARTIES Information about parties such as organizations, people, and groups 
HZ_PARTY_SITES Links party to physical locations 
HZ_PARTY_SITE_USES The way that a party uses a particular site or address 
HZ_RELATIONSHIPS Relationships between entities 
HZ_RELATIONSHIP_TYPES Relationship types 

CE- Cash Management

Table Name Description 
CE_BANK_ACCOUNTS This table contains bank account information. Each bank account must be affiliated with one bank branch. 
CE_BANK_ACCT_BALANCES This table stores the internal bank account balances 
CE_BANK_ACCT_USES_ALL This table stores information about your bank account uses. 
CE_STATEMENT_HEADERS Bank statements 
CE_STATEMENT_LINES Bank statement lines 
CE_STATEMENT_HEADERS_INT Open interface for bank statements 
CE_STATEMENT_LINES_INTERFACE Open interface for bank statement lines 
CE_TRANSACTION_CODES Bank transaction codes 


AP- Accounts Payables

Table Name Description 
AP_ACCOUNTING_EVENTS_ALL Accounting events table 
AP_AE_HEADERS_ALL Accounting entry headers table 
AP_AE_LINES_ALL Accounting entry lines table 
AP_BANK_ACCOUNTS_ALL Bank Account Details 
AP_BANK_ACCOUNT_USES_ALL Bank Account Uses Information 
AP_BANK_BRANCHES Bank Branches 
AP_BATCHES_ALL Summary invoice batch information 
AP_CHECKS_ALL Supplier payment data 
AP_HOLDS_ALL Invoice hold information 
AP_INVOICES_ALL Detailed invoice records 
AP_INVOICE_LINES_ALL AP_INVOICE_LINES_ALL contains records for invoice lines entered manually, generated automatically or imported from the Open Interface. 
AP_INVOICE_DISTRIBUTIONS_ALL Invoice distribution line information 
AP.AP_INVOICE_PAYMENTS_ALL Invoice payment records 
AP_PAYMENT_DISTRIBUTIONS_ALL Payment distribution information 
AP_PAYMENT_HISTORY_ALL Maturity and reconciliation history for payments 
AP_PAYMENT_SCHEDULES_ALL Scheduled payment information on invoices 
AP_INTERFACE_REJECTIONS Information about data that could not be loaded by Payables Open Interface Import 
AP_INVOICES_INTERFACE Information used to create an invoice using Payables Open Interface Import 
AP_INVOICE_LINES_INTERFACE Information used to create one or more invoice distributions 
AP_SUPPLIERS AP_SUPPLIERS stores information about your supplier level attributes. 
AP_SUPPLIER_SITES_ALL AP_SUPPLIER_SITES_ALL stores information about your supplier site level attributes. 
AP_SUPPLIER_CONTACTS Stores Supplier Contacts 


FA - Fixed Assets

Table Name Description 
FA_ADDITIONS_B Descriptive information about assets 
FA_ADJUSTMENTS Information used by the posting program to generate journal entry lines in the general ledger 
FA_ASSET_HISTORY Historical information about asset reclassifications and unit adjustments 
FA_ASSET_INVOICES Accounts payable and purchasing information for each asset 
FA_BOOKS Financial information of each asset 
FA_BOOK_CONTROLS Control information that affects all assets in a depreciation book 
FA_CALENDAR_PERIODS Detailed calendar information 
FA_CALENDAR_TYPES General calendar information 
FA_CATEGORIES_B Default financial information for asset categories 
FA_CATEGORY_BOOKS Default financial information for an asset category and depreciation book combination 
FA_DEPRN_DETAIL Depreciation amounts charged to the depreciation expense account in each distribution line 
FA_DEPRN_PERIODS Information about each depreciation period 
FA_DEPRN_EVENTS Information about depreciation accounting events. 
FA_DEPRN_SUMMARY Depreciation information at the asset level 
FA_DISTRIBUTION_ACCOUNTS Table to store account ccids for all distributions for a book 
FA_DISTRIBUTION_DEFAULTS Distribution set information 
FA_DISTRIBUTION_HISTORY Employee, location, and Accounting Flexfield values assigned to each asset 
FA_DISTRIBUTION_SETS Header information for distribution sets 
FA_FORMULAS Depreciation rates for formula-based methods 
FA_LOCATIONS Location flexfield segment value combinations 
FA_MASS_ADDITIONS Information about assets that you want to automatically add to Oracle Assets from another system 
FA_METHODS Depreciation method information 
FA_RETIREMENTS Information about asset retirements and reinstatements



HRMS- Human Resource Management System

Table Name Description 
HR_ALL_ORGANIZATION_UNITS Organization unit definitions. 
HR_ALL_POSITIONS_F Position definition information. 
HR_LOCATIONS_ALL Work location definitions. 
PER_ADDRESSES Address information for people 
PER_ALL_PEOPLE_F DateTracked table holding personal information for employees, applicants and other people. 
PER_ALL_ASSIGNMENTS_F Allocated Tasks 
PER_ANALYSIS_CRITERIA Flexfield combination table for the personal analysis key flexfield. 
PER_ASSIGNMENT_EXTRA_INFO Extra information for an assignment. 
PER_ASSIGNMENT_STATUS_TYPES Predefined and user defined assignment status types. 
PER_CONTRACTS_F The details of a persons contract of employment 
PER_CONTACT_RELATIONSHIPS Contacts and relationship details for dependents, beneficiaries, emergency contacts, parents etc. 
PER_GRADES Grade definitions for a business group. 
PER_JOBS Jobs defined for a Business Group 
PER_PAY_BASES Definitions of specific salary bases 
PER_PAY_PROPOSALS Salary proposals and performance review information for employee assignments 
PER_PEOPLE_EXTRA_INFO Extra information for a person 
PER_PERIODS_OF_PLACEMENT Periods of placement details for a non-payrolled worker 
PER_PERIODS_OF_SERVICE Period of service details for an employee. 
PER_PERSON_ANALYSES Special information types for a person 
PER_PERSON_TYPES Person types visible to specific Business Groups. 
PER_PERSON_TYPE_USAGES_F Identifies the types a person may be. 
PER_PHONES PER_PHONES holds phone numbers for current and ex-employees, current and ex-applicants and employee contacts. 
PER_SECURITY_PROFILES Security profile definitions to restrict user access to specific HRMS records

PAY- Payroll
Table Name Description 
PAY_ACTION_INFORMATION Archived data stored by legislation 
PAY_ALL_PAYROLLS_F Payroll group definitions. 
PAY_ASSIGNMENT_ACTIONS Action or process results, showing which assignments have been processed by a specific payroll action, or process. 
PAY_ELEMENT_CLASSIFICATIONS Element classifications for legislation and information needs. 
PAY_ELEMENT_ENTRIES_F Element entry list for each assignment. 
PAY_ELEMENT_ENTRY_VALUES_F Actual input values for specific element entries. 
PAY_ELEMENT_LINKS_F Eligibility rules for an element type. 
PAY_ELEMENT_TYPES_F Element definitions. 
PAY_ELEMENT_TYPE_USAGES_F Used to store elements included or excluded from a defined run type. 
PAY_ORG_PAYMENT_METHODS_F Payment methods used by a Business Group. 
PAY_PAYMENT_TYPES Types of payment that can be processed by the system. 
PAY_PAYROLL_ACTIONS Holds information about a payroll process. 
PAY_PEOPLE_GROUPS People group flexfield information. 
PAY_PERSONAL_PAYMENT_METHODS_F Personal payment method details for an employee. 
PAY_RUN_RESULTS Result of processing a single element entry. 
PAY_RUN_RESULT_VALUES Result values from processing a single element entry. 
PAY_SECURITY_PAYROLLS List of payrolls and security profile access rules. 
PAY_INPUT_VALUES_F Input value definitions for specific elements. 


BOM - Bills Of Material 

Table Name Description 
BOM_DEPARTMENTS Departments 
BOM_DEPARTMENT_CLASSES Department classes 
BOM_DEPARTMENT_RESOURCES Resources associated with departments 
BOM_OPERATIONAL_ROUTINGS Routings 
BOM_OPERATION_NETWORKS Routing operation networks 
BOM_OPERATION_RESOURCES Resources on operations 
BOM_OPERATION_SEQUENCES Routing operations 
BOM_OPERATION_SKILLS 
BOM_RESOURCES Resources, overheads, material cost codes, and material overheads 
BOM_STANDARD_OPERATIONS Standard operations 
BOM_ALTERNATE_DESIGNATORS Alternate designators 
BOM_COMPONENTS_B Bill of material components 
BOM_STRUCTURES_B Bills of material 
BOM_STRUCTURE_TYPES_B Structure Type master table 




WIP - Work in Process 

Table Name Description 
WIP_DISCRETE_JOBS Discrete jobs 
WIP_ENTITIES Information common to jobs and schedules 
WIP_LINES Production lines 
WIP_MOVE_TRANSACTIONS Shop floor move transactions 
WIP_MOVE_TXN_ALLOCATIONS Move transaction allocations for repetitive schedules 
WIP_OPERATIONS Operations necessary for jobs and schedules 
WIP_OPERATION_NETWORKS Operation dependency 
WIP_OPERATION_OVERHEADS Overheads for operations in an average costing organization 
WIP_OPERATION_RESOURCES Resources necessary for operations 
WIP_OPERATION_YIELDS This table keeps all costing information for operation yield costing. 
WIP_TRANSACTIONS WIP resource transactions 
WIP_TRANSACTION_ACCOUNTS Debits and credits due to resource transactions 


FND - Appication Object Library

Table Name Description 
FND_APPLICATION Applications registered with Oracle Application Object Library 
FND_CONCURRENT_PROGRAMS Concurrent programs 
FND_CONCURRENT_REQUESTS Concurrent requests information 
FND_CURRENCIES Currencies enabled for use at your site 
FND_DATA_GROUPS Data groups registered with Oracle Application Object Library 
FND_FLEX_VALUES Valid values for flexfield segments 
FND_FLEX_VALUE_HIERARCHIES Child value ranges for key flexfield segment values 
FND_FLEX_VALUE_SETS Value sets used by both key and descriptive flexfields 
FND_FORM Application forms registered with Oracle Application Object Library 
FND_FORM_FUNCTIONS Functionality groupings 
FND_ID_FLEXS Registration information about key flexfields 
FND_ID_FLEX_SEGMENTS Key flexfield segments setup information and correspondences between table columns and key flexfield segments 
FND_ID_FLEX_STRUCTURES Key flexfield structure information 
FND_LOOKUP_TYPES Oracle Application Object Library QuickCodes 
FND_LOOKUP_VALUES QuickCode values 
FND_MENUS New menu tabl for Release 10SC 
FND_PROFILE_OPTIONS User profile options 
FND_PROFILE_OPTION_VALUES Values of user profile options defined at different profile levels 
FND_REQUEST_SETS Reports sets 
FND_REQUEST_SET_PROGRAMS Reports within report sets 
FND_REQUEST_SET_STAGES Stores request set stages 
FND_RESPONSIBILITY Responsibilities 
FND_RESP_FUNCTIONS Function Security 
FND_USER Application users

JA - Asia/Pacific Localizations

Table Name Description 
JAI_CMN_BOE_HDRS Stores BOE header info when a BOE Invoice is created through IL 
JAI_CMN_BOE_DTLS Detail table for BOE Invoices 
JAI_CMN_TAXES_ALL Master table for Localization Taxes 
JAI_CMN_TAX_CTGS_ALL Stores tax categories and their link to excise ITEM classes. 
JAI_CMN_TAX_CTG_LINES Stores the tax lines for defined tax categories 
JAI_CMN_VENDOR_SITES Stores excise account related information about vendors. 
JAI_RGM_DEFINITIONS Stores regime information. 
JAI_RGM_TAXES This table stores tax details for transactions having TCS tax type. 
JAI_CMN_RG_23AC_I_TRXS Stores Information of RG23A/C records and known as Quantity Register. 
JAI_CMN_RG_23AC_II_TRXS Stores Information of RG23A/C Part II Details. Also known as Amount Register 
JAI_CMN_RG_23D_TRXS Quantity register for Trading Organizations 
JAI_CMN_RG_BALANCES Store the current balances of RG23A, RG23C and PLA Registers 
JAI_CMN_RG_PLA_TRXS Stores the Transaction Information of PLA Register. 
JAI_CMN_RG_PLA_HDRS Stores PLA header Infomation when a PLA invoice is created in AP module 
JAI_CMN_RG_PLA_DTLS Stores PLA Detail Information when a PLA Invoice is created in AP Module 


QP - Advanced Pricing 

Table Name Description 
QP_LIST_HEADERS_B QP_LIST_HEADERS_B stores the header information for all lists. List types can be, for example, Price Lists, Discount Lists or Promotions. 
QP_LIST_LINES QP_LIST_LINES stores all list lines for lists in QP_LIST_HEADERS_B. 
QP_PRICE_FORMULAS_B QP_PRICE_FORMULAS_B stores the pricing formula header information. 
QP_PRICE_FORMULA_LINES QP_PRICE_FORMULA_LINES stores each component that makes up the formula. 
QP_PRICING_ATTRIBUTES QP_PRICING_ATTRIBUTES stores product information and pricing attributes. 
QP_QUALIFIERS QP_QUALIFIERS stores qualifier attribute information.



XLA - Subledger Accounting 

Table Name Description 
XLA_EVENTS The XLA_EVENTS table record all information related to a specific event. This table is created as a type XLA_ARRAY_EVENT_TYPE. 
XLA_TRANSACTION_ENTITIES The table XLA_ENTITIES contains information about sub-ledger document or transactions. 
XLA_AE_HEADERS The XLA_AE_HEADERS table stores subledger journal entries. There is a one-to-many relationship between accounting events and journal entry headers. 
XLA_AE_LINES The XLA_AE_LINES table stores the subledger journal entry lines. There is a one-to-many relationship between subledger journal entry headers and subledger journal entry lines. 
XLA_DISTRIBUTION_LINKS The XLA_DISTRIBUTION_LINKS table stores the link between transactions and subledger journal entry lines. 
XLA_ACCOUNTING_ERRORS The XLA_ACCOUNTING_ERRORS table stores the errors encountered during execution of the Accounting Program. 
XLA_ACCTG_METHODS_B The XLA_ACCTG_METHODS_B table stores Subledger Accounting Methods (SLAM) across products. SLAMs provided by development are not chart of accounts specific. Enabled SLAMs are assigned to ledgers. 
XLA_EVENT_TYPES_B The XLA_EVENT_TYPES_B table stores all event types that belong to an event class. 
XLA_GL_LEDGERS This table contains ledger information used by subledger accounting