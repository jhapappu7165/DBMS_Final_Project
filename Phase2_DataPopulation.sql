-- Phase 2: Data Population Script

USE electronics_vendor;

-- VENDORS
INSERT INTO Vendor (VendorName, ContactPerson, Email, Phone, Address, City, State, ZipCode) VALUES
('Sony Corporation', 'John Smith', 'john.smith@sony.com', '555-0101', '1 Sony Drive', 'San Diego', 'CA', '92127'),
('Apple Inc', 'Sarah Johnson', 'sarah.j@apple.com', '555-0102', '1 Apple Park Way', 'Cupertino', 'CA', '95014'),
('Samsung Electronics', 'Mike Lee', 'mike.lee@samsung.com', '555-0103', '129 Samsung-ro', 'Seoul', 'CA', '90001'),
('HP Inc', 'Emily Davis', 'emily.d@hp.com', '555-0104', '1501 Page Mill Rd', 'Palo Alto', 'CA', '94304'),
('Canon USA', 'David Wilson', 'david.w@canon.com', '555-0105', '15955 Alton Pkwy', 'Irvine', 'CA', '92618'),
('Dell Technologies', 'Lisa Brown', 'lisa.b@dell.com', '555-0106', '1 Dell Way', 'Round Rock', 'TX', '78682'),
('Microsoft Corporation', 'Robert Taylor', 'robert.t@microsoft.com', '555-0107', '1 Microsoft Way', 'Redmond', 'WA', '98052'),
('LG Electronics', 'Jennifer Martinez', 'jennifer.m@lg.com', '555-0108', '1000 Sylvan Ave', 'Englewood Cliffs', 'NJ', '07632');

-- PRODUCTS
INSERT INTO Product (UPC, ProductName, Description, UnitPrice, Manufacturer, ModelNumber, Weight, Dimensions, VendorID) VALUES
('123456789012', 'Sony Alpha A7 III Camera', 'Full-frame mirrorless camera with 24.2MP sensor', 1999.99, 'Sony', 'ILCE-7M3', 1.43, '5.0 x 3.8 x 2.9 inches', 1),
('123456789013', 'Sony WH-1000XM4 Headphones', 'Noise-cancelling wireless headphones', 349.99, 'Sony', 'WH-1000XM4', 0.57, '7.3 x 3.0 x 10.3 inches', 1),
('123456789014', 'Sony 65" 4K TV', '65-inch 4K Ultra HD Smart TV', 899.99, 'Sony', 'XBR-65X90J', 52.0, '57.0 x 32.8 x 2.4 inches', 1),
('234567890123', 'iPhone 15 Pro', '6.1-inch Super Retina XDR display, A17 Pro chip', 999.99, 'Apple', 'IPHONE15PRO', 0.44, '5.77 x 2.78 x 0.32 inches', 2),
('234567890124', 'MacBook Pro 16"', '16-inch MacBook Pro with M3 Pro chip', 2499.99, 'Apple', 'MBP16-M3', 4.7, '14.0 x 9.8 x 0.66 inches', 2),
('234567890125', 'AirPods Pro', 'Active noise cancellation, spatial audio', 249.99, 'Apple', 'AIRPODSPRO2', 0.19, '2.4 x 0.9 x 0.9 inches', 2),
('345678901234', 'Samsung Galaxy S24', '6.2-inch Dynamic AMOLED, Snapdragon 8 Gen 3', 799.99, 'Samsung', 'SM-S921B', 0.39, '5.79 x 2.78 x 0.30 inches', 3),
('345678901235', 'Samsung 55" QLED TV', '55-inch 4K QLED Smart TV', 1199.99, 'Samsung', 'QN55Q80C', 42.0, '48.3 x 27.8 x 1.8 inches', 3),
('345678901236', 'Samsung Galaxy Watch 6', '40mm smartwatch with health tracking', 299.99, 'Samsung', 'SM-R930', 0.08, '1.6 x 1.6 x 0.4 inches', 3),
('456789012345', 'HP Pavilion Laptop', '15.6-inch Intel Core i7, 16GB RAM, 512GB SSD', 899.99, 'HP', '15-eg2023nr', 3.75, '14.2 x 9.2 x 0.7 inches', 4),
('456789012346', 'HP LaserJet Printer', 'Monochrome laser printer, wireless', 199.99, 'HP', 'LaserJet Pro M404dn', 18.5, '14.9 x 10.0 x 9.4 inches', 4),
('567890123456', 'Canon EOS R5', '45MP full-frame mirrorless camera', 3899.99, 'Canon', 'EOS-R5', 1.62, '5.4 x 3.9 x 3.5 inches', 5),
('567890123457', 'Canon EF 24-70mm Lens', 'Professional zoom lens f/2.8', 1699.99, 'Canon', 'EF-24-70-F2.8', 0.81, '3.3 x 4.4 inches', 5),
('678901234567', 'Dell XPS 13 Laptop', '13.4-inch Intel Core i7, 16GB RAM, 1TB SSD', 1299.99, 'Dell', 'XPS-13-9320', 2.59, '11.6 x 7.9 x 0.55 inches', 6),
('789012345678', 'Microsoft Surface Pro 9', '13-inch 2-in-1 tablet, Intel Core i7', 1599.99, 'Microsoft', 'SP9-I7-256', 1.94, '11.3 x 8.2 x 0.37 inches', 7),
('890123456789', 'LG 75" OLED TV', '75-inch 4K OLED Smart TV', 2499.99, 'LG', 'OLED75C3PUA', 78.0, '66.0 x 38.0 x 1.8 inches', 8);

