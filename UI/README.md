# User Interfaces - Electronics Vendor System

## Check MySQL Status and Start if Needed

**Before starting the UI, check if MySQL is running:**

```bash
# Check if container exists and is running
docker ps -a | grep electronics-mysql
```

**If container is running:** You're good to go! Skip to "Quick Setup Guide" below.

**If container exists but is stopped:**
```bash
docker start electronics-mysql
# Wait 3-5 seconds for MySQL to initialize
```

**If container doesn't exist (first time setup):**
```bash
# 1. Create and start MySQL container
docker run --name electronics-mysql -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=electronics_vendor -p 3306:3306 -d mysql:8.0

# 2. Wait 5-10 seconds for MySQL to initialize, then create schema
cd DBMS_Final_Project
docker exec -i electronics-mysql mysql -uroot -prootpass < database/Phase1_Schm.sql

# 3. Populate with test data
docker exec -i electronics-mysql mysql -uroot -prootpass < database/Phase2_DataPopulation.sql

# 4. Verify (should show 15 tables)
docker exec -i electronics-mysql mysql -uroot -prootpass -e "USE electronics_vendor; SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'electronics_vendor';"
```

**Verify MySQL is ready:**
```bash
# Check container status
docker ps | grep electronics-mysql

# Test connection
docker exec -i electronics-mysql mysql -uroot -prootpass -e "SELECT 1;" 2>/dev/null && echo "✓ MySQL is ready" || echo "✗ MySQL not ready yet"
```

## Quick Setup Guide

### Step 1: Install Dependencies

```bash
cd UI
pip install -r requirements.txt
```

### Step 2: Ensure MySQL Container is Running

```bash
# Check status first
docker ps | grep electronics-mysql

# If not running, start it
docker start electronics-mysql

# Wait 3-5 seconds for MySQL to initialize
```

### Step 3: Start Flask Server

```bash
python backend.py
```

### Step 4: Access Interfaces

Open browser and go to: **http://localhost:8888**

You'll see a portal page with links to all 4 interfaces:
- Customer Service
- Online Customers  
- Call Center
- Warehouse

## Cleanup (Stop All Services)

To stop all services (MySQL container, Flask backend) **while preserving your data**:

```bash
# From DBMS_Final_Project directory
./cleanup.sh

# Or from project root
./DBMS_Final_Project/cleanup.sh

# Or using bash directly
bash cleanup.sh
```

**Note:** The cleanup script stops the MySQL container but does NOT remove it, so all your data remains intact. To start again, just run `docker start electronics-mysql` and `python backend.py`.

Or manually:
```bash
# Stop MySQL container (data preserved)
docker stop electronics-mysql

# Stop Flask server (Ctrl+C if running in terminal, or):
pkill -f "python.*backend.py"
```

**To completely reset database** (removes all data):
```bash
docker stop electronics-mysql
docker rm electronics-mysql
# Then recreate: see main README.md for setup instructions
```

## Overview

This folder contains all user interfaces for the Electronics Vendor database system:
- **Customer Service** - Inventory lookup at stores
- **Online Customers** - Web store for browsing and purchasing
- **Call Center** - Customer lookup and phone order entry
- **Warehouse** - Inventory management and shipment tracking

## Prerequisites

- Python 3.7+
- MySQL database running (Docker container: `electronics-mysql`)
- Flask and mysql-connector-python

## Setup

1. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

2. **Ensure MySQL container is running:**
```bash
docker start electronics-mysql
```

3. **Start the Flask backend server:**
```bash
python backend.py
```

The server will start on `http://localhost:8888`

## Accessing Interfaces

Once the server is running, access the interfaces at:

- **Customer Service:** http://localhost:8888/customer-service
- **Online Customers:** http://localhost:8888/online-customers
- **Call Center:** http://localhost:8888/call-center
- **Warehouse:** http://localhost:8888/warehouse

