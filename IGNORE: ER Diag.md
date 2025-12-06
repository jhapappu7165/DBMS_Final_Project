# E-R Diagram for Electronics Vendor Database System

## Entity-Relationship Diagram Description

This document describes the complete E-R diagram for the Electronics Vendor database system. The diagram follows standard E-R notation with entities, attributes, relationships, and cardinalities.

---

## ENTITIES

### 1. **Product**
- **Primary Key:** UPC (Universal Product Code)
- **Attributes:**
  - UPC (String, unique identifier)
  - ProductName (String)
  - Description (Text)
  - UnitPrice (Decimal)
  - Manufacturer (String)
  - ModelNumber (String)
  - Weight (Decimal, optional)
  - Dimensions (String, optional)

### 2. **Category**
- **Primary Key:** CategoryID
- **Attributes:**
  - CategoryID (Integer)
  - CategoryName (String)
  - CategoryType (Enum: 'ProductType', 'Manufacturer', 'Package')
  - Description (Text, optional)

### 3. **Vendor**
- **Primary Key:** VendorID
- **Attributes:**
  - VendorID (Integer)
  - VendorName (String)
  - ContactPerson (String)
  - Email (String)
  - Phone (String)
  - Address (String)
  - City (String)
  - State (String)
  - ZipCode (String)

### 4. **Customer**
- **Primary Key:** CustomerID
- **Attributes:**
  - CustomerID (Integer)
  - FirstName (String)
  - LastName (String)
  - Email (String)
  - Phone (String)
  - Address (String)
  - City (String)
  - State (String)
  - ZipCode (String)
  - CustomerType (Enum: 'Contract', 'Infrequent')
  - AccountNumber (String, nullable - only for contract customers)
  - CreditCardNumber (String, nullable - only for infrequent/online customers)
  - CreditCardExpiry (Date, nullable)
  - CreditCardCVV (String, nullable)

### 5. **Store**
- **Primary Key:** StoreID
- **Attributes:**
  - StoreID (Integer)
  - StoreName (String)
  - Address (String)
  - City (String)
  - State (String)
  - ZipCode (String)
  - Phone (String)
  - ManagerName (String, optional)

### 6. **Warehouse**
- **Primary Key:** WarehouseID
- **Attributes:**
  - WarehouseID (Integer)
  - WarehouseName (String)
  - Address (String) 
  - City (String)
  - State (String)
  - ZipCode (String)
  - Phone (String)
  - ManagerName (String, optional)

