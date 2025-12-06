#!/usr/bin/env python3
"""
Electronics Vendor Database - Backend API
Connects all user interfaces to MySQL database
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import os

app = Flask(__name__, static_folder='.', static_url_path='')
CORS(app)  # Enable CORS for all routes

# Serve HTML pages
@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/customer-service')
def customer_service():
    return send_from_directory('customer_service', 'index.html')

@app.route('/online-customers')
def online_customers():
    return send_from_directory('online_customers', 'index.html')

@app.route('/call-center')
def call_center():
    return send_from_directory('call_center', 'index.html')

@app.route('/warehouse')
def warehouse():
    return send_from_directory('warehouse', 'index.html')

# Database configuration
# Note: If Flask runs on host, use 'localhost'. If in Docker, use container name 'electronics-mysql'
DB_CONFIG = {
    'host': 'localhost',  # Change to 'electronics-mysql' if running Flask in Docker
    'port': 3306,
    'user': 'root',
    'password': 'rootpass',
    'database': 'electronics_vendor'
}

def get_db_connection():
    """Create and return database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# ============================================================================
# CUSTOMER SERVICE INTERFACE - Inventory Lookup
# ============================================================================

@app.route('/api/inventory/search', methods=['GET'])
def search_inventory():
    """Search inventory by product name or UPC"""
    product_query = request.args.get('product', '')
    store_id = request.args.get('store_id', None)
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT 
                p.UPC,
                p.ProductName,
                p.UnitPrice,
                s.StoreID,
                s.StoreName,
                s.City,
                s.State,
                s.Phone,
                COALESCE(i.Quantity, 0) AS Quantity,
                i.ReorderLevel
            FROM Product p
            CROSS JOIN Store s
            LEFT JOIN Inventory i ON p.UPC = i.UPC 
                AND i.LocationType = 'Store' 
                AND i.LocationID = s.StoreID
            WHERE (p.ProductName LIKE %s OR p.UPC LIKE %s)
        """
        params = [f'%{product_query}%', f'%{product_query}%']
        
        if store_id:
            query += " AND s.StoreID = %s"
            params.append(store_id)
        
        query += " ORDER BY s.StoreID, p.ProductName"
        
        cursor.execute(query, params)
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stores', methods=['GET'])
def get_stores():
    """Get all stores"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT StoreID, StoreName, City, State, Phone FROM Store ORDER BY State, City")
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

# ============================================================================
# ONLINE CUSTOMERS INTERFACE
# ============================================================================

@app.route('/api/products', methods=['GET'])
def get_products():
    """Get all products with pagination"""
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 20))
    category = request.args.get('category', None)
    search = request.args.get('search', '')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT DISTINCT
                p.UPC,
                p.ProductName,
                p.Description,
                p.UnitPrice,
                p.Manufacturer,
                v.VendorName
            FROM Product p
            JOIN Vendor v ON p.VendorID = v.VendorID
            LEFT JOIN ProductCategory pc ON p.UPC = pc.UPC
            LEFT JOIN Category c ON pc.CategoryID = c.CategoryID
            WHERE 1=1
        """
        params = []
        
        if search:
            query += " AND (p.ProductName LIKE %s OR p.Description LIKE %s)"
            params.extend([f'%{search}%', f'%{search}%'])
        
        if category:
            query += " AND c.CategoryID = %s"
            params.append(category)
        
        query += " ORDER BY p.ProductName LIMIT %s OFFSET %s"
        params.extend([per_page, (page - 1) * per_page])
        
        cursor.execute(query, params)
        results = cursor.fetchall()
        
        # Get total count
        count_query = """
            SELECT COUNT(DISTINCT p.UPC) as total
            FROM Product p
            LEFT JOIN ProductCategory pc ON p.UPC = pc.UPC
            LEFT JOIN Category c ON pc.CategoryID = c.CategoryID
            WHERE 1=1
        """
        count_params = []
        if search:
            count_query += " AND (p.ProductName LIKE %s OR p.Description LIKE %s)"
            count_params.extend([f'%{search}%', f'%{search}%'])
        if category:
            count_query += " AND c.CategoryID = %s"
            count_params.append(category)
        
        cursor.execute(count_query, count_params)
        total = cursor.fetchone()['total']
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'products': results,
            'total': total,
            'page': page,
            'per_page': per_page
        })
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/categories', methods=['GET'])
def get_categories():
    """Get all categories"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT CategoryID, CategoryName, CategoryType FROM Category ORDER BY CategoryType, CategoryName")
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/order/create', methods=['POST'])
def create_order():
    """Create a new order"""
    data = request.json
    customer_id = data.get('customer_id')
    items = data.get('items', [])
    order_type = data.get('order_type', 'Online')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        
        # Calculate total
        total = 0
        for item in items:
            cursor.execute("SELECT UnitPrice FROM Product WHERE UPC = %s", (item['upc'],))
            price = cursor.fetchone()[0]
            total += price * item['quantity']
        
        # Create order
        cursor.execute("""
            INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod)
            VALUES (%s, NOW(), %s, %s, 'Pending', %s)
        """, (customer_id, order_type, total, data.get('payment_method', 'Credit Card')))
        
        order_id = cursor.lastrowid
        
        # Add order items
        for item in items:
            cursor.execute("SELECT UnitPrice FROM Product WHERE UPC = %s", (item['upc'],))
            unit_price = cursor.fetchone()[0]
            subtotal = unit_price * item['quantity']
            
            cursor.execute("""
                INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal)
                VALUES (%s, %s, %s, %s, %s)
            """, (order_id, item['upc'], item['quantity'], unit_price, subtotal))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'order_id': order_id, 'total': total, 'status': 'success'})
    except Error as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

