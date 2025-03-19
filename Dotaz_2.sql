/* DOTAZ 2
 Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?*/

WITH cte_avg_salary AS (           -- CTE ke zjisteni prumernych platu v jednotlivych rocnich kvartalech
SELECT 
	payroll_year, payroll_quarter,
	round(avg(value::NUMERIC),2)  AS average_salary
FROM t_milan_krocil_project_sql_primary_final tmkpspf
GROUP BY payroll_year, payroll_quarter
), cte_price_selected_items AS (                       -- CTE ke zjisteni prumernych cen chleba a mleka v jednotlivych rocnich kvartalech
SELECT  
	name,	
	f_year,f_quarter,
	round(avg(price::NUMERIC),2)  AS average_price
FROM t_milan_krocil_project_sql_primary_final tmkpspf    
WHERE name LIKE '%Chléb%'                                 -- vyber polozky mleka a chleba
OR name LIKE '%Mléko%'
GROUP BY f_year,f_quarter,name 
), cte_selected_period as(                             -- CTE ke zjisteni prvniho a posledniho srovnatelneho obdobi
SELECT
min(f_year) AS first_period,                     
max(f_year) AS last_period,
min(f_quarter) AS first_quarter,
max(f_quarter) AS last_quarter
FROM t_milan_krocil_project_sql_primary_final tmkpspf   
)
SELECT f_year,f_quarter,name,
round(average_salary/average_price,0) AS qty_of_purchase
FROM cte_price_selected_items cpsi
JOIN cte_avg_salary cts 
	ON cpsi.f_year = cts.payroll_year::TEXT 
	AND cpsi.f_quarter = cts.payroll_quarter::TEXT
JOIN cte_selected_period csp 
	ON cpsi.f_quarter = csp.first_quarter
	OR cpsi.f_quarter = csp.last_quarter
WHERE f_year = first_period AND f_quarter::integer = 1
	OR f_year = last_period AND f_quarter::integer = 4
GROUP BY f_year,f_quarter,name,average_salary,average_price;
/* ODPOVED
 * V prvnim srovnatelnem obdobi (Q1 2006) bylo mozne za prumernou mzdu koupit 1358ks chleba a 1405 litru mleka.
 * V poslednim srovnatelnem obdobi (Q4 2018) bylo mozne za prumernou mzdu koupit 1471ks chleba a 1803 litru mleka.
 */





   


	

