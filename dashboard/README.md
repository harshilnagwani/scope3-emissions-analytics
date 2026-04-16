# 📊 Power BI Dashboard — Scope-3 Emissions & Supplier Risk

This dashboard visualises the complete Scope-3 emissions analysis pipeline — from procurement spend to supplier risk scores and ML predictions.

---

## 🗂️ Dashboard Pages

### Page 1 — Executive Overview
![Executive Overview](dashboard_page_1.png)

**KPI Cards:** Total Emissions (tCO₂e) · Total Spend (USD) · Avg Priority Score  
**Visuals:** Top Suppliers by Emissions (bar) · Emissions Trend by Period (line)

---

### Page 2 — Supplier & Category Analysis
![Supplier & Category Analysis](dashboard_page_2.png)

**Visuals:**
- Scatter Plot: Spend vs Emissions (bubble size = Priority Score)
- Emissions by Category (bar chart)
- Data Quality Distribution (donut — Secondary vs Imputed EF)

---

### Page 3 — Supplier Drilldown
![Supplier Drilldown](dashboard_page_3.png)

**Visuals:**
- Interactive supplier table: Spend · Emissions · PO Lines · Priority Score · Risk Band
- Slicers: Supplier · Period · Category

---

## 🧠 Tools & Data Sources

| Tool | Usage |
|---|---|
| Power BI Desktop | Dashboard authoring |
| DAX Measures | Priority Score, YoY Δ Emissions, Risk Band classification |
| `supplier_summary_with_priority.csv` | Primary data source |
| `supplier_predictions.csv` | ML Validation page |

---

## 📌 Key DAX Measures Used

```dax
-- Total Estimated Emissions
Total Emissions (tCO2e) = SUM(supplier_summary[Total_Emissions_tCO2e])

-- Avg Priority Score
Avg Priority Score = AVERAGE(supplier_summary[Priority_Score])

-- Risk Band classification
Risk Band =
    IF([Avg Priority Score] >= 0.7, "High",
    IF([Avg Priority Score] >= 0.4, "Medium", "Low"))

-- YoY Emissions Change
YoY Δ Emissions =
    VAR curr = [Total Emissions (tCO2e)]
    VAR prev = CALCULATE([Total Emissions (tCO2e)],
                  DATEADD(supplier_summary[Period], -1, YEAR))
    RETURN DIVIDE(curr - prev, prev, BLANK())
```

---

## 🎯 Business Value

- Identifies **high-risk suppliers** driving majority of Scope-3 footprint
- Supports **GHG Protocol Category 1** sustainability reporting
- Enables **data-driven procurement decisions** to reduce emissions
- Provides **audit-ready** emission traceability from PO line to supplier total
