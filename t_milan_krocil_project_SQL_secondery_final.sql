/* Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
 */ 
 
CREATE TABLE t_milan_krocil_project_SQL_secondery_final AS 
WITH cte_year_selection AS (          -- Vytvoreni CTE k ziskani stejneho obdobi jako byla analyza HDP v dotazu 5
	SELECT
		f_year 
	FROM mv_comparison_avg_price_vs_avg_salary mcapvas  
)
SELECT                                -- Zobrazeni pozadovanych dat z tabulky economies, za obdobi definovane v CTE
 	country,
 	gdp,
 	population, 
 	year
FROM economies e
JOIN cte_year_selection cys
	ON e.year::TEXT =cys.f_year;
