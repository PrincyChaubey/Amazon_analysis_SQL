# 🛒 Amazon Sales Data Analysis (SQL Project)

## 📌 Project Overview

This project focuses on analyzing an Amazon sales dataset using SQL to extract meaningful business insights.
The goal is to understand customer behavior, pricing strategies, and revenue patterns.

---

## 📊 Objectives

* Analyze sales trends and patterns
* Understand price impact on sales volume
* Identify high-performing categories/products
* Apply advanced SQL concepts like window functions and aggregations

---

## 🧾 Dataset Description

The dataset contains the following columns (example):

* `order_id` – Unique order identifier
* `order_date` – Date of purchase
* `product_id` – Product identifier
* `category` – Product category
* `price` – Selling price
* `quantity_sold` – Number of units sold
* `revenue` – Total revenue

---

## 🔍 Key Analysis Performed

### 1️⃣ Price Bucket Analysis

* Grouped products into price ranges
* Analyzed quantity sold per bucket
* Insight: Lower price ranges tend to have higher sales volume

---

### 2️⃣ Price Elasticity Insight

* Checked how changes in price affect sales volume
* Compared quantity sold across different price levels
* Insight: Demand is sensitive to price changes

---

### 3️⃣ Revenue Concentration (Pareto Analysis)

* Identified top contributors to total revenue
* Used cumulative revenue approach (80/20 rule)
* Insight: A small percentage of products/categories generate most revenue

---

### 4️⃣ Declining Trend Analysis

* Used window functions (`LAG`) to compare daily sales
* Identified periods where sales continuously declined

---

### 5️⃣ Revenue Sacrificed Analysis

* Calculated % revenue lost due to discounts
* Compared potential vs actual revenue per category

---

### 6️⃣ RFM-Style Analysis (Advanced)

* Applied Recency, Frequency, Monetary logic on regions/products
* Ranked entities based on performance
* Identified high-value and low-performing segments

---

## 🛠️ Tools & Technologies

* SQL (MySQL)
* Window Functions (`LAG`, `SUM OVER`, `NTILE`)
* Aggregations (`SUM`, `COUNT`, `GROUP BY`)

---

## 📈 Key Insights

* Lower-priced products generally drive higher sales volume
* A small portion of products contributes to the majority of revenue
* Certain categories sacrifice more revenue due to discounts
* High-performing regions/products can be identified using RFM logic

---

## 📂 Project Structure

```
amazon-analysis/
├── queries.sql
├── RFM-analysis.sql
├── revenue-sacrifice.sql
├── analysis-notes.md
└── README.md
```

---

## 🚀 How to Use

1. Import dataset into MySQL
2. Run SQL queries from `.sql` files
3. Analyze outputs and insights

---

## 📌 Future Improvements

* Add data visualizations (Power BI / Tableau)
* Automate analysis using Python
* Expand dataset for deeper insights

---

## 👤 Author

Princy Chaubey
Data Analyst

---

## ⭐ Conclusion

This project demonstrates practical use of SQL for real-world business analysis, including pricing strategy, customer behavior, and revenue optimization.