# ============================================================================
# CALL CENTER INTERFACE
# ============================================================================

@app.route('/api/customers/search', methods=['GET'])
def search_customers():
    """Search customers by name, email, phone, or account number"""
    query_param = request.args.get('q', '')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT 
                CustomerID,
                FirstName,
                LastName,
                Email,
                Phone,
                CustomerType,
                AccountNumber
            FROM Customer
            WHERE CONCAT(FirstName, ' ', LastName) LIKE %s
               OR FirstName LIKE %s 
               OR LastName LIKE %s
               OR Email LIKE %s
               OR Phone LIKE %s
               OR AccountNumber LIKE %s
            ORDER BY LastName, FirstName
            LIMIT 50
        """
        search_pattern = f'%{query_param}%'
        cursor.execute(query, (search_pattern, search_pattern, search_pattern, search_pattern, search_pattern, search_pattern))
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def get_customer_details(customer_id):
    """Get customer details and order history"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get customer info
        cursor.execute("""
            SELECT * FROM Customer WHERE CustomerID = %s
        """, (customer_id,))
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        # Get order history
        cursor.execute("""
            SELECT 
                o.OrderID,
                o.OrderDate,
                o.OrderType,
                o.TotalAmount,
                o.Status,
                COUNT(oi.UPC) as ItemCount
            FROM `Order` o
            LEFT JOIN OrderItem oi ON o.OrderID = oi.OrderID
            WHERE o.CustomerID = %s
            GROUP BY o.OrderID
            ORDER BY o.OrderDate DESC
            LIMIT 20
        """, (customer_id,))
        orders = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'customer': customer,
            'orders': orders
        })
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/phone-order/create', methods=['POST'])
def create_phone_order():
    """Create a phone order (call center)"""
    data = request.json
    customer_id = data.get('customer_id')
    items = data.get('items', [])
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        
        # Calculate total
        total = 0
        for item in items:
            cursor.execute("SELECT UnitPrice FROM Product WHERE UPC = %s", (item['upc'],))
            price = cursor.fetchone()[0]
            total += price * item['quantity']
        
        # Create phone order
        cursor.execute("""
            INSERT INTO `Order` (CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod)
            VALUES (%s, NOW(), 'Phone', %s, 'Processing', 'Account')
        """, (customer_id, total))
        
        order_id = cursor.lastrowid
        
        # Add order items
        for item in items:
            cursor.execute("SELECT UnitPrice FROM Product WHERE UPC = %s", (item['upc'],))
            unit_price = cursor.fetchone()[0]
            subtotal = unit_price * item['quantity']
            
            cursor.execute("""
                INSERT INTO OrderItem (OrderID, UPC, Quantity, UnitPrice, Subtotal)
                VALUES (%s, %s, %s, %s, %s)
            """, (order_id, item['upc'], item['quantity'], unit_price, subtotal))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'order_id': order_id, 'total': total, 'status': 'success'})
    except Error as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

# ============================================================================
# WAREHOUSE INTERFACE
# ============================================================================

