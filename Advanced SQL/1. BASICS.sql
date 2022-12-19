/*
BASICS




EX1
Using the Products and Categories tables, display the product name (ProductS.ProductName) 
and the name of the category (CategorieS.CategoryName) to which the product belongS.
Sort by product name (AScending). 
*/

SELECT      P.ProductName, 
			C.CategoryName
FROM         Products AS P 
INNER JOIN   Categories AS C ON C.CategoryID = P.CategoryID
ORDER BY P.ProductName

/*
EX2

Using the Suppliers table, expand the previous one so AS to also present the supplier name
of a given product (CompanyName) - name the column SupplierNamE.
Sort by the product unit price (descending).
*/

SELECT      P.ProductName, 
			C.CategoryName, 
			S.CompanyName AS SupplierName

FROM Products AS P 
INNER JOIN  Categories AS C ON C.CategoryID = P.CategoryID 
INNER JOIN  Suppliers AS S ON S.SupplierID = P.SupplierID
ORDER BY P.UnitPrice desc

/*
EX3

Using the Products table, display the product names (ProductName) with the highest unit price in a given category (UnitPrice).
Sort by product name (AScending).
*/

--1ST
WITH TEMP AS (
				SELECT	  CategoryID, MAX(UnitPrice) AS MaxUnitPricePerCategory
				FROM	  Products AS P
				GROUP BY  CategoryID
)

SELECT        P.ProductName, 
			  T.MaxUnitPricePerCategory
FROM          Products AS P 
INNER JOIN    TEMP AS T ON T.CategoryID = P.CategoryID AND T.MaxUnitPricePerCategory = P.UnitPrice
ORDER BY      P.ProductName


--2ND
SELECT 	P1.productname, 
		P1.UnitPrice 
FROM  Products AS P1 
WHERE UnitPrice = (SELECT MAX(P2.UnitPrice) FROM Products AS P2 WHERE P1.CategoryID = P2.CategoryID)

/*
EX4

Using the Products table, display the names of products whose unit price is higher than all 
average product prices calculated for other categories (other than the one to which the product belongs).
Sort by unit price (descending).

*/
SELECT        P.ProductName
FROM          Products AS P
WHERE        (UnitPrice > ALL
                             (SELECT AVG(UnitPrice) AS Expr1
                               FROM  Products AS P2
                               WHERE (P.CategoryID <> CategoryID)
                               GROUP BY CategoryID))
ORDER BY P.UnitPrice DESC

/* 
EX5 

Using the Order Details table, expand the previous query to also 
display the maximum quantity ordered (Quantity) of a given product in one order (in a given OrderID).
*/

SELECT      P.ProductName
			,MAX(O.Quantity) AS MaxQuantityPerOrder
FROM        Products AS P 
			INNER JOIN [Order Details] AS O ON O.ProductID = P.ProductID
WHERE       (P.UnitPrice > ALL
                             (SELECT AVG(UnitPrice) AS Expr1
                               FROM Products AS P2
                               WHERE (P.CategoryID <> CategoryID)
                               GROUP BY CategoryID))
GROUP BY P.ProductName    

/* 
EX 6.  

Using the Products and Order Details tables, display the category IDs (CategoryID) and the sum of all 
order values of products in a given category ([Order Details].UnitPrice * [Order Details].Quantity) without discount. 
The result should contain only those categories for which the above the sum is greater than 200,000.
Sort the result by the sum of the order values (descending).
*/

SELECT  P.CategoryID, 
		SUM(O.UnitPrice * O.Quantity) AS Expr1
FROM Products AS P INNER JOIN [Order Details] AS O ON O.ProductID = P.ProductID
GROUP BY P.CategoryID
HAVING (SUM(O.UnitPrice * O.Quantity) > 200000)


/* 
EX 7

Using the Categories table, update the previous query to return the category name in addition to the category ID.
*/

SELECT      P.CategoryID, 
			C.CategoryName, 
			SUM(O.UnitPrice * O.Quantity) AS Value
FROM Products AS P 
INNER JOIN [Order Details] AS O ON O.ProductID = P.ProductID 
INNER JOIN Categories AS C ON C.CategoryID = P.CategoryID
GROUP BY P.CategoryID, C.CategoryName
HAVING (SUM(O.UnitPrice * O.Quantity) > 200000)




/* 
EX 8

Using the tables Orders and Employees, display the number of orders that have been shipped (ShipRegion) to regions other than those handled 
by the employee Robert King (FirstName -> Robert; LAStName -> King).
*/

SELECT COUNT(*) AS Expr1
FROM Orders AS O
WHERE        (NOT EXISTS
                             (SELECT        1
                               FROM         Orders AS O2 INNER JOIN
                                            Employees AS E ON E.EmployeeID = O2.EmployeeID
                               WHERE        (O2.ShipRegion = O.ShipRegion) AND (E.FirstName = 'Robert') AND (E.LAStName = 'King')))

/*
EX 9

Using the Orders table, display all shipping countries (ShipCountry) for which there are records (orders) that have a filled value in 
the ShipRegion field AS well AS records with a NULL value.
*/

--1ST
WITH TEMP AS (SELECT distinct ShipCountry FROM Orders WHERE  ShipRegion IS NULL) 
SELECT ShipCountry FROM TEMP WHERE ShipCountry IN (SELECT distinct ShipCountry FROM Orders WHERE  ShipRegion IS NOT NULL) 

