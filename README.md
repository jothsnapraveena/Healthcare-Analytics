## Healthcare Data Analysis Project

This project is a comprehensive analysis of healthcare data, leveraging SQL to extract meaningful insights into healthcare utilization, costs, insurance coverage, and demographic disparities. The project involves using views, stored procedures, and various SQL queries including simple queries, Common Table Expressions (CTEs), and window functions.

## Project Overview

This project aims to analyze healthcare data from various perspectives, including:

- Healthcare utilization: Identifying prevalent conditions and their variation by demographics.
- Healthcare costs and insurance coverage: Understanding the financial burden on patients and the role of insurance.
- Immunization rates: Investigating preventive care access across different age and income groups.
- Disparities in care: Analyzing how healthcare access and costs differ across racial and ethnic groups.
- Chronic disease management: Monitoring how patients with chronic diseases utilize healthcare services.
I  used Postgre SQL to perform advanced queries involving CTEs, window functions, and views to model real-world use cases in healthcare analytics.

### Dataset

The dataset consists of four tables:

- Patients: Contains demographic and healthcare data for each patient (e.g., birthdate, race, income, healthcare expenses, and coverage).
- Conditions: Captures medical conditions diagnosed during encounters.
- Encounters: Records healthcare visits, including details on costs and insurance.
- Immunizations: Logs immunization events, including type and patient details.

### Analysis Goals

The analysis is designed to answer key questions of interest to healthcare stakeholders, such as:

What are the most common conditions, and how do they vary across demographics?
How well are healthcare costs covered by insurance across different conditions?
Are there disparities in immunization rates or healthcare access by race or income?
How are chronic diseases being managed in terms of healthcare encounters?
