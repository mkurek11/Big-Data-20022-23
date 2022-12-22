--CTE

/* EX 1
Using the Products table, display all product IDs (ProductID) and names (ProductName)
whose unit price (UnitPrice) is higher than the average in a given category. Sort the result by unit price (UnitPrice).
Execute the query in two variants: without and with CTE.
*/ 

--WITH CTE
	WITH AVGPRICE AS (
						SELECT 
							AVG(UNITPRICE) AS AVGPRICE
							,CATEGORYID 
						FROM PRODUCTS 
						GROUP BY CATEGORYID
	)

	SELECT 
		P.PRODUCTID, 
		P.PRODUCTNAME 
	FROM PRODUCTS AS P
	JOIN AVGPRICE AS AP ON AP.CATEGORYID = P.CATEGORYID
	WHERE AP.AVGPRICE < P.UNITPRICE
	ORDER BY P.UNITPRICE 

--REGULAR

SELECT       PRODUCTID, PRODUCTNAME
FROM         PRODUCTS AS P1
WHERE        (UNITPRICE >
                             (SELECT        AVG(UNITPRICE) AS AVGPRICE
                               FROM            PRODUCTS AS P2
                               WHERE        (P1.CATEGORYID = CATEGORYID)
                               GROUP BY CATEGORYID))
ORDER BY UNITPRICE

/* EX 2 
Using the Products and Order Details tables and the CTE construct, display all IDs
(Products.ProductID) and product names (Products.ProductName) whose maximum value
of orders without discount (UnitPrice*Quantity) is less than the average in the category.
In other words – there is no order value greater than the average order value in the category,
to which the Product belongs.
Sort the result in ascending order by product ID.
*/

WITH AVGTEM AS ( 
				SELECT 
						AVG(OD.UNITPRICE * OD.QUANTITY) AS AVGORDERS
						,P.CATEGORYID
				FROM [ORDER DETAILS] AS OD 
				INNER JOIN PRODUCTS AS P ON P.PRODUCTID = OD.PRODUCTID
				GROUP BY P.CATEGORYID 
),

MAXORDERS AS (
				SELECT 
						MAX(OD.UNITPRICE * OD.QUANTITY) AS AVGORDERS
						,P.PRODUCTID
				FROM [ORDER DETAILS] AS OD 
				INNER JOIN PRODUCTS AS P ON P.PRODUCTID = OD.PRODUCTID
				GROUP BY P.PRODUCTID 
)

SELECT DISTINCT
	P.PRODUCTID
	,P.PRODUCTNAME
FROM PRODUCTS AS P
JOIN MAXORDERS AS MO ON P.PRODUCTID = MO.PRODUCTID 
JOIN AVGTEM AS ATEM ON ATEM.CATEGORYID = P.CATEGORYID 
WHERE ATEM.AVGORDERS > MO.AVGORDERS

ORDER BY P.PRODUCTID ASC 

/* EX 3 
Using the Employees table, display the ID, name and surname of the employee together
with an identifier, name and surname of his supervisor. To find a given supervisor
work, use the ReportsTo field. Display results for hierarchy level no greater than 1
(starting from 0). Add the WhoIsThis column to the result, which will take the appropriate values ​​for
of a given level:
• Level = 0 – Krzysiu Jarzyna from Szczecin
• Level = 1 - Pan Żabka
*/

WITH EMPLOYEESRECCTE
	(
	EMPLOYEEID, FIRSTNAME, LASTNAME, REPORTSTO, MANAGERFIRSTNAME, MANAGERLASTNAME, LEVEL
	)
AS
	(
		SELECT EMPLOYEEID, FIRSTNAME, LASTNAME, REPORTSTO,
				CAST(NULL AS NVARCHAR(10)) AS MANAGERFIRSTNAME,
				CAST(NULL AS NVARCHAR(20)) AS MANAGERLASTNAME,
				0 AS LEVEL
		FROM EMPLOYEES WHERE REPORTSTO IS NULL

		UNION ALL

		SELECT E.EMPLOYEEID, E.FIRSTNAME, E.LASTNAME, R.EMPLOYEEID, R.FIRSTNAME,
				R.LASTNAME, LEVEL + 1
		FROM EMPLOYEES E JOIN EMPLOYEESRECCTE R ON E.REPORTSTO = R.EMPLOYEEID
		WHERE LEVEL < 1

	)
SELECT EMPLOYEEID, FIRSTNAME, LASTNAME, REPORTSTO, MANAGERFIRSTNAME,MANAGERLASTNAME, 
CASE 
	WHEN LEVEL = 0 THEN 'KRZYSIU JARZYNA ZE SZCZECINA'
	WHEN LEVEL = 1 THEN 'PAN ŻABKA'
	END AS 'WHOISTHIS'
FROM EMPLOYEESRECCTE

/* EX 4
Extend the previous query so that in the ReportsTo column, instead of the identifier, it appears
the value from the supervisor's WhoIsThis column. This time present all levels of the hierarchy.
3
Let the WhoIsThis column for the Level=2 level take the value - Reżyser kina akcji. In first
order, try to complete the task without adding more subqueries.
*/


;WITH EMPLOYEESRECCTE
	(
	EMPLOYEEID, FIRSTNAME, LASTNAME, REPORTSTO, MANAGERFIRSTNAME, MANAGERLASTNAME, LEVEL
	)
AS
	(
		SELECT EMPLOYEEID, FIRSTNAME, LASTNAME, REPORTSTO,
				CAST(NULL AS NVARCHAR(10)) AS MANAGERFIRSTNAME,
				CAST(NULL AS NVARCHAR(20)) AS MANAGERLASTNAME,
				0 AS LEVEL
		FROM EMPLOYEES WHERE REPORTSTO IS NULL

		UNION ALL
		
		SELECT E.EMPLOYEEID, E.FIRSTNAME, E.LASTNAME, R.EMPLOYEEID, R.FIRSTNAME,
				R.LASTNAME, LEVEL + 1
		FROM EMPLOYEES E JOIN EMPLOYEESRECCTE R ON E.REPORTSTO = R.EMPLOYEEID
		WHERE LEVEL < 2

	)
SELECT 
			EMPLOYEEID
			,FIRSTNAME
			,LASTNAME
			,CASE 
				WHEN REPORTSTO = 2 THEN 'KRZYSIU JARZYNA ZE SZCZECINA'
				WHEN REPORTSTO = 5 THEN 'PAN ŻABKA'
				END AS 'REPORTSTO'
			,MANAGERFIRSTNAME
			,MANAGERLASTNAME
			,CASE 
				WHEN LEVEL = 0 THEN 'KRZYSIU JARZYNA ZE SZCZECINA'
				WHEN LEVEL = 1 THEN 'PAN ŻABKA'
				WHEN LEVEL = 2 THEN 'REŻYSER KINA AKCJI'
				END AS 'WHOISTHIS'
FROM EMPLOYEESRECCTE


/* EX 5 
Using CTEs and recursions, build a query to represent a Fibonacci sequence
*/ 

;WITH FIBONACCI (LEVEL, PREVN, N) AS
(
     SELECT 0, 0, 1
     UNION ALL
     SELECT LEVEL+1, N, PREVN + N
     FROM FIBONACCI
     WHERE N < 1000000000
)
SELECT LEVEL, PREVN AS FIBO, N 
     FROM FIBONACCI
     OPTION (MAXRECURSION 0);