-- CATEGORIES
INSERT INTO Category (CategoryName, CategoryType, Description) VALUES
-- ProductType categories
('Camera', 'ProductType', 'Digital cameras and photography equipment'),
('Phone', 'ProductType', 'Smartphones and mobile devices'),
('Laptop', 'ProductType', 'Laptop computers'),
('TV', 'ProductType', 'Televisions and displays'),
('Headphones', 'ProductType', 'Audio headphones and earbuds'),
('Printer', 'ProductType', 'Printers and scanners'),
('Tablet', 'ProductType', 'Tablet computers'),
('Watch', 'ProductType', 'Smartwatches and wearables'),
-- Manufacturer categories
('Sony', 'Manufacturer', 'All Sony products'),
('Apple', 'Manufacturer', 'All Apple products'),
('Samsung', 'Manufacturer', 'All Samsung products'),
('HP', 'Manufacturer', 'All HP products'),
('Canon', 'Manufacturer', 'All Canon products'),
('Dell', 'Manufacturer', 'All Dell products'),
('Microsoft', 'Manufacturer', 'All Microsoft products'),
('LG', 'Manufacturer', 'All LG products'),
-- Package categories
('Photography Bundle', 'Package', 'Camera and lens packages'),
('Home Office Setup', 'Package', 'Laptop and printer bundles'),
('Entertainment Package', 'Package', 'TV and audio equipment bundles');


-- PRODUCT-CATEGORY RELATIONSHIPS
-- Category IDs: 1=Camera, 2=Phone, 3=Laptop, 4=TV, 5=Headphones, 6=Printer, 7=Tablet, 8=Watch
-- 9=Sony, 10=Apple, 11=Samsung, 12=HP, 13=Canon, 14=Dell, 15=Microsoft, 16=LG
-- 17=Photography Bundle, 18=Home Office Setup, 19=Entertainment Package
INSERT INTO ProductCategory (UPC, CategoryID) VALUES
-- Cameras
('123456789012', 1), ('123456789012', 9), ('123456789012', 19),
('567890123456', 1), ('567890123456', 13), ('567890123456', 17),
('567890123457', 1), ('567890123457', 13),
-- Phones
('234567890123', 2), ('234567890123', 10),
('345678901234', 2), ('345678901234', 11),
-- Laptops
('234567890124', 3), ('234567890124', 10),
('456789012345', 3), ('456789012345', 12), ('456789012345', 18),
('678901234567', 3), ('678901234567', 14),
-- TVs
('123456789014', 4), ('123456789014', 9), ('123456789014', 19),
('345678901235', 4), ('345678901235', 11), ('345678901235', 19),
('890123456789', 4), ('890123456789', 16), ('890123456789', 19),
-- Headphones
('123456789013', 5), ('123456789013', 9),
('234567890125', 5), ('234567890125', 10),
-- Printers
('456789012346', 6), ('456789012346', 12), ('456789012346', 18),
-- Tablets
('789012345678', 7), ('789012345678', 15),
-- Watches
('345678901236', 8), ('345678901236', 11);

