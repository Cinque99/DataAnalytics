# Delta Flight Delay Analysis (2024)

## Project Overview
This project focuses on analyzing Delta Air Lines’ 2024 flight performance data to uncover delay patterns, measure on-time performance, and provide insights that support operational decision-making.

The work demonstrates the end-to-end process of data wrangling with SQL and data visualization with Tableau, two critical skills for data analysts and business intelligence professionals.

The primary goals of this project were to:
1. Clean and enrich raw airline delay data.
2. Build queries to calculate key performance indicators (KPIs).
3. Compare hubs versus non-hubs, as well as delay causes.
4. Create an interactive Tableau dashboard to communicate insights.

## Key Skills Demonstrated
- SQL Development: Writing queries to clean, transform, and aggregate large datasets.
- Data Wrangling: Creating an enriched dataset with derived fields such as hub flags, delay percentages, and on-time rates.
- Business Intelligence: Designing Tableau dashboards with KPIs, filters, and comparative views for stakeholders.
- Analytical Storytelling: Presenting findings in a structured way that connects data patterns to -real-world airline operations.

## Tableau Dashboard
The interactive dashboard provides a visual summary of Delta’s 2024 flight performance. It includes overall KPIs, delay causes, airport rankings, hub versus non-hub analysis, and monthly delay trends.
View Dashboard on Tableau Public
(Replace with your actual Tableau link before publishing.)

## Files in this Repository
1. DeltaStory.sql
This SQL script contains the queries used to clean, transform, and analyze the airline dataset.

The script includes:
- Creation of the delta_enriched view with hub flags and derived KPIs.
- Calculation of overall KPIs (flights, delays, cancellations, on-time rates).
- Delay cause breakdowns (carrier, weather, NAS, security, late aircraft).
- Top 10 airports ranked by percentage of delays.
- Hub versus non-hub comparisons across multiple delay metrics.
- ATL-specific spotlight analysis.
- Monthly trend analysis for on-time performance and delay hours.

2. DeltaStory.twbx
This is a Tableau Packaged Workbook that contains the completed dashboard.
Features of the dashboard:
- Overall KPIs for Delta flight performance.
- Breakdown of delay causes by events and hours.
- Rankings of the top airports with the highest delay percentages.
- Hub versus non-hub comparison of delays and cancellations.
- A focused case study on ATL (Delta’s primary hub).
- Monthly trend analysis of on-time rates and delay hours.

## How to Use
### SQL
1. Open DeltaStory.sql in MySQL Workbench or any MySQL 8.0-compatible client.
2. Run the script to:
   - Create the delta_enriched view.
   - Execute the KPI and analysis queries.
3. Use the results for reporting or as an input dataset for Tableau or another BI tool.

### Tableau
1. Open DeltaStory.twbx in Tableau Desktop.
2. Explore the interactive dashboard, which contains:
   - Overall KPIs.
   - Delay causes and hours.
   - Top airports by delay percentage.
   - Hub versus non-hub comparison.
   - ATL-specific metrics.
   - Monthly delay trends.
3. Alternatively, view the Tableau Public link in a web browser if you do not have Tableau Desktop installed.

## Insights from the Analysis
- Carrier-related and late aircraft delays are the most significant contributors to overall delays.
- Delta hubs generally maintain higher throughput but still face higher delay percentages compared to some non-hubs.
- ATL (Atlanta), as Delta’s largest hub, shows both the scale of operations and its unique delay challenges.
- Delay hours vary widely by month and cause, highlighting seasonal and operational fluctuations.

## Learning Outcome
- This project highlights the full analytics pipeline:
- Starting with raw operational data.
- Wrangling and enriching it with SQL queries.
- Building meaningful KPIs and breakdowns.
- Visualizing and communicating results with Tableau.

The project serves as a portfolio example of technical SQL work combined with professional BI dashboarding, showcasing the ability to transform raw data into actionable insights.