--2ND
SELECT distinct ShipCountry FROM Orders WHERE  ShipRegion IS NULL
INTERSECT
SELECT distinct ShipCountry FROM Orders WHERE  ShipRegion IS NOT NULL


/*
EX 10

Using the appropriate tables, display the product ID (Products.ProductID), product name (Products.ProductName), 
country and city of supplier (Suppliers.Country, Suppliers.City - name them respectively: SupplierCountry and SupplierCity) 
and country and city of delivery of a given product ( Orders.ShipCountry, Orders.ShipCity). Limit the score to products that have been shipped at leASt once to the same country AS their supplier. 
In addition, extend the result with information whether, in addition to the country, the city where the product supplier is bASed also matches the city to which the product wAS shipped - name the column FullMatch, which will ASsume Y/N values.
Sort the result so that the alphabetically sorted products for which there is a full match are displayed first.
*/

SELECT DISTINCT 
P.ProductID
,P.ProductName
,S.Country AS SupplierCountry
,S.City AS SupplierCity
,O.ShipCountry
,O.ShipCity
,CASE 
	WHEN O.ShipCity = S.City and O.shipcountry = S.Country
	THEN 'Y' 
	ELSE 'N' END AS FullMatch

FROM Products AS P 
INNER JOIN Suppliers AS S ON S.SupplierID = P.SupplierID 
INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID 
INNER JOIN Orders AS O ON OD.OrderID = O.OrderID AND S.Country = O.ShipCountry
ORDER BY FullMatch DESC, P.ProductName

/*
EX 11 

Expand the previous query to also take into account the region from which the delivery comes and the region of shipment. The FullMatch column should have the following set of values:
• Y – for full agreement of three values
• N (the region doesn't match) - for country and city match, but not region
• N – for non-compliance
Also add the fields containing the region to the result: Suppliers.Region (name them SupplierRegion) and Orders.ShipRegion)
*/

SELECT distinct
P.ProductID
,P.ProductName
,S.Country AS SupplierCountry
,S.City AS SupplierCity
,S.Region AS SupplierRegion
,O.ShipCountry
,O.ShipCity
,O.ShipRegion
, CASE 
	WHEN O.ShipCity = S.City and O.shipcountry = S.Country and ((O.ShipRegion = S.Region  ) or (S.Region IS NULL and O.shipregion IS NULL)) THEN 'Y'
	WHEN O.ShipCity = S.City and O.shipcountry = S.Country THEN 'N (the region doesnt match)'
	ELSE 'N'
	END AS FullMatch

FROM Products AS P
JOIN Suppliers AS S ON S.SupplierID = P.SupplierID
JOIN [Order Details] OD ON P.ProductID = OD.ProductID
JOIN Orders O ON OD.orderid = O.OrderID
WHERE S.Country = O.ShipCountry 
ORDER BY FullMatch desc, P.ProductName ASC   

/*
EX 12  

Use the Products table to verify that there are two (or more) products with the same name. 
The query should return either Yes or No in the DuplicatedProductsFlag column.
*/

WITH Temp AS 
			(SELECT ProductName, 
					COUNT(*) AS Cnt
			FROM    Products
			GROUP BY ProductName)

SELECT  
	CASE WHEN MAX(Temp.cnt) > 1 
	THEN 'Yes' 
	ELSE 'No' END AS DuplicatedProductsFlag
FROM Temp

/*
EX 13 

Using the Products and Order Details tables, display the names of the products along with information on how many orders the given products appeared on.
Sort the result so that the products that appear on orders most often appear first.
*/

;WITH Temp AS (
SELECT ProductID, 
		Count(Orderid) AS Cnt
FROM [Order Details] 
GROUP BY Productid
)

SELECT 
	P.ProductName 
	,Temp.Cnt 
	FROM Temp 
JOIN Products AS P ON P.ProductID = TemP.ProductID ORDER BY cnt DESC



/*
EX 14 

Using the Orders table, expand the previous query so that the above analysis is presented 
in the context of individual years (Orders.OrderDate) - name the column OrderYear.
This time, sort the result so that the products most often appearing on orders in the context of a given year are 
displayed first, i.e. we are first interested in the year: 1996, then 1997, etc.
*/

;WITH Temp AS (
		SELECT OD.ProductID 
		,year(O.OrderDate) AS OrderYear
		,count(OD.orderid) AS Cnt

FROM [Order Details] AS OD
JOIN Orders AS O ON  O.OrderID = od.OrderID
GROUP BY Productid, year(O.OrderDate)
)

SELECT 
	P.ProductName 
	,TemP.OrderYear
	,TemP.cnt FROM Temp 
JOIN Products AS P ON P.ProductID = Temp.ProductID ORDER BY OrderYear ASC, cnt DESC 



/*
EX 15 

Using the Suppliers table, expand the query so that for each product, you can additionally display the name of the supplier 
of a given product (Suppliers.CompanyName) - name the column SupplierName.
*/
;WITH Temp AS (
		SELECT od.ProductID 
		,year(O.OrderDate) AS OrderYear
		,count(od.orderid) AS Cnt

FROM [Order Details] AS OD
JOIN Orders AS O ON  O.OrderID = od.OrderID
GROUP BY Productid, year(O.OrderDate)
)

SELECT 
	P.ProductName 
	,S.CompanyName AS SupplierName
	,TemP.OrderYear
	,TemP.cnt FROM Temp 
JOIN Products AS P ON P.ProductID = TemP.ProductID 
JOIN Suppliers AS S ON P.SupplierID = S.SupplierID
ORDER BY OrderYear ASc, cnt desc 

