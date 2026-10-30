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
WHERE region LIKE "%northeast";
