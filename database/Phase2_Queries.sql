-- Phase 2: Required Queries: All 7 queries 

USE electronics_vendor;

-- QUERY 1: Damaged Shipment Replacement

SELECT 
    '=== CUSTOMER CONTACT INFORMATION ===' AS QuerySection;
    
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone,
    c.Address,
    c.City,
    c.State,
    c.ZipCode,
    s.TrackingNumber,
    s.Carrier,
    s.OrderID
FROM Shipment s
JOIN `Order` o ON s.OrderID = o.OrderID
JOIN Customer c ON o.CustomerID = c.CustomerID
WHERE s.TrackingNumber = '123456';

-- Step 2: Find contents of the damaged shipment
SELECT 
    '=== DAMAGED SHIPMENT CONTENTS ===' AS QuerySection;
    
SELECT 
    oi.OrderID,
    oi.UPC,
    p.ProductName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Subtotal,
    s.TrackingNumber,
    s.Carrier
FROM OrderItem oi
JOIN Product p ON oi.UPC = p.UPC
JOIN `Order` o ON oi.OrderID = o.OrderID
JOIN Shipment s ON o.OrderID = s.OrderID
WHERE s.TrackingNumber = '123456';

-- Step 3: Update shipment status to Damaged
UPDATE Shipment 
SET Status = 'Damaged'
WHERE TrackingNumber = '123456';

-- Step 4: Create new order and shipment for replacement items
-- Get original order details
SET @original_order_id = (SELECT OrderID FROM Shipment WHERE TrackingNumber = '123456');
SET @customer_id = (SELECT CustomerID FROM `Order` WHERE OrderID = @original_order_id);
SET @shipping_address = (SELECT ShippingAddress FROM Shipment WHERE TrackingNumber = '123456');
SET @shipping_city = (SELECT ShippingCity FROM Shipment WHERE TrackingNumber = '123456');
SET @shipping_state = (SELECT ShippingState FROM Shipment WHERE TrackingNumber = '123456');
SET @shipping_zip = (SELECT ShippingZipCode FROM Shipment WHERE TrackingNumber = '123456');
SET @carrier = (SELECT Carrier FROM Shipment WHERE TrackingNumber = '123456');
SET @total_amount = (SELECT TotalAmount FROM `Order` WHERE OrderID = @original_order_id);

-- Create new replacement order
INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod)
SELECT CustomerID, NOW(), 'Online', TotalAmount, 'Processing', PaymentMethod
FROM `Order`
WHERE OrderID = @original_order_id;

SET @new_order_id = LAST_INSERT_ID();

-- Copy order items to new replacement order
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal)
SELECT @new_order_id, UPC, Quantity, UnitPrice, Subtotal
FROM OrderItem
WHERE OrderID = @original_order_id;

-- Create new shipment for replacement order
INSERT INTO Shipment (
    OrderID, 
    TrackingNumber, 
    Carrier, 
    ShippedDate, 
    PromisedDeliveryDate, 
    ActualDeliveryDate, 
    Status, 
    ShippingAddress, 
    ShippingCity, 
    ShippingState, 
    ShippingZipCode
)
VALUES (
    @new_order_id,
    '123456-REPLACEMENT',
    @carrier,
    NOW(),
    DATE_ADD(NOW(), INTERVAL 5 DAY),
    NULL,
    'Shipped',
    @shipping_address,
    @shipping_city,
    @shipping_state,
    @shipping_zip
);

SELECT 
    '=== NEW REPLACEMENT ORDER AND SHIPMENT CREATED ===' AS QuerySection;
    
SELECT 
    o.OrderID AS ReplacementOrderID,
    s.ShipmentID,
    s.TrackingNumber,
    s.Carrier,
    s.ShippedDate,
    s.PromisedDeliveryDate,
    s.Status,
    o.TotalAmount
FROM Shipment s
JOIN `Order` o ON s.OrderID = o.OrderID
WHERE s.TrackingNumber = '123456-REPLACEMENT';


-- QUERY 2: Top Customer by Revenue (Past Year)
SELECT 
    '=== TOP CUSTOMER BY REVENUE (PAST YEAR) ===' AS QuerySection;
    
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.CustomerType,
    SUM(o.TotalAmount) AS TotalSpent,
    COUNT(o.OrderID) AS NumberOfOrders
FROM Customer c
JOIN `Order` o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.CustomerType
ORDER BY TotalSpent DESC
LIMIT 1;


-- QUERY 3: Top 2 Products by Dollar-Amount Sold (Past Year)
SELECT 
    '=== TOP 2 PRODUCTS BY REVENUE (PAST YEAR) ===' AS QuerySection;
    
