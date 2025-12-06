# Electronics Vendor Database System

**Complete Setup Guide for Novice Users**

This guide will walk you through setting up and running the Electronics Vendor Database System from scratch, even if you've never used Docker or MySQL before.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start Guide](#quick-start-guide)
3. [Detailed Setup Instructions](#detailed-setup-instructions)
4. [Running the User Interfaces](#running-the-user-interfaces)
5. [Database Verification](#database-verification)
6. [Running Queries](#running-queries)
7. [Query Results Reference](#query-results-reference)
8. [UI Testing Data](#ui-testing-data)
9. [Troubleshooting](#troubleshooting)
10. [System Overview](#system-overview)

---

## Prerequisites

Before starting, you need:

1. **Docker** - For running MySQL database
2. **Python 3.7+** - For running the web interface backend
3. **Web Browser** - To access the user interfaces

### Checking Prerequisites

**Check if Docker is installed:**
```bash
docker --version
```

**If Docker is NOT installed:**
- **Linux:** `sudo apt-get update && sudo apt-get install docker.io` (or use your package manager)
- **macOS:** Download Docker Desktop from https://www.docker.com/products/docker-desktop
- **Windows:** Download Docker Desktop from https://www.docker.com/products/docker-desktop

**Check if Python is installed:**
```bash
python3 --version
# or
python --version
```

**If Python is NOT installed:**
- **Linux:** `sudo apt-get install python3 python3-pip`
- **macOS:** Usually pre-installed, or install via Homebrew
- **Windows:** Download from https://www.python.org/downloads/

---

## Quick Start Guide

**For users who want to get started immediately:**

```bash
# 1. Navigate to project directory
cd /path/to/dbmsFinal

# 2. Check if database already exists
docker ps -a | grep electronics-mysql

# 3. If container doesn't exist, create it (see Detailed Setup below)
# If container exists but is stopped, just start it:
docker start electronics-mysql

# 4. Start the web interface
cd DBMS_Final_Project/UI
pip install -r requirements.txt
python backend.py

# 5. Open browser: http://localhost:8888
```

---

## Detailed Setup Instructions

### Step 1: Check Current Status

**First, check if you already have the database set up:**

```bash
# Check if MySQL container exists
docker ps -a | grep electronics-mysql
```

**Possible outcomes:**

#### Scenario A: Container doesn't exist (First Time Setup)
→ Go to [Step 2: Create Database](#step-2-create-database)

#### Scenario B: Container exists but is stopped
```bash
# Just start it
docker start electronics-mysql
# Wait 5 seconds, then verify it's running
docker ps | grep electronics-mysql
```
→ Skip to [Step 3: Verify Database](#step-3-verify-database)

#### Scenario C: Container is already running
```bash
# Verify it's working
docker exec -i electronics-mysql mysql -uroot -prootpass -e "SELECT 1;" 2>/dev/null && echo "✓ Database is ready"
```
→ Skip to [Step 4: Check if Data is Populated](#step-4-check-if-data-is-populated)

---

### Step 2: Create Database

**Only do this if the container doesn't exist (Scenario A):**

```bash
# Navigate to project root directory
cd /path/to/dbmsFinal

# Create and start MySQL container
docker run --name electronics-mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=electronics_vendor \
  -p 3306:3306 \
  -d mysql:8.0

# Wait 10-15 seconds for MySQL to fully initialize
# You can check if it's ready:
docker logs electronics-mysql | tail -5
# Look for "ready for connections" message
```

**What this does:**
- Creates a MySQL 8.0 container named `electronics-mysql`
- Sets root password to `rootpass`
- Creates database `electronics_vendor`
- Maps port 3306 to your computer

---

### Step 3: Verify Database

**Check if database container is running:**

```bash
# Check container status
docker ps | grep electronics-mysql
```

**Expected output:** Should show `electronics-mysql` with status "Up"

**If container is not running:**
```bash
docker start electronics-mysql
sleep 5
docker ps | grep electronics-mysql
```

**Test database connection:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass -e "SELECT 1;" 2>/dev/null && echo "✓ Database connection successful" || echo "✗ Database not ready yet - wait a few more seconds"
```

---

### Step 4: Check if Data is Populated

**Check if database already has data:**

```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT COUNT(*) as CustomerCount FROM Customer;" 2>&1 | grep -v "Warning"
```

**Possible outcomes:**

#### Outcome A: Shows "CustomerCount: 13" (or any number > 0)
→ **Data is already populated!** Skip to [Step 6: Run Queries](#step-6-run-queries) or [Running the User Interfaces](#running-the-user-interfaces)

#### Outcome B: Shows "CustomerCount: 0" or error
→ **Need to populate data** → Go to [Step 5: Populate Database](#step-5-populate-database)

---

### Step 5: Populate Database

**Only do this if database is empty (Outcome B from Step 4):**

#### 5.1 Create Database Schema

```bash
# Make sure you're in the project root directory
cd /path/to/dbmsFinal

# Create all tables, constraints, indexes, triggers, and views
docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase1_Schm.sql
```

**Expected output:** No errors (may show some warnings about existing objects, which is fine)

**Verify schema was created:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SHOW TABLES;" 2>&1 | grep -v "Warning"
```

**Expected output:** Should show 15 tables:
- Category, Customer, Inventory, Order, OrderItem, Product, ProductCategory, Reorder, Shipment, Store, Vendor, Warehouse, and others

#### 5.2 Populate with Test Data

```bash
# Populate all tables with realistic test data
docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase2_DataPopulation.sql
```

**Expected output:** 
```
Status
Data population completed successfully!
```

**Verify data was populated:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT 'Customers' as TableName, COUNT(*) as Count FROM Customer UNION ALL SELECT 'Products', COUNT(*) FROM Product UNION ALL SELECT 'Orders', COUNT(*) FROM \`Order\`;" 2>&1 | grep -v "Warning"
```

**Expected output:**
```
TableName    Count
Customers    13
Products     16
Orders       35
```

---

### Step 6: Run Queries

**Run all 7 required queries and save results:**

```bash
# Navigate to project root
cd /path/to/dbmsFinal

# Run all queries and save output
docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase2_Queries.sql 2>&1 | grep -v "Warning" > DBMS_Final_Project/database/Phase2_query_results.txt

# View the results
cat DBMS_Final_Project/database/Phase2_query_results.txt
```

**What this does:**
- Executes all 7 required queries
- Saves results to `Phase2_query_results.txt`
- Filters out MySQL warnings for cleaner output

**Note:** Query 1 modifies the database (creates a replacement order). If you run queries again, you may get errors. See [Troubleshooting: Query 1 Reset](#query-1-reset) below.

---

## Running the User Interfaces

### Prerequisites for UI

1. **Python 3.7+** installed
2. **MySQL container running** (see Step 3 above)
3. **Database populated** (see Step 5 above)

### Step-by-Step UI Setup

#### Step 1: Install Python Dependencies

```bash
# Navigate to UI directory
cd /path/to/dbmsFinal/DBMS_Final_Project/UI

# Install required Python packages
pip install -r requirements.txt
```

**If you get "pip: command not found":**
```bash
# Try pip3 instead
pip3 install -r requirements.txt

# Or install pip first
python3 -m ensurepip --upgrade
```

**Expected packages installed:**
- Flask (web framework)
- mysql-connector-python (database connector)
- Flask-CORS (for cross-origin requests)

#### Step 2: Verify MySQL Container is Running

```bash
# Check if container is running
docker ps | grep electronics-mysql
```

**If not running:**
```bash
docker start electronics-mysql
# Wait 5 seconds
docker ps | grep electronics-mysql
```

#### Step 3: Start Flask Backend Server

```bash
# Make sure you're in the UI directory
cd /path/to/dbmsFinal/DBMS_Final_Project/UI

# Start the server
python backend.py
```

**If you get "python: command not found":**
```bash
# Try python3 instead
python3 backend.py
```

**Expected output:**
```
✓ Database connection successful

Starting Flask server on http://localhost:8888
Available interfaces:
  - Customer Service: http://localhost:8888/customer-service
  - Online Customers: http://localhost:8888/online-customers
  - Call Center: http://localhost:8888/call-center
  - Warehouse: http://localhost:8888/warehouse

Press Ctrl+C to stop the server
 * Serving Flask app 'backend'
 * Debug mode: on
 * Running on http://127.0.0.1:8888
```

**Keep this terminal window open!** The server must stay running.

#### Step 4: Access the Interfaces

**Open your web browser and go to:**
```
http://localhost:8888
```

You'll see a portal page with 4 interface options:
- **Customer Service** - Look up inventory at stores
- **Online Customers** - Web store for browsing and purchasing
- **Call Center** - Customer lookup and phone order entry
- **Warehouse** - Inventory management and shipment tracking

**Click any interface to start using it!**

#### Step 5: Stop the Server

**When you're done:**
- Press `Ctrl+C` in the terminal where Flask is running
- Or close the terminal window

**To stop MySQL container (keeps your data):**
```bash
docker stop electronics-mysql
```

**To completely remove everything (deletes all data):**
```bash
docker stop electronics-mysql
docker rm electronics-mysql
```

---

## Database Verification

**Use these commands to verify your database contains all expected data:**

### Quick Verification

```bash
# Check total counts
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT 'Vendors' as TableName, COUNT(*) as Count FROM Vendor UNION ALL SELECT 'Products', COUNT(*) FROM Product UNION ALL SELECT 'Categories', COUNT(*) FROM Category UNION ALL SELECT 'Stores', COUNT(*) FROM Store UNION ALL SELECT 'Warehouses', COUNT(*) FROM Warehouse UNION ALL SELECT 'Customers', COUNT(*) FROM Customer UNION ALL SELECT 'Orders', COUNT(*) FROM \`Order\` UNION ALL SELECT 'OrderItems', COUNT(*) FROM OrderItem UNION ALL SELECT 'Shipments', COUNT(*) FROM Shipment UNION ALL SELECT 'Inventory', COUNT(*) FROM Inventory UNION ALL SELECT 'Reorders', COUNT(*) FROM Reorder;" 2>&1 | grep -v "Warning"
```

**Expected Output:**
```
TableName       Count
Vendors         8
Products        16
Categories      19
Stores          8
Warehouses      3
Customers       13
Orders          35
OrderItems      35
Shipments       23
Inventory       43
Reorders        5
```

### Detailed Verification Commands

**1. Verify Vendors:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT VendorID, VendorName, City, State FROM Vendor ORDER BY VendorID;" 2>&1 | grep -v "Warning"
```
**Expected:** 8 vendors including Sony, Apple, Samsung, HP, Canon, Dell, Microsoft, LG

**2. Verify Products:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT p.UPC, p.ProductName, p.UnitPrice, v.VendorName FROM Product p JOIN Vendor v ON p.VendorID = v.VendorID LIMIT 10;" 2>&1 | grep -v "Warning"
```
**Expected:** 10 products with prices and vendor names

**3. Verify Categories:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT CategoryID, CategoryName, CategoryType FROM Category ORDER BY CategoryType, CategoryID;" 2>&1 | grep -v "Warning"
```
**Expected:** 19 categories (8 ProductType, 8 Manufacturer, 3 Package)

**4. Verify Product-Category Relationships:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT COUNT(*) as TotalProductCategoryLinks FROM ProductCategory;" 2>&1 | grep -v "Warning"
```
**Expected:** `TotalProductCategoryLinks: 39`

**5. Verify CA Stores:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT StoreID, StoreName, City, State FROM Store WHERE State = 'CA' ORDER BY StoreID;" 2>&1 | grep -v "Warning"
```
**Expected:** 5 California stores (Los Angeles Downtown, Westside, San Francisco, San Diego, Sacramento)

**6. Verify Customer Types:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT CustomerType, COUNT(*) as Count FROM Customer GROUP BY CustomerType;" 2>&1 | grep -v "Warning"
```
**Expected:**
```
CustomerType    Count
Contract        5
Infrequent      8
```

**7. Verify Orders by Type:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT OrderType, COUNT(*) as Count, MIN(OrderDate) as EarliestOrder, MAX(OrderDate) as LatestOrder FROM \`Order\` GROUP BY OrderType;" 2>&1 | grep -v "Warning"
```
**Expected:**
```
OrderType       Count   EarliestOrder          LatestOrder
Online          20      2024-01-15 10:30:00    2024-12-20 13:15:00
InStore         12      2024-01-20 10:00:00    2024-12-05 15:45:00
Phone           3       2024-11-12 14:30:00     2024-11-18 10:30:00
```

**8. Verify Shipment with Tracking #123456 (for Query 1):**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT TrackingNumber, Carrier, OrderID, Status, ShippedDate FROM Shipment WHERE TrackingNumber = '123456' OR TrackingNumber LIKE '123456%';" 2>&1 | grep -v "Warning"
```
**Expected:** Shipment with tracking number 123456 (USPS, OrderID 1)

**9. Verify Out-of-Stock Products in CA Stores:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT i.UPC, p.ProductName, s.StoreName, s.State, i.Quantity, i.ReorderLevel FROM Inventory i JOIN Product p ON i.UPC = p.UPC JOIN Store s ON i.LocationID = s.StoreID WHERE i.LocationType = 'Store' AND s.State = 'CA' AND i.Quantity = 0 ORDER BY s.StoreID, p.ProductName;" 2>&1 | grep -v "Warning"
```
**Expected:** Products out of stock at San Francisco and Sacramento stores (Sony Alpha A7 III Camera, MacBook Pro 16", Canon EOS R5)

**10. Verify Contract Customer Orders for November 2024:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT c.CustomerID, c.AccountNumber, c.FirstName, c.LastName, COUNT(o.OrderID) as OrderCount, SUM(o.TotalAmount) as TotalAmount FROM Customer c JOIN \`Order\` o ON c.CustomerID = o.CustomerID WHERE c.CustomerType = 'Contract' AND YEAR(o.OrderDate) = 2024 AND MONTH(o.OrderDate) = 11 GROUP BY c.CustomerID, c.AccountNumber, c.FirstName, c.LastName;" 2>&1 | grep -v "Warning"
```
**Expected:** 5 contract customers with their November 2024 order counts and totals

**11. Verify Late Deliveries Exist:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT TrackingNumber, Carrier, PromisedDeliveryDate, ActualDeliveryDate, DATEDIFF(ActualDeliveryDate, PromisedDeliveryDate) as DaysLate FROM Shipment WHERE ActualDeliveryDate IS NOT NULL AND ActualDeliveryDate > PromisedDeliveryDate;" 2>&1 | grep -v "Warning"
```
**Expected:** At least one late delivery (tracking 567891, 2 days late)

**12. Verify Product Sales Data:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT p.UPC, p.ProductName, SUM(oi.Quantity) as TotalUnits, SUM(oi.Subtotal) as TotalRevenue FROM Product p JOIN OrderItem oi ON p.UPC = oi.UPC JOIN \`Order\` o ON oi.OrderID = o.OrderID WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) GROUP BY p.UPC, p.ProductName ORDER BY TotalRevenue DESC LIMIT 5;" 2>&1 | grep -v "Warning"
```
**Expected:** Top products by revenue (may vary based on current date)

**13. Complete Data Summary:**
```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "SELECT 'Summary' as Info, CONCAT('Vendors: ', (SELECT COUNT(*) FROM Vendor), ', Products: ', (SELECT COUNT(*) FROM Product), ', Customers: ', (SELECT COUNT(*) FROM Customer), ', Orders: ', (SELECT COUNT(*) FROM \`Order\`), ', Shipments: ', (SELECT COUNT(*) FROM Shipment)) as Data;" 2>&1 | grep -v "Warning"
```
**Expected:**
```
Info    Data
Summary Vendors: 8, Products: 16, Customers: 13, Orders: 35, Shipments: 23
```

---

## Running Queries

### Overview

The file `DBMS_Final_Project/database/Phase2_Queries.sql` contains all 7 required queries:

1. **Damaged shipment replacement** (tracking #123456) - Creates replacement order
2. **Top customer by revenue** (past year)
3. **Top 2 products by revenue** (past year)
4. **Top 2 products by units** (past year)
5. **Products out-of-stock at all CA stores**
6. **Late deliveries** with customer information
7. **Monthly billing for contract customers** (November 2024) - Itemized bills

### Run All Queries

```bash
# Navigate to project root
cd /path/to/dbmsFinal

# Run all queries and save results
docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase2_Queries.sql 2>&1 | grep -v "Warning" > DBMS_Final_Project/database/Phase2_query_results.txt

# View results
cat DBMS_Final_Project/database/Phase2_query_results.txt
```

### Run Individual Queries

**To run a specific query, open the file and copy the query section:**

```bash
# Connect to MySQL
docker exec -it electronics-mysql mysql -uroot -prootpass electronics_vendor

# Then paste and run the query you want
```

### Query 1 Reset (Important!)

**Query 1 modifies the database** (creates a replacement order). If you want to run Query 1 again, reset first:

```bash
docker exec -i electronics-mysql mysql -uroot -prootpass electronics_vendor -e "UPDATE Shipment SET Status = 'Delivered' WHERE TrackingNumber = '123456'; DELETE FROM Shipment WHERE TrackingNumber = '123456-REPLACEMENT'; DELETE FROM OrderItem WHERE OrderID > 35; DELETE FROM \`Order\` WHERE OrderID > 35;"
```

This resets Query 1's changes so you can run it again.

---

## Query Results Reference

**Expected results from `Phase2_query_results.txt`:**

### Query 1: Damaged Shipment Replacement
- **Customer Contact:** Emily Davis (CustomerID: 6), Email: emily.d@email.com, Phone: 555-3001
- **Damaged Shipment:** Tracking #123456, OrderID 1, iPhone 15 Pro
- **Replacement Created:** New OrderID 39, New Shipment with tracking #123456-REPLACEMENT

### Query 2: Top Customer by Revenue (Past Year)
- **Top Customer:** Emily Davis (CustomerID: 6)
- **Total Spent:** $1,299.98
- **Number of Orders:** 2

### Query 3: Top 2 Products by Revenue (Past Year)
1. **iPhone 15 Pro** (UPC: 234567890123) - Revenue: $999.99
2. **Samsung Galaxy Watch 6** (UPC: 345678901236) - Revenue: $299.99

### Query 4: Top 2 Products by Units (Past Year)
1. **Samsung Galaxy Watch 6** (UPC: 345678901236) - 1 unit, $299.99
2. **HP LaserJet Printer** (UPC: 456789012346) - 1 unit, $199.99

### Query 5: Products Out-of-Stock at All CA Stores
- **MacBook Pro 16"** (UPC: 234567890124) - Out of stock at all 5 CA stores

### Query 6: Late Deliveries
- **Tracking #567891** - 2 days late
- **Customer:** John Doe (CustomerID: 1)
- **Order Date:** 2024-11-05
- **Promised:** 2024-11-10, **Actual:** 2024-11-12

### Query 7: Monthly Billing for Contract Customers (November 2024)

**Summary:**
- **5 Contract Customers** with November 2024 orders
- **Total Orders:** 9 orders across all contract customers

**Individual Customer Bills:**

1. **John Doe (ACC-001)**
   - 3 orders, Total: $2,599.97
   - Orders: Sony Camera ($1,999.99), Sony Headphones ($349.99), AirPods Pro ($249.99)

2. **Jane Smith (ACC-002)**
   - 2 orders, Total: $3,299.98
   - Orders: MacBook Pro 16" ($2,499.99), Samsung Galaxy S24 ($799.99)

3. **Michael Johnson (ACC-003)**
   - 2 orders, Total: $2,199.98
   - Orders: HP Pavilion Laptop ($899.99), Dell XPS 13 Laptop ($1,299.99)

4. **Sarah Williams (ACC-004)**
   - 1 order, Total: $3,899.99
   - Order: Canon EOS R5 ($3,899.99)

5. **Robert Brown (ACC-005)**
   - 1 order, Total: $1,199.99
   - Order: Samsung 55" QLED TV ($1,199.99)

**Full itemized details** are in the query results file showing each order with product details, quantities, and subtotals.

---

## UI Testing Data

**Use this data to navigate and test the user interfaces:**

### Customers (for Online Orders & Call Center)

**Contract Customers (IDs 1-5):**
- **ID 1:** John Doe, Account: ACC-001, Email: john.doe@email.com, Phone: 555-2001
- **ID 2:** Jane Smith, Account: ACC-002, Email: jane.smith@email.com, Phone: 555-2002
- **ID 3:** Michael Johnson, Account: ACC-003, Email: michael.j@email.com, Phone: 555-2003
- **ID 4:** Sarah Williams, Account: ACC-004, Email: sarah.w@email.com, Phone: 555-2004
- **ID 5:** Robert Brown, Account: ACC-005, Email: robert.b@email.com, Phone: 555-2005

**Infrequent Customers (IDs 6-13):**
- **ID 6:** Emily Davis, Email: emily.d@email.com, Phone: 555-3001
- **ID 7:** James Wilson, Email: james.w@email.com, Phone: 555-3002
- **ID 8:** Lisa Martinez, Email: lisa.m@email.com, Phone: 555-3003
- **ID 9:** David Anderson, Email: david.a@email.com, Phone: 555-3004
- **ID 10:** Maria Taylor, Email: maria.t@email.com, Phone: 555-3005
- **ID 11:** Thomas Jackson, Email: thomas.j@email.com, Phone: 555-4001
- **ID 12:** Jennifer White, Email: jennifer.w@email.com, Phone: 555-4002
- **ID 13:** Christopher Harris, Email: chris.h@email.com, Phone: 555-4003

### Products (for Search, Cart, Orders)

| UPC | Product Name | Price |
|-----|--------------|-------|
| 123456789012 | Sony Alpha A7 III Camera | $1,999.99 |
| 123456789013 | Sony WH-1000XM4 Headphones | $349.99 |
| 123456789014 | Sony 65" 4K TV | $899.99 |
| 234567890123 | iPhone 15 Pro | $999.99 |
| 234567890125 | AirPods Pro | $249.99 |
| 345678901234 | Samsung Galaxy S24 | $799.99 |
| 345678901235 | Samsung 55" QLED TV | $1,199.99 |
| 345678901236 | Samsung Galaxy Watch 6 | $299.99 |
| 456789012345 | HP Pavilion Laptop | $899.99 |
| 456789012346 | HP LaserJet Printer | $199.99 |
| 567890123456 | Canon EOS R5 | $3,899.99 |
| 567890123457 | Canon EF 24-70mm Lens | $1,699.99 |
| 678901234567 | Dell XPS 13 Laptop | $1,299.99 |
| 789012345678 | Microsoft Surface Pro 9 | $1,599.99 |
| 890123456789 | LG 75" OLED TV | $2,499.99 |
| 234567890124 | MacBook Pro 16" | $2,499.99 |

### Stores (for Customer Service Inventory Lookup)

**California Stores:**
- ElectroMart Downtown (Los Angeles, CA) - Phone: 555-1001
- ElectroMart Westside (Los Angeles, CA) - Phone: 555-1002
- ElectroMart San Francisco (San Francisco, CA) - Phone: 555-1003
- ElectroMart San Diego (San Diego, CA) - Phone: 555-1004
- ElectroMart Sacramento (Sacramento, CA) - Phone: 555-1005

**Other States:**
- ElectroMart Austin (Austin, TX) - Phone: 555-2001
- ElectroMart Dallas (Dallas, TX) - Phone: 555-2002
- ElectroMart Seattle (Seattle, WA) - Phone: 555-3001

### Product Categories (for Filtering)

- Camera
- Headphones
- Laptop
- Phone
- Printer
- Tablet
- TV
- Watch

### Sample Inventory (Available Products)

**ElectroMart Downtown (Los Angeles, CA):**
- Sony Alpha A7 III Camera: 5 units
- iPhone 15 Pro: 8 units
- AirPods Pro: 15 units
- Samsung Galaxy S24: 6 units
- Sony WH-1000XM4 Headphones: 10 units
- Canon EOS R5: 2 units
- HP Pavilion Laptop: 4 units
- Sony 65" 4K TV: 3 units

**ElectroMart San Diego (San Diego, CA):**
- Sony Alpha A7 III Camera: 6 units
- iPhone 15 Pro: 9 units
- Canon EOS R5: 4 units
- Canon EF 24-70mm Lens: 3 units

**ElectroMart San Francisco (San Francisco, CA):**
- Samsung Galaxy S24: 7 units
- Sony 65" 4K TV: 1 unit

**ElectroMart Sacramento (Sacramento, CA):**
- Samsung 55" QLED TV: 2 units

### Testing Scenarios

**Customer Service Interface:**
- Search: "iPhone" or "234567890123" (UPC)
- Search: "Sony Alpha A7 III Camera" or "123456789012"
- Filter by: "ElectroMart Downtown"

**Online Customers Interface:**
- Browse all products
- Search: "iPhone", "Laptop", "TV"
- Filter by category: "Phone", "Laptop", "TV"
- Add products to cart and checkout with Customer ID 6-13

**Call Center Interface:**
- Search customer: "John Doe" or "john.doe@email.com" or "555-2001" or "ACC-001"
- Search: "Emily" or "emily.d@email.com"
- Create phone order for any customer
- Click on any order in history to view detailed order information

**Warehouse Interface:**
- View inventory by warehouse
- Check shipments and reorders
- Update inventory quantities

---

## Troubleshooting

### Docker Issues

**Problem: "docker: command not found"**
- **Solution:** Install Docker (see Prerequisites section)
- **Linux:** `sudo apt-get install docker.io` (or your package manager)
- **macOS/Windows:** Download Docker Desktop

**Problem: "Cannot connect to Docker daemon"**
- **Solution:** Start Docker service
- **Linux:** `sudo systemctl start docker` or `sudo service docker start`
- **macOS/Windows:** Start Docker Desktop application

**Problem: "Permission denied" when running docker commands**
- **Solution:** Add your user to docker group (Linux) or use sudo
- **Linux:** `sudo usermod -aG docker $USER` (then log out and back in)
- **Alternative:** Use `sudo docker` instead of `docker`

### Database Issues

**Problem: "Container already exists" error**
```bash
# Remove existing container first
docker rm electronics-mysql
# Then create new one (see Step 2)
```

**Problem: "Port 3306 already in use"**
```bash
# Find what's using port 3306
sudo lsof -i :3306
# Stop that process, or use a different port:
docker run --name electronics-mysql -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=electronics_vendor -p 3307:3306 -d mysql:8.0
# Then update backend.py to use port 3307
```

**Problem: "Database connection failed" in UI**
- **Check 1:** Is container running? `docker ps | grep electronics-mysql`
- **Check 2:** Wait 10-15 seconds after starting container for MySQL to initialize
- **Check 3:** Test connection: `docker exec -i electronics-mysql mysql -uroot -prootpass -e "SELECT 1;"`
- **Check 4:** Verify database exists: `docker exec -i electronics-mysql mysql -uroot -prootpass -e "SHOW DATABASES;"`

**Problem: "Table doesn't exist" errors**
- **Solution:** Schema not created. Run: `docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase1_Schm.sql`

**Problem: "No data" or "0 rows" in queries**
- **Solution:** Data not populated. Run: `docker exec -i electronics-mysql mysql -uroot -prootpass < DBMS_Final_Project/database/Phase2_DataPopulation.sql`

### Python/Flask Issues

**Problem: "python: command not found"**
- **Solution:** Use `python3` instead of `python`
- **Or install Python:** See Prerequisites section

**Problem: "pip: command not found"**
- **Solution:** Use `pip3` instead of `pip`
- **Or install pip:** `python3 -m ensurepip --upgrade`

**Problem: "ModuleNotFoundError: No module named 'flask'"**
- **Solution:** Install dependencies: `pip install -r requirements.txt`
- **Or:** `pip3 install -r requirements.txt`

**Problem: "Address already in use" (Port 8888)**
```bash
# Kill process using port 8888
pkill -9 -f "backend.py"
pkill -9 -f "flask"

# Or find and kill specific process
lsof -ti:8888 | xargs kill -9

# Then start Flask again
python backend.py
```

**Problem: "Database connection failed" in Flask**
- **Check:** Is MySQL container running? `docker ps | grep electronics-mysql`
- **Check:** Wait 5 seconds after starting container
- **Check:** Test connection manually (see Database Issues above)

### Query Issues

**Problem: "Query 1 error: Duplicate entry"**
- **Solution:** Query 1 was already run. Reset it first (see Query 1 Reset section)

**Problem: "No results" for queries**
- **Check:** Is data populated? Run verification commands
- **Check:** Are you using the correct database? `USE electronics_vendor;`

### UI Issues

**Problem: "404 Not Found" when accessing interfaces**
- **Check:** Is Flask server running? Look for "Running on http://127.0.0.1:8888" message
- **Check:** Are you using the correct URL? `http://localhost:8888`
- **Check:** Try `http://127.0.0.1:8888` instead

**Problem: "CORS error" in browser console**
- **Solution:** Flask-CORS should handle this. Make sure it's installed: `pip install flask-cors`

**Problem: "Product not found" in Call Center**
- **Solution:** Search by product name (e.g., "iPhone", "Laptop") or full UPC code
- **Note:** Search is case-sensitive for exact matches, but partial matches work

### Data Already Populated Scenarios

**If you see data already exists:**
- **Option 1:** Use existing data (skip population step)
- **Option 2:** Reset and repopulate:
```bash
# Stop container
docker stop electronics-mysql
# Remove container (deletes all data)
docker rm electronics-mysql
# Start fresh (see Step 2)
```

**If you want to keep existing data but verify it:**
- Use verification commands (see Database Verification section)

---

## Database Connection

**To connect directly to MySQL for manual queries:**

```bash
docker exec -it electronics-mysql mysql -uroot -prootpass electronics_vendor
```

**This opens an interactive MySQL session where you can run SQL commands:**
```sql
-- Example queries
SHOW TABLES;
SELECT * FROM Customer LIMIT 5;
SELECT * FROM Product;
EXIT;  -- To exit
```

---

## Stopping and Starting Services

### Stop MySQL Container (Keeps Data)

```bash
docker stop electronics-mysql
```

**To start again:**
```bash
docker start electronics-mysql
# Wait 5 seconds
docker ps | grep electronics-mysql
```

### Stop Flask Server

**In the terminal where Flask is running:**
- Press `Ctrl+C`

**Or kill the process:**
```bash
pkill -f "python.*backend.py"
```

### Stop Everything (Cleanup Script)

**Use the cleanup script:**
```bash
cd /path/to/dbmsFinal/DBMS_Final_Project
./cleanup.sh
```

**This will:**
- Stop MySQL container (but keep it - data preserved)
- Stop Flask server
- Show instructions to start again

### Completely Remove Database (Deletes All Data)

**⚠️ WARNING: This deletes all data!**

```bash
docker stop electronics-mysql
docker rm electronics-mysql
```

**To start fresh after removal:**
- Follow Step 2: Create Database (above)

---

## Platform Independence Analysis

### ✅ Platform Independent Components

1. **Database (MySQL in Docker)**
   - ✅ Works on Linux, macOS, Windows
   - ✅ Docker provides platform abstraction
   - ✅ Same MySQL commands work everywhere

2. **Python Backend (Flask)**
   - ✅ Python is cross-platform
   - ✅ Flask works on all platforms
   - ✅ Same code runs on Linux, macOS, Windows

3. **Web Interfaces (HTML/CSS/JavaScript)**
   - ✅ Pure web standards
   - ✅ Works in any modern browser
   - ✅ No platform-specific code

4. **SQL Scripts**
   - ✅ Standard SQL (MySQL dialect)
   - ✅ Works on any MySQL installation
   - ✅ Platform-agnostic

### ⚠️ Platform-Specific Considerations

1. **Docker Installation**
   - Different installers for Linux/macOS/Windows
   - Docker Desktop required for macOS/Windows
   - Native Docker for Linux

2. **Command Syntax**
   - **Linux/macOS:** Commands shown work as-is
   - **Windows:** May need adjustments:
     - Use `docker exec -i` (works on Windows)
     - Use PowerShell or Git Bash instead of cmd.exe
     - Path separators: `/` works in Git Bash, `\` in cmd.exe

3. **Python Installation**
   - Same Python code, but:
     - Linux/macOS: Usually `python3`
     - Windows: May be `python` or `py`
     - Package managers differ (apt, brew, pip, etc.)

4. **File Paths**
   - **Linux/macOS:** `/path/to/file` (forward slashes)
   - **Windows:** `C:\path\to\file` (backslashes) or `/path/to/file` (in Git Bash)

### 📊 Platform Independence Summary

**Overall Assessment: ✅ Highly Platform Independent**

- **Database:** ✅ Platform independent (Docker)
- **Backend:** ✅ Platform independent (Python/Flask)
- **Frontend:** ✅ Platform independent (Web standards)
- **SQL Scripts:** ✅ Platform independent (Standard SQL)

**Minor Platform Differences:**
- Docker installation method (but Docker itself is cross-platform)
- Command shell syntax (but all commands work with Git Bash on Windows)
- Python command name (`python` vs `python3`)

**Recommendation for Windows Users:**
- Use Git Bash or WSL (Windows Subsystem for Linux) for best compatibility
- Or use PowerShell with minor path adjustments
- All Docker commands work the same

**Conclusion:** The project is **platform independent** with Docker and Python providing the necessary abstraction. The only differences are installation methods and minor command variations, which are well-documented above.

---

## System Overview: Business Model & User Roles

### Software Perspective

This system is built from the perspective of **ElectroMart** (an Electronics Vendor/Retailer company) to manage:
- Product inventory across warehouses and retail stores
- Customer orders (online, in-store, phone)
- Shipments and deliveries
- Customer relationships and service

### Business Model & Supply Chain

**Supply Chain Flow:**
```
Vendors (Sony, Apple, Samsung, etc.)
    ↓
Warehouses (Distribution Centers)
    ↓
Retail Stores (ElectroMart Downtown, ElectroMart Westside, etc.)
    ↓
General Public (End Customers - John Doe, Emily Davis, etc.)
```

**Key Points:**
- **General Public** = End customers who buy from retail stores
- **Retail Stores** = Company-owned locations (NOT customers of warehouses)
- **Warehouses** = Distribution centers that supply products to stores
- **Vendors** = External suppliers (Sony, Apple, etc.) who supply products to warehouses

### Involved Parties

1. **ElectroMart Company** - The main entity that owns warehouses and retail stores
2. **Vendors/Suppliers** - External companies (Sony, Apple, Samsung, HP, Canon, Dell, Microsoft, LG) that supply products
3. **End Customers** - General public who purchase products:
   - **Contract Customers** (IDs 1-5): Business accounts with account numbers
   - **Infrequent Customers** (IDs 6-13): Regular consumers
4. **Staff Roles** - Internal employees who use the system

### Admin vs Users

#### **Admin (Database Administrator - DBA)**
- **Role:** Manages the database system
- **Interface:** No UI - uses SQL directly
- **Tasks:**
  - Database design and schema creation
  - Indexing and query optimization
  - Database maintenance and backup
  - Security and access control
  - Performance monitoring

#### **Users (Staff with UI Access)**

1. **Customer Service Representatives**
   - **Interface:** Customer Service
   - **Task:** Help end customers find products at retail stores
   - **Purpose:** Look up product availability at store locations

2. **Call Center Staff**
   - **Interface:** Call Center
   - **Task:** Handle phone orders and customer inquiries
   - **Purpose:** Look up customers and create phone orders

3. **Warehouse Staff**
   - **Interface:** Warehouse Management
   - **Tasks:**
     - Monitor warehouse inventory levels
     - Track shipments to stores
     - Manage reorder requests
     - Update inventory when shipments arrive
   - **Purpose:** Manage warehouse operations and distribution

4. **End Customers (General Public)**
   - **Interface:** Online Customers (Web Store)
   - **Task:** Browse and purchase products online
   - **Purpose:** Self-service online shopping

### Business Flow

1. **Products arrive** at warehouses from vendors
2. **Warehouses distribute** products to retail stores
3. **Customers purchase** products through:
   - Online store (web interface)
   - In-store (at retail locations)
   - Phone orders (via call center)
4. **Orders are fulfilled** and shipped to customers
5. **Inventory is tracked** and reordered as needed

### Summary

This is an **internal business management system** for an electronics retailer (ElectroMart) that:
- Manages inventory across warehouses and retail stores
- Processes orders from end customers (general public)
- Supports different staff roles with specialized interfaces
- Tracks the complete supply chain from vendors to end customers

**Key Distinction:**
- **Warehouse Inventory** = Bulk stock at distribution centers (for internal use)
- **Store Inventory** = Products available at retail locations (for customers to purchase)

**NOTE:**
- Products are "Low Stock" when quantity ≤ Reorder Level. Each product has its own reorder level (shown in table)

**How warehouse sections relate:**
- Inventory: Shows current warehouse stock levels
- Shipments: Shows shipments sent to customers (created when orders are shipped)
- Reorders: Shows reorder requests from stores (when store inventory is low)
- Update Inventory: Add new stock when products arrive from vendors

**Flow:**
- Products arrive → Update Inventory → Inventory tab shows new quantities
- Store inventory low → Reorders tab shows reorder request
- Order placed → Appears in customer history (not shipments yet)
- Order shipped → Shipment created → Appears in Shipments tab
