# Phase 1: Database Design Documentation
## Electronics Vendor Database System

---

## 1. DESIGN OVERVIEW

This document describes the complete database design for the Electronics Vendor system, including the E-R diagram, relational schema, and design decisions. The design follows normalization principles and is optimized for the required queries.

---

## 2. ENTITY-RELATIONSHIP MODEL

### 2.1 Entity Summary

The database contains **11 main entities**:

1. **Vendor** - Manufacturers/suppliers of products
2. **Product** - Products sold by the company (UPC as primary key)
3. **Category** - Product categories (by type, manufacturer, or package)
4. **ProductCategory** - Junction table for many-to-many relationship
5. **Customer** - Both contract and infrequent customers
6. **Store** - Physical retail locations
7. **Warehouse** - Warehouse facilities
8. **Order** - Sales orders (online, in-store, phone)
9. **OrderItem** - Items within each order
10. **Shipment** - Shipping information for online orders
11. **Inventory** - Stock levels at stores and warehouses
12. **Reorder** - Reorder requests to vendors

### 2.2 Key Design Decisions

#### Customer Type Handling
- **Unified Customer Table**: Instead of separate tables for contract and infrequent customers, we use a single table with a `CustomerType` enum and conditional attributes.
- **Rationale**: Simplifies queries, reduces joins, and maintains referential integrity. The CHECK constraint ensures data consistency (contract customers have AccountNumber, infrequent customers may have credit card info).

#### Product-Vendor Relationship
- **Direct Many-to-One**: Each product has a direct foreign key to Vendor.
- **Rationale**: From feedback - establish direct relationships to minimize joins. This allows efficient queries like "find all products from Sony" without complex joins.

#### Category System
- **Flexible Categorization**: Products can belong to multiple categories via ProductCategory junction table.
- **CategoryType Enum**: Supports three types - ProductType, Manufacturer, Package.
- **Rationale**: Meets requirement for overlapping categories while maintaining normalization.

#### Inventory Design
- **Unified Inventory Table**: Single table for both store and warehouse inventory using LocationType enum.
- **Composite Key**: (UPC, LocationType, LocationID) ensures unique inventory records per location.
- **Rationale**: Simplifies queries, allows consistent inventory management across location types.

#### Order-Shipment Relationship
- **One-to-One**: Each online order has exactly one shipment.
- **Rationale**: Simplifies tracking and meets requirement that "online sales must be sent to a shipper."

---

## 3. RELATIONAL SCHEMA DESIGN

### 3.1 Normalization

All tables are in **Third Normal Form (3NF)** or higher:

- **1NF**: All attributes are atomic, no repeating groups
- **2NF**: All non-key attributes fully dependent on primary key
- **3NF**: No transitive dependencies

**Example of Normalization:**
- OrderItem stores `UnitPrice` (price at time of order) to maintain historical accuracy
- This prevents issues if Product.UnitPrice changes later
- Subtotal is calculated via trigger to maintain consistency

### 3.2 Primary Keys

- **Simple Keys**: VendorID, CategoryID, CustomerID, StoreID, WarehouseID, OrderID, ShipmentID, ReorderID (all AUTO_INCREMENT integers)
- **Composite Keys**: 
  - OrderItem: (OrderID, UPC)
  - Inventory: (UPC, LocationType, LocationID)
  - ProductCategory: (UPC, CategoryID)
- **Natural Key**: Product.UPC (Universal Product Code is naturally unique)

### 3.3 Foreign Keys and Referential Integrity

