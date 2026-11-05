/* This is to familiarize myself with the tables and their column information
and as a text comment
I will be analyzing the Northeast region as specified in the management table
 unless told otherwise.*/

 -- This is to familarize my self with the regions and directors. 
 
 SELECT *
 FROM sample_sales.management;
 
/*The regional director is Michael Jarvis 
Where he directs 4 different sales managers.*/

SELECT *
FROM sample_sales.management
WHERE region LIKE "%northeast" 
and RegionalDirector LIKE 'mich%';

-- Bo heap is the sales manager I will do my analysis with.

SELECT *
FROM sample_sales.management 
Where SalesManager LIKE '%bo%';

/* Bo Heap wants to know the OVERALL sales of the region for this analysis. 
I will start to look at all the tables we have regarding sales, which may include 
online sales if one of the columns include sales. I will also have to look into 
the dates as well. */ 

-- Seeing all store ids for the state related to Bo Heap in massachuscets. 

SELECT *
FROM store_locations
Where state LIKE 'massachu%';

/* This returned 18 rows, meaning under Bo heap there are 18 store locations he has a assigned to his territory.
730, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817 are his store IDs.
*/

-- I will read through the tables for both store and online sales. starting with store sales

SELECT *
FROM store_sales;

-- This is the product table with category and sub-category ids for later analysis.

SELECT *
FROM products;

-- The above is for me to go back to reference column and data names for analysis. 

/*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the first question presented: "What is total revenue overall for sales in the assigned territory, plus the start date and end date
that tell you what period the data covers?"
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- I will utilize the management, store locations, and store_sales tables.

SELECT *
FROM management AS m 
JOIN store_locations AS SL ON m.State = SL.State
JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
WHERE region LIKE 'northeast';

-- The query above is to make sure that I have all the northeast region sales managers and their respective dates.

SELECT region, CONCAT('$', format(sum(Sale_Amount), 2)) AS overallsales
FROM management AS m 
JOIN store_locations AS SL ON m.State = SL.State
JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
WHERE region LIKE 'northeast' and m.state LIKE '%massac%'
GROUP BY region;

-- The query above is to make sure I get the correct overall sales and converting the output of the summed sales into currency, which I was helped by MS CoPilot

SELECT region as REGION, m.state AS STATE, CONCAT('$', format(SUM(Sale_Amount), 2)) AS overallsales,
 MIN(Transaction_Date) AS startdate, MAX(Transaction_Date) as enddate
FROM management AS m 
JOIN store_locations AS SL ON m.State = SL.State
JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
WHERE region LIKE 'northeast' and m.state LIKE '%massac%'
GROUP BY region, m.state;

/*The query above will be the correct answer to the questions presenteed, in which, for the region being northeast and the assigned state/territory,
overall sales is 5,733,256.27 starting from Jan. 1st, 2022 to Dec. 31st, 2025. */


 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the second question presented: What is the revenue breakdown by year and month for the sales territory?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- The query below is getting all the unique year and month values to show the total rev from the stores in the territory. 

-- DATE_FORMAT(Transaction_Date, '%Y-%m')  I utilized MS co-pilot to help me correctly type this year month format


-- My first inital query from above provided the answer to the question presented, I ereased the online sales from below after understanding that online sales are its own territory.


 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the third question presented:  Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- This query below will demonstrate the overall sales for the region, and a column showing the sales for massachussets

SELECT region,
(SELECT CONCAT('$', format(SUM(Sale_Amount), 2)) 
 FROM management AS m3
 JOIN store_locations AS SL ON m3.State = SL.State 					
 JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
 WHERE region LIKE 'northeast') AS overall_regsales,

-- The subquery above is adding all the sales including massachussets

 CONCAT('$', format(SUM(Sale_Amount), 2)) AS overall_excMassach_regsales, 

-- the column above excludes the massachusset sales from the overall

(SELECT CONCAT('$', format(SUM(Sale_Amount), 2))
 FROM management AS m2
 JOIN store_locations AS SL ON m2.State = SL.State
 JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
 WHERE region LIKE 'northeast' AND m2.state LIKE '%massac%') AS massach_sales

