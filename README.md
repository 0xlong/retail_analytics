# 👟 Sportswear Retail Analytics Ecosystem

[![dbt](https://img.shields.io/badge/dbt-enabled-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/duckdb-fast--analytics-FFFF00?logo=duckdb&logoColor=black)](https://duckdb.org/)
[![Data Governance](https://img.shields.io/badge/Governance-Version--Controlled-blue)](#data-governance--workflows)

An end-to-end retail analytics and data modeling platform tailored for the sportswear, athletic, and premium retail space. This project demonstrates a production-scale approach to translating raw, complex retail point-of-sale and e-commerce data into actionable insights for merchandising, operations, and leadership.

## Dashboard

[Nike Global Retail Analytics](https://lookerstudio.google.com/u/0/reporting/751f8413-75b4-4070-a182-f6e2bff0da82/page/bSYuF)

[nike_retail_analytics.webm](https://github.com/user-attachments/assets/f51fd6af-d0f3-42b7-85dd-34aca9df46a0)

## 🎯 Project Mission

The primary goal of this platform is to act as the bridge between raw data and commercial decision-making. By maintaining a robust, scalable analytics infrastructure, this ecosystem empowers cross-functional teams to act independently on data.

Key analytical domains covered:
- **Store Performance:** Tracking holistic retail KPIs across geographic networks.
- **Merchandising Effectiveness:** Monitoring sell-through, inventory health, and assortment strategy.
- **Customer Intelligence:** D2C e-commerce analytics, cohort analysis, and customer lifetime value (LTV).

## 🏗️ Architecture & Tech Stack

This project is built using modern data stack principles to mirror high-throughput cloud environments (like **BigQuery**), scaled locally via DuckDB for rapid iteration and AI-assisted development.

* **Data Warehouse:** **DuckDB** (`retail.duckdb`) acting as the high-performance OLAP engine, modeling data with patterns fully transferable to cloud data warehouses.
* **Data Transformation:** **dbt** (Data Build Tool) controls the transformation layer. All data models are maintained in a scalable, well-governed DAG repository.
* **Complex Data Manipulation:** Advanced **SQL**. The models extensively leverage window functions, CTEs (Common Table Expressions), and robust query optimization techniques to ensure performant views.
* **Data Visualization & Self-Service Analytic:** Architected for **Looker** / Looker Studio. Includes design schemas and self-service reporting models that enable business users to self-serve insights confidently.

## 📂 Repository Structure

```tree
.
├── datasets/           # Raw e-commerce and retail seed data
├── dbt/                # Version-controlled analytics workflows, data models, and metrics
├── exports/            # Downstream data artifacts for reporting layers
├── looker_studio_new_charts_guide.md # Dashboard design guidelines and LookML equivalents
├── nike_global_eda.ipynb # Exploratory data analysis for consumer-facing sports brands
├── sql/                # Standalone advanced SQL queries for debugging & optimization
└── src/                # Python processing layers
```

## 🛠️ Key Technical Highlights

### 1. Robust Data Modeling & Advanced SQL
We follow a strict dimensional modeling approach within `dbt`. The transformation pipeline moves from raw staging tables through intermediate logic layers into polished dimensional marts. 
* Contains examples of **advanced SQL** designed to handle sparse retail data, utilizing deep CTEs for modularity and window functions for running totals and moving averages. 
* All queries are rigorously optimized for analytical processing speed.

### 2. Data Governance & Version Control
Analytics is treated as software engineering. 
* Strict **data governance** practices are enforced.
* Workflows rely on pull requests, code reviews, and comprehensive dbt tests (uniqueness, referential integrity, not-null constraints) before any metric definitions reach production dashboards.

### 3. Dashboards & Self-Service Empowerment
Rather than building isolated, static reports, this repo establishes a **dashboard ecosystem**. 
* Detailed analytical frameworks and foundational KPIs are centralized.
* This ensures complete alignment between what is modeled in the data warehouse and what is presented in the visualization layer, fostering genuine self-service analytics.

## 🚀 Getting Started

### Prerequisites
* Python 3.10+
* Local cloning of this repository.

### Installation

1. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. Inspect the local Database:
   ```bash
   # Enter the DuckDB CLI
   duckdb retail.duckdb
   ```
   > From here, you can execute exploratory queries against the local warehouse.

3. Run dbt Transformations:
   ```bash
   cd dbt
   dbt deps
   dbt build
   ```
