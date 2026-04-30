

CREATE DATABASE POS_DB;
USE POS_DB;
GO

-- ************************************************************
-- ********************** STORED PROCEDURES *******************
-- ************************************************************

---------------------------------------------------------------
-- PROCEDURE: AddProduct
-- Description: Inserts a new product into Products table
-- Inputs: Name, Price, Quantity
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE AddProduct
@Name VARCHAR(100),
@Price DECIMAL(10,2),
@Quantity INT
AS
BEGIN
    INSERT INTO Products(Name,Price,Quantity)          
    VALUES(@Name,@Price,@Quantity);
END
GO
  ---------------------------------------------------------------
-- PROCEDURE: UpdateProduct
-- Description: Updates an existing product using ProductID
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE UpdateProduct         
@ID INT,                                        
@Name VARCHAR(100),
@Price DECIMAL(10,2),
@Quantity INT
AS
BEGIN
    UPDATE Products
    SET Name=@Name, Price=@Price, Quantity=@Quantity       
    WHERE ProductID=@ID;
END
GO

---------------------------------------------------------------
-- PROCEDURE: DeleteProduct
-- Description: Deletes a product using ProductID
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE DeleteProduct          
@ID INT                                          
AS
BEGIN
    DELETE FROM Products WHERE ProductID=@ID;      
END
GO

---------------------------------------------------------------
-- PROCEDURE: AddCustomer
-- Description: Inserts a new customer into Customers table
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE AddCustomer      
@Name VARCHAR(100),
@Phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Customers(Name,Phone)             
    VALUES(@Name,@Phone);
END
GO
---------------------------------------------------------------
-- PROCEDURE: UpdateCustomer
-- Description: Updates customer details using CustomerID
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE UpdateCustomer        
@ID INT,
@Name VARCHAR(100),
@Phone VARCHAR(20)
AS
BEGIN
    UPDATE Customers
    SET Name=@Name, Phone=@Phone                             
    WHERE CustomerID=@ID;
END
GO
---------------------------------------------------------------
-- PROCEDURE: DeleteCustomer
-- Description: Deletes a customer using CustomerID
---------------------------------------------------------------

CREATE OR ALTER PROCEDURE DeleteCustomer         
@ID INT                              
AS
BEGIN
    DELETE FROM Customers WHERE CustomerID=@ID;                
END
GO
---------------------------------------------------------------
-- PROCEDURE: AddSale
-- Description: Creates a sale record and returns generated SaleID
---------------------------------------------------------------

CREATE OR ALTER PROCEDURE AddSale
@CustomerID INT,
@TotalAmount DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Sales(CustomerID, TotalAmount)           
    VALUES(@CustomerID, @TotalAmount);

    SELECT SCOPE_IDENTITY() AS SaleID;
END
GO
---------------------------------------------------------------
-- PROCEDURE: AddSaleItem
-- Description: Inserts items for a specific sale
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE AddSaleItem           
@SaleID INT,
@ProductID INT,
@Quantity INT,
@Price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO SaleItems(SaleID, ProductID, Quantity, Price)         
    VALUES(@SaleID, @ProductID, @Quantity, @Price);
END
GO

-- ************************************************************
-- ************************ TABLES ****************************
-- ************************************************************

---------------------------------------------------------------
-- TABLE: Users
-- Description: Stores login credentials
---------------------------------------------------------------

CREATE TABLE Users( UserID INT PRIMARY KEY IDENTITY(1,1), Username VARCHAR(50) UNIQUE NOT NULL, Password VARCHAR(50) NOT NULL );
---------------------------------------------------------------
-- TABLE: Products
-- Description: Stores product details and stock
---------------------------------------------------------------
CREATE TABLE Products( ProductID INT PRIMARY KEY IDENTITY(1,1), Name VARCHAR(100) NOT NULL, Price DECIMAL(10,2) NOT NULL CHECK(Price > 0), Quantity INT NOT NULL CHECK(Quantity >= 0) ); 
---------------------------------------------------------------
-- TABLE: Customers
-- Description: Stores customer information
---------------------------------------------------------------
CREATE TABLE Customers( CustomerID INT PRIMARY KEY IDENTITY(1,1), Name VARCHAR(100) NOT NULL, Phone VARCHAR(20) UNIQUE );
---------------------------------------------------------------
-- TABLE: Sales
-- Description: Stores main sales transaction
---------------------------------------------------------------
CREATE TABLE Sales( SaleID INT PRIMARY KEY IDENTITY(1,1), CustomerID INT, TotalAmount DECIMAL(10,2), SaleDate DATETIME DEFAULT GETDATE(), FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) );
---------------------------------------------------------------
-- TABLE: SaleItems
-- Description: Stores individual items of each sale
---------------------------------------------------------------
CREATE TABLE SaleItems( ItemID INT PRIMARY KEY IDENTITY(1,1), SaleID INT, ProductID INT, Quantity INT, Price DECIMAL(10,2), FOREIGN KEY (SaleID) REFERENCES Sales(SaleID), FOREIGN KEY (ProductID) REFERENCES Products(ProductID) );


-- ************************************************************
-- ************************ TRIGGERS **************************
-- ************************************************************

---------------------------------------------------------------
-- TRIGGER: UpdateStock
-- Description: Automatically decreases product quantity after sale
---------------------------------------------------------------
CREATE TRIGGER UpdateStock
ON SaleItems
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.Quantity = p.Quantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END
GO

---------------------------------------------------------------
-- TRIGGER: PreventNegativeStock
-- Description: Prevents stock from going below zero
---------------------------------------------------------------
CREATE TRIGGER PreventNegativeStock
ON SaleItems
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT *
        FROM Products p
        INNER JOIN inserted i ON p.ProductID = i.ProductID
        WHERE p.Quantity < 0
    )
    BEGIN
        PRINT 'Error: Stock not available';
        ROLLBACK TRANSACTION;
    END
END
GO

-- ************************************************************
-- *********************** SAMPLE DATA ************************
-- ************************************************************
-- Insert users
INSERT INTO Users (Username, Password) VALUES ('admin', '1234'), ('maryam', 'pass123'); 
-- Insert products
INSERT INTO Products (Name, Price, Quantity) VALUES ('Laptop', 85000, 10), ('Mouse', 1500, 50), ('Keyboard', 2500, 30), ('Mobile', 60000, 15), ('USB Cable', 500, 100);
-- Insert customers
INSERT INTO Customers (Name, Phone) VALUES ('Ali Khan', '03001234567'), ('Sara Ahmed', '03111222333'), ('Usman Ali', '03214567890');
-- Insert sales
INSERT INTO Sales (CustomerID, TotalAmount) VALUES (1, 87000), (2, 60000); 
-- Insert sale items 
INSERT INTO SaleItems (SaleID, ProductID, Quantity, Price) VALUES (1, 1, 1, 85000), (1, 2, 1, 1500), (2, 4, 1, 60000); 

