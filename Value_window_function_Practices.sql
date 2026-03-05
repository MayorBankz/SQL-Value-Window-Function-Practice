/* VALUE WiNDOW FUNCTION 
TASK 1: Analyze the month-over-month (MoM) performance by finding the percentage change in sales between the current and previous month
Step by Step explanation
1. Aggregate monthly sales - calculates the total sales for each month 
2. Get previous month sales - LAG() looks at the previous row
		Because rows are ordered by Month(orderdate), it returns sales from the previous month.
3. Calculate MoM Chnage - This gives the absolute difference in sales between months
3. Calculate percentage change */

select *,
current_month_sales - previous_month_sales as MoM_Change,
round((current_month_sales - previous_month_sales) / previous_month_sales * 100, 1) as Percentage_change
from  
(select date_format(orderdate, '%Y - %m') as order_month,
sum(sales) as current_month_sales,
lag(sum(sales)) over(order by date_format(orderdate, '%Y - %m')) as previous_month_sales
from salesdb.orders
group by date_format(orderdate, '%Y - %m'))t
;

/* TASK 2: Analyze the Year-over-Year performance of sales by month. 
Write a SQL query that:

1Calculates the total sales for each month of each year
2️ Uses a value window function to get the sales of the same month in the previous year
3️ Calculates:

- YoY Sales Change

- YoY Percentage Change

Note: This task is impossible because the dataset contains only one year, hence the solution provided is a 'MoM' Analysis  */

select *,
current_monthly_sales - previous_monthly_sales as YoY_change,
round((current_monthly_sales - previous_monthly_sales) / previous_monthly_sales * 100, 1) as YoY_perc_change
from 
(Select 
date_format(orderdate, '%Y - %m') as order_month,
sum(sales) as current_monthly_sales,
lag(sum(sales)) over(order by date_format(orderdate, '%Y - %m')) as previous_monthly_sales
from salesdb.orders
group by date_format(orderdate, '%Y - %m')) t
;

/* TASK 3: Analyze customer loyalty by ranking customers based on the average days between their orders 
In order to analyze customer loyalty,
Rank customers based on the average days between their orders
Step-by-Step Explanation
- Calculate days between orders
	Use lead() to get the next orderdate
	calculates the number of days until next order
- Compute average days per customer
- Rank customers by loyalty*/

select *,
rank() over(order by coalesce(Avg_days, 999999)) as loyalty_Rank 
from (select customerid,
round(avg(DaysUntilNextOrder), 0) as Avg_days
from (select orderid,
customerid,
orderdate as currentorder,
lead(orderdate) over(partition by customerid order by orderdate) as NextOrder,
datediff(lead(orderdate) over(partition by customerid order by orderdate), orderdate) as DaysUntilNextOrder 
from salesdb.orders) t
group by customerid
)
 x;
 
 /* TASK 3: Find the lowest and highest sales for each product and find the difference between the current and lowest sales 
 Step-by-Step Explanation
 - First_value() - Lowest sales per product
	orders each product's sales ascending
	Returns the first value - the lowest sales for that product
- Last_value() - Highest sales per product
	- IMPORTANT: Without ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING, LAST_VALUE() might return the current row value instead of the true last value 
    - This syntax ensures the window extends to the end of the partition*/
 
 select
 orderid,
 productid, 
 sales,
 first_value(sales) over(partition by productid order by sales) as 'Lowest Sales',
 last_value(sales) over(partition by productid order by sales rows between current row and unbounded following) as 'Highest Sales',
 min(sales) over(partition by productid order by sales) as 'lowest sales2',
 max(sales) over(partition by productid order by sales desc) as 'Highest Sales2'
 from salesdb.orders
 ;
 
