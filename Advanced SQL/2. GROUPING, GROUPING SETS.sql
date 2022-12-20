/* EX 1
Using the Products table, display the maximum unit price of the available products
(UnitPrice).
*/

SELECT MAX(UNITPRICE) AS MAXUNITPRICE FROM PRODUCTS 

/* EX 2
Using the Products and Categories tables, display the sum of the product values ​​in the warehouse
(UnitPrice * UnitsInStock) divided into categories (in the result, include the name of the category and
products assigned to a certain category). Sort the result by category (ascending).
*/

SELECT	C.CategoryName, 
		SUM(P.UnitPrice * P.UnitsInStock) AS Expr1
FROM  Products AS P 
INNER JOIN Categories AS C ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName
ORDER BY C.CategoryName

/* EX 3 
Extend the query from task 2 so that only the categories for which are presented
the value of products exceeds 10000. Sort the result descending by product value.
*/

SELECT C.CATEGORYNAME
,SUM(P.UNITPRICE * P.UNITSINSTOCK) AS SUMVALUE
FROM PRODUCTS AS P 
JOIN CATEGORIES C ON C.CATEGORYID = P.CATEGORYID
GROUP BY CATEGORYNAME 
HAVING SUM(P.UNITPRICE * P.UNITSINSTOCK) > 10000
ORDER BY SUMVALUE DESC

/* EX 4
Using the Suppliers, Products and Order Details tables, display information on how many unique ones
orders appeared products of a given supplier. Sort the results alphabetically by namesupplier.
*/

SELECT S.COMPANYNAME
,COUNT(DISTINCT OD.ORDERID) AS ORDERS_NUMBER
FROM SUPPLIERS S 
JOIN PRODUCTS P ON S.SUPPLIERID = P.SUPPLIERID
JOIN [ORDER DETAILS] OD ON OD.PRODUCTID = P.PRODUCTID  
GROUP BY S.COMPANYNAME 

/* EX 5 
Using the Orders, Customers, and Order Details tables, show the average, minimum, and
the maximum value of the order (rounded to two decimal places, without taking into account
discounts) for each customer (Customers.CustomerID). Sort the results according to the average value
orders - descending. Remember to keep the average, minimum and maximum order value
calculated based on its value, i.e. the sum of the products of unit prices and the size of the order.
*/

;WITH ORDERS_AVG AS (
		SELECT OD.ORDERID
		,SUM(OD.UNITPRICE * OD.QUANTITY) AS ORDER_LEVEL_AVG
		FROM [ORDER DETAILS] OD GROUP BY OD.ORDERID
)

	SELECT O.CUSTOMERID
	,AVG(OD2.ORDER_LEVEL_AVG) AS AVG_ORDERS
	,MIN(OD2.ORDER_LEVEL_AVG) AS MIN_ORDERS
	,MAX(OD2.ORDER_LEVEL_AVG) AS MAX_ORDERS

FROM ORDERS O 
JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID 
JOIN ORDERS_AVG OD2 ON OD2.ORDERID = O.ORDERID 
GROUP BY O.CUSTOMERID
ORDER BY AVG_ORDERS DESC

/* EX 6
Using the Orders table, display the dates (OrderDate) where there was more than one order
taking into account the exact number of orders. Display the order date in the format YYYY-MM-DD. 
Result sort descending by number of orders.
*/

SELECT  CONVERT(CHAR(10), ORDERDATE, 126) AS ORDERDATE, 
		COUNT(ORDERID) AS CNT
FROM ORDERS
GROUP BY CONVERT(CHAR(10), ORDERDATE, 126)
HAVING COUNT(ORDERID) > 1 
ORDER BY CNT DESC

/*EX 7 
Using the Orders table, analyze the number of orders in 3 dimensions: Year and month, year and
overall summary. Sort the result by "Year-Month" (descending).
*/

SELECT	
		FORMAT(ORDERDATE, 'YYYY') AS 'YEAR'
		,FORMAT(ORDERDATE, 'YYYY-MM') AS 'YEAR-MONTH'
		,COUNT(ORDERID) AS CNT
