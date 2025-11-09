-- ============================================
-- K.K.Y MEAT SHOP DATABASE STRUCTURE
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS kky_meatshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kky_meatshop;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- PRODUCTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(255),
    category VARCHAR(100),
    stock_quantity INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_available (is_available)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Sample Products
INSERT INTO products (product_name, description, price, image_url, category, stock_quantity) VALUES
('Wagyu Beef Striploin MB 7-8', 'Premium marbled Japanese Wagyu beef, perfect for grilling', 8500.00, 'beef thajima.jpg', 'Beef', 50),
('Fresh Chicken Breast', 'Boneless, skinless chicken breast - ideal for grilling or frying', 1200.00, 'chicken.jpg', 'Chicken', 100),
('Australian Lamb Chops', 'Juicy, tender lamb chops with rich flavor', 3200.00, 'lamb.jpg', 'Lamb', 75),
('Premium Ribeye Steak', 'Tender and juicy ribeye cuts with excellent marbling', 4200.00, 'hokubee melt.jpg', 'Beef', 60),
('Fresh Minced Meat', 'Premium quality minced beef', 2800.00, 'Minced meat.jpg', 'Beef', 80);

-- ============================================
-- ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    delivery_address TEXT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status ENUM('Pending', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    payment_method VARCHAR(50),
    driver_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_tracking (tracking_number),
    INDEX idx_status (order_status),
    INDEX idx_customer_phone (customer_phone),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ORDER ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ORDER STATUS HISTORY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS order_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- DRIVERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    driver_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_type VARCHAR(50),
    vehicle_number VARCHAR(50),
    rating DECIMAL(3, 2) DEFAULT 0.00,
    total_deliveries INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    last_location_update TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_available (is_available),
    INDEX idx_location (current_latitude, current_longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Sample Drivers
INSERT INTO drivers (driver_name, phone, vehicle_type, vehicle_number, rating, total_deliveries, is_available) VALUES
('Mohamed Rizwan', '0740689243', 'Bike', 'LK ABC-1234', 4.9, 250, TRUE),
('Kasun Fernando', '0771234567', 'Van', 'LK XYZ-5678', 4.8, 180, TRUE),
('Anil Silva', '0769876543', 'Bike', 'LK DEF-9012', 4.7, 320, FALSE);

-- ============================================
-- DELIVERY TRACKING TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS delivery_tracking (
    tracking_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    driver_id INT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE SET NULL,
    INDEX idx_order (order_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    notification_type ENUM('SMS', 'Email', 'Push') NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('Pending', 'Sent', 'Failed') DEFAULT 'Pending',
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ADMIN USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin_users (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Manager', 'Staff') DEFAULT 'Staff',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Default Admin (password: admin123)
INSERT INTO admin_users (username, password, full_name, email, role) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Admin', 'admin@kkymeatshop.lk', 'Admin');

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

-- View: Order Details with Items
CREATE OR REPLACE VIEW order_details_view AS
SELECT 
    o.order_id,
    o.tracking_number,
    o.customer_name,
    o.customer_email,
    o.customer_phone,
    o.delivery_address,
    o.total_amount,
    o.order_status,
    o.payment_status,
    o.created_at,
    d.driver_name,
    d.phone as driver_phone,
    d.vehicle_number,
    GROUP_CONCAT(
        CONCAT(oi.product_name, ' (', oi.quantity, 'kg)')
        SEPARATOR ', '
    ) as items
FROM orders o
LEFT JOIN drivers d ON o.driver_id = d.driver_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure: Create New Order
DELIMITER //
CREATE PROCEDURE create_order(
    IN p_tracking_number VARCHAR(20),
    IN p_customer_name VARCHAR(255),
    IN p_customer_email VARCHAR(255),
    IN p_customer_phone VARCHAR(20),
    IN p_delivery_address TEXT,
    IN p_total_amount DECIMAL(10, 2)
)
BEGIN
    INSERT INTO orders (
        tracking_number,
        customer_name,
        customer_email,
        customer_phone,
        delivery_address,
        total_amount,
        order_status
    ) VALUES (
        p_tracking_number,
        p_customer_name,
        p_customer_email,
        p_customer_phone,
        p_delivery_address,
        p_total_amount,
        'Pending'
    );
    
    -- Return the new order ID
    SELECT LAST_INSERT_ID() as order_id;
END //
DELIMITER ;

-- Procedure: Update Order Status
DELIMITER //
CREATE PROCEDURE update_order_status(
    IN p_order_id INT,
    IN p_new_status VARCHAR(50),
    IN p_notes TEXT
)
BEGIN
    -- Update order status
    UPDATE orders 
    SET order_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;
    
    -- Log status change
    INSERT INTO order_status_history (order_id, status, notes)
    VALUES (p_order_id, p_new_status, p_notes);
    
    -- Mark as delivered if status is Delivered
    IF p_new_status = 'Delivered' THEN
        UPDATE orders 
        SET delivered_at = CURRENT_TIMESTAMP
        WHERE order_id = p_order_id;
    END IF;
END //
DELIMITER ;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Log order status changes
DELIMITER //
CREATE TRIGGER after_order_status_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.order_status != NEW.order_status THEN
        INSERT INTO order_status_history (order_id, status, notes)
        VALUES (NEW.order_id, NEW.order_status, 'Status automatically updated');
    END IF;
END //
DELIMITER ;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_order_created ON orders(created_at DESC);
CREATE INDEX idx_order_status_tracking ON orders(order_status, tracking_number);
CREATE INDEX idx_product_availability ON products(is_available, category);

-- ============================================
-- GRANT PERMISSIONS (Update with your credentials)
-- ============================================
-- GRANT ALL PRIVILEGES ON kky_meatshop.* TO 'kky_user'@'localhost' IDENTIFIED BY 'your_password';
-- FLUSH PRIVILEGES;

-- ============================================
-- SAMPLE QUERIES FOR TESTING
-- ============================================

-- Get all orders
-- SELECT * FROM order_details_view ORDER BY created_at DESC;

-- Track specific order
-- SELECT * FROM orders WHERE tracking_number = 'KKY12345';

-- Get order with items
-- SELECT o.*, oi.* FROM orders o
-- JOIN order_items oi ON o.order_id = oi.order_id
-- WHERE o.tracking_number = 'KKY12345';

-- Get active drivers
-- SELECT * FROM drivers WHERE is_available = TRUE;

-- Get order status history
-- SELECT * FROM order_status_history WHERE order_id = 1 ORDER BY created_at DESC;