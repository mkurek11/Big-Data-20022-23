/*EX1
Using the Products table, design a query that returns the average unit price of all products. 
Round the result to two decimal places.
*/ 

SELECT AVG(UNITPRICE) AS AVGUNITPRICE  FROM PRODUCTS 

/*EX2
Using the Products and Categories tables, design a query that returns the name of the category and the average unit price of products in that category. 
Round the average to two decimal places. Sort the result alphabetically by category name.
*/ 

SELECT DISTINCT C.CATEGORYNAME, 
	   AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME) AS AVGUNITPRICE
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 

SELECT C.CATEGORYNAME, 
       AVG(P.UNITPRICE) AS AVGUNITPRICE
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
GROUP BY C.CATEGORYNAME

/*EX3
Using the Products and Categories tables, design a query that will return all products (ProductName) along with the categories they 
belong to (CategoryName) and the average unit price for all products. The analysis should include products from all categories except Beverages. 
Sort the result alphabetically by product name.
*/ 

SELECT 
P.PRODUCTNAME, 
C.CATEGORYNAME,
--AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME)
ROUND(AVG(P.UNITPRICE) OVER (),2) AS AVGUNITPRICE
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
WHERE C.CATEGORYNAME NOT IN ('BEVERAGES') 
ORDER BY P.PRODUCTNAME

/*EX4
Extend the previous inquiry with the minimum and maximum unit price for all products. 
This time we are interested in all products (remove the category restriction).
*/ 

SELECT 
P.PRODUCTNAME, 
C.CATEGORYNAME,
ROUND(AVG(P.UNITPRICE) OVER (),2) AS AVGUNITPRICE,
ROUND(MIN(P.UNITPRICE) OVER (),2) AS MINUNITPRICE,
ROUND(MAX(P.UNITPRICE) OVER (),2) AS MAXUNITPRICE
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
ORDER BY P.PRODUCTNAME

/*EX5
Extend the previous query with the average unit price in the category and for the given supplier.
*/

SELECT 
P.PRODUCTNAME, 
C.CATEGORYNAME,
ROUND(AVG(P.UNITPRICE) OVER (),2) AS AVGUNITPRICE,
ROUND(MIN(P.UNITPRICE) OVER (),2) AS MINUNITPRICE,
ROUND(MAX(P.UNITPRICE) OVER (),2) AS MAXUNITPRICE,
ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME),2) AS AVGUNITPRICEINCATEGORY,
ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY P.SUPPLIERID),2) AS AVGUNITPRICEINSUPPLIER
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
ORDER BY P.PRODUCTNAME

/*EX6
Expand the previous query with the number of products in a given category.
*/

SELECT 
P.PRODUCTNAME, 
C.CATEGORYNAME,
ROUND(AVG(P.UNITPRICE) OVER (),2) AS AVGUNITPRICE,
ROUND(MIN(P.UNITPRICE) OVER (),2) AS MINUNITPRICE,
ROUND(MAX(P.UNITPRICE) OVER (),2) AS MAXUNITPRICE,
ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME),2) AS AVGUNITPRICEINCATEGORY,
ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY P.SUPPLIERID),2) AS AVGUNITPRICEINSUPPLIER,
COUNT(C.CATEGORYID) OVER (PARTITION BY C.CATEGORYNAME) AS NUMOFPRODUCTS
FROM PRODUCTS AS P 
JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
ORDER BY P.PRODUCTNAME

/*EX7
Using the Orders and Customers tables, prepare a query that displays the order ID (OrderID), 
customer name (CompanyName) and record number. 
Record numbering should be in accordance with the date of the order sorted in ascending order. Sort the results by order ID (ascending).
*/

SELECT 
O.ORDERID,
C.COMPANYNAME,
ROW_NUMBER() OVER (ORDER BY O.ORDERDATE ASC) AS ROWNUM
FROM ORDERS AS O 
JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID 

/*EX8
Update the previous query so that the result is sorted first by customer name (ascending) and then by order date (descending).
*/

SELECT 
O.ORDERID,
C.COMPANYNAME,
ROW_NUMBER() OVER (ORDER BY O.ORDERDATE ASC) AS ROWNUM
FROM ORDERS AS O 
JOIN CUSTOMERS C ON O.CUSTOMERID = C.CUSTOMERID 
ORDER BY C.COMPANYNAME ASC, O.ORDERDATE DESC

/*EX9
Using the Products and Categories tables, design a query that includes paging (designated in ascending order after the product ID) 
that will display the desired page containing information about the products: ID, product name, category name, product unit price, 
average product price per unit in a given category, and number page (line number should not be displayed). Page size and page number 
should be parameterizable. The result (after taking into account paging!) should be sorted by product name (alphabetically, ascending).
*/

DECLARE 
	@PAGENUM AS INT = 3,
	@PAGESIZE AS INT = 15;