@app.route('/api/warehouse/shipments', methods=['GET'])
def get_shipments():
    """Get shipments for warehouse"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                s.ShipmentID,
                s.TrackingNumber,
                s.Carrier,
                s.ShippedDate,
                s.Status,
                o.OrderID,
                c.FirstName,
                c.LastName
            FROM Shipment s
            JOIN `Order` o ON s.OrderID = o.OrderID
            JOIN Customer c ON o.CustomerID = c.CustomerID
            ORDER BY s.ShippedDate DESC
            LIMIT 50
        """)
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/warehouse/inventory', methods=['GET'])
def get_warehouse_inventory():
    """Get warehouse inventory"""
    warehouse_id = request.args.get('warehouse_id', None)
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        query = """
            SELECT 
                i.UPC,
                p.ProductName,
                w.WarehouseID,
                w.WarehouseName,
                i.Quantity,
                i.ReorderLevel,
                i.LastUpdated
            FROM Inventory i
            JOIN Product p ON i.UPC = p.UPC
            JOIN Warehouse w ON i.LocationID = w.WarehouseID
            WHERE i.LocationType = 'Warehouse'
        """
        
        if warehouse_id:
            query += " AND w.WarehouseID = %s"
            cursor.execute(query, (warehouse_id,))
        else:
            cursor.execute(query)
        
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/warehouse/inventory/update', methods=['POST'])
def update_warehouse_inventory():
    """Update warehouse inventory after receiving shipment"""
    data = request.json
    upc = data.get('upc')
    warehouse_id = data.get('warehouse_id')
    quantity_added = data.get('quantity_added', 0)
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        
        # Check if inventory record exists
        cursor.execute("""
            SELECT Quantity FROM Inventory 
            WHERE UPC = %s AND LocationType = 'Warehouse' AND LocationID = %s
        """, (upc, warehouse_id))
        
        result = cursor.fetchone()
        
        if result:
            # Update existing inventory
            new_quantity = result[0] + quantity_added
            cursor.execute("""
                UPDATE Inventory 
                SET Quantity = %s, LastUpdated = NOW()
                WHERE UPC = %s AND LocationType = 'Warehouse' AND LocationID = %s
            """, (new_quantity, upc, warehouse_id))
        else:
            # Create new inventory record
            cursor.execute("""
                INSERT INTO Inventory (UPC, LocationType, LocationID, Quantity, ReorderLevel)
                VALUES (%s, 'Warehouse', %s, %s, 10)
            """, (upc, warehouse_id, quantity_added))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'status': 'success', 'message': 'Inventory updated'})
    except Error as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/warehouse/reorders', methods=['GET'])
def get_reorders():
    """Get reorder requests"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                r.ReorderID,
                r.UPC,
                p.ProductName,
                v.VendorName,
                r.Quantity,
                r.OrderDate,
                r.Status,
                r.ExpectedDeliveryDate,
                r.ReceivedDate
            FROM Reorder r
            JOIN Product p ON r.UPC = p.UPC
            JOIN Vendor v ON r.VendorID = v.VendorID
            ORDER BY r.OrderDate DESC
        """)
        results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify(results)
    except Error as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/warehouse/reorders/update', methods=['POST'])
def update_reorder_status():
    """Update reorder status when received"""
    data = request.json
    reorder_id = data.get('reorder_id')
    status = data.get('status')
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        
        if status == 'Received':
            cursor.execute("""
                UPDATE Reorder 
                SET Status = 'Received', ReceivedDate = NOW()
                WHERE ReorderID = %s
            """, (reorder_id,))
        else:
            cursor.execute("""
                UPDATE Reorder 
                SET Status = %s
                WHERE ReorderID = %s
            """, (status, reorder_id))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'status': 'success'})
    except Error as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order_details(order_id):
    """Get detailed order information including items"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Get order info
        cursor.execute("""
            SELECT OrderID, CustomerID, OrderDate, OrderType, TotalAmount, Status, PaymentMethod
            FROM `Order`
            WHERE OrderID = %s
        """, (order_id,))
        order = cursor.fetchone()
        
        if not order:
            return jsonify({'error': 'Order not found'}), 404
        
        # Get order items
        cursor.execute("""
            SELECT oi.UPC, p.ProductName, oi.Quantity, oi.UnitPrice, oi.Subtotal
            FROM OrderItem oi
            JOIN Product p ON oi.UPC = p.UPC
            WHERE oi.OrderID = %s
            ORDER BY p.ProductName
        """, (order_id,))
        items = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'order': order,
            'items': items
        })
    except Error as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Check if MySQL is accessible
    conn = get_db_connection()
    if conn:
        print("✓ Database connection successful")
        conn.close()
    else:
        print("✗ Database connection failed. Make sure MySQL container is running.")
        print("  Run: docker start electronics-mysql")
        print("  Note: If using Docker, MySQL host should be 'localhost' or container name")
    
    print("\nStarting Flask server on http://localhost:8888")
    print("Available interfaces:")
    print("  - Customer Service: http://localhost:8888/customer-service")
    print("  - Online Customers: http://localhost:8888/online-customers")
    print("  - Call Center: http://localhost:8888/call-center")
    print("  - Warehouse: http://localhost:8888/warehouse")
    print("\nPress Ctrl+C to stop the server")
    
    app.run(host='0.0.0.0', port=8888, debug=True)

