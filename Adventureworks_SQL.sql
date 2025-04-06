USE AdventureWorks2022;
GO
DROP TABLE IF EXISTS dbo.FactSalesOrderDetail;
DROP TABLE IF EXISTS dbo.FactProduccion;

-- Eliminar las tablas de dimensiones
DROP TABLE IF EXISTS dbo.DimFecha;
DROP TABLE IF EXISTS dbo.DimProducto;
DROP TABLE IF EXISTS dbo.DimCliente;
DROP TABLE IF EXISTS dbo.DimTerritorio;
DROP TABLE IF EXISTS dbo.DimPromocion;

USE AdventureWorks2022;
GO

-- Crear tabla de dimensión Fecha
CREATE TABLE dbo.DimFecha (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    FiscalYear INT NOT NULL,
    WeekOfYear INT NOT NULL,
    DayOfWeek INT NOT NULL,
    DayOfWeekName NVARCHAR(20) NOT NULL
);

-- Creo los datos para la tabla de dimensión Fecha
DECLARE @StartDate DATE = '2000-01-01';  
DECLARE @EndDate DATE = '2030-12-31';  
DECLARE @CurrentDate DATE = @StartDate;  

WHILE @CurrentDate <= @EndDate  
BEGIN  
    INSERT INTO dbo.DimFecha (  
        DateKey,  
        FullDate,  
        Day,  
        Month,  
        MonthName,  
        Year,  
        Quarter,  
        FiscalYear,  
        WeekOfYear,  
        DayOfWeek,  
        DayOfWeekName
    )  
    VALUES (  
        YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
        @CurrentDate,  
        DAY(@CurrentDate),  
        MONTH(@CurrentDate),  
        DATENAME(MONTH, @CurrentDate),  
        YEAR(@CurrentDate),  
        DATEPART(QUARTER, @CurrentDate),  
        CASE WHEN MONTH(@CurrentDate) >= 7 THEN YEAR(@CurrentDate) + 1 ELSE YEAR(@CurrentDate) END,  
        DATEPART(WEEK, @CurrentDate),  
        DATEPART(WEEKDAY, @CurrentDate),  
        DATENAME(WEEKDAY, @CurrentDate)  
    );  

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);  
END;

-- Crear tabla de dimensión Producto
CREATE TABLE dbo.DimProducto (
    ProductKey INT PRIMARY KEY,
    ProductName NVARCHAR(255),
    ProductSubcategory NVARCHAR(255),
    ProductCategory NVARCHAR(255),
    StandardCost DECIMAL(10,2)
);

-- Inserto datos en la tabla de dimensión Producto
INSERT INTO dbo.DimProducto (ProductKey, ProductName, ProductSubcategory, ProductCategory, StandardCost)
SELECT
    p.ProductID,
    p.Name,
    ISNULL(ps.Name, 'Sin Subcategoría'),
    ISNULL(pc.Name, 'Sin Categoría'),
    p.StandardCost
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

-- Crear tabla de dimensión Cliente
CREATE TABLE dbo.DimCliente (
    CustomerKey INT PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    EmailAddress NVARCHAR(255),
    Phone NVARCHAR(50),
    Gender NVARCHAR(20),
    TotalCompras INT,
    ImporteTotal DECIMAL(18, 2)
);

-- Inserto datos en la tabla de dimensión Cliente
INSERT INTO dbo.DimCliente (CustomerKey, FirstName, LastName, EmailAddress, Phone, Gender, TotalCompras, ImporteTotal)
SELECT
    c.CustomerID,
    ISNULL(p.FirstName, 'No Definido'),
    ISNULL(p.LastName, 'No Definido'),
    ISNULL(e.EmailAddress, 'No Definido'),
    ISNULL(pp.PhoneNumber, 'No Definido'),
    CASE 
        WHEN p.Title LIKE 'Mr%' THEN 'Hombre'
        WHEN p.Title LIKE 'Mrs%' OR p.Title LIKE 'Ms%' THEN 'Mujer'
        ELSE 'No especificado'
    END,
    0,
    0.00
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID;

-- Completar con clientes de SalesOrderHeader que no estén en la tabla
INSERT INTO dbo.DimCliente (CustomerKey, FirstName, LastName, EmailAddress, Phone, Gender, TotalCompras, ImporteTotal)
SELECT DISTINCT 
    soh.CustomerID,
    'Desconocido',
    'Desconocido',
    'Desconocido',
    'Desconocido',
    'N/A',
    0,
    0.00
