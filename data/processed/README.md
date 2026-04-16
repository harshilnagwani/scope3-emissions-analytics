# ⚙️ Processed & Generated Datasets

These datasets are created automatically by running `notebooks/scope3_pipeline.ipynb`. They should not be manually edited.

---

## 🔗 1. `category_to_naics.csv`

### 📌 Description
Manual mapping between procurement categories and 6-digit NAICS industry codes.

### 📊 Schema
| Column | Type | Example |
|---|---|---|
| `Item_Category` | string | `Raw Materials` |
| `NAICS6` | string | `325199` |

### 🎯 Purpose
- Bridge between procurement data and EPA emission factors
- Generated once; extend manually if new categories are added

---

## 📄 2. `line_level_emissions_with_imputation.csv`

### 📌 Description
Transaction-level dataset — one row per procurement line — with spend and estimated Scope-3 emissions.

### 📊 Schema
| Column | Description |
|---|---|
| `PO_ID` | Purchase Order identifier |
| `Supplier` | Supplier name |
| `Item_Category` | Procurement category |
| `NAICS6` | NAICS code (mapped) |
| `Spend_USD` | Quantity × Effective Price |
| `EF_kg_per_USD` | Emission factor used |
| `EF_imputed` | `True` if EF was imputed (not direct match) |
| `Emissions_tCO2e` | `Spend_USD × EF / 1000` |

### 🎯 Purpose
- Granular emission tracking per transaction
- Data quality analysis (imputed vs. actual EF)
- Foundation for supplier-level aggregation

---

## 🏢 3. `supplier_summary_with_priority.csv` ← **CORE DATASET**

### 📌 Description
Supplier-level aggregated dataset used as input for the Power BI dashboard and ML model.

### 📊 Schema
| Column | Description |
|---|---|
| `Supplier` | Supplier name |
| `Period` | Year |
| `Total_Spend_USD` | Total annual spend |
| `Total_Emissions_tCO2e` | Total estimated Scope-3 emissions |
| `PO_Lines` | Number of procurement lines |
| `Imputed_Fraction` | Share of lines with imputed EF (data quality indicator) |
| `Spend_Norm` | Min-max normalised spend |
| `Emissions_Norm` | Min-max normalised emissions |
| `Priority_Score` | Composite risk score = 0.5×Emissions + 0.5×Spend |

### 🎯 Purpose
- Power BI dashboard primary data source
- ML model training input
- Supplier risk ranking & segmentation

---

## 🤖 4. `supplier_predictions.csv`

### 📌 Description
Output of `notebooks/ml_model.ipynb`. Adds ML predictions to the supplier summary dataset.

### 📊 Additional Columns
| Column | Description |
|---|---|
| `log_spend` | Log-transformed spend (model feature) |
| `pred_log` | Raw model output (log scale) |
| `Predicted_Emissions` | Back-transformed predicted emissions (tCO₂e) |

### 🎯 Purpose
- Compare predicted vs actual emissions
- Identify suppliers where spend-emissions relationship is anomalous
- Dashboard ML Validation page (Page 4)

---

## 📊 5. `model_comparison.csv`

### 📌 Description
Performance metrics for all trained regression models.

### 📊 Schema
| Column | Description |
|---|---|
| `Model` | Model name |
| `MAE` | Mean Absolute Error (log scale) |
| `R²` | Coefficient of Determination |
| `RMSE` | Root Mean Squared Error |
| `MAPE (%)` | Mean Absolute Percentage Error |

**Best Model:** Random Forest — MAE: 0.1908, R²: 0.9968, MAPE: 2.49%

---

## 📈 Feature Importance (`feature_importance.csv`)

Records feature importance scores from the best model. `log_spend` dominates (~0.97), confirming spend is the primary emissions driver.

---

## 🔑 Pipeline Flow Summary

```
Raw Procurement CSV
  → filter Delivered orders
  → calculate Spend_USD
  → map Category → NAICS6
  → join with EPA Emission Factors
  → impute missing EFs (NAICS median)
  → calculate Emissions_tCO2e
  → aggregate by Supplier + Period
  → compute Priority Score
  → export supplier_summary_with_priority.csv  ← dashboard + ML input
```
