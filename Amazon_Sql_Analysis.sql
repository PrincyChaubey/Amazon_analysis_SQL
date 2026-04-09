drop table  if exists amazon ; 
 create table amazon (
                      order_id	int,
                      order_date date,
					  product_id int,
                      product_category	varchar(16),
                      price	float,
                      discount_percent int,
					  quantity_sold	int,
                      customer_region varchar(15),
                      payment_method varchar(20),
                      rating	float,
                      review_count	int,
                      discounted_price	float,
                      total_revenue float
);
select count(*) from amazon;

select * from amazon limit 10;

##Monthly Revenue Trend

#Calculate total revenue per month.

select month(order_date) as month , 
       year(order_date) as year ,
       sum(total_revenue) as total_revenue
from amazon
group by month ,year
order by month ,year;

#Show month-over-month growth percentage.

select month ,
	year ,
    total_rev,
    lag(total_rev) over(order by month) as prv_rev ,
    (total_rev-lag(total_rev) over(order by year ,month))*100/lag(total_rev) over(order by year,month) as mom_growth_per
from(
select month(order_date) as month ,year(order_date) as year, sum(total_revenue) as total_rev from amazon group by year,month order by year,month )t;

#Identify the highest revenue month.

select month(order_date) as month , 
       sum(total_revenue) as total_revenue 
from amazon
group by month
order by total_revenue desc limit 5;


##Top 5 Revenue-Generating Products

#Find top 5 product_id by total revenue.

select product_id,
       sum(total_revenue) as total 
from amazon
group by product_id 
order by total desc limit 5;

#Show their contribution % to overall revenue.

select product_id,
       (sum(total_revenue) /(select sum(total_revenue) from amazon )*100) as percen_contri
from amazon  
group by product_id 
order by percen_contri desc ;


##3Category-wise Profitability Analysis

#Total revenue by product_category

select product_category,
       sum(total_revenue)
from amazon
group by product_category;

#Average discount per category
select product_category,
       avg(discount_percent) 
from amazon
group by product_category;

#Average rating per category
select product_category,
	   avg(rating) as avg_rating 
from amazon
group by product_category;

#Rank categories by revenue
select product_category,
       sum(total_revenue) as revenue ,
       rank() over(order by sum(total_revenue)desc) as rnk 
from amazon 
group by product_category;

##4️Regional Sales Performance

#Total revenue per customer_region
select customer_region,
       sum(total_revenue)
from amazon
group by customer_region;

#Average order value (AOV) per region
select customer_region,
       sum(total_revenue)/count(distinct order_id) as aov
from amazon 
group by customer_region;

#Best-performing region by revenue
select customer_region,
       sum(total_revenue)  
from amazon
group by customer_region 
order by sum(total_revenue) desc limit 1;


##5️iscount Impact Analysis

#Compare revenue where discount_percent > 20% vs <= 20%
select 
    case
       when discount_percent>20 then 'High_discount'
       when discount_percent <=20 then 'Low_discount'
	end as discount_category,
    sum(total_revenue)
from amazon 
group by discount_category;

select * from amazon limit 5;
#Does higher discount increase quantity sold?
select 
    case
       when discount_percent <10 then '0-10%'
	   when discount_percent between 10 and 20 then '10-20%'
       when discount_percent between 21 and 30 then '20-30%'
       else '30%+'
	end as discount_range,
    avg(quantity_sold) as avg_quantity ,
    sum(quantity_sold) as total_quantity
    from amazon
    group by discount_range
    order by discount_range;


#Calculate correlation trend manually using grouped averages
select
    (AVG(avg_discount * avg_quantity) 
     - AVG(avg_discount) * AVG(avg_quantity)) 
    /
    (STDDEV(avg_discount) * STDDEV(avg_quantity)) 
    AS grouped_correlation
from (
    select
        case
            when discount < 10 then '0-10%'
            when discount between 10 and 20 then '10-20%'
            when discount between 21 and 30 then '20-30%'
            else'30%+'
        end as discount_range,

        AVG(discount) AS avg_discount,
        AVG(quantity) AS avg_quantity
    FROM amazon_data
    GROUP BY discount_range
) t;


##6️Payment Method Analysis

#Revenue by payment_method
select payment_method,sum(total_revenue) as revenue from amazon group by payment_method;

