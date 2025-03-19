/*DOTAZ 4:
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/

CREATE MATERIALIZED VIEW mv_comparison_avg_price_vs_avg_salary AS            -- Vytvoreni materializovaneho view   
WITH cte_average_price AS (         -- Vytvoreni CTE s prumernymi rocnimi cenami potravin vcetne doplneni info o prumerne cene z predchazejiciho roku
SELECT 
	f_year,
	round(avg(price::NUMERIC),2) AS average_price,
	LAG (round(avg(price::NUMERIC),2)) OVER (ORDER BY f_year) AS previous_year_avg_price
FROM t_milan_krocil_project_sql_primary_final tmkpspf
GROUP BY f_year
), cte_average_salary as(           -- Vytvoreni CTE s prumernymi rocnimi mzdy vcetne doplneni info o prumerne mzde z predchazejiciho roku
SELECT 
	payroll_year::TEXT AS payroll_year_text,
	round(avg(value::NUMERIC),2) AS average_salary,
	LAG (round(avg(value::NUMERIC),2)) OVER (ORDER BY payroll_year::TEXT) AS previous_year_avg_salary
FROM t_milan_krocil_project_sql_primary_final tmkpspf
GROUP BY payroll_year
)
SELECT f_year,
(average_price - previous_year_avg_price)/previous_year_avg_price*100 AS procentage_change_price,      --Vypocet % rocniho narustu cen potravin 
(average_salary - previous_year_avg_salary)/previous_year_avg_salary*100 AS procentage_change_salary,  --Vypocet % rocniho narustu mezd  
(average_price - previous_year_avg_price)/previous_year_avg_price*100 - (average_salary - previous_year_avg_salary)/previous_year_avg_salary*100 AS proc_difference_price_vs_salary
FROM cte_average_price cap
JOIN cte_average_salary cas ON cap.f_year = cas.payroll_year_text      -- Propojeni CTE
ORDER BY proc_difference_price_vs_salary DESC;                          -- Serazeni podle rozdilu rocnich procentualnich narustu cen oproti procentualnimu narustu mezd

/* ODPOVED:
 V zadnem roce nebylo procentualni zvyseni cen potravin vyssi nez 10% oproti procentualnim zvyseni mezd.
 Pro zajimavost nejvyssi bylo o 7,11% v roce 2013. Naopak nejvyssi procentualni zvyseni mezd oproti cen potravin bylo v roce 2009 a to 10,75%.*/
 

DROP MATERIALIZED VIEW IF EXISTS mv_comparison_avg_price_vs_avg_salary;