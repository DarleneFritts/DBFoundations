--*************************************************************************--
-- Title: Assignment06
-- Author: DFritts
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-08-12,DFritts,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DFritts')
	 Begin 
	  Alter Database [Assignment06DB_DFritts] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DFritts;
	 End
	Create Database Assignment06DB_DFritts;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DFritts;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for your  views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


Create View  vCategories
 With SCHEMABINDING
   As 
	Select CategoryID, CategoryName
	  From dbo.Categories;
Go 	  

Create View vProducts
With SCHEMABINDING
As 
 Select ProductID, ProductName, CategoryID, UnitPrice
 From dbo.Products;
Go

Create View vEmployees
  With SCHEMABINDING
  AS
    Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID 
	From dbo.Employees;
Go

Create View vInventories
With SCHEMABINDING
As 
	Select InventoryId, InventoryDate, EmployeeID, ProductID, [Count] 
	From dbo.Inventories;
Go 

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select Categories to Public;
Deny Select Products to Public;
Deny Select Employees to Public;
Deny Select Inventories to Public;
Go 

Grant Select On vCategories to Public;
Grant Select On vProducts to Public;
Grant Select On vEmployees to Public;
Grant Select On vInventories to Public;
Go 


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


Create View vProductsByCategories
AS
  SELECT Top 10000000
    C.CategoryName
  , P.ProductName
  , P.UnitPrice
  From vCategories as C
	   Inner Join vProducts as P
    ON C.CategoryID = P.CategoryID
Order By 1, 2, 3;
Go 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


Create View vInventoriesByProductsByDates
As 
 SELECT Top 10000000
   P.ProductName
 , I.InventoryDate
 , I.[Count]
From vProducts As P
Inner Join vInventories as I
ON P.ProductID = I.InventoryID
ORDER BY 1, 2, 3;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View vInventoriesByEmployeesByDates
As
 Select Distinct Top 1000000
    I.InventoryDate
  , E.EmployeeFirstName + ' ' + E.EmployeeLastName As EmployeeName
  From vInventories as I 
  Inner Join vEmployees as E 
   On I.EmployeeID =E.EmployeeID
Order By 1, 2;
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


Create View  vInventoriesByProductsByCategories
AS
  SELECT Top 100000000
   C.CategoryName
  , P.ProductName
  , I.InventoryDate 
  , I.Count 
   FROM vInventories as I
     Inner Join vEmployees as E
      On I.EmployeeID = E.EmployeeID
	  Inner Join vProducts as P 
	    On I.ProductID = P.ProductID
       Inner Join vCategories as C 
	    On P.CategoryID = C.CategoryID 
Order By 1, 2, 3, 4;
Go
    

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
As 
  Select Top 1000000
    C.CategoryName
  , P.ProductName
  , I.InventoryDate
  , I.COUNT
  , E.EmployeeFirstName + ' '+ E.EmployeeLastName As EmployeeName
  From vInventories as I 
   Inner Join vEmployees as E 
     On I.EmployeeId = E.EmployeeID
   Inner Join vProducts as P 
     On I.ProductID = P.ProductID
   Inner Join vCategories as C 
     On P.CategoryID = C.CategoryId
Order By 3,1, 2, 4;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
As 
Select Top 10000000
 C.CategoryName
  , P.ProductName
  , I.InventoryDate
  , I.COUNT
  , E.EmployeeFirstName + ' '+ E.EmployeeLastName As EmployeeName
  From vInventories as I 
   Inner Join vEmployees as E 
     On I.EmployeeId = E.EmployeeID
   Inner Join vProducts as P 
     On I.ProductID = P.ProductID
   Inner Join vCategories as C 
     On P.CategoryID = C.CategoryId
   Where I.ProductID in (Select ProductID From vProducts Where ProductName in ('Chai', 'Chang'))	 
Order By 3,1, 2, 4;
Go 

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!


Create View vEmployeesByManager
As
  SELECT Top 1000000
    M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
  , E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
FROM vEmployees As E
	INNER JOIN vEmployees AS M
	ON E.ManagerID = M.EmployeeID
ORDER BY 1,2;
Go 

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


Create View vInventoriesByProductsByCategoriesByEmployees
As 
Select Top 10000000
    C.CategoryID
  , C.CategoryName
  , P.ProductID
  , P.ProductName
  , P.UnitPrice
  , I.InventoryID
  , I.InventoryDate
  , I.[COUNT]
  , E.EmployeeID
  , E.EmployeeFirstName + ' '+ E.EmployeeLastName As Employee
  , E.EmployeeFirstName + ' '+ E.EmployeeLastName As Manager
From vCategories as C 
	Inner Join vProducts As P 
	 On P.CategoryID = C.CategoryID 
	Inner Join vInventories As I 
	 On P.ProductID = I.ProductID
	Inner Join vEmployees As E 
	 On I.EmployeeID = E.EmployeeID
	Inner Join vEmployees As M 
	 On E.ManagerID = M.EmployeeID
Order By 
1, 3, 6, 9;
Go


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/