SELECT 
    p.UPC,
    p.ProductName,
    p.Manufacturer,
    SUM(oi.Subtotal) AS TotalRevenue,
    SUM(oi.Quantity) AS TotalUnitsSold
FROM Product p
JOIN OrderItem oi ON p.UPC = oi.UPC
JOIN `Order` o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.UPC, p.ProductName, p.Manufacturer
ORDER BY TotalRevenue DESC
LIMIT 2;


-- QUERY 4: Top 2 Products by Unit Sales (Past Year)
SELECT 
    '=== TOP 2 PRODUCTS BY UNIT SALES (PAST YEAR) ===' AS QuerySection;
    
SELECT 
    p.UPC,
    p.ProductName,
    p.Manufacturer,
    SUM(oi.Quantity) AS TotalUnitsSold,
    SUM(oi.Subtotal) AS TotalRevenue
FROM Product p
JOIN OrderItem oi ON p.UPC = oi.UPC
JOIN `Order` o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.UPC, p.ProductName, p.Manufacturer
ORDER BY TotalUnitsSold DESC
LIMIT 2;


-- QUERY 5: Products Out-of-Stock at Every Store in California

SELECT 
    '=== PRODUCTS OUT-OF-STOCK AT ALL CA STORES ===' AS QuerySection;
    
-- Find products that are out of stock (quantity = 0 or NULL) at every California store
SELECT 
    p.UPC,
    p.ProductName,
    p.Manufacturer,
    COUNT(DISTINCT s.StoreID) AS CAStoresCount,
    COUNT(DISTINCT CASE WHEN COALESCE(i.Quantity, 0) = 0 THEN s.StoreID END) AS OutOfStockStores
FROM Product p
CROSS JOIN Store s
LEFT JOIN Inventory i ON p.UPC = i.UPC 
    AND i.LocationType = 'Store' 
    AND i.LocationID = s.StoreID
WHERE s.State = 'CA'
GROUP BY p.UPC, p.ProductName, p.Manufacturer
HAVING CAStoresCount = OutOfStockStores
ORDER BY p.ProductName;

-- QUERY 6: Packages Not Delivered Within Promised Time
SELECT 
    '=== LATE DELIVERIES ===' AS QuerySection;
    
SELECT 
    s.ShipmentID,
    s.TrackingNumber,
    s.Carrier,
    s.OrderID,
    o.OrderDate,
    s.ShippedDate,
    s.PromisedDeliveryDate,
    s.ActualDeliveryDate,
    s.Status,
    DATEDIFF(s.ActualDeliveryDate, s.PromisedDeliveryDate) AS DaysLate,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone
FROM Shipment s
JOIN `Order` o ON s.OrderID = o.OrderID
JOIN Customer c ON o.CustomerID = c.CustomerID
WHERE s.ActualDeliveryDate IS NOT NULL
    AND s.ActualDeliveryDate > s.PromisedDeliveryDate
ORDER BY DaysLate DESC;


-- QUERY 7: Monthly Billing for Contract Customers (Past Month)
SELECT 
    '=== MONTHLY BILLING FOR CONTRACT CUSTOMERS (NOVEMBER 2024) ===' AS QuerySection;

-- Generate bill for each contract customer for November 2024
SELECT 
    c.CustomerID,
    c.AccountNumber,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Address,
    c.City,
    c.State,
    c.ZipCode,
    COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
    SUM(o.TotalAmount) AS TotalAmount,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate
FROM Customer c
JOIN `Order` o ON c.CustomerID = o.CustomerID
WHERE c.CustomerType = 'Contract'
    AND YEAR(o.OrderDate) = 2024
    AND MONTH(o.OrderDate) = 11
GROUP BY c.CustomerID, c.AccountNumber, c.FirstName, c.LastName, c.Email, 
         c.Address, c.City, c.State, c.ZipCode
ORDER BY c.CustomerID;

-- Detailed itemized billing for each contract customer
SELECT 
    '=== DETAILED ITEMIZED BILLING ===' AS QuerySection;
    
SELECT 
    c.CustomerID,
    c.AccountNumber,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    o.OrderType,
    oi.UPC,
    p.ProductName,
    oi.Quantity,
    oi.UnitPrice,
    oi.Subtotal,
    o.TotalAmount AS OrderTotal
FROM Customer c
JOIN `Order` o ON c.CustomerID = o.CustomerID
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN Product p ON oi.UPC = p.UPC
WHERE c.CustomerType = 'Contract'
    AND YEAR(o.OrderDate) = 2024
    AND MONTH(o.OrderDate) = 11
ORDER BY c.CustomerID, o.OrderDate, oi.UPC;