#Average order value per payment method
SELECT 
    payment_method,
    SUM(total_revenue) / COUNT(DISTINCT order_id) AS avg_order_value
FROM amazon
GROUP BY payment_method;
select * from amazon limit 5;

#Which payment method has highest-rated orders?
select payment_method ,
        avg(rating) as avg_rating,
        count(*) as total_orders 
from amazon 
group by payment_method 
order by avg_rating desc limit 1;


##7️Customer Satisfaction Analysis

#Average rating per category
select product_category,
       avg(rating) as avg_rating,
       count(*) as total_review
from amazon
group by product_category;

#Categories with rating < overall average rating
select 
    product_category,
    avg(rating) as avg_rating
from amazon
group by product_category
having avg(rating) < (select avg(rating) from amazon);

#Region with highest average rating
select 
    customer_region,
    avg(rating) as avg_rating,
    count(*) as total_orders
from amazon
group by  customer_region
having COUNT(*) > 50
order by  avg_rating desc
limit 1;


##8 Cohort Analysis (Monthly)
#Group product by first selling month
SELECT 
    product_id,
    DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
FROM amazon
GROUP BY product_id;

#Track revenue from each cohort over next months
SELECT 
    c.cohort_month,

    TIMESTAMPDIFF(
        MONTH,
        c.cohort_date,
        DATE_FORMAT(a.order_date, '%Y-%m-01')
    ) AS month_number,

    SUM(a.price * a.quantity_sold) AS revenue
FROM amazon a
JOIN (
    SELECT 
        product_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m-01')) AS cohort_date,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM amazon
    GROUP BY product_id
) c
ON a.product_id = c.product_id

GROUP BY c.cohort_month, month_number
ORDER BY c.cohort_month, month_number;


##Rolling 3-Month Revenue
#Calculate rolling 3-month moving average revenue

with monthly_revenue as (
    select year(order_date) as year ,month(order_date) as month ,
    sum(total_revenue) as total_rev from amazon 
    group by year,month )
select year,
      month ,
      avg(total_rev) over (order by year,month rows between 2 preceding and current row )as rolling_3_rev 
from monthly_revenue 
order by year ,month;

##🔟 Revenue Concentration (Pareto 80/20 Rule)
#Identify top 20% products contributing to 80% revenue

with Product_revenue as (
    select product_id ,
       sum(total_revenue) as total_revenue 
from amazon 
group by product_id),
cum_calcu as ( 
    select * ,
        sum(total_revenue) over ( order by total_revenue desc) as cum_revenue,
		sum( total_revenue) over () as total_revenue_all 
	from product_revenue
)
select * from cum_calcu where cum_revenue/total_revenue_all <0.8;

##Price Elasticity Insight
#Group data by price ranges
#Analyze quantity_sold per price bucket
 select 
     case
         when price <=200 then '0-200'
         when price <=400 then '201-400'
         else 'Above 400'
	end as price_category,
sum(quantity_sold) as total_qsold from amazon 
group by price_category;
    

#Determine if lower price increases volume significantly
SELECT 
    CASE
        WHEN price <= 200 THEN '0-200'
        WHEN price <= 400 THEN '201-400'
        ELSE 'Above 400'
    END AS price_bucket,
    SUM(quantity_sold) AS total_quantity,
    AVG(quantity_sold) AS avg_quantity
FROM amazon
GROUP BY price_bucket
ORDER BY MIN(price);


##Detect Seasonal Trends
#Extract month & quarter
SELECT month(order_date) as month,
      monthname(order_date) as month_name,
      quarter(order_date) as qutr 
from amazon;

#Compare revenue across quarters
select quarter(order_date) as quarter ,
       sum(total_revenue) as tot_revenue 
from amazon 
group by quarter;

#Identify seasonal peak months
select month(order_date) as month ,
       sum(total_revenue) as tot_revenue 
from amazon 
group by month 
order by tot_revenue desc;

##RFM-Style Analysis (Advanced Logic)
Using:
Recency → latest order_date
Frequency → count(order_id)
Monetary → total revenue

