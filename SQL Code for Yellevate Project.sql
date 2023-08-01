--Create a table named yellevate_invoices

CREATE TABLE yellevate_invoices
(country VARCHAR,
customer_id VARCHAR,
invoice_number NUMERIC,
invoice_date DATE,
due_date DATE,
invoice_amount_usd NUMERIC,
disputed NUMERIC,
dispute_lost NUMERIC, 
settled_date DATE,
days_to_settled INTEGER,
days_late INTEGER);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Import dataset from CSV file
 
COPY yellevate_invoices
FROM 'C:\GP1\yellevate_invoices.csv' 		/* this is the filename & directory where the .csv file is located */
DELIMITER ',' CSV HEADER; 			/* this defines the delimeter type and indicate that the dataset have headers */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING AND VERIFICATION

--Check if dataset from CSV was imported to the created table
SELECT * FROM yellevate_invoices;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHECK COUNTRY NAMES FOR ERRORS
SELECT
DISTINCT(country)
FROM yellevate_invoices;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHECK DISOUNTED COLUMNS FOR ERRORS ( VALUE SHOULD ONLY BE 1 OR 0)
SELECT
DISTINCT(disputed)
FROM yellevate_invoices;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHECK DISPUTE LOST COLUMNS FOR ERRORS ( VALUE SHOULD ONLY BE 1 OR 0)
SELECT
DISTINCT(dispute_lost)
FROM yellevate_invoices;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Data analysis goals:

--QUESTION 1. The processing time in which invoices are settled (average # of days rounded to a whole number)

SELECT
ROUND(AVG(days_to_settled)) AS invoice_avg_days_settled		/* get the ave processing time to settle the invoices then roound it of to whole number */
FROM yellevate_invoices;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION 2. The processing time for the company to settle disputes(average # of days rounded to a whole number)*/

SELECT
ROUND(AVG(days_to_settled)) AS dispute_ave_days_settled		/* get the ave processing time to settle the disputes then roound it of to whole number */
FROM yellevate_invoices
WHERE disputed = 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION 3. Percentage of disputes received by the company that were lost (within two decimal places)

SELECT (
		ROUND(
				100*(
						(SELECT SUM(dispute_lost) FROM yellevate_invoices WHERE dispute_lost = 1) 		/* SUM OF ALL LOST DISPUTE lost */
						/ 													/* divided by */
        				(SELECT SUM(disputed) FROM yellevate_invoices) 							 	/* SUM OF disputed */
					),2) 														/* ROUNDED OFF TO 2 DECIMAL PLACES */
       ) || '%' AS percent_dispute_lost;															/* INCLUDE % CHARACTER */
	   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION 4. Percentage of revenue lost from disputes(within two decimal places)

SELECT (
		ROUND(
				100*(
					(SELECT SUM(invoice_amount_usd) FROM yellevate_invoices WHERE dispute_lost = 1) 	/* SUM OF ALL LOST DISPUTES */
					/ 													/* divided by */
        					(SELECT SUM(invoice_amount_usd) FROM yellevate_invoices) 					/* SUM OF ALL AMOUNT */
					),2) 													/* ROUNDED OFF TO 2 DECIMAL PLACES */
       ) || '%' AS percent_revenue_lost;														/* INCLUDE % CHARACTER */
	   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION 5. The country where the company reached the highest losses from lost disputes(in USD)

SELECT country,
SUM(invoice_amount_usd):: money as total_losses		/* TOTAL OF THE AMOUNT AND FORMATTED IT AS MONEY to get USD data type */
FROM yellevate_invoices
WHERE dispute_lost = 1
GROUP BY country
ORDER BY total_losses DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------