FROM ORDERS 
GROUP BY ROLLUP (FORMAT(ORDERDATE, 'YYYY'), FORMAT(ORDERDATE, 'YYYY-MM'))
ORDER BY 'YEAR-MONTH' DESC

/* EX 8
Using the Orders table, I analyze the number of orders due to the dimensions:
	• Country, region and city of delivery
	• Country and region of delivery
	• Country of delivery
	• Summary
Add a GroupingLevel column to explain the grouping level that's for each dimension
will assume the following values:
	• Country & Region & City
	• Country & Region
	• Country
	• Total
The region field may have empty values ​​- mark such values ​​as "Not Provided"
Sort the result alphabetically according to the country of delivery.
*/

SELECT  
		SHIPCOUNTRY
		,CASE 
			WHEN GROUPING(SHIPREGION) = 0 AND SHIPREGION IS NULL 
				THEN 'NOT PROVIDED'
			ELSE SHIPREGION
			END AS SHIPREGION
		,SHIPCITY 
		,COUNT(*) AS CNT
		,CASE GROUPING_ID (SHIPCOUNTRY, SHIPREGION, SHIPCITY )
			WHEN 3 THEN 'COUNTRY'
			WHEN 1 THEN 'COUNTRY & REGION'
			WHEN 0 THEN 'COUNTRY & REGION & CITY'
			WHEN 7 THEN 'TOTAL'
		END AS GROUPINGLEVEL
FROM ORDERS 
GROUP BY  ROLLUP (SHIPCOUNTRY, SHIPREGION, SHIPCITY)

/* EX 9 
Using the tables Orders, Order Details, Customers, present an analysis of the sum of the value of orders (without
discount) as a full analysis (all combinations) of dimensions:
	• Year (Order.OrderDate)
	• Customer (Customers.CompanyName)
	• Overall summary
Include only records that have all the required information (no joins needed
external). Sort the result by customer name (alphabetically).
*/

SELECT 
	FORMAT(O.ORDERDATE, 'YYYY') AS 'YEAR'
	,C.COMPANYNAME
	,SUM(OD.UNITPRICE * OD.QUANTITY)
FROM ORDERS AS O
JOIN CUSTOMERS AS C ON C.CUSTOMERID = O.CUSTOMERID
JOIN [ORDER DETAILS] AS OD ON OD.ORDERID = O.ORDERID
GROUP BY GROUPING SETS (FORMAT(O.ORDERDATE, 'YYYY'), C.COMPANYNAME, (FORMAT(O.ORDERDATE, 'YYYY'), C.COMPANYNAME),()) 
ORDER BY C.COMPANYNAME, 'YEAR' ASC

/*EX 10
Modify the query created in exercise 9 to include the country instead of the name
(Customers.Country) and region (Customers.Region) of the customer (the dimension should consist of two: country
and region; summary should not be counted separately for country and region). 
Sort the results by country name (alphabetically).
*/

SELECT 
	FORMAT(O.ORDERDATE, 'YYYY') AS 'YEAR'
	,C.COUNTRY
	,C.REGION
	,SUM(OD.UNITPRICE * OD.QUANTITY)
FROM ORDERS AS O
JOIN CUSTOMERS AS C ON C.CUSTOMERID = O.CUSTOMERID
JOIN [ORDER DETAILS] AS OD ON OD.ORDERID = O.ORDERID
GROUP BY 
	GROUPING SETS	(FORMAT(O.ORDERDATE, 'YYYY'), 
					(FORMAT(O.ORDERDATE, 'YYYY'), C.COUNTRY, C.REGION),
					(C.COUNTRY, C.REGION),
					()) 
ORDER BY C.COUNTRY, 'YEAR' ASC

