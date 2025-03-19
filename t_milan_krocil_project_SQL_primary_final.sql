/* Vytvoreni tabulky t_{jmeno}_{prijmeni}_project_SQL_primary_final 
(pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) */

CREATE TABLE t_milan_krocil_project_SQL_primary_final AS
	SELECT 
		czp.value AS price,
		czp.category_code, 
		to_char(czp.date_from,'YYYY') AS f_year,                    
		to_char(czp.date_from,'Q') AS f_quarter, 
		czpc.name,
		czpc.price_value,
		czpc.price_unit,
		cp.*,
		cpc.name AS name_calculation,
		cpib.name AS name_branch,
		cpu.name AS name_unit,
		cpvt.name AS name_value_type
	FROM czechia_price AS czp
	JOIN czechia_price_category AS czpc 
		ON czp.category_code = czpc.code
	JOIN czechia_payroll cp 
		ON date_part('year',czp.date_from) = cp.payroll_year 
		AND date_part('quarter',czp.date_from) = cp.payroll_quarter
	JOIN czechia_payroll_calculation AS cpc
		ON cp.calculation_code = cpc.code
	JOIN czechia_payroll_industry_branch AS cpib 
		ON cp.industry_branch_code = cpib.code
	JOIN czechia_payroll_unit AS cpu
		ON cp.unit_code = cpu.code 
	JOIN czechia_payroll_value_type AS cpvt
		ON cp.value_type_code  = cpvt.code
	WHERE cp.value_type_code = 5958
	AND cp.calculation_code = 200;
