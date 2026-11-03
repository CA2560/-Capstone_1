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

-- Here I wanted to join the tables to compare with product numbers to be grouped together to get ready for the first analysis

SELECT *
FROM sample_sales.online_sales JOIN sample_sales.store_sales
ON online_sales.ProdNum = store_sales.Prod_Num;

-- Both sales tables have their transaction dates, which will be considered for the first analysis.



-- The above is for me to go back to reference column and data names for analysis. 

/*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the first question presented: "What is total revenue overall for sales in the assigned territory, plus the start date and end date
that tell you what period the data covers?"
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/* I utilize sub-queries to get the the amounts of the store and online sales and then I had to add them up for the overall territory
I made a second query to show the start and end date of both store and online. demonstrating a 3 year period*/

SELECT state, 
		(SELECT SUM(SalesTotal)
			FROM online_sales
            WHERE ShiptoState LIKE '%massac%') AS OnlineSales,
            
		(SELECT SUM(Sale_Amount)
        FROM store_sales AS SS JOIN store_locations AS SL
        ON SS.Store_ID = SL.StoreId
        WHERE SL.State LIKE '%massac%') AS StoreSales,
            
		(SELECT SUM(SalesTotal)
			FROM online_sales
            WHERE ShiptoState LIKE '%massac%')
            +
        (SELECT SUM(Sale_Amount)
        FROM store_sales AS SS JOIN store_locations AS SL
        ON SS.Store_ID = SL.StoreId
        WHERE SL.State LIKE '%massac%') AS totalsales
FROM (SELECT State
		FROM store_locations
        WHERE State LIKE '%massac%') AS storeLOC
ORDER BY 1 LIMIT 1 ;



SELECT MIN(OS.Date) AS ONLINESTARTDATE, MAX(OS.Date) AS OnlineEndDate,  MIN(SS.Transaction_Date) AS StoreStartDate,MAX(SS.Transaction_Date) AS StoreEndDate
FROM online_sales AS OS JOIN store_sales AS SS ON OS.ProdNum = SS.Prod_Num
WHERE OS.ShiptoState LIKE '%massac%';

-- Query above shows a 3 year period for both the store and online sales with store sales starting in jan. 1st, 2022 and online starting on jan. 6th, 2022, with both ending in dec. 31st, 2025

 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the second question presented: What is the revenue breakdown by year and month for the sales territory?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- The query below is getting all the unique year and month values to show the total rev from the stores in the territory. 

-- DATE_FORMAT(Transaction_Date, '%Y-%m')  I utilized MS co-pilot to help me correctly type this year month format

SELECT SL.State, DATE_FORMAT(SS.Transaction_Date, '%Y-%m') AS yearmondates, SUM(SS.Sale_Amount) AS Mon_total
FROM store_locations AS SL JOIN store_sales AS SS 
ON SL.StoreId = SS.Store_ID
WHERE SL.State LIKE '%massac%'
GROUP BY SL.State, DATE_FORMAT(SS.Transaction_Date, '%Y-%m');

-- I decided to keep store sales and online sales monthly sales seperate for analysis. 

SELECT DATE_FORMAT(Date, '%Y-%m'), SUM(SalesTotal)
FROM online_sales
WHERE ShiptoState LIKE '%massac%'
GROUP BY DATE_FORMAT(Date, '%Y-%m');


 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the third question presented:  Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/* It seems that I need to obtain the overall revenue from the region, which is 3 states for the northeast. 
To accomplish this, I will need to use the join clause on management and store sales table along with online sales*/

-- I utilized microsoft co-pilot and the student guide to help me understand the concepts of sub-querying for these queries compared to how I first did them.

SELECT region, SUM(SalesTotal) AS onlinesales, 
(SELECT SUM(Sale_Amount)
 FROM management AS m2
 JOIN store_locations AS SL ON m2.State = SL.State
 JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
 WHERE region LIKE 'northeast' AND m2.State NOT LIKE '%massac%') AS storesales ,SUM(SalesTotal) +
(SELECT SUM(Sale_Amount)
 FROM management AS m2
 JOIN store_locations AS SL ON m2.State = SL.State
 JOIN store_sales AS SS ON SL.StoreId = SS.Store_ID
 WHERE region LIKE 'northeast' AND m2.State NOT LIKE '%massac%') AS overrallregsales
FROM management AS m join online_sales AS OS
ON m.State = OS.ShiptoState 
WHERE region LIKE 'northeast' AND m.State NOT LIKE '%massac%'
GROUP BY region;


/* The Query above is to obtain the overall sales data excluding the massachussets territory and the Query below is the same query from the
first question to do a comparasion against the whole region*/

SELECT state, 
		(SELECT SUM(SalesTotal)
			FROM online_sales
            WHERE ShiptoState LIKE '%massac%') AS OnlineSales,
            
		(SELECT SUM(Sale_Amount)
        FROM store_sales AS SS JOIN store_locations AS SL
        ON SS.Store_ID = SL.StoreId
        WHERE SL.State LIKE '%massac%') AS StoreSales,
            
		(SELECT SUM(SalesTotal)
			FROM online_sales
            WHERE ShiptoState LIKE '%massac%')
            +
        (SELECT SUM(Sale_Amount)
        FROM store_sales AS SS JOIN store_locations AS SL
        ON SS.Store_ID = SL.StoreId
        WHERE SL.State LIKE '%massac%') AS totalsales
FROM (SELECT State
		FROM store_locations
        WHERE State LIKE '%massac%') AS storeLOC
ORDER BY 1 LIMIT 1 ;

