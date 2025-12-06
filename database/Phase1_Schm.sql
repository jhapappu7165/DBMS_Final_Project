-- Electronics Vendor Database - Relational Schema
-- Phase 1: Database Design
-- Normalized relational design derived from the E-R diagram. 
-- All tables are in 3NF (Third Normal Form) or higher.


-- Database already created by Docker container
USE electronics_vendor;


-- BASE ENTITIES

-- Vendor/Manufacturer Table--
CREATE TABLE Vendor (
    VendorID INT PRIMARY KEY AUTO_INCREMENT,
    VendorName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    INDEX idx_vendor_name (VendorName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Product Table
CREATE TABLE Product (
    UPC VARCHAR(50) PRIMARY KEY,
    ProductName VARCHAR(200) NOT NULL,
    Description TEXT,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    Manufacturer VARCHAR(100),
    ModelNumber VARCHAR(50),
    Weight DECIMAL(8, 2),
    Dimensions VARCHAR(100),
    VendorID INT NOT NULL,
    FOREIGN KEY (VendorID) REFERENCES Vendor(VendorID) ON DELETE RESTRICT,
    INDEX idx_product_name (ProductName),
    INDEX idx_vendor (VendorID),
    INDEX idx_manufacturer (Manufacturer)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Category Table
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL,
    CategoryType ENUM('ProductType', 'Manufacturer', 'Package') NOT NULL,
    Description TEXT,
    INDEX idx_category_type (CategoryType),
    INDEX idx_category_name (CategoryName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Product-Category Relationship Table (Many-to-Many)
CREATE TABLE ProductCategory (
    UPC VARCHAR(50),
    CategoryID INT,
    PRIMARY KEY (UPC, CategoryID),
    FOREIGN KEY (UPC) REFERENCES Product(UPC) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID) ON DELETE CASCADE,
    INDEX idx_category (CategoryID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Store Table
CREATE TABLE Store (
    StoreID INT PRIMARY KEY AUTO_INCREMENT,
    StoreName VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(10),
    Phone VARCHAR(20),
    ManagerName VARCHAR(100),
    INDEX idx_store_state (State),
    INDEX idx_store_city (City, State)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Warehouse Table
CREATE TABLE Warehouse (
    WarehouseID INT PRIMARY KEY AUTO_INCREMENT,
    WarehouseName VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Phone VARCHAR(20),
    ManagerName VARCHAR(100),
    INDEX idx_warehouse_state (State)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    CustomerType ENUM('Contract', 'Infrequent') NOT NULL,
    AccountNumber VARCHAR(50) NULL, -- Only for contract customers
    CreditCardNumber VARCHAR(20) NULL, -- Only for infrequent/online customers
    CreditCardExpiry DATE NULL,
    CreditCardCVV VARCHAR(4) NULL,
    -- Constraints
    CONSTRAINT chk_contract_customer CHECK (
        (CustomerType = 'Contract' AND AccountNumber IS NOT NULL AND CreditCardNumber IS NULL) OR
        (CustomerType = 'Infrequent')
    ),
    INDEX idx_customer_type (CustomerType),
    INDEX idx_customer_name (LastName, FirstName),
    INDEX idx_account_number (AccountNumber),
    INDEX idx_email (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ORDER MANAGEMENT

-- Order Table
CREATE TABLE `Order` (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    OrderType ENUM('Online', 'InStore', 'Phone') NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL CHECK (TotalAmount >= 0),
    Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    StoreID INT NULL, -- Only for in-store orders
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE RESTRICT,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID) ON DELETE SET NULL,
    INDEX idx_order_date (OrderDate),
    INDEX idx_customer (CustomerID),
    INDEX idx_store (StoreID),
    INDEX idx_order_type (OrderType),
    INDEX idx_status (Status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- OrderItem Table
CREATE TABLE OrderItem (
    OrderID INT,
    UPC VARCHAR(50),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    Subtotal DECIMAL(10, 2) NOT NULL CHECK (Subtotal >= 0),
    PRIMARY KEY (OrderID, UPC),
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (UPC) REFERENCES Product(UPC) ON DELETE RESTRICT,
    INDEX idx_upc (UPC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- SHIPMENT MANAGEMENT

-- Shipment Table
CREATE TABLE Shipment (
    ShipmentID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL UNIQUE, -- One shipment per online order
    TrackingNumber VARCHAR(50) NOT NULL UNIQUE,
    Carrier VARCHAR(50) NOT NULL, -- e.g., 'USPS', 'FedEx', 'UPS'
    ShippedDate DATETIME NOT NULL,
    PromisedDeliveryDate DATETIME NOT NULL,
    ActualDeliveryDate DATETIME NULL,
    Status ENUM('Shipped', 'InTransit', 'Delivered', 'Lost', 'Damaged') NOT NULL DEFAULT 'Shipped',
    ShippingAddress VARCHAR(200) NOT NULL,
    ShippingCity VARCHAR(50) NOT NULL,
    ShippingState VARCHAR(50) NOT NULL,
    ShippingZipCode VARCHAR(10) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID) ON DELETE CASCADE,
    INDEX idx_tracking_number (TrackingNumber),
    INDEX idx_carrier (Carrier),
    INDEX idx_shipped_date (ShippedDate),
    INDEX idx_promised_delivery (PromisedDeliveryDate),
    INDEX idx_status (Status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- INVENTORY MANAGEMENT

-- Inventory Table
CREATE TABLE Inventory (
    UPC VARCHAR(50),
    LocationType ENUM('Store', 'Warehouse') NOT NULL,
    LocationID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 0 CHECK (Quantity >= 0),
    ReorderLevel INT NOT NULL DEFAULT 10 CHECK (ReorderLevel >= 0),
    LastUpdated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (UPC, LocationType, LocationID),
    FOREIGN KEY (UPC) REFERENCES Product(UPC) ON DELETE CASCADE,
    -- Note: LocationID references StoreID or WarehouseID based on LocationType
    -- This is enforced at application level or via triggers
    INDEX idx_location (LocationType, LocationID),
    INDEX idx_quantity (Quantity),
    INDEX idx_reorder_check (UPC, LocationType, LocationID, Quantity, ReorderLevel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Reorder Table
CREATE TABLE Reorder (
    ReorderID INT PRIMARY KEY AUTO_INCREMENT,
    UPC VARCHAR(50) NOT NULL,
    VendorID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Pending', 'Ordered', 'Shipped', 'Received', 'Cancelled') NOT NULL DEFAULT 'Pending',
    ExpectedDeliveryDate DATETIME NULL,
    ReceivedDate DATETIME NULL,
    UnitCost DECIMAL(10, 2) NOT NULL CHECK (UnitCost >= 0),
    FOREIGN KEY (UPC) REFERENCES Product(UPC) ON DELETE RESTRICT,
    FOREIGN KEY (VendorID) REFERENCES Vendor(VendorID) ON DELETE RESTRICT,
    INDEX idx_upc (UPC),
    INDEX idx_vendor (VendorID),
    INDEX idx_status (Status),
    INDEX idx_order_date (OrderDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- TRIGGERS FOR DATA INTEGRITY

-- Trigger to automatically calculate OrderItem.Subtotal
DELIMITER //
CREATE TRIGGER calculate_order_item_subtotal
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    SET NEW.Subtotal = NEW.Quantity * NEW.UnitPrice;
END//

CREATE TRIGGER update_order_item_subtotal
BEFORE UPDATE ON OrderItem
FOR EACH ROW
BEGIN
    SET NEW.Subtotal = NEW.Quantity * NEW.UnitPrice;
END//
DELIMITER ;



-- VIEWS FOR COMMON QUERIES

-- View: Product with Vendor Information
CREATE VIEW ProductVendorView AS
SELECT 
    p.UPC,
    p.ProductName,
    p.UnitPrice,
    p.Manufacturer,
    v.VendorName,
    v.VendorID
FROM Product p
JOIN Vendor v ON p.VendorID = v.VendorID;

-- View: Order Summary with Customer Info
CREATE VIEW OrderSummaryView AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.OrderType,
    o.TotalAmount,
    o.Status,
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.CustomerType,
    s.StoreName
FROM `Order` o
JOIN Customer c ON o.CustomerID = c.CustomerID
LEFT JOIN Store s ON o.StoreID = s.StoreID;

-- View: Inventory Status (showing low stock)
CREATE VIEW InventoryStatusView AS
SELECT 
    i.UPC,
    p.ProductName,
    i.LocationType,
    i.LocationID,
    CASE 
        WHEN i.LocationType = 'Store' THEN s.StoreName
        WHEN i.LocationType = 'Warehouse' THEN w.WarehouseName
    END AS LocationName,
    i.Quantity,
    i.ReorderLevel,
    CASE 
        WHEN i.Quantity <= i.ReorderLevel THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus
FROM Inventory i
JOIN Product p ON i.UPC = p.UPC
LEFT JOIN Store s ON i.LocationType = 'Store' AND i.LocationID = s.StoreID
LEFT JOIN Warehouse w ON i.LocationType = 'Warehouse' AND i.LocationID = w.WarehouseID;
