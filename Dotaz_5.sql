/* DOTAZ 5:
 Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*/

WITH cte_adding_gdp AS (              -- Vytvoreni CTE k ziskani HDP pro CR vcetne jeho procentualni mezirocni zmeny
	SELECT
		gdp,
		year,
		population,
		country,
		LAG (gdp) OVER (ORDER BY year) AS previous_year_gdp,
		(gdp-LAG (gdp) OVER (ORDER BY year))/LAG (gdp) OVER (ORDER BY year) *100 AS procentage_change_gdp
	FROM economies
	WHERE country LIKE '%Cz%'
 ) 
SELECT         -- Ziskani a zobrazeni hodnot rocnich HDP vcetne jeji procentualni rocni zmeny. Zobrazeni procentualnich rocnich zmen u cen a platu.  
cag.YEAR,
round(cag.procentage_change_gdp::NUMERIC,2) AS proc_change_gdp,        
round(mvcapvas.procentage_change_price,2) AS proc_change_price,
lead(round(mvcapvas.procentage_change_price,2)) OVER (ORDER BY year) AS proc_next_price,
round(mvcapvas.procentage_change_salary,2) AS proc_change_salary,
lead(round(mvcapvas.procentage_change_salary,2)) OVER (ORDER BY year) AS proc_next_salary,
CASE 
	WHEN ABS(procentage_change_price - procentage_change_gdp) <1 THEN 'low impact'     -- Zatrideni zmen rozdilu HDP a cen do kategorii. Kategorie byly zvolenz podle hranic do 1%, od 1-5% a nad 5% 
	WHEN ABS(procentage_change_price - procentage_change_gdp) <5 THEN 'medium impact'
	WHEN ABS(procentage_change_price - procentage_change_gdp) >=5 THEN 'high impact'
END AS Impact_price_vs_gdp_same_year,
CASE 
	WHEN ABS(lead(round(mvcapvas.procentage_change_price,2)) OVER (ORDER BY year) - procentage_change_gdp) <1 THEN 'low impact'
	WHEN ABS(lead(round(mvcapvas.procentage_change_price,2)) OVER (ORDER BY year) - procentage_change_gdp) <5 THEN 'medium impact'
	WHEN ABS(lead(round(mvcapvas.procentage_change_price,2)) OVER (ORDER BY year) - procentage_change_gdp) >=5 THEN 'high impact'
END AS Impact_price_vs_gdp_next_year,
CASE 
	WHEN ABS(procentage_change_salary - procentage_change_gdp) <1 THEN 'low impact'
	WHEN ABS(procentage_change_salary  - procentage_change_gdp) <5 THEN 'medium impact'
	WHEN ABS(procentage_change_salary  - procentage_change_gdp) >=5 THEN 'high impact'
END AS Impact_salary_vs_gdp_same_year,
CASE 
	WHEN ABS(lead(round(mvcapvas.procentage_change_salary,2)) OVER (ORDER BY year) - procentage_change_gdp) <1 THEN 'low impact'
	WHEN ABS(lead(round(mvcapvas.procentage_change_salary,2)) OVER (ORDER BY year) - procentage_change_gdp) <5 THEN 'medium impact'
	WHEN ABS(lead(round(mvcapvas.procentage_change_salary,2)) OVER (ORDER BY year) - procentage_change_gdp) >=5 THEN 'high impact'
END AS Impact_salary_vs_gdp_next_year
FROM mv_comparison_avg_price_vs_avg_salary mvcapvas
JOIN cte_adding_gdp cag ON mvcapvas.f_year=cag.year::TEXT
WHERE country LIKE '%Cz%'                                             -- Vyber dat jen pro Ceskou republiku
ORDER BY year; 

/* ODPOVED:
 * Vyska zmeny HDP na ceny potravin a mzdy v tomtez a nasledujicim roce je nejvice patrna u roku 2009. 
 * Jednotlive hodnoty jsou zarazeny do jednotlivych kategorii a to nasledovne:
 * kategorie "low impact" - obsahuje hodnoty, kde zmeny byly mensi nez jedno procento
 * kategorie "medium impact" - obsahuje hodnoty, kde zmeny byly mezi 1 az 5 procenty
 * kategorie "high impact" - obsahuje hodnoty, kde zmeny byly vetsi nez pet procent.
 */
 