## Testing Each Interface

### Customer Service
- Search for: "iPhone" or "123456789012"
- Should show inventory at all stores

### Online Customers
- Browse products
- Add items to cart
- Checkout with Customer ID (use 6-13 for infrequent customers)

### Call Center
- Search for: "John" or "john.doe@email.com"
- View customer details
- Create phone order

### Warehouse
- View inventory tabs
- Update inventory with UPC and quantity
- View shipments and reorders

## Interface Descriptions

### 1. Customer Service Interface
**Purpose:** Look up inventory at stores for customer inquiries

**Features:**
- Search products by name or UPC
- Filter by specific store
- View inventory levels at all stores
- See stock status (In Stock, Low Stock, Out of Stock)
- Store contact information

**Usage:**
1. Enter product name or UPC in search box
2. Optionally select a specific store
3. Click "Search Inventory"
4. View results showing inventory at all stores

### 2. Online Customers Interface
**Purpose:** Web store for customers to browse and purchase products

**Features:**
- Browse all products
- Search products
- Filter by category
- Add products to shopping cart
- Place orders

**Usage:**
1. Browse or search for products
2. Click "Add to Cart" for desired products
3. Review cart (top right)
4. Click "Checkout"
5. Enter Customer ID (for demo: use 1-13)
6. Order is created in database

### 3. Call Center Interface
**Purpose:** Quick customer lookup and phone order entry

**Features:**
- Search customers by name, email, phone, or account number
- View customer details and order history
- Create phone orders
- Add products to order
- Place orders directly

**Usage:**
1. Search for customer
2. View customer information and order history
3. Click "Create New Phone Order"
4. Search and add products
5. Click "Place Order"

### 4. Warehouse Interface
**Purpose:** Manage warehouse inventory and track shipments

**Features:**
- View warehouse inventory
- Track shipments
- View reorder requests
- Update inventory when shipments arrive
- Mark reorders as received

**Usage:**
- **Inventory Tab:** View current inventory levels
- **Shipments Tab:** View all shipments
- **Reorders Tab:** View and manage reorder requests
- **Update Inventory Tab:** Record incoming shipments

## API Endpoints

The backend provides REST API endpoints:

- `GET /api/stores` - Get all stores
- `GET /api/inventory/search` - Search inventory
- `GET /api/products` - Get products (with search/filter)
- `GET /api/categories` - Get categories
- `POST /api/order/create` - Create online order
- `GET /api/customers/search` - Search customers
- `GET /api/customers/<id>` - Get customer details
- `POST /api/phone-order/create` - Create phone order
- `GET /api/warehouse/inventory` - Get warehouse inventory
- `POST /api/warehouse/inventory/update` - Update inventory
- `GET /api/warehouse/shipments` - Get shipments
- `GET /api/warehouse/reorders` - Get reorders
- `POST /api/warehouse/reorders/update` - Update reorder status

## Troubleshooting

**Database Connection Error:**
- Ensure MySQL container is running: `docker start electronics-mysql`
- Check container status: `docker ps | grep electronics-mysql`
- If using Docker network, change host in backend.py to 'electronics-mysql'

**Port Already in Use:**
```bash
# Quick fix: Kill processes using the port
pkill -9 -f "backend.py"
pkill -9 -f "flask"

# Then try starting Flask again
python backend.py
```

**Note:** Flask is configured to run on port 8888. If you need to change it:
- Edit `backend.py` line 635: `app.run(host='0.0.0.0', port=8888, debug=True)`
- Update all HTML files to use the new port (search for `localhost:8888`)

**CORS Errors:**
- If accessing from different origin, add CORS headers to Flask app

## Notes

- All interfaces connect to the same MySQL database
- Customer IDs 1-5 are contract customers
- Customer IDs 6-13 are infrequent customers
- For testing, use existing customer IDs from the database
- All orders are created in the database and can be viewed via SQL queries
