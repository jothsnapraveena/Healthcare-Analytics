/*Patient Demographics Overview*/

with patient_age as(
	select 
		id,
		first,
		last,
		extract(year from age(birthdate)) as age,
		ethnicity,
		gender,
		race
	from 
		patients
)
select
	case
		when age<18 then 'under 18'
		when age between 18 and 65 then '18-65'
		when age>65 then 'above 65'
	end as age_group,
	gender,race,ethnicity,
	count(*) as patient_count
	from patient_age
	group by age_group,gender,race,ethnicity
	order by count(*) desc, age_group,gender,race,ethnicity;
	
/*Analyze Condition Prevalence*/

with patient_age as(
	select 
		id,extract(year from age(birthdate)) as age,
		gender,race,ethnicity
		from patients 		
),
conditions_count as(
	select c.code,
		   c.description,
		   p.gender,
		   p.race,
		   p.ethnicity,
		   case 
				when age<18 then 'under 18'
				when age between 18 and 65 then '18-65'
				when age>65 then 'above 65'
	      end as age_group,
		  count(*) as condition_count
	from conditions as c
	join patient_age as p
	on c.patient=p.id
	group by c.code,
		     c.description,
		     p.gender,
		     p.race,
		     p.ethnicity,
			 age_group

)
select 
	age_group,
	gender,
	race,
	ethnicity,
	code,
	description,
	condition_count
from conditions_count
order by age_group,condition_count desc;
	
/*Encounter Frequency and Types */

WITH encounter_summary AS (
    SELECT 
        patient,
        encounterclass,
        COUNT(encounterclass) AS total_encounters,
        ROUND(SUM(total_claim_cost)::numeric, 2) AS total_claims,
        ROUND(AVG(base_encounter_cost)::numeric, 2) AS avg_cost
    FROM 
        encounters
    GROUP BY 
        patient, encounterclass
)

SELECT 
    e.patient,
    e.encounterclass,
    e.total_encounters,
    e.total_claims,
    e.avg_cost
FROM 
    encounter_summary e
ORDER BY 
    e.total_encounters desc;

/*Immunization Rates by Demographics*/

WITH patient_age AS (
    SELECT 
        id,
        EXTRACT(YEAR FROM AGE(birthdate)) AS age,
        gender,
        race,
        ethnicity
    FROM 
        patients
),
immunization_counts AS (
    SELECT 
        i.patient,
        COUNT(i.code) AS total_immunizations,
        p.gender,
        p.race,
        p.ethnicity,
        CASE 
            WHEN p.age < 18 THEN 'Under 18'
            WHEN p.age BETWEEN 18 AND 65 THEN '18-65'
            ELSE '65 and over'
        END AS age_group
    FROM 
        immunizations i
    JOIN 
        patient_age p ON i.patient = p.id
    GROUP BY 
        i.patient, p.gender, p.race, p.ethnicity, age_group
)

SELECT 
    age_group,
    gender,
    race,
    ethnicity,
    SUM(total_immunizations) AS total_immunizations,
    COUNT(DISTINCT patient) AS total_patients,
    ROUND(SUM(total_immunizations) * 100.0 / NULLIF(COUNT(DISTINCT patient), 0), 2) AS immunization_rate
FROM 
    immunization_counts
GROUP BY 
    age_group, gender, race, ethnicity
ORDER BY 
    age_group, immunization_rate DESC;

/* Healthcare expenses */

WITH patient_age AS (
    SELECT 
        id,
        EXTRACT(YEAR FROM AGE(birthdate)) AS age,
        gender,
        race
    FROM 
        patients
)

SELECT 
    CASE 
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 65 THEN '18-65'
        ELSE '65 and over'
    END AS age_group,
    p.gender,
    p.race,
    ROUND(AVG(healthcare_expenses)::numeric, 2) AS average_expenses
FROM 
    patient_age p
JOIN 
    patients pt ON p.id = pt.id
GROUP BY 
    age_group, p.gender, p.race
ORDER BY 
    age_group, average_expenses DESC;





/*Patient expenses */

with patient_expenses as(
select id,
first,
last,
round(sum(healthcare_expenses)::numeric,2) as Total_expense
from patients
group by 
id,first,last
)
select 
id,
first ||''|| last as full_name,
rank()over(order by total_expense desc) as expense_rank
from patient_expenses
order by expense_rank
limit 10