-- STORES
INSERT INTO Store (StoreName, Address, City, State, ZipCode, Phone, ManagerName) VALUES
('ElectroMart Downtown', '123 Main Street', 'Los Angeles', 'CA', '90012', '555-1001', 'Alice Johnson'),
('ElectroMart Westside', '456 Sunset Blvd', 'Los Angeles', 'CA', '90028', '555-1002', 'Bob Smith'),
('ElectroMart San Francisco', '789 Market Street', 'San Francisco', 'CA', '94102', '555-1003', 'Carol White'),
('ElectroMart San Diego', '321 Harbor Drive', 'San Diego', 'CA', '92101', '555-1004', 'David Brown'),
('ElectroMart Sacramento', '654 Capitol Mall', 'Sacramento', 'CA', '95814', '555-1005', 'Eva Garcia'),
('ElectroMart Austin', '987 Congress Ave', 'Austin', 'TX', '78701', '555-2001', 'Frank Miller'),
('ElectroMart Dallas', '147 Commerce St', 'Dallas', 'TX', '75201', '555-2002', 'Grace Lee'),
('ElectroMart Seattle', '258 Pike St', 'Seattle', 'WA', '98101', '555-3001', 'Henry Davis');

-- WAREHOUSES
INSERT INTO Warehouse (WarehouseName, Address, City, State, ZipCode, Phone, ManagerName) VALUES
('West Coast Distribution', '1000 Industrial Blvd', 'Los Angeles', 'CA', '90040', '555-5001', 'Ivan Petrov'),
('Central Distribution', '2000 Logistics Way', 'Dallas', 'TX', '75220', '555-5002', 'Julia Kim'),
('Northwest Distribution', '3000 Supply Chain Rd', 'Seattle', 'WA', '98134', '555-5003', 'Kevin Chen');

-- CUSTOMERS

-- Contract Customers
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, State, ZipCode, CustomerType, AccountNumber) VALUES
('John', 'Doe', 'john.doe@email.com', '555-2001', '100 Oak Avenue', 'Los Angeles', 'CA', '90001', 'Contract', 'ACC-001'),
('Jane', 'Smith', 'jane.smith@email.com', '555-2002', '200 Pine Street', 'San Francisco', 'CA', '94102', 'Contract', 'ACC-002'),
('Michael', 'Johnson', 'michael.j@email.com', '555-2003', '300 Elm Drive', 'San Diego', 'CA', '92101', 'Contract', 'ACC-003'),
('Sarah', 'Williams', 'sarah.w@email.com', '555-2004', '400 Maple Lane', 'Sacramento', 'CA', '95814', 'Contract', 'ACC-004'),
('Robert', 'Brown', 'robert.b@email.com', '555-2005', '500 Cedar Road', 'Austin', 'TX', '78701', 'Contract', 'ACC-005');

-- Infrequent Customers (with credit card for online)
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, State, ZipCode, CustomerType, CreditCardNumber, CreditCardExpiry, CreditCardCVV) VALUES
('Emily', 'Davis', 'emily.d@email.com', '555-3001', '600 Birch St', 'Los Angeles', 'CA', '90015', 'Infrequent', '4111111111111111', '2026-12-31', '123'),
('James', 'Wilson', 'james.w@email.com', '555-3002', '700 Spruce Ave', 'San Francisco', 'CA', '94110', 'Infrequent', '5555555555554444', '2027-06-30', '456'),
('Lisa', 'Martinez', 'lisa.m@email.com', '555-3003', '800 Fir Boulevard', 'Seattle', 'WA', '98102', 'Infrequent', '378282246310005', '2026-09-30', '789'),
('David', 'Anderson', 'david.a@email.com', '555-3004', '900 Redwood Circle', 'Dallas', 'TX', '75201', 'Infrequent', '4242424242424242', '2027-03-31', '321'),
('Maria', 'Taylor', 'maria.t@email.com', '555-3005', '1000 Sequoia Way', 'Austin', 'TX', '78702', 'Infrequent', '5105105105105100', '2026-11-30', '654');

