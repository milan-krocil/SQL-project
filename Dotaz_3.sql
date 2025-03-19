/* Dotaz:
 * Ktera kategorie potravin zdrazuje nejpomaleji (je u ni nejnizsi percentualni mezirocni narust)?
 */

WITH cte_average_category_price AS (                      -- Vytvoreni CTE s prumernymi cenami jednotlivych katergorii potravin
	SELECT 
	category_code,
	name,
	f_year,
	round(avg(price::NUMERIC),2) AS average_price 
FROM t_milan_krocil_project_SQL_primary_final
GROUP BY
	f_year, category_code, name
), cte_previous_year_avg_price AS (                       -- Vytvoreni CTE s doplnenim prumernych cen potravin z predchazejiciho roku
SELECT *,
	LAG (average_price) OVER (PARTITION BY name ORDER BY f_year) AS previous_year_avg_price
FROM cte_average_category_price AS cacp
)
SELECT	
name,
round(sum((average_price - previous_year_avg_price)/previous_year_avg_price*100),1) AS procentage_calculation   -- Soucet vsech procentualnich mezirocnich zmen cen pro kazdou kategorii
FROM cte_previous_year_avg_price
GROUP BY name
HAVING sum((average_price - previous_year_avg_price)/previous_year_avg_price*100) > 0    --Vyber kategorii, kde celkova suma mezirocnich procentualnich zmen je vetsi nez 0
ORDER BY procentage_calculation                                                         
LIMIT 1;                            -- Vysledne soucty jsou serazeny od nejmensich narustu a nakonec vybran jen s tim, nejnizsim.

/* Odpoved na dotaz:
 * Kategorie, ktera zdrazuje nejpomaleji je Jakostni vino bile */



