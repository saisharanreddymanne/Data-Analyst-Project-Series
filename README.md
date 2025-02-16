**Data Analyst Project Series**


**1. Data Exploration using SQL**

COVID-19 Data Exploration in Google BigQuery

**Project Overview**

This project explores COVID-19 data using Google Cloud Platform (GCP) BigQuery. The goal is to analyze and generate insights by combining multiple datasets related to COVID-19 cases and vaccinations. The project involves SQL-based data transformation, aggregation, and visualization-ready table creation.

**Tech Stack**

Google Cloud Platform (GCP)
BigQuery
SQL
Google Cloud Storage (if needed for data upload)


**Datasets Used:**

CovidDeaths - Contains information on COVID-19 cases, deaths, and population statistics.
CovidVaccinations - Contains data on vaccinations administered worldwide.


**Key Operations Performed**
Data Cleaning & Transformation:
Filtering out NULL values for meaningful analysis.
Standardizing column data types (FLOAT64, STRING, INT64).

Data Aggregation & Joins:

Combining CovidDeaths and CovidVaccinations datasets on location and date fields.
Calculating Total Death Rate as (Total Deaths / Population) * 100.

Table Creation for Visualization:
Creating visual_table in BigQuery to store aggregated results for dashboarding.

Adding key metrics such as:
new_cases, total_cases
new_vaccinations, total_vaccinations