WITH TEMP AS (
	SELECT 
	P.PRODUCTID,
	P.PRODUCTNAME,
	C.CATEGORYNAME,
	P.UNITPRICE,
	ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME), 2 ) AS AVGUNITPRICEINCATEGORY, 
	ROW_NUMBER() OVER (ORDER BY P.PRODUCTID) AS ROWNUM
	FROM PRODUCTS AS P 
	JOIN CATEGORIES AS C ON P.CATEGORYID = C.CATEGORYID
)
SELECT
	PRODUCTID,
	PRODUCTNAME,
	CATEGORYNAME,
	UNITPRICE,
	AVGUNITPRICEINCATEGORY,
	@PAGENUM AS PAGENUM
FROM TEMP WHERE ROWNUM BETWEEN (@PAGENUM - 1) * @PAGESIZE + 1 AND @PAGENUM * @PAGESIZE
ORDER BY PRODUCTNAME ASC 

/*EX10
Using the Products and Categories tables and analytical functions, create a ranking of the most expensive (by unit price)
5 products in a given category. For products with the same value in the last position, include all of them. 
If it was in the previous positions, then each of the products is counted separately. Sort the results by category (ascending) and place in the ranking (ascending).
*/

WITH TEMP AS (
	SELECT 
	P.PRODUCTID,
	P.PRODUCTNAME,
	C.CATEGORYNAME,
	P.UNITPRICE,
	RANK () OVER (PARTITION BY C.CATEGORYNAME ORDER BY P.UNITPRICE DESC  ) AS RANK
FROM PRODUCTS AS P JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
)
SELECT * FROM TEMP WHERE RANK < 6

/*EX11
Now try to solve the problem below, which we used to solve using CTE, taking into account analytical functions. In this case, you can also (you don't have to!) use a CTE.
Using the Products and Order Details tables, display all product IDs (Products.ProductID) and product names (Products.ProductName) whose maximum order value without discount (UnitPrice*Quantity)
is less than the average for the category. In other words, there is no order value greater than the average order value in the category to which the Product belongs.
Sort the result in ascending order by product ID
*/

WITH TEMP AS (
SELECT 
P.PRODUCTID,
P.PRODUCTNAME,
MAX(O.UNITPRICE * O.QUANTITY) OVER (PARTITION BY P.PRODUCTID) AS MAX1,
AVG(O.UNITPRICE * O.QUANTITY) OVER (PARTITION BY P.CATEGORYID ) AS AVG1

FROM PRODUCTS P JOIN [ORDER DETAILS] O ON P.PRODUCTID = O.PRODUCTID  
) 

SELECT DISTINCT PRODUCTID, PRODUCTNAME FROM TEMP WHERE MAX1 < AVG1

/*EX12
Using the Products and Categories tables, display the product ID, the category to which 
the product belongs, the unit price and the calculated running sum of the unit 
price of products in the next category. The running sum, defined as the sum of all preceding records (product unit prices), 
should be calculated on a set of data sorted by the product unit price - ascending.
Sort the result in ascending order by category name and product unit price.
*/

