# SQL-Value-Window-Function-Practice
### TOOL: MySQL
### DATE: 05-03-2026

## OVERVIEW
This repository demonstrates value window functions in MySQL, including LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE(), MIN(), MAX(), and RANK().

We cover: 

* Month-over-Month (MoM) analysis

* Year-over-Year (YoY) analysis

* Customer loyalty

* Product sales extremes

---

### TASK 1: Month-over-Month (MoM) Sales Analysis
Objective: Analyze MoM sales performance by calculating the percentage change between the current and previous month.

```sql
SELECT *,
       current_month_sales - previous_month_sales AS MoM_Change,
       ROUND((current_month_sales - previous_month_sales) / previous_month_sales * 100, 1) AS Percentage_change
FROM (
    SELECT DATE_FORMAT(orderdate, '%Y-%m') AS order_month,
           SUM(sales) AS current_month_sales,
           LAG(SUM(sales)) OVER(ORDER BY DATE_FORMAT(orderdate, '%Y-%m')) AS previous_month_sales
    FROM salesdb.orders
    GROUP BY DATE_FORMAT(orderdate, '%Y-%m')
) t;
```
### Example Output

| order_month | current_month_sales | previous_month_sales | MoM_Change | Percentage_change |
| ----------- | ------------------- | -------------------- | ---------- | ----------------- |
| 2023-01     | 15000               | NULL                 | NULL       | NULL              |
| 2023-02     | 18000               | 15000                | 3000       | 20.0              |
| 2023-03     | 21000               | 18000                | 3000       | 16.7              |

---

Task 2: Year-over-Year (YoY) Sales Analysis
Objective: Compare sales of the same month from the previous year.

Note: Dataset contains only one year; query effectively repeats MoM logic.

```sql
SELECT *,
       current_monthly_sales - previous_monthly_sales AS YoY_change,
       ROUND((current_monthly_sales - previous_monthly_sales) / previous_monthly_sales * 100, 1) AS YoY_perc_change
FROM (
    SELECT DATE_FORMAT(orderdate, '%Y-%m') AS order_month,
           SUM(sales) AS current_monthly_sales,
           LAG(SUM(sales)) OVER(ORDER BY DATE_FORMAT(orderdate, '%Y-%m')) AS previous_monthly_sales
    FROM salesdb.orders
    GROUP BY DATE_FORMAT(orderdate, '%Y-%m')
) t;
```

### Example Output

| order_month | current_monthly_sales | previous_monthly_sales | YoY_change | YoY_perc_change |
| ----------- | --------------------- | ---------------------- | ---------- | --------------- |
| 2023-01     | 15000                 | NULL                   | NULL       | NULL            |
| 2023-02     | 18000                 | 15000                  | 3000       | 20.0            |

---

Task 3: Customer Loyalty Analysis

Objective: Rank customers based on average days between orders. Smaller averages = more loyal.

```sql
SELECT *,
       RANK() OVER(ORDER BY COALESCE(Avg_days, 999999)) AS loyalty_Rank
FROM (
    SELECT customerid,
           ROUND(AVG(DaysUntilNextOrder), 0) AS Avg_days
    FROM (
        SELECT orderid,
               customerid,
               orderdate AS currentorder,
               LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) AS NextOrder,
               DATEDIFF(
                   LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate),
                   orderdate
               ) AS DaysUntilNextOrder
        FROM salesdb.orders
    ) t
    GROUP BY customerid
) x;
```
### Example Output
| customerid | Avg_days | loyalty_Rank |
| ---------- | -------- | ------------ |
| 102        | 7        | 1            |
| 105        | 12       | 2            |
| 110        | 25       | 3            |
| 115        | NULL     | 4            |

---

Task 4: Product Sales Extremes
Objective: Find the lowest and highest sales per product and calculate the difference from the lowest sale.

```sql
SELECT
    orderid,
    productid,
    sales,
    FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales) AS Lowest_Sales,
    LAST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS Highest_Sales,
    MIN(sales) OVER(PARTITION BY productid ORDER BY sales) AS Lowest_Sales2,
    MAX(sales) OVER(PARTITION BY productid ORDER BY sales DESC) AS Highest_Sales2
FROM salesdb.orders;
```
### EXAMPLE OUTPUT
| orderid | productid | sales | Lowest_Sales | Highest_Sales | Lowest_Sales2 | Highest_Sales2 |
| ------- | --------- | ----- | ------------ | ------------- | ------------- | -------------- |
| 1       | A         | 50    | 50           | 200           | 50            | 200            |
| 2       | A         | 100   | 50           | 200           | 50            | 200            |
| 3       | A         | 200   | 50           | 200           | 50            | 200            |
| 4       | B         | 80    | 80           | 150           | 80            | 150            |

---
✅ Key Takeaways

* LAG() / LEAD(): Compare previous or next row values within a partition.

* FIRST_VALUE() / LAST_VALUE(): Retrieve first/last values based on custom ordering.

* MIN() / MAX(): Simple window functions to find extremes per partition.

* RANK(): Rank rows based on a metric, handling ties.

* DATEDIFF(): Calculate intervals between dates, useful for loyalty and retention analysis.