FROM Sales.SalesOrderHeader soh
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimCliente dc WHERE dc.CustomerKey = soh.CustomerID
);

-- Actualizar datos de compras en DimCliente
UPDATE dbo.DimCliente
SET TotalCompras = TotalCompras.Cantidad,
    ImporteTotal = TotalCompras.Total
FROM dbo.DimCliente
JOIN (
    SELECT 
        CustomerID,
        COUNT(SalesOrderID) AS Cantidad,
        SUM(TotalDue) AS Total
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
) AS TotalCompras ON dbo.DimCliente.CustomerKey = TotalCompras.CustomerID;

-- Crear tabla de dimensión Territorio
CREATE TABLE dbo.DimTerritorio (
    TerritoryKey INT PRIMARY KEY,
    CountryRegionCode NVARCHAR(10),
    TerritoryGroup NVARCHAR(50)
);

-- Inserto datos en la tabla de dimensión Territorio
INSERT INTO dbo.DimTerritorio (TerritoryKey, CountryRegionCode, TerritoryGroup)
SELECT 
    TerritoryID, 
    CountryRegionCode, 
    [Group]
FROM Sales.SalesTerritory;

-- Crear tabla de dimensión Promoción
CREATE TABLE dbo.DimPromocion (
    PromotionKey INT PRIMARY KEY,
    PromotionName NVARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    DiscountPct DECIMAL(5,2),
    Description NVARCHAR(MAX)
);

-- Inserto datos en la tabla de dimensión Promoción
INSERT INTO dbo.DimPromocion (PromotionKey, PromotionName, StartDate, EndDate, DiscountPct, Description)
SELECT
    SpecialOfferID,
    Description,
    StartDate,
    EndDate,
    DiscountPct,
    Description
FROM Sales.SpecialOffer;

-- Crear tabla de hechos 
CREATE TABLE dbo.FactSalesOrderDetail (
    SalesOrderDetailKey INT IDENTITY(1,1) PRIMARY KEY,  
    OrderDateKey INT,               
    CustomerKey INT,                
    TerritoryKey INT,               
    ProductKey INT,                 
    PromotionKey INT,               
    ShipDateKey INT,                
    OrderQty INT,                   
    UnitPrice DECIMAL(10,2),        
    UnitPriceDiscount DECIMAL(10,2),
    LineTotal DECIMAL(18,2),
    StandardCost DECIMAL(10,2),     
    ProductCost DECIMAL(10,2),      
    GrossProfit DECIMAL(18,2),      
    ProfitMargin DECIMAL(5,2),      
    CreditCardID INT,               
    CreditCardType NVARCHAR(50),
    ShippingDays INT     
);

-- Inserto datos en la tabla de hechos FactSalesOrderDetail
INSERT INTO dbo.FactSalesOrderDetail (
    OrderDateKey,
    CustomerKey,
    TerritoryKey,
    ProductKey,
    PromotionKey,
    ShipDateKey,
    OrderQty,
    UnitPrice,
    UnitPriceDiscount,
    LineTotal,
    StandardCost,
    ProductCost,
    GrossProfit,
    ProfitMargin,
    CreditCardID,
    CreditCardType,
    ShippingDays
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR, soh.OrderDate, 112)) AS OrderDateKey, 
    soh.CustomerID, 
    soh.TerritoryID,  
    sod.ProductID,  
    sod.SpecialOfferID,  
    CONVERT(INT, CONVERT(VARCHAR, soh.ShipDate, 112)) AS ShipDateKey,
    sod.OrderQty,  
    sod.UnitPrice,  
    sod.UnitPriceDiscount,  
    (sod.OrderQty * sod.UnitPrice) - (sod.OrderQty * sod.UnitPriceDiscount) AS LineTotal,
    
    -- Métricas financieras
    p.StandardCost,
    p.StandardCost * sod.OrderQty AS ProductCost,
    (sod.OrderQty * sod.UnitPrice) - (p.StandardCost * sod.OrderQty) AS GrossProfit,
    CASE 
        WHEN sod.UnitPrice > 0 
        THEN ROUND(((sod.UnitPrice - p.StandardCost) / sod.UnitPrice) * 100, 2)
        ELSE NULL 
    END AS ProfitMargin,
    soh.CreditCardID,
    cc.CardType AS CreditCardType,
    
    -- Días de envío
    DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) AS ShippingDays

FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
LEFT JOIN Production.Product p ON sod.ProductID = p.ProductID
LEFT JOIN Sales.CreditCard cc ON soh.CreditCardID = cc.CreditCardID;