SELECT 
P.PRODUCTID, 
C.CATEGORYNAME, 
P.UNITPRICE,
SUM(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RUNSUM
FROM PRODUCTS AS P JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 

/*EX13
Extend the previous query to calculate the maximum value of the unit price from the window covering the 2 previous rows and the 2 following the current one.
In addition, calculate the moving average from the unit price consisting of a window covering the 2 previous records and the current one. Do not change the sorting - all collections 
should be sorted in ascending order by the unit price of the product.
The final result should be sorted ascending by category name and product unit price.
*/

SELECT 
P.PRODUCTID, 
C.CATEGORYNAME, 
P.UNITPRICE,
ROUND(SUM(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS RUNSUM,
ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS MOVAVG, 
ROUND(MAX(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),2) AS MAXUNITPRICE

FROM PRODUCTS AS P JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
ORDER BY C. CATEGORYNAME, P.UNITPRICE ASC 

/*EX14
To investigate how subsequent products affect the moving average, 
expand the previous query with the calculated difference of moving averages between the current record and 
the previous record. Remember that the calculations should be within a given category.
*/

WITH TEMP AS (

	SELECT 
		P.PRODUCTID, 
		C.CATEGORYNAME, 
		P.UNITPRICE,
		ROUND(SUM(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS RUNSUM,
		ROUND(AVG(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS MOVAVG, 
		ROUND(MAX(P.UNITPRICE) OVER (PARTITION BY C.CATEGORYNAME ORDER BY C.CATEGORYNAME, P.UNITPRICE ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),2) AS MAXUNITPRICE

	FROM PRODUCTS AS P JOIN CATEGORIES AS C ON C.CATEGORYID = P.CATEGORYID 
) 

	SELECT PRODUCTID, CATEGORYNAME, UNITPRICE, RUNSUM, MAXUNITPRICE, MOVAVG, 
	MOVAVG - LAG(MOVAVG,1) OVER (PARTITION BY CATEGORYNAME ORDER BY CATEGORYNAME, UNITPRICE) AS MOVAVGDIFF
	FROM TEMP 

/*EX15
The first line is used to delete the MyCategories table if it exists. 
The next command is a type of CAS - CREATE AS SELECT command, which creates a table and fills it with data. In our case,
it is inserting records from the Categories table three times.

Using analytical functions and a command or set of commands, after which only a unique set of records will remain in the MyCategories table.
There are several options for completing the task:
1. You can delete data directly in the table (DELETE command) - in our case, the table is small, but in the case of large data sets, this solution may be inefficient
2. You can create an XYZ intermediate table, to which we will only insert unique records, delete the primary table, rename the XYZ table to the name of our primary table and recreate all components related to the object: indexes, constraints, triggers.
For simplicity, assume that we can recognize duplicates by the value of the CategoryID field (you don't have to compare all the fields in the table).

*/

IF OBJECT_ID('DBO.MYCATEGORIES') IS NOT NULL DROP TABLE DBO.MYCATEGORIES;
SELECT * INTO DBO.MYCATEGORIES FROM DBO.CATEGORIES
UNION ALL
SELECT * FROM DBO.CATEGORIES
UNION ALL
SELECT * FROM DBO.CATEGORIES


SELECT TOP 0 * INTO XYZ FROM MYCATEGORIES

WITH TEMP1 AS (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY CATEGORYID ORDER BY CATEGORYID) AS CNT 
	FROM MYCATEGORIES
)
INSERT INTO XYZ 
SELECT CATEGORYID, CATEGORYNAME, DESCRIPTION, PICTURE FROM TEMP1 WHERE CNT = 1 

DROP TABLE MYCATEGORIES
EXEC SP_RENAME 'XYZ', 'MYCATEGORIES'

/*EX16 
For the purposes of the task, the concept of Vulnerabilities should be defined:
Given a sequence of numbers or a time series (dates), a gap is a place where some items are missing (the number or time interval between successive elements is greater than in other cases).

Using the Orders table, create a query that will allow you to find all gaps (ranges) in the delivery dates (ShippedDates), greater than 1 day (we are looking for a gap greater than or equal to 1 day). 
Do not include null values. Sort the result in ascending order by the column representing the beginning of the interval. 
Don't worry about the date format for this task.
*/
;
WITH TABELDATES AS (
SELECT  TOP (DATEDIFF(DAY,'19960710', '19980506') + 1)
        DATE = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY A.OBJECT_ID) - 1 , '19960710') 
FROM    SYS.ALL_OBJECTS A
), 

TEMP AS (
SELECT 
	TD.DATE AS DATES, 
	COUNT(O.SHIPPEDDATE) OVER (PARTITION BY O.SHIPPEDDATE)	AS CNT
  FROM TABELDATES AS TD
  LEFT OUTER JOIN ORDERS AS O ON O.SHIPPEDDATE = TD.DATE

 ), 
  
LUKI AS
(
  SELECT DATES, 
         CNT, 
         LUKA = DATEADD(DAY, DENSE_RANK() OVER (ORDER BY DATES) * -1, DATES)
  FROM TEMP
  WHERE CNT = 0
),

RAWDATA(DATES, CNT, LABEL) AS
(
  SELECT DATES, 
         CNT, 
         LABEL = 'GAP ' + RTRIM(DENSE_RANK() OVER (ORDER BY LUKA)) 
  FROM LUKI

)
SELECT RANGESTART = MIN(DATES), 
       RANGEEND = MAX(DATES)

FROM RAWDATA 
GROUP BY LABEL
ORDER BY RANGESTART;

/*EX17
For the purposes of the task, the concept of Islands must be defined:
Islands, unlike Gaps, are intervals where no values ​​are missing (no gaps).

Using the Orders table, design a query that will return all islands for the ShippedDate field (do not include null values). Don't worry about the date format for this task.
Sort the result according to the column representing the beginning of the range.
*/

;WITH TABELDATE AS (
SELECT  TOP (DATEDIFF(DAY,'19960710', '19980506') + 1)
        DATE = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY A.OBJECT_ID) - 1, '19960710') 
FROM    SYS.ALL_OBJECTS A 
), 

TEMP AS (
SELECT 
	TD.DATE AS DATES, 
	COUNT(O.SHIPPEDDATE) OVER (PARTITION BY O.SHIPPEDDATE)	AS CNT
  FROM TABELDATE AS TD
  LEFT OUTER JOIN ORDERS AS O ON O.SHIPPEDDATE = TD.DATE

 ), 
  
WYSPY AS
(
  SELECT DATES, 
         CNT, 
         DATEADD(DAY, DENSE_RANK() OVER (ORDER BY DATES) * -1, DATES) AS ISLAND
  FROM TEMP WHERE CNT > 0
),
RAWDATA(DATES, CNT, LABEL) AS
(

  SELECT DATES,
         CNT, 
         DENSE_RANK() OVER (ORDER BY ISLAND) AS LABEL
  FROM WYSPY
)
SELECT RANGESTART      = MIN(DATES), 
       RANGEEND        = MAX(DATES)

FROM RAWDATA 
GROUP BY LABEL
ORDER BY RANGESTART;
