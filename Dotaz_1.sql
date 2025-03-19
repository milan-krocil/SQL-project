/* DOTAZ 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají*/
WITH cte_average_salary_in_branches_per_years AS (               -- Vytvoreni CTE pro zobrazeni prumernych platu v jednotlivych odvetvi serazenych podle let
	SELECT 
		mk_primary.payroll_year,
		mk_primary.name_branch,
		round(avg(mk_primary.value::NUMERIC), 2) AS average_salary
	FROM t_milan_krocil_project_SQL_primary_final AS mk_primary
	GROUP BY
		mk_primary.name_branch,
		mk_primary.payroll_year
	ORDER BY 
		mk_primary.name_branch,
		mk_primary.payroll_year
), cte_previous_year_added AS (                 -- Vytvoreni CTE pro zjisteni prumerne mzdy z predchazejiciho roku
SELECT 
	average_salary,
	name_branch,
	payroll_year,
	LAG(average_salary) OVER (PARTITION BY name_branch ORDER BY payroll_year) AS previous_salary
FROM cte_average_salary_in_branches_per_years AS casibpy
)
SELECT                                                  -- Vyber odvetvi, kde prumerna mzda v nekterem roce klesla
	name_branch,payroll_year,average_salary,previous_salary,    
	--DISTINCT name_branch AS branches_with_decresing_salary,      -- slouzi jen pro pripad zobrazeni jen seznamu odvetvi, kde v nekterem roce klesla prumerna mzda. K zobrazeni je nutne "zakomentovat" ve skriptu predesly radek a  posledni radek "GROUP BY" a 
	CASE 
		WHEN average_salary - previous_salary > 0 THEN 'Increase'
		WHEN average_salary - previous_salary < 0 THEN 'Decrease'
		WHEN previous_salary IS NULL THEN 'Null'
	END AS Differences
FROM cte_previous_year_added
WHERE 
	average_salary - previous_salary < 0;
GROUP BY name_branch,payroll_year,average_salary,previous_salary;    -- slouzi pro zobrazeni podrobnosti poklesu v jednotlivych letech


/* ODPOVED:
 * Z dat vyplyva, ze existuji odvetvi, kde behem obdobi doslo ke snizeni prumerne mzdy.Celkem se jedna o 18 odvetvi, kde v nekterem roce k poklesu doslo */