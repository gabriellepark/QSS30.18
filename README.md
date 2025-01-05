# QSS 30.18 Final Project: Influence of Conflict on the Spread of COVID-19


**Winter 2024**
**QSS 30.18: Quantitative Applications to Peace and Justice**

## Project Overview
This repository contains the code, data, and written paper for a final project in QSS 30.18—a course in the Quantitative Social Science Department at Dartmouth College, taught by Professor Elsa Voytas. This project researched how infectious diseases are affected by conflict and can be mitigated by health infrastructure, specifically investigating Covid-19 in the Middle East and North Africa (MENA) region.


## Data
This project uses the following data sources:

**1. Armed Conflict Location & Event Data (ACLED)**

- **File:** `2020-01-01-2022-05-31-Algeria-Bahrain-Djibouti-Egypt-Iran-Iraq-Israel-Jordan-Kuwait-Lebanon-Libya-Malta-Morocco-Oman-Qatar-Saudi_Arabia-Syria-Tunisia-United_Arab_Emirates-Yemen.csv`
- **Source:** ACLED (2023). *“Armed Conflict Location & Event Data Project (ACLED) Codebook, 2023.”*
  - Full data can be accessed [here](https://acleddata.com/data/).

**2. COVID-19 Data from Our World in Data (OWID)**

- **File:** `weekly_cases.csv`
- **File:** `weekly_deaths.csv`
- **Source:** Our World in Data. (n.d.). *Data on COVID-19 (coronavirus) by Our World in Data*. GitHub.  
  - COVID-19 case data, collected from the World Health Organization (WHO) Coronavirus Dashboard.
  - GitHub Repository: [OWID COVID-19 Data](https://github.com/owid/covid-19-data/tree/master/public/data/cases_deaths)

**3. World Health Organization (WHO) Data**

- **File:** `whodata.csv`
- **Source:** World Health Organization. (n.d.-a). *Current health expenditure (CHE) as percentage of gross domestic product (GDP) (%)*. World Health Organization.  
  - Data from the WHO’s Global Health Observatory, specifically on the current health expenditure (CHE) as a percentage of GDP per capita for each country in the MENA region.
  - Full data can be accessed [here](https://www.who.int/data/gho/data/indicators/indicator-details/GHO/current-health-expenditure-(che)-as-percentage-of-gross-domestic-product-(gdp)-(-)).

---

## Code

- **File:** `FinalProject_Park.R`
  - This R script runs linear regressions and fixed effects models with interaction terms.
 
## Figures

The following figures were produced from the project:

**1. conflict_MENA.png**  
   - Conflict in Middle East and North Africa (MENA) Region Countries, February 2020 to March 2022

**2. conflict_coefficients_MENA.png**  
   - Heterogeneity of high and low conflict countries: Predicting Covid-19 deaths with case counts in the MENA region

**3. conflict_vs_cases_MENA.png**  
   - Conflict events and Covid-19 case counts in a given day, Feb. 2020 to March 2022

**4. covid_cases_MENA.png**  
   - COVID-19 Cases in Middle East and North Africa (MENA) Region Countries, February 2020 to March 202
     
**5. health_expenditure_MENA.png**  
   - Current health expenditure as a percent of GDP (in USD) per capita


## Paper
Final project write-up:

- **File:** `QSS 30.18 Final Research Paper.pdf`


