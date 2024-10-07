
/*[1] VARIATION OF DELIVERY TIME ACROSS CITIES*/


with cte1 as
(select s.order_id, s.city, datediff(minute, s.order_time, s.receive_time) as delivery_time, a.avg_delivery_time,
case
when datediff(minute, s.order_time, s.receive_time) > a.avg_delivery_time then 'above average'
when datediff(minute, s.order_time, s.receive_time) <= a.avg_delivery_time then 'below average' end as delivery_judge
from swiggy s
left join 
(select city, avg(datediff(minute, order_time, receive_time)) as avg_delivery_time
from swiggy
group by city) a
on s.city = a.city),

cte2 as (select city, count(*) total_orders, avg_delivery_time,
sum(case when delivery_judge = 'below average' then 1 else 0 end) as no_below_average,
sum(case when delivery_judge = 'above average' then 1 else 0 end) as no_above_average
from cte1
group by city, avg_delivery_time)

select *, round((no_below_average/cast (total_orders as float))*100.0, 0) as below_avg_perct,
round((no_above_average/cast (total_orders as float))*100.0, 0) as above_avg_perct
from cte2

/*
|--------|--------------|-------------------|-------------------|-------------------|-------------|-------------|
| City   | Total Orders | Avg Delivery Time | No. Below Average | No. Above Average | Below Avg % | Above Avg % |
|--------|--------------|-------------------|-------------------|-------------------|-------------|-------------|
| Jaipur | 33           | 30                | 18                | 15                | 55%         | 45%         |
| Noida  | 54           | 34                | 28                | 26                | 52%         | 48%         |
| Pune   | 8            | 36                | 4                 | 4                 | 50%         | 50%         |
|--------|--------------|-------------------|-------------------|-------------------|-------------|-------------|
*/

/*INSIGHT
Jaipur had the fastest delivery times, with 55% of orders delivered faster than the average time, 
while Pune had the slowest, with 50% of deliveries taking longer than the average.*/


/*[2] IMPACT OF DISCOUNT ON SAVINGS AND ORDER VALUE */


----No of orders where coupon is applied & not applied and their %-------

with cte1 as (select
count(1) as total_orders,
sum(case when coupon_applied = 'Not applied' then 1 else 0 end) as not_applied,
sum(case when coupon_applied != 'Not applied' then 1 else 0 end) as coupon_applied
from swiggy)

select *,
round(cast(not_applied as float)*100.0/total_orders, 0) as not_applied_perct,
round(cast(coupon_applied as float)*100.0/total_orders, 0) as applied_perct
from cte1

/*
|--------------|-------------|----------------|--------------------|----------------|
| total_orders | not_applied | coupon_applied | not_applied_perct  | applied_perct  |
|--------------|-------------|----------------|--------------------|----------------|
| 95           | 21          | 74             | 22                 | 78             |
|--------------|-------------|----------------|--------------------|----------------|
*/

----Savings due to use of discount--------

select sum(coupon_discount) as coupon_saving_amt,
sum(final_paid) as total_paid,
sum(final_paid) + sum(coupon_discount) as coupon_and_paid_total,
round(sum(coupon_discount)*100/(sum(final_paid) + sum(coupon_discount)), 0) as saving_perct
from swiggy

/*
|--------------------|-----------|---------------------|------------------|
| coupon_saving_amt  |total_paid |coupon_and_paid_total| saving_perct     |
|--------------------|-----------|---------------------|------------------|
| 6956.31            | 18096     | 25052.31            | 28               |
|--------------------|-----------|---------------------|------------------|
*/

-----Average order value with and without discount & average saving-----

with cte1 as (select
case when is_coupon_applied = 'False' then avg(final_paid) end as without_coupon_avg,
case when is_coupon_applied = 'True' then avg(final_paid) end as with_coupon_avg
from swiggy
group by is_coupon_applied)

select round(max(without_coupon_avg),2) as avg_no_coupon, 
round(max(with_coupon_avg),2) as avg_when_coupon,
round(max(without_coupon_avg) - max(with_coupon_avg), 0) as avg_saving_with_coupon
from cte1

