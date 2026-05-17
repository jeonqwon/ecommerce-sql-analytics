# E-Commerce User Retention & Engagement Analytics

## Business Problem
How do we identify at-risk users before they churn, and which engagement behaviours predict long-term retention?

## Dataset
Olist Brazilian E-Commerce Dataset (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 100k orders, 2016-2018.

## Tech Stack
- PostgreSQL 16 — database
- TablePlus — SQL editor
- Tableau/Power BI — dashboard

## Project Structure
- etl/01_raw_schema.sql — Raw table definitions
- etl/02_clean.sql — Data cleaning and deduplication
- etl/03_warehouse.sql — Aggregated warehouse tables
- queries/01_cohort_retention.sql
- queries/02_churn_risk.sql
- queries/03_rfm_segmentation.sql
- queries/04_review_score_by_cohort.sql
- queries/05_rolling_mau.sql
- dashboard/screenshots/

## Key Findings
- 96k unique customers after deduplication (removed 3,345 duplicates)
- 24% of users are Lost, 28% At Risk — over half the user base needs re-engagement
- Most users are one-time buyers — repeat purchase rate is critically low
- Review scores dip in high-volume months (Nov 2017, Feb 2018)
- Rolling MAU grew steadily from late 2016 through mid-2018

## Data Pipeline
Raw CSVs → Clean layer → Warehouse layer → Dashboard
