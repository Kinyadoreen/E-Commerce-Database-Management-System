-- Create Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Users Table
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE Products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT DEFAULT 0
);

-- Orders Table
CREATE TABLE Orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(50) DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- OrderItems Table
CREATE TABLE OrderItems (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_at_purchase DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

-- Categories Table
CREATE TABLE Categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

-- ProductCategories Table (Many-to-Many)
CREATE TABLE ProductCategories (
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

-- Insert Users
INSERT INTO Users (username, email, password_hash) VALUES
('doreenxanders', 'doreen@example.com', 'hashedpassword5'),
('techguru', 'guru@example.com', 'hashedpassword2');

-- Insert Categories
INSERT INTO Categories (name) VALUES
('Electronics'),
('Books'),
('Clothing');

-- Insert Products
INSERT INTO Products (name, description, price, stock_quantity) VALUES
('Laptop', 'Powerful gaming laptop', 1200.00, 10),
('Wireless Mouse', 'Ergonomic wireless mouse', 250.00, 50),
('Sci-Fi Novel', 'A thrilling space adventure', 150.00, 100);

-- Link Products to Categories
INSERT INTO ProductCategories (product_id, category_id) VALUES
(1, 1),  -- Laptop -> Electronics
(2, 1),  -- Wireless Mouse -> Electronics
(3, 2);  -- Sci-Fi Novel -> Books

-- Insert Orders
INSERT INTO Orders (user_id, status) VALUES
(1, 'pending'),
(2, 'completed');

-- Insert OrderItems
INSERT INTO OrderItems (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 1200.00),  -- 1 Laptop in Order 1
(1, 2, 2, 250.00),    -- 2 Wireless Mice in Order 1
(2, 3, 3, 150.00);    -- 3 Sci-Fi Novels in Order 2


### 1. View all orders with details for each user
SELECT 
  u.username,
  o.order_id,
  o.order_date,
  o.status,
  p.name AS product,
  oi.quantity,
  oi.price_at_purchase,
  (oi.quantity * oi.price_at_purchase) AS item_total
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
ORDER BY u.username, o.order_date;


### 2. Total spend per user (sum of all their orders)
SELECT 
  u.username,
  SUM(oi.quantity * oi.price_at_purchase) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY u.username
ORDER BY total_spent DESC;


### 1. Filter orders by status (e.g., ‘completed’)
SELECT 
  u.username,
  o.order_id,
  o.order_date,
  o.status,
  p.name AS product,
  oi.quantity,
  oi.price_at_purchase,
  (oi.quantity * oi.price_at_purchase) AS item_total
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
ORDER BY o.order_date DESC;

### 2. Filter orders by a date range (e.g., 1st to 30th September 2025)
SELECT 
  u.username,
  o.order_id,
  o.order_date,
  o.status,
  p.name AS product,
  oi.quantity,
  oi.price_at_purchase,
  (oi.quantity * oi.price_at_purchase) AS item_total
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_date BETWEEN '2025-09-01' AND '2025-09-30'
ORDER BY o.order_date;

### 3. Combine both filters (e.g., completed orders in September)
SELECT 
  u.username,
  o.order_id,
  o.order_date,
  o.status,
  p.name AS product,
  oi.quantity,
  oi.price_at_purchase,
  (oi.quantity * oi.price_at_purchase) AS item_total
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
  AND o.order_date BETWEEN '2025-09-01' AND '2025-09-30'
ORDER BY o.order_date DESC;