-- Infrequent Customers (in-store only, no credit card stored)
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address, City, State, ZipCode, CustomerType) VALUES
('Thomas', 'Jackson', 'thomas.j@email.com', '555-4001', '1100 Willow St', 'Sacramento', 'CA', '95815', 'Infrequent'),
('Jennifer', 'White', 'jennifer.w@email.com', '555-4002', '1200 Ash Drive', 'Los Angeles', 'CA', '90020', 'Infrequent'),
('Christopher', 'Harris', 'chris.h@email.com', '555-4003', '1300 Poplar Ave', 'San Diego', 'CA', '92102', 'Infrequent');


-- INVENTORY (Stores and Warehouses)

-- Store 1 (Los Angeles Downtown) inventory
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('123456789012', 'Store', 1, 5, 3),
('234567890123', 'Store', 1, 8, 5),
('345678901234', 'Store', 1, 6, 4),
('456789012345', 'Store', 1, 4, 2),
('567890123456', 'Store', 1, 2, 2),
('123456789013', 'Store', 1, 10, 5),
('234567890125', 'Store', 1, 15, 8),
('123456789014', 'Store', 1, 3, 2);

-- Store 2 (Los Angeles Westside) inventory
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('345678901235', 'Store', 2, 4, 2),
('456789012346', 'Store', 2, 6, 3),
('678901234567', 'Store', 2, 5, 3),
('789012345678', 'Store', 2, 3, 2),
('890123456789', 'Store', 2, 2, 1),
('345678901236', 'Store', 2, 8, 5);

-- Store 3 (San Francisco) inventory - some out of stock
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('123456789012', 'Store', 3, 0, 3),
('234567890124', 'Store', 3, 0, 2),
('567890123456', 'Store', 3, 0, 2),
('123456789014', 'Store', 3, 1, 2),
('345678901234', 'Store', 3, 7, 4);

-- Store 4 (San Diego) inventory
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('123456789012', 'Store', 4, 6, 3),
('567890123456', 'Store', 4, 4, 2),
('567890123457', 'Store', 4, 3, 2),
('234567890123', 'Store', 4, 9, 5);

-- Store 5 (Sacramento) inventory - some out of stock
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('123456789012', 'Store', 5, 0, 3),
('234567890124', 'Store', 5, 0, 2),
('567890123456', 'Store', 5, 0, 2),
('345678901235', 'Store', 5, 2, 2);

-- Warehouse inventory
INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel) VALUES
('123456789012', 'Warehouse', 1, 50, 20),
('234567890123', 'Warehouse', 1, 75, 30),
('345678901234', 'Warehouse', 1, 60, 25),
('456789012345', 'Warehouse', 1, 40, 15),
('567890123456', 'Warehouse', 1, 30, 10),
('123456789013', 'Warehouse', 1, 100, 40),
('234567890125', 'Warehouse', 1, 150, 60),
('123456789014', 'Warehouse', 1, 25, 10),
('345678901235', 'Warehouse', 2, 35, 15),
('456789012346', 'Warehouse', 2, 80, 30),
('678901234567', 'Warehouse', 2, 45, 20),
('789012345678', 'Warehouse', 2, 30, 12),
('890123456789', 'Warehouse', 2, 20, 8),
('345678901236', 'Warehouse', 2, 90, 35),
('234567890124', 'Warehouse', 3, 55, 25),
('567890123457', 'Warehouse', 3, 40, 15);


-- ORDERS (Mix of Online, InStore, and Phone orders)

-- Online Orders (past year)
INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod) VALUES
(6, '2024-01-15 10:30:00', 'Online', 999.99, 'Delivered', 'Credit Card'),
(7, '2024-02-20 14:45:00', 'Online', 2499.99, 'Delivered', 'Credit Card'),
(8, '2024-03-10 09:15:00', 'Online', 1999.99, 'Delivered', 'Credit Card'),
(6, '2024-04-05 16:20:00', 'Online', 349.99, 'Delivered', 'Credit Card'),
(9, '2024-05-12 11:00:00', 'Online', 799.99, 'Delivered', 'Credit Card'),
(7, '2024-06-18 13:30:00', 'Online', 1299.99, 'Delivered', 'Credit Card'),
(10, '2024-07-22 10:15:00', 'Online', 3899.99, 'Delivered', 'Credit Card'),
(8, '2024-08-30 15:45:00', 'Online', 899.99, 'Delivered', 'Credit Card'),
(6, '2024-09-14 12:00:00', 'Online', 249.99, 'Delivered', 'Credit Card'),
(9, '2024-10-25 14:20:00', 'Online', 1199.99, 'Delivered', 'Credit Card'),
(7, '2024-11-08 09:30:00', 'Online', 1599.99, 'Delivered', 'Credit Card'),
(10, '2024-12-01 16:00:00', 'Online', 2499.99, 'Delivered', 'Credit Card'),
(6, '2024-12-15 11:45:00', 'Online', 299.99, 'Shipped', 'Credit Card'),
(8, '2024-12-20 13:15:00', 'Online', 199.99, 'Shipped', 'Credit Card');

