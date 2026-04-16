# 📥 Raw Datasets

This project uses two publicly available datasets to estimate Scope-3 emissions and perform supplier risk analysis.

---

## 🧾 1. Procurement KPI Analysis Dataset

**Source:** [Kaggle — Procurement KPI Analysis Dataset](https://www.kaggle.com/datasets/)

### 📌 Description
This dataset represents procurement operations of a global enterprise, including supplier performance, purchasing activity, and cost metrics.

### 📊 Key Columns
| Column | Description |
|---|---|
| `Supplier` | Supplier name |
| `Item_Category` | Procurement category (Electronics, MRO, Raw Materials, etc.) |
| `Quantity` | Units ordered |
| `Unit_Price` | Listed price per unit |
| `Negotiated_Price` | Final negotiated price (used for spend calculation) |
| `Order_Status` | Delivered / Cancelled / Pending |
| `Order_Date` | Date of purchase order |

### 🎯 Usage in Project
- Calculated **Total Spend (USD)** per supplier per period
- Identified **active suppliers** (Delivered orders only)
- Enabled **time-based analysis** by year (Period)
- Computed **Effective Price** = `Negotiated_Price` (fallback: `Unit_Price`)

---

## 🌍 2. Supply Chain GHG Emission Factors Dataset

**Source:** [Kaggle — Supply Chain GHG Emission Factors v1.2](https://www.kaggle.com/datasets/)

### 📌 Description
Greenhouse gas emission factors for 1,000+ U.S. commodities based on NAICS classification (U.S. EPA / USEEIO model). Factors are expressed in **kg CO₂e per USD of spend**.

### 📊 Key Columns
| Column | Description |
|---|---|
| `2017 NAICS Code` | 6-digit industry classification code |
| `Supply Chain Emission Factors with Margins` | EF including supply chain overhead (used) |
| `Supply Chain Emission Factors without Margins` | EF excluding overhead (fallback) |

### 🎯 Usage in Project
- Mapped procurement categories → NAICS codes
- Converted **spend (USD) → emissions (tCO₂e)**
- Used **"with margins"** EF for conservative, accurate estimates
- Imputed missing EFs using **NAICS median**

---

## ⚠️ Notes
- Data is **secondary** (not supplier-specific measurement)
- Methodology: **Spend-Based Scope-3 Estimation** (GHG Protocol Category 1)
- Suitable for **early-stage Scope-3 reporting** and supplier prioritisation
- Accuracy improves with primary supplier-level data