/*
|---------------------|------------------|-----------------------|
| avg_no_coupon       |avg_when_coupon   |avg_saving_with_coupon |
|---------------------|------------------|-----------------------|
| 194.14              | 189.45           | 5                     |
|---------------------|------------------|-----------------------|
*/

/*INSIGHT
78% of total orders utilized discounts, resulting in an impressive 28% savings on overall spending.
demonstrating that discounts effectively encourage purchases without significantly impacting order value.
*/

/*[3] TREND OF LATE NIGHT ORDERS IN DIFFERENT CITIES*/


----City, order hour, no of orders & total spent-----

select city, datepart(hour, order_time) as order_hr,
count(1) no_order_placed,
sum(final_paid) as total_amt
from swiggy
group by city, datepart(hour, order_time)
order by 1, 2 desc

/*
|-------|----------|----------------|------------|
| city  | order_hr |no_order_placed | total_amt  |
|-------|----------|----------------|------------|
| Jaipur| 23       | 3              | 505        |
| Jaipur| 22       | 6              | 1066       |
| Jaipur| 21       | 5              | 1145       |
| Jaipur| 19       | 1              | 234        |
| Jaipur| 17       | 1              | 208        |
|-------|----------|----------------|------------|
*/


----Categorising order time-----

/*6-11 =  early order
12-17 = mid day ordera
18-23 = night orders
0-5 = late night orders*/

-----% of orders in different delivery time categories in each city------

with cte1 as
(select
case
when datepart(hour, order_time) between 6 and 11 then 'early orders (6-11)'
when datepart(hour, order_time) between 12 and 17 then 'mid day orders (12-17)'
when datepart(hour, order_time) between 18 and 23 then 'night orders (18-23)'
when datepart(hour, order_time) between 0 and 5 then 'late night orders (0-5)'
end as order_time_category,
city, final_paid
from swiggy),

cte2 as 
(select order_time_category, city, sum(final_paid) as total_spent, count(1) as total_no
from cte1
group by order_time_category, city)

select *,
round(cast(total_no as float)*100/sum(total_no) over (partition by city),0) as city_orders_percent
from cte2

/*
|------------------------ |--------|------------|----------|---------------------|
| order_time_category     | city   |total_spent | total_no |city_orders_percent  |
|-------------------------|--------|------------|----------|---------------------|
| early orders (6-11)     | Jaipur | 467        | 4        | 12                  |
| late night orders (0-5) | Jaipur | 524        | 5        | 15                  |
| mid day orders (12-17)  | Jaipur | 1544       | 9        | 27                  |
| night orders (18-23)    | Jaipur | 2950       | 15       | 45                  |
| early orders (6-11)     | Noida  | 96         | 1        | 2                   |
|-------------------------|--------|------------|----------|---------------------|
*/

/*INSIGHT
Here’s a concise insight based on the data:

Pune had the highest proportion of late-night orders, with 75% of orders placed after 9 PM, 
significantly higher than Jaipur (45%) and Noida (83% during evening but only 2% after midnight).
This suggests a strong trend of late-night dining in Pune compared to the other cities, 
where orders were more concentrated earlier in the evening.
*/

/*[4] COMPARISON BETWEEN DIFFERENT DELIVERY TIME CATEGORIES & DELIVERY HOURS*/


-------Average delivery time and average amount for each delivery time category-------

with cte1 as
(select
case
when datepart(hour, order_time) between 6 and 11 then 'early orders(6-11)'
when datepart(hour, order_time) between 12 and 17 then 'mid day orders(12-17)'
when datepart(hour, order_time) between 18 and 23 then 'night orders(18-23)'
when datepart(hour, order_time) between 0 and 5 then 'late night orders(0-5)'
end as order_time_category,
datediff(minute, order_time, receive_time) as delivery_time,
city, final_paid
from swiggy)

select order_time_category, city, avg(delivery_time) as avg_delivery_time, round(avg(final_paid),0) avg_amount
from cte1
group by order_time_category, city

