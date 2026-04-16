-- ============================================================
-- Scope-3 Emissions Analytics — SQL Query Reference
-- Compatible with PostgreSQL
-- ============================================================

-- 1. Supplier Spend Aggregation (delivered orders only)
SELECT
    Supplier,
    EXTRACT(YEAR FROM Order_Date::DATE) AS Period,
    SUM(Quantity * COALESCE(Negotiated_Price, Unit_Price)) AS Total_Spend_USD,
    COUNT(*) AS PO_Lines
FROM procurement_data
WHERE Order_Status IN ('Delivered', 'Partially Delivered')
GROUP BY Supplier, EXTRACT(YEAR FROM Order_Date::DATE)
ORDER BY Total_Spend_USD DESC;


-- 2. Emissions per Supplier (after joining with emission factors)
SELECT
    p.Supplier,
    p.Item_Category,
    m.NAICS6,
    SUM(p.Quantity * COALESCE(p.Negotiated_Price, p.Unit_Price)) AS Total_Spend_USD,
    AVG(ef.EF_kg_per_USD) AS Avg_EF,
    SUM(p.Quantity * COALESCE(p.Negotiated_Price, p.Unit_Price) * ef.EF_kg_per_USD) / 1000.0 AS Total_Emissions_tCO2e
FROM procurement_data p
JOIN category_naics_mapping m ON p.Item_Category = m.Item_Category
JOIN emission_factors ef ON m.NAICS6 = ef.NAICS6
WHERE p.Order_Status = 'Delivered'
GROUP BY p.Supplier, p.Item_Category, m.NAICS6
ORDER BY Total_Emissions_tCO2e DESC;


-- 3. Top 10 Suppliers by Emissions with Priority Score (Window Function)
WITH supplier_stats AS (
    SELECT
        Supplier,
        SUM(Total_Spend_USD) AS Total_Spend,
        SUM(Total_Emissions_tCO2e) AS Total_Emissions,
        COUNT(*) AS PO_Lines
    FROM supplier_summary
    GROUP BY Supplier
),
normalized AS (
    SELECT
        Supplier,
        Total_Spend,
        Total_Emissions,
        PO_Lines,
        (Total_Emissions - MIN(Total_Emissions) OVER()) /
            NULLIF(MAX(Total_Emissions) OVER() - MIN(Total_Emissions) OVER(), 0) AS Emissions_Norm,
        (Total_Spend - MIN(Total_Spend) OVER()) /
            NULLIF(MAX(Total_Spend) OVER() - MIN(Total_Spend) OVER(), 0) AS Spend_Norm
    FROM supplier_stats
)
SELECT
    Supplier,
    Total_Spend,
    Total_Emissions,
    PO_Lines,
    ROUND((0.5 * Emissions_Norm + 0.5 * Spend_Norm)::NUMERIC, 4) AS Priority_Score,
    RANK() OVER (ORDER BY Total_Emissions DESC) AS Emissions_Rank
FROM normalized
ORDER BY Priority_Score DESC
LIMIT 10;


-- 4. Emission Factor Coverage Check (Imputation Audit)
SELECT
    Item_Category,
    COUNT(*) AS Total_Lines,
    SUM(CASE WHEN ef.EF_kg_per_USD IS NULL THEN 1 ELSE 0 END) AS Missing_EF,
    ROUND(
        100.0 * SUM(CASE WHEN ef.EF_kg_per_USD IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS Coverage_Pct
FROM procurement_data p
JOIN category_naics_mapping m ON p.Item_Category = m.Item_Category
LEFT JOIN emission_factors ef ON m.NAICS6 = ef.NAICS6
WHERE p.Order_Status = 'Delivered'
GROUP BY Item_Category
ORDER BY Missing_EF DESC;


-- 5. Year-over-Year Emissions Trend per Supplier (LAG function)
WITH yearly AS (
    SELECT
        Supplier,
        Period,
        SUM(Total_Emissions_tCO2e) AS Yearly_Emissions
    FROM supplier_summary
    GROUP BY Supplier, Period
)
SELECT
    Supplier,
    Period,
    Yearly_Emissions,
    LAG(Yearly_Emissions) OVER (PARTITION BY Supplier ORDER BY Period) AS Prev_Year_Emissions,
    ROUND(
        100.0 * (Yearly_Emissions - LAG(Yearly_Emissions) OVER (PARTITION BY Supplier ORDER BY Period))
        / NULLIF(LAG(Yearly_Emissions) OVER (PARTITION BY Supplier ORDER BY Period), 0),
        2
    ) AS YoY_Change_Pct
FROM yearly
ORDER BY Supplier, Period;