/*Patients with Healthcare Expenses Above Average*/


with avg_health_expenses as(
select round(avg(healthcare_expenses)::numeric,2) as avg_expenses
from patients
)
select p.id,
first ||' '|| last as full_name,
p.healthcare_expenses,
e.avg_expenses,
round((p.healthcare_expenses-e.avg_expenses)::numeric,2) as expense_difference
from patients p,avg_health_expenses e
where p.healthcare_expenses > e.avg_expenses
ORDER BY expense_difference DESC;

/*Demographic Disparities in Healthcare Access*/

SELECT 
    race,
    ROUND(AVG(healthcare_expenses)::numeric, 2) AS avg_expenses,
    ROUND(AVG(healthcare_coverage)::numeric, 2) AS avg_coverage,
    ROUND(AVG(healthcare_expenses - healthcare_coverage)::numeric, 2) AS avg_out_of_pocket
FROM 
    patients
GROUP BY 
    race
ORDER BY 
    avg_out_of_pocket DESC;


/*Healthcare Expenses & Insurance Coverage*/

with patient_expenses as(
select id,
race,
ethnicity,
healthcare_expenses,
healthcare_coverage
from patients
)
select 
race,ethnicity,
ROUND(AVG(healthcare_expenses)::numeric, 2) AS avg_expenses,
    ROUND(AVG(healthcare_coverage)::numeric, 2) AS avg_coverage,
    ROUND(AVG(healthcare_expenses - healthcare_coverage)::numeric, 2) AS avg_out_of_pocket_expense
FROM 
    patient_expenses
GROUP BY 
    race,ethnicity
ORDER BY 
    avg_out_of_pocket_expense DESC;


/*Chronic Disease Management*/

WITH chronic_conditions AS (
    SELECT 
        c.description AS condition,
        c.patient,
        COUNT(e.id) AS encounter_count
    FROM 
        conditions c
    JOIN 
        encounters e ON c.encounter = e.id
    GROUP BY 
        c.description, c.patient
)

SELECT 
    condition,
    AVG(encounter_count) AS avg_visits_per_patient
FROM 
    chronic_conditions
GROUP BY 
    condition
ORDER BY 
    avg_visits_per_patient DESC;

/*Preventive Care*/

select p.id,i.code,
count(i.code) as immunizations_received,
sum(p.healthcare_expenses) as expenses
from patients p
join immunizations i
on p.id=i.patient
group by p.id,i.code

/* Insurance Coverage Gaps*/

WITH patient_expenses_coverage AS (
    SELECT 
        id,
        income,
        healthcare_expenses,
        healthcare_coverage,
        healthcare_expenses - healthcare_coverage AS out_of_pocket
    FROM 
        patients
)

SELECT 
    income,
    COUNT(id) AS total_patients,
    ROUND(AVG(out_of_pocket)::numeric, 2) AS avg_out_of_pocket
FROM 
    patient_expenses_coverage
WHERE 
    out_of_pocket > 0
GROUP BY 
    income
ORDER BY 
    avg_out_of_pocket DESC;

/* Conditions with Healthcare Expenses vs. Insurance Coverage*/

WITH condition_expenses AS (
    SELECT 
        c.description AS condition,  -- Disease/condition description
        e.patient,
        SUM(e.total_claim_cost) AS total_expenses,
        SUM(e.payer_coverage) AS total_coverage,
        SUM(e.total_claim_cost - e.payer_coverage) AS out_of_pocket_expenses
    FROM 
        conditions c
    JOIN 
        encounters e ON c.encounter = e.id
    GROUP BY 
        c.description, e.patient
)

SELECT 
    condition,
    ROUND(AVG(total_expenses)::numeric, 2) AS avg_total_expenses,
    ROUND(AVG(total_coverage)::numeric, 2) AS avg_coverage,
    ROUND(AVG(out_of_pocket_expenses)::numeric, 2) AS avg_out_of_pocket,
    ROUND(AVG(total_coverage / NULLIF(total_expenses, 0))::numeric, 2) AS coverage_ratio  -- Ratio of insurance coverage to total expenses
FROM 
    condition_expenses
GROUP BY 
    condition
ORDER BY 
    coverage_ratio ASC, avg_out_of_pocket DESC;