-- In-Store Orders
INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, StoreID, PaymentMethod) VALUES
(11, '2024-01-20 10:00:00', 'InStore', 1999.99, 'Delivered', 1, 'Cash'),
(12, '2024-02-25 14:30:00', 'InStore', 349.99, 'Delivered', 2, 'Debit Card'),
(13, '2024-03-15 11:00:00', 'InStore', 899.99, 'Delivered', 3, 'Credit Card'),
(11, '2024-04-10 15:20:00', 'InStore', 249.99, 'Delivered', 1, 'Cash'),
(12, '2024-05-18 10:45:00', 'InStore', 799.99, 'Delivered', 2, 'Debit Card'),
(13, '2024-06-22 13:00:00', 'InStore', 1299.99, 'Delivered', 4, 'Credit Card'),
(11, '2024-07-28 09:30:00', 'InStore', 3899.99, 'Delivered', 1, 'Cash'),
(12, '2024-08-05 16:15:00', 'InStore', 1699.99, 'Delivered', 2, 'Debit Card'),
(13, '2024-09-20 12:30:00', 'InStore', 899.99, 'Delivered', 4, 'Credit Card'),
(11, '2024-10-30 14:00:00', 'InStore', 199.99, 'Delivered', 1, 'Cash'),
(12, '2024-11-12 10:20:00', 'InStore', 1199.99, 'Delivered', 2, 'Debit Card'),
(13, '2024-12-05 15:45:00', 'InStore', 1599.99, 'Delivered', 4, 'Credit Card');

-- Contract Customer Orders (for monthly billing)
INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod) VALUES
(1, '2024-11-05 10:00:00', 'Online', 1999.99, 'Delivered', 'Account'),
(1, '2024-11-12 14:30:00', 'Phone', 349.99, 'Delivered', 'Account'),
(1, '2024-11-20 11:15:00', 'Online', 249.99, 'Delivered', 'Account'),
(2, '2024-11-08 09:45:00', 'Online', 2499.99, 'Delivered', 'Account'),
(2, '2024-11-15 16:20:00', 'Phone', 799.99, 'Delivered', 'Account'),
(3, '2024-11-10 13:00:00', 'Online', 899.99, 'Delivered', 'Account'),
(3, '2024-11-18 10:30:00', 'Phone', 1299.99, 'Delivered', 'Account'),
(4, '2024-11-14 15:15:00', 'Online', 3899.99, 'Delivered', 'Account'),
(5, '2024-11-22 12:00:00', 'Online', 1199.99, 'Delivered', 'Account');


-- ORDER ITEMS

-- Order 1 (Online - iPhone)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(1, '234567890123', 1, 999.99, 999.99);

-- Order 2 (Online - MacBook)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(2, '234567890124', 1, 2499.99, 2499.99);

-- Order 3 (Online - Sony Camera)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(3, '123456789012', 1, 1999.99, 1999.99);

-- Order 4 (Online - Sony Headphones)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(4, '123456789013', 1, 349.99, 349.99);

-- Order 5 (Online - Samsung Phone)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(5, '345678901234', 1, 799.99, 799.99);

-- Order 6 (Online - Dell Laptop)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(6, '678901234567', 1, 1299.99, 1299.99);

-- Order 7 (Online - Canon Camera)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(7, '567890123456', 1, 3899.99, 3899.99);

-- Order 8 (Online - Sony TV)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(8, '123456789014', 1, 899.99, 899.99);

-- Order 9 (Online - AirPods)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(9, '234567890125', 1, 249.99, 249.99);

