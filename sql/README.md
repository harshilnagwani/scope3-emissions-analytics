# 🗄️ SQL Query Reference — Scope-3 Emissions Analytics

All queries are **PostgreSQL-compatible** and demonstrate the full range of SQL skills required for a Data Analyst role: aggregations, multi-table JOINs, CTEs, and window functions.

---

## 📋 Table Schemas

### `procurement_data`
| Column | Type | Description |
|--------|------|-------------|
| `PO_ID` | VARCHAR | Purchase order identifier |
| `Supplier` | VARCHAR | Supplier name |
| `Item_Category` | VARCHAR | Product category |
| `Order_Date` | DATE | Order placement date |
| `Order_Status` | VARCHAR | Delivered / Cancelled / Pending |
| `Quantity` | INTEGER | Units ordered |
| `Unit_Price` | NUMERIC | Listed price per unit |
| `Negotiated_Price` | NUMERIC | Final agreed price (preferred) |

### `category_naics_mapping`
| Column | Type | Description |
|--------|------|-------------|
| `Item_Category` | VARCHAR | Procurement category |
| `NAICS6` | VARCHAR | 6-digit NAICS industry code |

### `emission_factors`
| Column | Type | Description |
|--------|------|-------------|
| `NAICS6` | VARCHAR | 6-digit NAICS code |
| `EF_kg_per_USD` | NUMERIC | kg CO₂e emitted per USD of spend |

### `supplier_summary`
| Column | Type | Description |
|--------|------|-------------|
| `Supplier` | VARCHAR | Supplier name |
| `Period` | INTEGER | Year |
| `Total_Spend_USD` | NUMERIC | Total annual spend |
| `Total_Emissions_tCO2e` | NUMERIC | Total estimated Scope-3 emissions |
| `PO_Lines` | INTEGER | Number of procurement lines |
| `Priority_Score` | NUMERIC | Composite risk score (0–1) |

---

## 🔍 Query Index

| # | Query | Techniques Used |
|---|-------|-----------------|
| 1 | Supplier Spend Aggregation | `GROUP BY`, `COALESCE`, `EXTRACT`, `WHERE` filter |
| 2 | Emissions per Supplier & Category | Multi-table `JOIN`, aggregation, derived columns |
| 3 | Top 10 by Priority Score | CTE, window functions (`MIN/MAX OVER`, `RANK OVER`) |
| 4 | Emission Factor Coverage Audit | `LEFT JOIN`, `CASE WHEN`, data quality metrics |
| 5 | Year-over-Year Emissions Trend | CTE, `LAG()` window function, `PARTITION BY` |

---

## ▶️ How to Run

```bash
# Load data into PostgreSQL first
psql -U your_user -d your_db

\copy procurement_data FROM 'data/procurement_dataset.csv' CSV HEADER;
\copy emission_factors FROM 'data/SupplyChainGHGEmissionFactors_v1.2_NAICS_CO2e_USD_2021.csv' CSV HEADER;
\copy supplier_summary FROM 'data/supplier_summary_with_priority.csv' CSV HEADER;

-- Then run queries
\i sql/sample_queries.sql
```

---

> 💡 **Tip for recruiters:** Query #3 demonstrates composite priority scoring using window functions — the same logic as the Python `safe_normalize()` function in `notebooks/scope3_pipeline.ipynb`, implemented purely in SQL.