#Rank regions or products based on RFM score.
select * ,
       datediff(current_date,max(order_date) as recency 
       count(product_id) as frequency 
       sum(total_revenue) as monetary 
from amazon 
group by region;



##Outlier Detection

#Find products with unusually high discount but low sales
SELECT product_id, SUM(quantity_sold) AS total_quantity, AVG(discount_percent) AS avg_discount
FROM amazon
GROUP BY product_id
HAVING avg_discount >=20 AND total_quantity < 5;   

   
#Detect regions with abnormal average revenue
##15 Revenue Leakage Analysis

#price * quantity_sold
SELECT *,
       (revenue_1 - revenue_2) AS revenue_loss 
from (select * ,(price* quantity_sold) as revenue_1 ,
                   (discounted_price* quantity_sold) as revenue_2 
from amazon) t;

#Show % revenue sacrificed per categoryamazon
SELECT 
    product_category,
    SUM(price * quantity_sold) AS potential_revenue,
    SUM(discounted_price * quantity_sold) AS actual_revenue,
    ROUND(
        (SUM(price * quantity_sold) - SUM(discounted_price * quantity_sold)) / SUM(price * quantity_sold) * 100,
        2
    ) AS pct_revenue_sacrificed
FROM amazon
GROUP BY product_category
ORDER BY pct_revenue_sacrificed DESC;


##Find products with revenue higher than average revenue
select * from (
select product_id ,
       sum(total_revenue) as total_revenue
from amazon 
group by product_id) x
where total_revenue > (select avg(Total_revenue) from (select product_id,sum(total_revenue) total_revenue from amazon group by product_id)t);


select * from 
(
select product_id	,
sum( total_revenue) as total_revenue,
(select avg(total_revenue) 
from (
select product_id,sum(total_revenue) as total_revenue from amazon group by product_id)t) as avg_revenue from amazon group by product_id)x 
where total_revenue >avg_revenue;

select* from amazon limit 5;
##Find orders where quantity is greater than average quantity
 select * from (select order_id,quantity_sold,(select avg(quantity_sold) from amazon) as avg_quantity from amazon)t where quantity_sold> avg_quantity ;


##Find categories with total revenue above overall average revenue
select product_category ,
       sum(total_revenue)as total_reve ,
       (select avg(total_revenue) from amazon) as overall_rev
from amazon 
group by product_category  
having total_reve > Overall_rev;

##Find top-selling products (above average total revenue)
select * from (
select product_id ,
       sum(total_revenue) as total_revenue
from amazon 
group by product_id) x
where total_revenue > (select avg(Total_revenue) from (select product_id,sum(total_revenue) total_revenue from amazon group by product_id)t);

##5️ Find customers/regions with highest frequency than average

select * from (
    select customer_region,
    count(order_id) as frequency 
from amazon 
group by customer_region) t 
where frequency >   
(select avg(frequency) from ( select customer_region,count(order_id) as frequency from amazon group by customer_region )x);



##6 Find second highest revenue
select max(total_revenue) as second_highest
from amazon 
where total_revenue < (
    select max(total_revenue) as highest_revenue 
    from amazon 
);

##Find products not in top 5 revenue
select product_id,sum(total_revenue) from amazon group by product_id having product_id not in ( select product_id from (
select product_id ,sum(total_revenue) as product_revenue from amazon group by product_id order by product_revenue desc limit 5)t);

select * from amazon limit 5;

##8️⃣ Find categories contributing more than 50% of total revenue
select * from (select product_category,
	   sum(total_revenue) as product_revenue,
       (select sum(total_revenue) from amazon) as total_revenue ,
       sum(total_revenue) /(select sum(total_revenue) from amazon) as revenue_ratio
from amazon
group by product_category)t
where revenue_ratio>=0.5;


##9️⃣ Find orders where revenue is higher than previous day's average

SELECT *
FROM (
    SELECT 
        order_date,
        daily_revenue,
        LAG(daily_revenue) OVER (ORDER BY order_date) AS prev_day_avg
    FROM (
        SELECT 
            order_date,
            SUM(total_revenue) AS daily_revenue
        FROM amazon
        GROUP BY order_date
    ) t1
) t2
WHERE daily_revenue > prev_day_avg;

##Find products whose revenue is higher than their category average
SELECT 
    product_id,
    category_id,
    product_revenue,
    category_avg_revenue
FROM (
    SELECT 
        product_id,
        category_id,
        SUM(total_revenue) AS product_revenue,
        AVG(SUM(total_revenue)) OVER (PARTITION BY category_id) AS category_avg_revenue
    FROM amazon
    GROUP BY product_id, category_id
) t
WHERE product_revenue > category_avg_revenue;