/*EX 11
Use the Orders, Orders Details, Customers, Products, Suppliers, and Categories tables to represent
analysis of the total value of orders (without discounts) for specific dimensions:
	• Categories (Cateogires.CategoryName)
	• Supplier country (Suppliers.Country)
	• Customer country and region (Customers.Country, Customers.Region)
Dimensions consisting of more than one attribute should be treated as a whole (no
groupings for subsets). Don't generate additional summaries - include them carefully
dimensions listed above.
Add a GroupingLevel field to the result explaining the level of grouping that will take the values
respectively for individual dimensions:
	• Category
	• Country-Supplier
	• Country & Region - Customer
Sort the result alphabetically first by GroupingLevel column (ascending) and then
after the column with the sum of the order values ​​OrdersValue (descending).
*/

SELECT 
	   CAT.CATEGORYNAME,
       S.COUNTRY,
       C.COUNTRY,
       C.REGION,
       CAST(SUM(OD.QUANTITY * OD.UNITPRICE) AS DECIMAL(10, 2)) AS ORDERS_VALUE,
       CASE GROUPING_ID(CAT.CATEGORYNAME,
                        S.COUNTRY,
                        C.COUNTRY,
                        C.REGION)
           WHEN 7 THEN 'CATEGORY'
           WHEN 11 THEN 'COUNTRY - SUPPLIER'
           WHEN 12 THEN 'COUNTRY & REGION - CUSTOMER'
           END AS GROUPINGLEVEL
FROM ORDERS O
JOIN [ORDER DETAILS] OD ON O.ORDERID = OD.ORDERID
JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID
JOIN PRODUCTS P ON OD.PRODUCTID = P.PRODUCTID
JOIN CATEGORIES CAT ON P.CATEGORYID = CAT.CATEGORYID
JOIN SUPPLIERS S ON P.SUPPLIERID = S.SUPPLIERID
GROUP BY GROUPING SETS ((CAT.CATEGORYNAME), (S.COUNTRY), (C.COUNTRY, C.REGION))
ORDER BY GROUPINGLEVEL, SUM(OD.QUANTITY * OD.UNITPRICE) DESC;

/*EX 12 
Using the Orders and Shippers tables, present a table containing the number of completed orders
to a given country (ShipCountry) by a given transport company. Enter the country of delivery as the rows a
as supplier columns. Sort the result by the name of the country of delivery (alphabetically).
*/

SELECT [SHIPCOUNTRY],  [FEDERAL SHIPPING], [SPEEDY EXPRESS], [UNITED PACKAGE]
FROM (
SELECT 
	O.SHIPCOUNTRY AS SHIPCOUNTRY
	,S.COMPANYNAME AS COMPANYNAME
	,O.ORDERID AS ORDERID
FROM ORDERS AS O
INNER JOIN SHIPPERS AS S ON S.SHIPPERID = O.SHIPVIA) S
PIVOT ( COUNT(S.ORDERID)
	FOR COMPANYNAME IN ([FEDERAL SHIPPING], [SPEEDY EXPRESS], [UNITED PACKAGE] ) )AS AMT

/* EX 13
Including the Order Details table, update the previous query so that instead of a number
completed orders, the sum of the value of orders handled by a given company appeared
freight forwarded to your country.
*/

SELECT [SHIPCOUNTRY],  [FEDERAL SHIPPING], [SPEEDY EXPRESS], [UNITED PACKAGE]
FROM (
SELECT 
	O.SHIPCOUNTRY AS SHIPCOUNTRY
	,S.COMPANYNAME AS COMPANYNAME
	--,O.ORDERID AS ORDERID
	,(OD.QUANTITY * OD.UNITPRICE) AS ORDERVALUE
FROM ORDERS AS O
INNER JOIN SHIPPERS AS S ON S.SHIPPERID = O.SHIPVIA
INNER JOIN [ORDER DETAILS] AS OD ON OD.ORDERID = O.ORDERID

) S
PIVOT ( SUM(S.ORDERVALUE)
	FOR COMPANYNAME IN ([FEDERAL SHIPPING], [SPEEDY EXPRESS], [UNITED PACKAGE] ) )AS AMT
ORDER BY SHIPCOUNTRY