### 7. **Order**
- **Primary Key:** OrderID
- **Attributes:**
  - OrderID (Integer)
  - CustomerID (Integer, Foreign Key)
  - OrderDate (DateTime)
  - OrderType (Enum: 'Online', 'InStore', 'Phone')
  - TotalAmount (Decimal)
  - Status (Enum: 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
  - StoreID (Integer, Foreign Key, nullable - only for in-store orders)
  - PaymentMethod (String)

### 8. **OrderItem**
- **Primary Key:** (OrderID, UPC) - Composite Key
- **Attributes:**
  - OrderID (Integer, Foreign Key)
  - UPC (String, Foreign Key)
  - Quantity (Integer)
  - UnitPrice (Decimal) - price at time of order
  - Subtotal (Decimal) - Quantity × UnitPrice

### 9. **Shipment**
- **Primary Key:** ShipmentID
- **Attributes:**
  - ShipmentID (Integer)
  - OrderID (Integer, Foreign Key, unique - one shipment per online order)
  - TrackingNumber (String, unique)
  - Carrier (String) - e.g., 'USPS', 'FedEx', 'UPS'
  - ShippedDate (DateTime)
  - PromisedDeliveryDate (DateTime)
  - ActualDeliveryDate (DateTime, nullable)
  - Status (Enum: 'Shipped', 'InTransit', 'Delivered', 'Lost', 'Damaged')
  - ShippingAddress (String)
  - ShippingCity (String)
  - ShippingState (String)
  - ShippingZipCode (String)

### 10. **Inventory**
- **Primary Key:** (UPC, LocationType, LocationID) - Composite Key
- **Attributes:**
  - UPC (String, Foreign Key)
  - LocationType (Enum: 'Store', 'Warehouse')
  - LocationID (Integer) - references StoreID or WarehouseID based on LocationType
  - Quantity (Integer)
  - ReorderLevel (Integer) - threshold to trigger reorder
  - LastUpdated (DateTime)

### 11. **Reorder**
- **Primary Key:** ReorderID
- **Attributes:**
  - ReorderID (Integer)
  - UPC (String, Foreign Key)
  - VendorID (Integer, Foreign Key)
  - Quantity (Integer)
  - OrderDate (DateTime)
  - Status (Enum: 'Pending', 'Ordered', 'Shipped', 'Received', 'Cancelled')
  - ExpectedDeliveryDate (DateTime, nullable)
  - ReceivedDate (DateTime, nullable)
  - UnitCost (Decimal)

---

## RELATIONSHIPS

### 1. **Product ↔ Category** (Many-to-Many)
- **Relationship Name:** BelongsTo
- **Cardinality:** Many-to-Many
- **Description:** A product can belong to multiple categories (by type, manufacturer, or package). A category contains many products.
- **Attributes:** None (pure many-to-many relationship)

### 2. **Product → Vendor** (Many-to-One)
- **Relationship Name:** SuppliedBy
- **Cardinality:** Many-to-One
- **Description:** Each product is supplied by one vendor. A vendor supplies many products.
- **Attributes:** None

### 3. **Customer → Order** (One-to-Many)
- **Relationship Name:** Places
- **Cardinality:** One-to-Many
- **Description:** A customer can place many orders. Each order belongs to one customer.
- **Attributes:** None

### 4. **Store → Order** (One-to-Many, Optional)
- **Relationship Name:** Processes
- **Cardinality:** One-to-Many (optional on Order side)
- **Description:** A store can process many in-store orders. An order may be associated with a store (for in-store orders) or null (for online/phone orders).
- **Attributes:** None

### 5. **Order → OrderItem** (One-to-Many)
- **Relationship Name:** Contains
- **Cardinality:** One-to-Many
- **Description:** An order contains many order items. Each order item belongs to exactly one order.
- **Attributes:** None

### 6. **Product → OrderItem** (One-to-Many)
- **Relationship Name:** OrderedAs
- **Cardinality:** One-to-Many
- **Description:** A product can appear in many order items. Each order item references one product.
- **Attributes:** None

### 7. **Order → Shipment** (One-to-One, Optional)
- **Relationship Name:** ShippedAs
- **Cardinality:** One-to-One (optional on Order side)
- **Description:** An online order has exactly one shipment. A shipment belongs to exactly one order. Only online orders have shipments.
- **Attributes:** None

### 8. **Product → Inventory** (One-to-Many)
- **Relationship Name:** StoredAt
- **Cardinality:** One-to-Many
- **Description:** A product can have inventory at multiple locations (stores and warehouses). Each inventory record is for one product at one location.
- **Attributes:** None

### 9. **Inventory → Reorder** (One-to-Many)
- **Relationship Name:** Triggers
- **Cardinality:** One-to-Many
- **Description:** When inventory at a location falls below reorder level, it can trigger multiple reorders. A reorder is triggered by inventory at a specific location.
- **Attributes:** None (implicit - reorder is created when inventory is low)

### 10. **Vendor → Reorder** (One-to-Many)
- **Relationship Name:** Receives
- **Cardinality:** One-to-Many
- **Description:** A vendor can receive many reorder requests. Each reorder is sent to one vendor.
- **Attributes:** None

---

## DESIGN NOTES

### Customer Type Handling
- **Contract Customers:** Have an AccountNumber and are billed monthly. Credit card info is NOT stored.
- **Infrequent Customers:** Pay with credit/debit card. Card information may be stored for online customers but NOT for in-store customers.

### Inventory Management
- Inventory is tracked separately for each location (store or warehouse)
- Each location has its own reorder level
- When inventory falls below reorder level, a reorder is created

### Order Types
- **Online Orders:** Must have a shipment with tracking number
- **In-Store Orders:** Associated with a store, no shipment needed
- **Phone Orders:** Placed by call center, may or may not have shipment depending on delivery method

### Category Types
- Products can be categorized in multiple ways:
  - **ProductType:** e.g., "Camera", "Phone", "Laptop"
  - **Manufacturer:** e.g., "Sony", "Apple", "Samsung"
  - **Package:** e.g., "Gateway PC Package" (includes PC, monitor, printer)

### Query Optimization Considerations
- Direct relationships established to minimize joins:
  - Product → Vendor (direct, not through intermediate entity)
  - Order → Store (direct for in-store orders)
  - Order → Shipment (direct one-to-one for online orders)
- Composite keys used where appropriate to ensure data integrity

---

## E-R DIAGRAM NOTATION

```
Entities: Rectangles
Relationships: Diamonds
Attributes: Ovals (or listed in entity boxes)
Primary Keys: Underlined
Foreign Keys: Marked with (FK)
Cardinality: 1, M, or N on relationship lines
```

### Visual Representation Summary:

```
Customer (1) ----< Places >---- (M) Order
Order (1) ----< Contains >---- (M) OrderItem
Product (1) ----< OrderedAs >---- (M) OrderItem
Product (1) ----< SuppliedBy >---- (M) Vendor
Product (M) ----< BelongsTo >---- (M) Category
Order (1) ----< ShippedAs >---- (1) Shipment
Product (1) ----< StoredAt >---- (M) Inventory
Inventory (1) ----< Triggers >---- (M) Reorder
Vendor (1) ----< Receives >---- (M) Reorder
Store (1) ----< Processes >---- (M) Order (optional)
```

---

## VALIDATION AGAINST REQUIREMENTS

✅ **Products with unique UPCs** - UPC is primary key  
✅ **Multiple category types** - CategoryType attribute supports this  
✅ **Two customer types** - CustomerType enum with different attributes  
✅ **Online sales with shipments** - OrderType and Shipment relationship  
✅ **Inventory tracking** - Inventory entity with location support  
✅ **Reorder system** - Reorder entity with status tracking  
✅ **Sales data for analysis** - Order, OrderItem with dates and prices  
✅ **Store and warehouse support** - Separate entities with location info  

---

**End of E-R Diagram Description**