All foreign keys have appropriate constraints:
- `ON DELETE RESTRICT`: Prevents deletion of referenced records (e.g., can't delete a vendor if products exist)
- `ON DELETE CASCADE`: Deletes dependent records (e.g., deleting an order deletes its items)
- `ON DELETE SET NULL`: Sets foreign key to NULL (e.g., deleting a store sets Order.StoreID to NULL)

### 3.4 Constraints

**CHECK Constraints:**
- Prices and quantities must be non-negative
- Customer type constraints ensure data consistency
- Quantity must be positive for OrderItem and Reorder

**UNIQUE Constraints:**
- TrackingNumber (shipments)
- AccountNumber (contract customers)
- UPC (products - natural uniqueness)

---

## 4. QUERY OPTIMIZATION ANALYSIS

The design is optimized for the 7 required queries:

### Query 1: Damaged Shipment Replacement
**Required Data:**
- Shipment (tracking number, status)
- Customer (contact info)
- OrderItem (contents of shipment)
- Product (replacement items)

**Design Support:**
- Direct Shipment → Order → Customer relationship
- OrderItem links Order to Product
- Status field in Shipment supports filtering

### Query 2: Top Customer by Revenue
**Required Data:**
- Customer
- Order (dates, total amounts)
- OrderItem (quantities, prices)

**Design Support:**
- Order.TotalAmount stores pre-calculated total
- OrderDate indexed for date filtering
- Direct Customer → Order relationship

### Query 3 & 4: Top Products by Revenue/Units
**Required Data:**
- Product
- OrderItem (quantities, prices)
- Order (dates)

**Design Support:**
- OrderItem stores UnitPrice and Quantity
- Subtotal pre-calculated via trigger
- OrderDate indexed for time-based filtering

### Query 5: Out-of-Stock in California Stores
**Required Data:**
- Product
- Inventory (quantity = 0)
- Store (state = 'California')

**Design Support:**
- Inventory.LocationType distinguishes stores from warehouses
- Store.State indexed for efficient filtering
- Direct Inventory → Store relationship via LocationID

### Query 6: Late Deliveries
**Required Data:**
- Shipment (PromisedDeliveryDate, ActualDeliveryDate)

**Design Support:**
- Both dates stored in Shipment table
- Indexes on both date fields for efficient comparison
- Status field for filtering

### Query 7: Monthly Billing
**Required Data:**
- Customer (contract customers only)
- Order (past month)
- OrderItem (prices)

**Design Support:**
- CustomerType = 'Contract' filters customers
- AccountNumber identifies billable customers
- OrderDate indexed for monthly filtering
- OrderItem provides itemized billing details

---

## 5. INDEXING STRATEGY

### Primary Indexes
- All primary keys are automatically indexed
- Foreign keys are indexed for join performance

### Secondary Indexes
Created for frequently queried attributes:

1. **Date-based queries:**
   - Order.OrderDate
   - Shipment.ShippedDate, PromisedDeliveryDate
   - Reorder.OrderDate

2. **Location-based queries:**
   - Store.State, Store.City
   - Warehouse.State

3. **Search and filtering:**
   - Product.ProductName, Manufacturer
   - Customer.LastName, FirstName, Email
   - Vendor.VendorName
   - Category.CategoryName, CategoryType

4. **Status and type filtering:**
   - Order.Status, OrderType
   - Shipment.Status, Carrier
   - Customer.CustomerType
   - Reorder.Status

5. **Composite indexes:**
   - Store (City, State) - for location-based queries
   - Inventory (LocationType, LocationID) - for inventory lookups

---

## 6. DATA INTEGRITY MECHANISMS

### Triggers
1. **calculate_order_item_subtotal**: Automatically calculates Subtotal when OrderItem is inserted
2. **update_order_item_subtotal**: Recalculates Subtotal when OrderItem is updated

### Constraints
- CHECK constraints ensure data validity (non-negative prices, positive quantities)
- UNIQUE constraints prevent duplicates (tracking numbers, UPCs)
- FOREIGN KEY constraints maintain referential integrity
- Customer type CHECK constraint ensures logical consistency

### Views
Created for common query patterns:
- **ProductVendorView**: Product with vendor information
- **OrderSummaryView**: Order with customer and store info
- **InventoryStatusView**: Inventory with low stock indicators

---

## 7. DESIGN VALIDATION

### Requirements Coverage

✅ **Products with unique UPCs**
- UPC is primary key, UNIQUE constraint enforced

✅ **Multiple category types**
- CategoryType enum supports ProductType, Manufacturer, Package
- Many-to-many relationship allows overlapping categories

✅ **Two customer types**
- CustomerType enum with CHECK constraint
- Contract customers: AccountNumber required, no credit card
- Infrequent customers: Credit card optional (online only)

✅ **Online sales with shipments**
- OrderType distinguishes online orders
- Shipment table with tracking numbers
- One-to-one relationship Order → Shipment

✅ **Inventory tracking**
- Inventory table supports stores and warehouses
- ReorderLevel triggers reorder process
- Quantity tracking with automatic updates

✅ **Reorder system**
- Reorder table tracks status
- Links to Vendor and Product
- Supports full lifecycle (Pending → Received)

✅ **Sales data for analysis**
- Order and OrderItem store historical prices
- Date fields support time-based analysis
- TotalAmount pre-calculated for efficiency

✅ **Store and warehouse support**
- Separate entities with location information
- State field supports regional queries

### Design Principles Applied

1. **Efficiency First**: Direct relationships minimize joins
2. **Simplification**: Unified tables where appropriate (Customer, Inventory)
3. **Normalization**: 3NF compliance prevents redundancy
4. **Query Optimization**: Indexes on frequently queried attributes
5. **Data Integrity**: Constraints and triggers ensure consistency

---

## 8. IMPLEMENTATION NOTES

### Database System
- Designed for MySQL (preferred) but compatible with PostgreSQL, Oracle, SQL Server
- Uses InnoDB engine for transaction support and foreign keys
- UTF-8 character set for international support

### Platform Independence
- Standard SQL syntax (no MySQL-specific features that break portability)
- Can be adapted to other DBMS with minor modifications

### Concurrency Support
- InnoDB engine provides ACID transaction support
- Row-level locking for concurrent access
- Transaction isolation levels configurable

---

## 9. NEXT STEPS (Phase 2)

After Phase 1 completion, Phase 2 will involve:

1. **Database Setup**
   - Create database using provided schema
   - Verify all constraints and indexes
   - Test foreign key relationships

2. **Data Population**
   - Generate realistic test data
   - Ensure sufficient data for interesting queries
   - Populate all tables with appropriate relationships

3. **Query Implementation**
   - Implement all 7 required queries
   - Test query performance
   - Capture screenshots of results

---

## 10. APPENDIX: E-R TO RELATIONAL MAPPING

### Entity to Table Mapping

| E-R Entity | Relational Table | Notes |
|------------|------------------|-------|
| Product | Product | UPC as PK |
| Category | Category | CategoryID as PK |
| Product-Category (M:N) | ProductCategory | Junction table |
| Vendor | Vendor | VendorID as PK |
| Customer | Customer | Unified table with type |
| Store | Store | StoreID as PK |
| Warehouse | Warehouse | WarehouseID as PK |
| Order | Order | OrderID as PK |
| OrderItem | OrderItem | Composite PK |
| Shipment | Shipment | ShipmentID as PK |
| Inventory | Inventory | Composite PK |
| Reorder | Reorder | ReorderID as PK |

### Relationship Implementation

- **1:1 Relationships**: Foreign key with UNIQUE constraint (Order → Shipment)
- **1:M Relationships**: Foreign key in "many" side (Customer → Order)
- **M:N Relationships**: Junction table (Product ↔ Category)

---

**End of Phase 1 Design Documentation**

