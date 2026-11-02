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

-- From the table returned from store sales and looking into the online_sales, they both share product numbers. 

SELECT *
FROM online_sales;

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

-- Will do a distinct of dates for store sales from beginning to end

SELECT DISTINCT min(Transaction_Date) AS StartDate, max(Transaction_Date) AS EndDate 
FROM store_sales;  -- This returned around 1461 rows from 335129 rows, which in turn mean there has been 1461 days of sales.alter

-- I will now find out for Bo's territory all STORE sales dates and overall revenue 

-- this is to make sure the sum syntax is correct for the next query
SELECT * 
FROM store_sales
WHERE Store_ID IN ('730', '801', '802', '803', '804', '805', '806', '807',
 '808', '809', '810', '811', '812', '813', '814', '815', '816', '817'); 
 -- From 335,129 rows, this query returned 42,010 from the listed store IDs which can help me find the start and end date period.
 
 
 -- The query below is to be sure that I have the correct start and end dates for the next query to answer the question according to the store IDs.
SELECT *
FROM store_sales
WHERE Store_ID IN ('730', '801', '802', '803', '804', '805', '806', '807',
 '808', '809', '810', '811', '812', '813', '814', '815', '816', '817')
 ORDER BY Transaction_Date ASC;
 
 -- The query below would be the answer to the question.
 
 SELECT min(Transaction_Date) AS StartDate, max(Transaction_Date) AS EndDate, CONCAT('$', format(sum(Sale_Amount), 2)) AS total_rev -- I used gemini to help me type the correct clause for the sum to be in monetary value. 
 FROM store_sales
 WHERE Store_ID IN ('730', '801', '802', '803', '804', '805', '806', '807',
 '808', '809', '810', '811', '812', '813', '814', '815', '816', '817');
 -- The returned rows were from jan. 1, 2022 to dec. 31 2025, meaning it was a 3 year period of sales from the assigned territory. 


 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for the second question presented: What is the revenue breakdown by year and month for the sales territory?
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

-- The query below is getting all the unique year and month values to show the total rev from the stores in the territory. 

SELECT DATE_FORMAT(Transaction_Date, '%Y-%m') AS Sales_Month, CONCAT('$', format(sum(Sale_Amount), 2)) AS total_rev
FROM store_sales
WHERE Store_ID IN ('730', '801', '802', '803', '804', '805', '806', '807',
 '808', '809', '810', '811', '812', '813', '814', '815', '816', '817')
GROUP BY DATE_FORMAT(Transaction_Date, '%Y-%m') -- I utilized MS co-pilot to help me correctly type the group by clause to get the total revenue for each month. 
ORDER BY 1 asc;



 /*
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Below will be the analysis for thRegione third question presented:  Provide a comparison of total revenue for the specific sales territory and the region it belongs to.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
/* It seems that I need to obtain the overall revenue from the region, which is 4 states for the northeast. 
To accomplish this, I will need to use the join clause on management and store sales table */

SELECT *
FROM management AS region
INNER JOIN store_locations AS state ON region.State = state.State
INNER JOIN store_sales AS overallSales ON state.StoreId = overallSales.Store_ID
WHERE region LIKE '%northeast%';

-- The query above was to make sure I was able to successfully join the tables to get the region data. 

