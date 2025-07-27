-- Sales and Inventory Management Database
-- Author: Shandara Mae De Las Llagas
-- Description: Full schema with sample data, constraints, and basic reporting queries for a sales and inventory management system.

-- ---------------------------
-- Drop and Recreate Database (for testing/demo)
-- ---------------------------
DROP DATABASE IF EXISTS SalesInventoryDB;
CREATE DATABASE SalesInventoryDB;
USE SalesInventoryDB;

-- ---------------------------
-- Customers Table
-- ---------------------------
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);

-- ---------------------------
-- Products Table
-- ---------------------------
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Stock INT CHECK (Stock >= 0)
);

-- ---------------------------
-- Suppliers Table
-- ---------------------------
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100)
);

-- ---------------------------
-- Inventory (Restocks) Table
-- ---------------------------
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    SupplierID INT NOT NULL,
    QuantityReceived INT CHECK (QuantityReceived > 0),
    RestockDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- ---------------------------
-- Sales Table
-- ---------------------------
CREATE TABLE Sales (
    SaleID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    SaleDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    TotalAmount DECIMAL(10,2) CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- ---------------------------
-- Sale Details Table
-- ---------------------------
CREATE TABLE SaleDetails (
    SaleDetailID INT AUTO_INCREMENT PRIMARY KEY,
    SaleID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    Subtotal DECIMAL(10,2) CHECK (Subtotal >= 0),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- ---------------------------
-- Sample Data
-- ---------------------------

-- Customers
INSERT INTO Customers (Name, Email, Phone) VALUES
('Shandara De Las Llagas', 'shan@gmail.com', '09123456789'),
('Brian Co', 'brian@gmail.com', '09234567890');

-- Products
INSERT INTO Products (ProductName, Price, Stock) VALUES
('Laptop', 35000.00, 10),
('Mouse', 500.00, 50),
('Keyboard', 1000.00, 30);

-- Suppliers
INSERT INTO Suppliers (SupplierName, ContactEmail) VALUES
('TechValley Co.', 'contact@techvalley.com'),
('GadgetPlanet Inc.', 'info@gadgetplanet.com');

-- Inventory Restocks
INSERT INTO Inventory (ProductID, SupplierID, QuantityReceived, RestockDate) VALUES
(1, 1, 5, '2025-07-20'),
(2, 2, 50, '2025-07-21'),
(3, 1, 25, '2025-07-22');

-- Sale
INSERT INTO Sales (CustomerID, SaleDate, TotalAmount) VALUES
(1, '2025-07-25', 37000.00);

-- Sale Details
INSERT INTO SaleDetails (SaleID, ProductID, Quantity, Subtotal) VALUES
(1, 1, 1, 35000.00),  -- Laptop
(1, 2, 4, 2000.00);   -- 4x Mouse

-- ---------------------------
-- Reports and Analytics
-- ---------------------------

-- 1️. Sales with Customer Name
SELECT s.SaleID, c.Name AS CustomerName, s.SaleDate, s.TotalAmount
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID;

-- 2️. Total Sales Per Product
SELECT p.ProductName, SUM(sd.Quantity) AS TotalSold, SUM(sd.Subtotal) AS TotalRevenue
FROM SaleDetails sd
JOIN Products p ON sd.ProductID = p.ProductID
GROUP BY p.ProductID;

-- 3️. Products with Low Stock (< 20 units)
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20;

-- 4️. Total Restocks Per Product
SELECT p.ProductName, SUM(i.QuantityReceived) AS TotalRestocked
FROM Inventory i
JOIN Products p ON i.ProductID = p.ProductID
GROUP BY p.ProductID;

-- 5️. Customers with Total Purchases
SELECT c.Name AS CustomerName, SUM(s.TotalAmount) AS TotalSpent
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID;

-- 6️. Current Inventory Levels (Stock + Restocked - Sold)
SELECT 
    p.ProductName,
    p.Stock AS InitialStock,
    IFNULL(SUM(i.QuantityReceived), 0) AS TotalRestocked,
    IFNULL(SUM(sd.Quantity), 0) AS TotalSold,
    (p.Stock + IFNULL(SUM(i.QuantityReceived), 0) - IFNULL(SUM(sd.Quantity), 0)) AS FinalStock
FROM Products p
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
LEFT JOIN SaleDetails sd ON p.ProductID = sd.ProductID
GROUP BY p.ProductID;