/*
|-------------------------|--------|------------------|-------------|
| order_time_category     | city   |avg_delivery_time | avg_amount  |
|-------------------------|--------|------------------|-------------|
| early orders (6-11)     | Jaipur | 38               | 117         |
| late night orders (0-5) | Jaipur | 24               | 105         |
| mid day orders (12-17)  | Jaipur | 28               | 172         |
| night orders (18-23)    | Jaipur | 31               | 197         |
| early orders (6-11)     | Noida  | 28               | 96          |
|-------------------------|--------|------------------|-------------|
*/


-----Average delivery time and average amount for each hour----

with cte1 as
(select datepart(hour, order_time) as order_hr,
datediff(minute, order_time, receive_time) as delivery_time, city, final_paid
from swiggy)

select city, order_hr, avg(delivery_time) as avg_delivery_time,
round(avg(final_paid),0) as avg_final_paid
from cte1
group by order_hr, city

/*
|-------|----------|------------------|-----------------|
| city  | order_hr |avg_delivery_time |avg_final_paid   |
|-------|----------|------------------|-----------------|
| Jaipur| 1        | 24               | 106             |
| Jaipur| 2        | 16               | 96              |
| Jaipur| 4        | 30               | 108             |
| Jaipur| 6        | 35               | 95              |
| Jaipur| 8        | 52               | 202             |
|-------|----------|------------------|-----------------|
*/

/*INSIGHT
Late-night orders (0-5 AM) in Jaipur had the fastest delivery times (24 minutes) and the lowest average spend (Rs 105), 
while mid-day orders (12-17 PM) in Pune took the longest, with an average delivery time of 52 minutes and the
highest spend (Rs 238). Across all cities, night orders (18-23 PM) showed a balance of moderate delivery times and relatively 
higher spending, indicating that evening hours tend to generate higher-value orders despite varying delivery speeds.
*/


/*[5] AVERAGE DELIVERY TIME COMPARISON FOR RESTAURANTS WITHIN 5 KM, 5-7 KM AND BEYOND 7 KM IN EACH CITY*/


with cte1 as
(select city, restaurant_customer_distance, datediff(minute, order_time, receive_time) as delivery_time
from swiggy)

select city,
avg(case when restaurant_customer_distance < 5 then delivery_time end) as avg_delivery_time_within_5km,
avg(case when restaurant_customer_distance between 5 and 7  then delivery_time end) as avg_delivery_time_between_5_to_7km,
avg(case when restaurant_customer_distance > 7 then delivery_time end) as avg_delivery_time_above_7km
from cte1
group by city


/*
|--------|-------------------------------|-----------------------------------|----------------------------|
| city   | avg_delivery_time_within_5km  |avg_delivery_time_between_5_to_7km |avg_delivery_time_above_7km |
|--------|-------------------------------|-----------------------------------|----------------------------|
| Jaipur | 29                            | 32                                | 37                         |
| Noida  | 30                            | 40                                | 38                         |
| Pune   | 28                            | NULL                              | 61                         |
|--------|-------------------------------|-----------------------------------|----------------------------|
*/

/*INSIGHT
Delivery times increased significantly for restaurants beyond 7 km, with Pune showing the most drastic rise (61 minutes). 
For Jaipur and Noida, delivery times also increased by 20-30% for distances beyond 5 km. 
This highlights that longer-distance deliveries across all cities are notably slower, 
with Pune experiencing the most inefficiency.
*/


/*[6] COMPARING DAY & NIGHT AVERAGE DELIVERY TIME AND AVERAGE AMOUNT SPENT*/


with cte1 as
(select
case
when datepart(hour, order_time) between 6 and 11 then 'early orders (6-11)'
when datepart(hour, order_time) between 12 and 17 then 'mid day orders (12-17)'
when datepart(hour, order_time) between 18 and 23 then 'night orders (18-23)'
when datepart(hour, order_time) between 0 and 5 then 'late night orders (0-5)'
end as order_time_category,
datediff(minute, order_time, receive_time) as delivery_time,
final_paid
from swiggy)

select order_time_category, avg(delivery_time) as avg_delivery_time, round(avg(final_paid),0) avg_amount
from cte1
group by order_time_category


