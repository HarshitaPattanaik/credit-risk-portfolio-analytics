# 🏦 End-to-End Credit Risk & Loan Portfolio Analytics Solution

An enterprise-grade analytical solution designed to model loan portfolio performance, risk segmentation, and delinquency behaviors. This project covers the full data lifecycle—from robust backend data modeling in SQL Server to interactive executive dashboards in Power BI and exploratory statistical analysis in Python.

---

## 🚀 Project Overview & Objectives
* **Objective:** Model and evaluate loan portfolio performance, risk segmentation, and repayment behaviors to monitor financial exposure and mitigate default risks.
* **Business Impact:** Empowers risk managers and executives with real-time visibility into non-performing loans (NPLs), delinquency aging (0–90+ DPD), and risk grade concentrations (A–E).

---

## 🛠️ Technical Implementation & Stack

1. **Database & Data Modeling (SQL Server):**
   * Managed via Microsoft SQL Server (`.\SQLEXPRESS`, `CreditRiskDB`).
   * Engineered a persistent analytical view (`vw_portfolio_risk_metrics`) to consolidate complex joins, delinquency aging logic, and risk tier assignments.

2. **Exploratory Data Analysis & Statistics (Python / Google Colab):**
   * Utilized `pandas` and `SQLAlchemy`/CSV pipelines for data wrangling and structure validation.
   * Leveraged `seaborn` and `matplotlib` to execute statistical EDA, visualizing outstanding balance distributions and default rate concentrations across risk tiers.

3. **Business Intelligence & Visualization (Power BI):**
   * **Dynamic KPI Cards:** Tracked *Total Portfolio Balance*, *NPL Outstanding Balance*, *Default Ratio (%)*, and *Average Interest Rate*.
   * **Risk Grade Donut Chart:** Visualized portfolio exposure breakdown across risk grades A through E.
   * **Delinquency Breakdown Chart:** Mapped financial exposure across DPD buckets stacked by risk tiers.
   * **Cross-Tabulation Matrix:** Developed a matrix cross-referencing risk grades against delinquency buckets featuring green-to-red conditional formatting and full cross-highlighting.

---

## 📂 Repository Structure
```text
├── sql/
│   └── vw_portfolio_risk_metrics.sql    # Core SQL view creation script
├── python/
│   └── credit_risk_eda.ipynb            # Google Colab / Jupyter Notebook for EDA & Seaborn plots
├── dashboard/
│   └── portfolio_risk_dashboard.pbix    # Power BI Executive Dashboard file
└── assets/
    └── dashboard_preview.png            # Visual preview screenshot
