# 🌿 Scope-3 Emissions Snapshot & Supplier Risk Score

> End-to-end data pipeline and predictive analytics system to estimate Scope-3 emissions, identify high-risk suppliers, and deliver actionable insights through an interactive Power BI dashboard.

[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)]()
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)]()
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)]()
[![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=flat&logo=scikit-learn&logoColor=white)]()

---

## 📌 Problem Statement

Organizations struggle to quantify **Scope-3 (Category 1: Purchased Goods & Services)** emissions because procurement data is not directly tied to carbon output. This project bridges that gap by:
- Mapping procurement spend to NAICS-based emission factors (US EPA USEEIO)
- Building a **supplier-level risk score** for prioritization
- Training a **Random Forest model** to predict supplier emissions
- Visualizing findings in an interactive **Power BI dashboard**

---

## 🗂️ Project Structure

```
scope3-emissions-analytics/
├── notebooks/
│   ├── scope3_pipeline.ipynb       # ETL pipeline: cleaning → NAICS mapping → emissions calc
│   └── ml_model.ipynb              # ML model: feature engineering → training → evaluation
├── sql/
│   └── sample_queries.sql          # Supplier spend aggregation & emissions queries
├── data/
│   └── sample_dataset.csv          # Anonymized sample of supplier summary output
├── dashboard/
│   └── (Power BI .pbix screenshots)
└── README.md
```

---

## 🧭 Data Flow

```
Raw Procurement Data (.csv)
        ↓
Cleaning & Filtering (Delivered orders only)
        ↓
Category → NAICS Code Mapping
        ↓
Join with EPA Emission Factors (kg CO₂e / USD)
        ↓
Imputation (NAICS-median for missing EFs)
        ↓
Line-Level Emissions Calculation  →  line_level_emissions_with_imputation.csv
        ↓
Supplier Aggregation + Priority Scoring  →  supplier_summary_with_priority.csv
        ↓
Machine Learning Model  →  supplier_predictions.csv
        ↓
Power BI Dashboard
```

---

## 📥 Datasets Used

### Input Datasets