/*
|-------------------------|------------------|-------------|
| order_time_category     |avg_delivery_time | avg_amount  |
|-------------------------|------------------|-------------|
| early orders (6-11)     | 36               | 113         |
| late night orders (0-5) | 25               | 112         |
| mid day orders (12-17)  | 33               | 183         |
| night orders (18-23)    | 33               | 205         |
|-------------------------|------------------|-------------|
*/

/*INSIGHT
Night orders (18-23 PM) had the highest average spend at Rs 205, about 12% higher than daytime orders,
indicating a greater willingness to spend more on dinner. Despite similar delivery times during the day and night (33 minutes),
the order value was significantly higher at night, suggesting that customers prefer placing larger,
more expensive orders during dinner hours.
*/

/*[7] TOP RESTAURANTS FROM EACH CITY*/


with cte1 as
(select restaurant_name, city, count(1) as total_orders,
dense_rank() over(partition by city order by count(1) desc) as ranking
from swiggy
group by restaurant_name, city),


cte2 as (select *,
sum(total_orders) over(partition by city) as cumulative_sum,
round(cast (total_orders as float)*100.0/sum(total_orders) over(partition by city), 2) as perct
from cte1)

select *,
round(sum(perct) over(partition by city), 0) as share_perct
from cte2
where ranking <= 3

/*
|-------------------------------|--------|-------------|--------|---------------|-------|------------|
| restaurant_name               | city   |total_orders |ranking |cumulative_sum | perct |share_perct |
|-------------------------------|--------|-------------|--------|---------------|-------|------------|
| Brown Sugar                   | Jaipur | 7           | 1      | 33            | 21.21 | 55         |
| Falahaar & Kota Kachori       | Jaipur | 3           | 2      | 33            | 9.09  | 55         |
| Kanha                         | Jaipur | 3           | 2      | 33            | 9.09  | 55         |
| Breakfast At Door             | Jaipur | 3           | 2      | 33            | 9.09  | 55         |
| Kanha- Gopalpura Tonk Road    | Jaipur | 2           | 3      | 33            | 6.06  | 55         |
|-------------------------------|--------|-------------|--------|---------------|-------|------------|
*/

/*INSIGHT
In Noida, 56% of total orders came from just 5 restaurants, showing a preference for a smaller group of favorites.
In contrast, Pune had a more diverse selection, with orders spread across multiple restaurants, 
where 100% of orders were from different outlets. Jaipur followed a similar pattern to Noida, 
with 55% of orders coming from a top 3 restaurants, reflecting a more concentrated ordering behavior in both 
Noida and Jaipur compared to Pune.
*/


/*[8] NO OF DAYS BETWEEN 2 ORDERS*/

with cte1 as
(select city, order_time as initial_order,
lead(order_time) over(order by order_time) as next_order
from swiggy)

select *,
datediff(day, initial_order, next_order) as day_diff
from cte1

/*
|-------|-------------------------------|-------------------------------|---------|
| city  | initial_order                 | next_order                    | day_diff|
|-------|-------------------------------|-------------------------------|---------|
| Pune  | 2023-07-03 20:51:03.000       | 2023-07-04 13:24:58.000       | 1       |
| Pune  | 2023-07-04 13:24:58.000       | 2023-07-22 23:33:15.000       | 18      |
| Pune  | 2023-07-22 23:33:15.000       | 2023-07-26 23:00:42.000       | 4       |
| Pune  | 2023-07-26 23:00:42.000       | 2023-08-12 22:04:57.000       | 17      |
| Pune  | 2023-08-12 22:04:57.000       | 2023-08-13 15:49:39.000       | 1       |
|-------|-------------------------------|-------------------------------|---------|
*/

/*INSIGHT
The ordering patterns vary across cities. Noida shows a high frequency of orders, 
often on consecutive days. Jaipur has mixed patterns, with some back-to-back orders and longer gaps, 
while Pune experiences more extended intervals between orders. 
This suggests distinct customer behavior in each location.
*/

/*[9] RESTAURANTS FROM WHERE CONTINOUS 2 ORDERS WERE PLACED*/

with cte1 as
(select city, restaurant_name as initial_order,
lead(restaurant_name) over(order by order_time) as next_order
from swiggy)

select *
from cte1
where initial_order = next_order