-- Order 10 (Online - Samsung TV)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(10, '345678901235', 1, 1199.99, 1199.99);

-- Order 11 (Online - Surface Pro)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(11, '789012345678', 1, 1599.99, 1599.99);

-- Order 12 (Online - LG TV)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(12, '890123456789', 1, 2499.99, 2499.99);

-- Order 13 (Online - Samsung Watch)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(13, '345678901236', 1, 299.99, 299.99);

-- Order 14 (Online - HP Printer)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(14, '456789012346', 1, 199.99, 199.99);

-- In-Store Orders
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(15, '123456789012', 1, 1999.99, 1999.99),
(16, '123456789013', 1, 349.99, 349.99),
(17, '456789012345', 1, 899.99, 899.99),
(18, '234567890125', 1, 249.99, 249.99),
(19, '345678901234', 1, 799.99, 799.99),
(20, '678901234567', 1, 1299.99, 1299.99),
(21, '567890123456', 1, 3899.99, 3899.99),
(22, '567890123457', 1, 1699.99, 1699.99),
(23, '456789012345', 1, 899.99, 899.99),
(24, '456789012346', 1, 199.99, 199.99),
(25, '345678901235', 1, 1199.99, 1199.99),
(26, '789012345678', 1, 1599.99, 1599.99);

-- Contract Customer Orders (November 2024 - for monthly billing)
INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal) VALUES
(27, '123456789012', 1, 1999.99, 1999.99),
(28, '123456789013', 1, 349.99, 349.99),
(29, '234567890125', 1, 249.99, 249.99),
(30, '234567890124', 1, 2499.99, 2499.99),
(31, '345678901234', 1, 799.99, 799.99),
(32, '456789012345', 1, 899.99, 899.99),
(33, '678901234567', 1, 1299.99, 1299.99),
(34, '567890123456', 1, 3899.99, 3899.99),
(35, '345678901235', 1, 1199.99, 1199.99);


-- SHIPMENTS (for online orders only)