-- The subquery above shows all massachusset sales

 FROM management AS m
 JOIN store_locations AS SL ON m.State = SL.State
 JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
 WHERE region LIKE 'northeast' AND m.State NOT LIKE '%massac%'
 GROUP BY region;
 
 -- clauses above goes with the region and region sales from the top select portion
 
 
 
 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the fouth question presented: What is the number of transactions per month and average transaction amount by product
category for the sales territory?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 

-- For this analysis, I will have to bring in the products table joining the store_sales table.

SELECT DATE_FORMAT(inv.Transaction_Date, '%Y-%m') AS dates, COUNT(inv.id) AS transactions, inv.category, CONCAT('$', format(AVG(inv.Sale_Amount), 2)) AS avgsalesamt

FROM (SELECT m.region, m.state, StoreId
		FROM management AS m
        JOIN store_locations AS SL
        ON m.State = SL.State
        WHERE m.region LIKE 'northeast' AND m.state LIKE '%massac%') AS storesloc 
JOIN        

 (SELECT SS.id, Store_ID, Prod_Num, p.Categoryid, IC.category, Transaction_Date, Sale_Amount
FROM inventory_categories AS IC
JOIN products AS P ON IC.Categoryid = P.Categoryid
JOIN store_sales AS SS ON P.ProdNum = SS.Prod_Num) AS inv 

ON storesloc.StoreId = inv.Store_ID

GROUP BY  DATE_FORMAT(inv.Transaction_Date, '%Y-%m'), inv.category;

/* I took the concept of sub-quering for tables to get the data I needed, the first subquery is to get data for the locations regarding the region and territory.
The seconf subquery was to get the data for product info and transactions. I joined these two subqueries to get the overall data, in which I confirmed by using select all first. */



/*
SELECT *
FROM inventory_categories AS IC join inventory_subcategories AS INS
ON IC.Categoryid = INS.Categoryid
JOIN products AS p ON INS.Categoryid = p.Categoryid
WHERE IC.Category LIKE '%textbook%';

SELECT *
FROM store_sales AS SS JOIN store_locations AS SL
ON SS.Store_ID = SL.StoreId
WHERE SL.State LIKE '%massac%' AND Prod_Num = '105350-T'
ORDER BY 2 ASC;

The above queries were to make sure I got the transactions correctly */



 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the fifth question presented: Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
ranking of online sales performance by state within an online sales territory?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 

-- Similar to previous queries, I would have to get the management tables and link it to the stores table. ordering them by their total sales

SELECT StoreLocation AS massac_stores, Store_ID, CONCAT('$', format(SUM(Sale_Amount), 2)) AS Storesales
FROM management AS m
JOIN store_locations AS SL ON m.State = SL.State
JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massac%'
GROUP BY StoreLocation, Store_ID
ORDER BY 3 DESC;
-- It seems that the Worcester store is at a high rank in sales, contributing the most in the overall territory (To be sure, I added those sales to get the same overall from the previous queries).



 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the sixth question presented: What is your recommendation for where to focus sales attention in the next quarter?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 

-- I noticed that some stores were below $600,000 in overall sales, I want to see why and their performance of sales from below $100 and above $1000. 


-- First I will do a count to find out how many sales below 100 stores did compared to store 817
SELECT SS.Store_ID, COUNT(Sale_Amount) AS storesales,

(SELECT COUNT(Sale_Amount)
FROM store_sales
WHERE Store_ID = 817 AND Sale_Amount <= 100) AS 817storesales
-- Subquery to reference the 817 store performance in sales below $100
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
AND Sale_Amount <= 100
GROUP BY SS.Store_ID
ORDER BY 2 DESC;

-- Below is the average of the amount of sales done below $100

SELECT AVG(S.storesales)
FROM (SELECT SS.Store_ID, COUNT(Sale_Amount) AS storesales
		FROM store_locations AS SL 
		JOIN store_sales AS SS 
		ON SL.StoreId = SS.Store_ID
        WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
		AND Sale_Amount <= 100
        GROUP BY SS.Store_ID) AS S;


-- Query below will show the all the $100 sales ranked from high to low per store compared to 817. 

SELECT SS.Store_ID, SUM(Sale_Amount) AS storesales,