| Dataset | Source | Key Columns |
|---------|--------|-------------|
| **Procurement Dataset** | Internal/Synthetic | `Supplier`, `Item_Category`, `Quantity`, `Unit_Price`, `Negotiated_Price`, `Order_Status`, `Order_Date` |
| **Emission Factors** | [US EPA USEEIO v1.2](https://www.epa.gov/land-research/us-environmentally-extended-input-output-useeio-technical-content) | `NAICS6`, `EF_kg_per_USD` (with margins) |
| **NAICS Mapping** | Manually curated | `Item_Category` → `NAICS6` |

### Intermediate & Output Datasets

| Dataset | Description |
|---------|-------------|
| `category_to_naics.csv` | Category → NAICS bridge |
| `line_level_emissions_with_imputation.csv` | Per-PO line emissions with imputation flags |
| `supplier_summary_with_priority.csv` | Aggregated supplier spend, emissions, priority score |
| `supplier_predictions.csv` | Actual vs predicted emissions (ML output) |

---

## ⚙️ Methodology

### ETL Pipeline (`notebooks/scope3_pipeline.ipynb`)

1. **Load & Validate** — Procurement (777 rows) and emission factor (1,016 rows) datasets
2. **Filter** — Retain `Delivered` orders only (633 valid PO lines)
3. **Spend Calculation** — `Spend_USD = Quantity × Effective_Price` (uses Negotiated_Price where available)
4. **NAICS Mapping** — Manual mapping of 5 procurement categories to NAICS-6 codes
5. **EF Join + Imputation** — Left-join with emission factors; missing EFs imputed via NAICS-median
6. **Emissions** — `Emissions_tCO2e = Spend_USD × EF_kg_per_USD / 1000`
7. **Priority Score** — Composite score: `0.5 × Emissions_Norm + 0.5 × Spend_Norm`

### ML Model (`notebooks/ml_model.ipynb`)

| Model | MAE | R² | RMSE | MAPE (%) |
|-------|-----|----|------|----------|
| Linear Regression | 0.3971 | -4.58 | 0.5015 | 5.26 |
| Ridge Regression | 0.2433 | -0.68 | 0.2747 | 3.22 |
| **Random Forest** ✅ | **0.1908** | **0.0333** | **0.2087** | **2.49** |
| Gradient Boosting | 0.2349 | -0.70 | 0.2768 | 3.14 |

**Best model: Random Forest** (lowest MAE & MAPE, highest R²)

**Features used:** `log_spend`, `PO_Lines`, `spend_per_po`, `Period` (one-hot)

**Target:** `log(Total_Emissions_tCO2e)` — log-transformed for normality

---

## 📊 Key Insights

- **Total Scope-3 Emissions:** ~18,169 tCO₂e across 633 delivered PO lines
- **Total Procurement Spend:** $36.5M
- **Top emitter:** Beta_Supplies — 2,757 tCO₂e (Priority Score: 1.0)
- **100% emission factor coverage** achieved after NAICS-median imputation
- **Raw Materials** category drives the highest emissions intensity (EF: 1.51 kg CO₂e/USD)

### Top 5 Suppliers by Emissions

| Supplier | Total Emissions (tCO₂e) | Total Spend (USD) | Priority Score |
|----------|------------------------|-------------------|----------------|
| Beta_Supplies | 2,756.88 | $4,635,743 | 1.000 |
| Gamma_Co | 2,476.18 | $3,405,407 | 0.813 |
| Delta_Logistics | 2,333.84 | $4,017,225 | 0.855 |
| Gamma_Co (2022) | 1,738.75 | $3,880,918 | 0.731 |
| Epsilon_Group | 1,698.48 | $3,549,121 | 0.687 |

---

## 📈 Dashboard

An interactive **Power BI dashboard** was built on top of `supplier_summary_with_priority.csv` and `supplier_predictions.csv`, covering:
- Supplier-level emissions heatmap
- Priority score ranking table
- Actual vs Predicted emissions scatter plot
- Year-over-year emissions trends
- Category-level emission intensity breakdown

> 📸 *Dashboard screenshots coming soon (see `/dashboard/` folder)*

---

## 🚀 How to Run

### Prerequisites
```bash
pip install pandas numpy scikit-learn matplotlib seaborn plotly
```

### Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/harshilnagwani/scope3-emissions-analytics.git
   cd scope3-emissions-analytics
   ```

2. **Place your datasets in `/data/`**
   - `procurement_dataset.csv`
   - `SupplyChainGHGEmissionFactors_v1.2_NAICS_CO2e_USD_2021.csv` (from [EPA](https://www.epa.gov/land-research/us-environmentally-extended-input-output-useeio-technical-content))

3. **Run ETL pipeline**
   ```bash
   jupyter notebook notebooks/scope3_pipeline.ipynb
   ```
   *(Outputs: `supplier_summary_with_priority.csv`, `line_level_emissions_with_imputation.csv`)*

4. **Run ML model**
   ```bash
   jupyter notebook notebooks/ml_model.ipynb
   ```
   *(Outputs: `supplier_predictions.csv`, `model_comparison.csv`, `feature_importance.csv`)*

5. **Open Power BI dashboard** (`.pbix` file — connect to output CSVs)

---

## 🛠️ Tech Stack

| Layer | Tools |
|-------|-------|
| Data Engineering | Python, Pandas, NumPy |
| Emissions Estimation | Spend-based methodology (USEEIO EFs) |
| Machine Learning | scikit-learn (Random Forest, Ridge, Gradient Boosting) |
| Visualization | Matplotlib, Seaborn, Plotly |
| Business Intelligence | Power BI, DAX |
| Database / Queries | SQL (PostgreSQL-compatible) |

---

## 🔮 Future Improvements

- [ ] Activity-based emissions estimation (beyond spend-based)
- [ ] Automated NAICS code mapping via NLP
- [ ] ESG risk score integration (supplier compliance, defect rate)
- [ ] Real-time pipeline with PostgreSQL + scheduled refreshes
- [ ] Scope-3 Category 4 (Upstream Transportation) expansion

---

## 📚 References

- [US EPA USEEIO Supply Chain Emission Factors v1.2](https://www.epa.gov/land-research/us-environmentally-extended-input-output-useeio-technical-content)
- [GHG Protocol Scope 3 Standard](https://ghgprotocol.org/scope-3-standard)
- [NAICS Code System](https://www.census.gov/naics/)

---

## 👤 Author

**Harshil Nagwani** — [GitHub](https://github.com/harshilnagwani) · [LinkedIn](https://www.linkedin.com/in/harshilnagwani/)