INSERT INTO Shipment (OrderID, TrackingNumber, Carrier, ShippedDate, PromisedDeliveryDate, ActualDeliveryDate, Status, ShippingAddress, ShippingCity, ShippingState, ShippingZipCode) VALUES
(1, '123456', 'USPS', '2024-01-16 08:00:00', '2024-01-20 17:00:00', '2024-01-19 14:30:00', 'Delivered', '600 Birch St', 'Los Angeles', 'CA', '90015'),
(2, '234567', 'FedEx', '2024-02-21 10:00:00', '2024-02-25 17:00:00', '2024-02-24 16:00:00', 'Delivered', '700 Spruce Ave', 'San Francisco', 'CA', '94110'),
(3, '345678', 'UPS', '2024-03-11 09:00:00', '2024-03-15 17:00:00', '2024-03-14 11:00:00', 'Delivered', '800 Fir Boulevard', 'Seattle', 'WA', '98102'),
(4, '456789', 'USPS', '2024-04-06 08:00:00', '2024-04-10 17:00:00', '2024-04-09 15:00:00', 'Delivered', '600 Birch St', 'Los Angeles', 'CA', '90015'),
(5, '567890', 'FedEx', '2024-05-13 10:00:00', '2024-05-17 17:00:00', '2024-05-16 13:00:00', 'Delivered', '900 Redwood Circle', 'Dallas', 'TX', '75201'),
(6, '678901', 'UPS', '2024-06-19 09:00:00', '2024-06-23 17:00:00', '2024-06-22 10:00:00', 'Delivered', '700 Spruce Ave', 'San Francisco', 'CA', '94110'),
(7, '789012', 'USPS', '2024-07-23 08:00:00', '2024-07-27 17:00:00', '2024-07-26 14:00:00', 'Delivered', '1000 Sequoia Way', 'Austin', 'TX', '78702'),
(8, '890123', 'FedEx', '2024-08-31 10:00:00', '2024-09-04 17:00:00', '2024-09-03 16:00:00', 'Delivered', '800 Fir Boulevard', 'Seattle', 'WA', '98102'),
(9, '901234', 'UPS', '2024-09-15 09:00:00', '2024-09-19 17:00:00', '2024-09-18 12:00:00', 'Delivered', '600 Birch St', 'Los Angeles', 'CA', '90015'),
(10, '012345', 'USPS', '2024-10-26 08:00:00', '2024-10-30 17:00:00', '2024-10-29 15:00:00', 'Delivered', '900 Redwood Circle', 'Dallas', 'TX', '75201'),
(11, '123450', 'FedEx', '2024-11-09 10:00:00', '2024-11-13 17:00:00', '2024-11-12 11:00:00', 'Delivered', '700 Spruce Ave', 'San Francisco', 'CA', '94110'),
(12, '234560', 'UPS', '2024-12-02 09:00:00', '2024-12-06 17:00:00', '2024-12-05 14:00:00', 'Delivered', '1000 Sequoia Way', 'Austin', 'TX', '78702'),
(13, '345670', 'USPS', '2024-12-16 08:00:00', '2024-12-20 17:00:00', NULL, 'InTransit', '600 Birch St', 'Los Angeles', 'CA', '90015'),
(14, '456780', 'FedEx', '2024-12-21 10:00:00', '2024-12-25 17:00:00', NULL, 'InTransit', '800 Fir Boulevard', 'Seattle', 'WA', '98102'),
-- Late delivery example
(27, '567891', 'USPS', '2024-11-06 08:00:00', '2024-11-10 17:00:00', '2024-11-12 16:00:00', 'Delivered', '100 Oak Avenue', 'Los Angeles', 'CA', '90001'),
-- Contract customer shipments
(28, '678902', 'FedEx', '2024-11-13 10:00:00', '2024-11-17 17:00:00', '2024-11-16 14:00:00', 'Delivered', '100 Oak Avenue', 'Los Angeles', 'CA', '90001'),
(29, '789013', 'UPS', '2024-11-21 09:00:00', '2024-11-25 17:00:00', '2024-11-24 13:00:00', 'Delivered', '100 Oak Avenue', 'Los Angeles', 'CA', '90001'),
(30, '890124', 'USPS', '2024-11-09 08:00:00', '2024-11-13 17:00:00', '2024-11-12 15:00:00', 'Delivered', '200 Pine Street', 'San Francisco', 'CA', '94102'),
(31, '901235', 'FedEx', '2024-11-16 10:00:00', '2024-11-20 17:00:00', '2024-11-19 16:00:00', 'Delivered', '200 Pine Street', 'San Francisco', 'CA', '94102'),
(32, '012346', 'UPS', '2024-11-11 09:00:00', '2024-11-15 17:00:00', '2024-11-14 12:00:00', 'Delivered', '300 Elm Drive', 'San Diego', 'CA', '92101'),
(33, '123451', 'USPS', '2024-11-19 08:00:00', '2024-11-23 17:00:00', '2024-11-22 14:00:00', 'Delivered', '300 Elm Drive', 'San Diego', 'CA', '92101'),
(34, '234561', 'FedEx', '2024-11-15 10:00:00', '2024-11-19 17:00:00', '2024-11-18 15:00:00', 'Delivered', '400 Maple Lane', 'Sacramento', 'CA', '95814'),
(35, '345671', 'UPS', '2024-11-23 09:00:00', '2024-11-27 17:00:00', '2024-11-26 11:00:00', 'Delivered', '500 Cedar Road', 'Austin', 'TX', '78701');


-- REORDERS

INSERT INTO Reorder (UPC, VendorID, Quantity, OrderDate, Status, ExpectedDeliveryDate, ReceivedDate, UnitCost) VALUES
('123456789012', 1, 20, '2024-10-15 10:00:00', 'Received', '2024-10-25 17:00:00', '2024-10-24 14:00:00', 1200.00),
('234567890123', 2, 30, '2024-11-01 09:00:00', 'Received', '2024-11-11 17:00:00', '2024-11-10 16:00:00', 600.00),
('345678901234', 3, 25, '2024-11-10 11:00:00', 'Shipped', '2024-11-20 17:00:00', NULL, 500.00),
('456789012345', 4, 15, '2024-11-20 10:00:00', 'Ordered', '2024-11-30 17:00:00', NULL, 550.00),
('567890123456', 5, 10, '2024-12-01 09:00:00', 'Pending', NULL, NULL, 2500.00);


SELECT 'Data population completed successfully!' AS Status;

