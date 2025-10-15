# Brazilian E-Commerce BI & Data Warehouse Solution
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange?logo=jupyter)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql)
![MIT License](https://img.shields.io/badge/License-MIT-green)

## Overview
>**Note:** This repository was developed as a final project for the BID3000 Business Intelligence and Data Warehousing course at University of South-Eastern Norway, Fall 2025.  
> **Final grade:** A

This repository provides a complete business intelligence and data warehouse solution for the [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). It covers the entire data pipeline: ETL, data warehousing, advanced SQL analytics, and interactive dashboards. The project enables descriptive, predictive, and prescriptive insights for e-commerce business questions.

## Dataset

- **Source:** [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Description:** Real-world data from Brazilian e-commerce, including orders, customers, products, payments, reviews, and sellers.

## Business Questions Answered

- What are the revenue trends by month, state, and payment type?
- Which product categories and sellers are most profitable?
- How do delivery times and review scores vary?
- What are the patterns in customer behavior?
- Which products should be recommended to customers?

## Structure

- **ETL/**: ETL jobs and source data for loading and transforming datasets.
- **Database/**: SQL scripts for schema creation and analytical queries.
- **Analytics/**: Jupyter notebooks for descriptive, predictive, and prescriptive analysis. Results are exported as CSVs.
- **Dashboard/**: Screenshots of BI dashboards.
- **Documentation/**: Project documentation.
- **Report/**: Final reports and deliverables.

## Main Features

- **Data Warehouse**: Star schema with fact and dimension tables.
- **ETL Pipeline**: Automated jobs for data extraction, transformation, and loading.
- **Descriptive Analytics**: Revenue, profitability, delivery times, and more.
- **Predictive Analytics**: Customer clustering and behavior prediction.
- **Prescriptive Analytics**: Product recommendations for customers.
- **Dashboards**: Visualizations for business insights.

## Getting Started

1. **ETL**: Run jobs in `ETL/` to populate the warehouse.
2. **Database**: Use `schema_creation.sql` to set up tables. Run queries in `analytical_queries.sql` or the notebook.
3. **Analytics**: Open notebooks in `Analytics/` for analysis and export results.
4. **Dashboard**: Review screenshots or connect your BI tool to the results.

## Requirements

- Python 3.12+
- Jupyter Notebook
- Pandas, SQLAlchemy, Matplotlib, Seaborn, scikit-learn
- PostgreSQL

## Authors

Gruppe 2, BID3000, 2025
- [Oscar G. Brøndbo](https://github.com/OscarGamst)
- [Sara Echkantana](https://github.com/saraechk)
- [Albert Einarssønn](https://github.com/AlbiDota)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

For details, see [Documentation/](Documentation) and [Report/](Report).
---


For details, see [Documentation/](Documentation) and [Report/](Report).