(SELECT SUM(Sale_Amount)
FROM store_sales
WHERE Store_ID = 817 AND Sale_Amount <= 100) AS 817storesales
-- Subquery to reference the 817 store performance in sales below 100 dollars
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
AND Sale_Amount <= 100
GROUP BY SS.Store_ID
ORDER BY 2 DESC; -- ORDER BY shows that store 804 has higher sales from below $100 sales. 
-- This is going to exclude store 817 from the table, since it is the only one with 600k or higher

-- I will make a query to find out about the average overall for sales under the 100 dollars 

SELECT AVG(S.storesales)
FROM (SELECT SS.Store_ID, SUM(Sale_Amount) AS storesales
		FROM store_locations AS SL 
		JOIN store_sales AS SS 
		ON SL.StoreId = SS.Store_ID
        WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
		AND Sale_Amount <= 100
        GROUP BY SS.Store_ID) AS S;

-- Average overall sales for the below 100 dollar sales is $43,605

-- I will now check overall sales above or equal to 1000 for all stores, First I will count those sales 
		-- Queries below are similar to the above with the added change in the where clause and changing sum to total in the select clasuses
SELECT SS.Store_ID, COUNT(Sale_Amount) AS storesales,

(SELECT COUNT(Sale_Amount)
FROM store_sales
WHERE Store_ID = 817 AND Sale_Amount >= 1000) AS 817storesales
-- Subquery to reference the 817 store performance in sales below 100 dollars
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
AND Sale_Amount >= 1000
GROUP BY SS.Store_ID
ORDER BY 2 DESC;

-- It appears that 807 has 107 sales above 1000 dollars

SELECT AVG(S.storesales)
FROM (SELECT SS.Store_ID, COUNT(Sale_Amount) AS storesales
		FROM store_locations AS SL 
		JOIN store_sales AS SS 
		ON SL.StoreId = SS.Store_ID
        WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
		AND Sale_Amount >= 1000
        GROUP BY SS.Store_ID) AS S;

-- From all the stores, excluding 817, the average is 82 sales with 1000 or above. 

SELECT SS.Store_ID, SUM(Sale_Amount) AS storesales,

(SELECT SUM(Sale_Amount)
FROM store_sales
WHERE Store_ID = 817 AND Sale_Amount >= 1000) AS 817storesales
-- Subquery to reference the 817 store performance in sales below 100 dollars
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
AND Sale_Amount >= 1000
GROUP BY SS.Store_ID
ORDER BY 2 DESC;


SELECT AVG(S.storesales)
FROM (SELECT SS.Store_ID, SUM(Sale_Amount) AS storesales
		FROM store_locations AS SL 
		JOIN store_sales AS SS 
		ON SL.StoreId = SS.Store_ID
        WHERE SL.State LIKE '%massach%' AND  Store_ID != 817
		AND Sale_Amount >= 1000
        GROUP BY SS.Store_ID) AS S; 
        
        
-- I want to know the highest sale from the overall stores in the territory

SELECT MAX(Sale_Amount) AS highsales
FROM store_locations AS SL 
		JOIN store_sales AS SS 
		ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%';

-- 1763.70 was the highest sale from 16 stores, where stores 803 and 812 were below those higher sales. 

-- Query below will allow me to check how many sales were made the maximum sales in which store 811 made 10 sales with that amount.

SELECT Store_ID, COUNT(Sale_Amount) AS highsales
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND Sale_Amount = 1763.70
GROUP BY 1
ORDER BY 2 DESC;

-- Query below will show what is the average sales with 1763.70

SELECT AVG(S.highsales)
FROM (SELECT Store_ID, COUNT(Sale_Amount) AS highsales
FROM store_locations AS SL 
JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massach%' AND Sale_Amount = 1763.70
GROUP BY 1
ORDER BY 2 DESC) AS S;


/* From the above analysis, my recommendation for the stores in the territory is to have more sales below $100 to catch up with store 817
While a couple of stores were able to surpass store 817 when it came to sales $1700 or above, their sales below 100 
are half of that of 817, which contributed to ninenty grand to overall revenue. All stores, not excluding 817, should strive to bring more sales below $100 and sales above 1000 to contribute to overall revenue to the territory. 
It is always the small things that count to something bigger, which was seen with store 817. */