/*
|-------|------------------ |-------------------|
| city  | initial_order     | next_order        |
|-------|-------------------|-------------------|
| Pune  | Healthy-O-Me      | Healthy-O-Me      |
| Jaipur| Brown Sugar       | Brown Sugar       |
| Jaipur| Brown Sugar       | Brown Sugar       |
| Pune  | Sandwich Express  | Sandwich Express  |
| Noida | Foodiness         | Foodiness         |
|-------|-------------------|-------------------|
*/

/*INSIGHT
A notable pattern across all three cities is that several consecutive orders were placed from the same restaurant, 
suggesting a strong preference for repeat orders. This reflects a tendency to favor familiar choices over exploring new options, 
indicating high satisfaction or convenience.
*/

/*[10] RESTAURANTS FROM WHERE CONTINOUS 3 ORDERS WERE PLACED*/

with cte1 as
(select city, restaurant_name as initial_order,
lead(restaurant_name) over(order by order_time) as next_order,
lead(restaurant_name, 2) over(order by order_time) as third_order
from swiggy)

select *
from cte1
where initial_order = next_order and next_order = third_order

/*
|-------|---------------------|---------------------|------------------|
| city  | initial_order       | next_order          |third_order       |
|-------|---------------------|---------------------|------------------|
| Jaipur| Breakfast At Door   | Breakfast At Door   |Breakfast At Door |
|-------|---------------------|---------------------|------------------|
*/


/*INSIGHT
In Jaipur, a clear preference was shown with three consecutive orders placed from the same restaurant, 
highlighting a strong loyalty or satisfaction with that particular choice.
*/

/*[11] NO OF ORDERS IN DIFFERENT MONTHS ACROSS CITIES*/

select datename(month, order_time) as order_month,
count(1) as total_orders
from swiggy
group by datename(month, order_time)
order by 2 desc

/*
|-------------|--------------|
| order_month | total_orders |
|-------------|--------------|
| June        | 22           |
| August      | 13           |
| March       | 12           |
| January     | 10           |
| July        | 8            |
|-------------|--------------|
*/

/*INSIGHT
The data indicates a significant trend in food ordering, with June seeing the highest orders at 22, 
likely due to summer vacations and reduced outdoor activities. Conversely, months like October, September, and December 
show fewer orders, possibly because of festivals and gatherings, which lead to less reliance on delivery. 
Overall, these patterns suggest that ordering habits are influenced by seasonal and lifestyle factors.
*/

/*[12] CITY AND MOTH WHERE MORE THAN 1 ORDER ON SAME DAY*/

with cte1 as
(select city, datename(month, order_time) as order_month, order_time as initial_order,
lead(order_time) over(order by order_time) as next_order
from swiggy)


select city, order_month
from cte1
where  datediff(day, initial_order, next_order) = 0
order by 2

/*
|-------|-------------|
| city  | order_month |
|-------|-------------|
| Noida | April       |
| Noida | April       |
| Jaipur| August      |
| Jaipur| August      |
| Noida | August      |
|-------|-------------|
*/


/*INSIGHT
In multiple instances across cities, several orders were placed on the same day, 
particularly noted in Noida and Jaipur during April and August, respectively. 
This trend highlights the likelihood of increased demand for food delivery during specific events or social gatherings, 
indicating a preference for convenience in busy periods.
*/

/*[13] AVERAGE NO OF DAYS BETWEEN 2 ORDERS IN DIFFERENT CITIES*/

with cte1 as
(select city, order_time as initial_order,
lead(order_time) over(order by order_time) as next_order
from swiggy), 

cte2 as
(select *,
datediff(day, initial_order, next_order) as day_diff
from cte1)

select city, avg(day_diff) as avg_gap
from cte2
group by city


/*
|-------|---------|
| city  | avg_gap |
|-------|---------|
| Jaipur| 4       |
| Noida | 3       |
| Pune  | 11      |
|-------|---------|
*/


/*INSIGHT
The average time between orders varies significantly across cities, with Jaipur averaging 4 days, 
Noida at 3 days, and Pune at 11 days. This indicates that customers in Jaipur and Noida tend to order more frequently, 
suggesting a higher demand or preference for food delivery compared to Pune.
*/