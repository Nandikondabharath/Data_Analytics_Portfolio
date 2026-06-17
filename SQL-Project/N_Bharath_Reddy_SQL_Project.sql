CREATE DATABASE food_delivery;
USE food_delivery;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    signup_date date
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    city VARCHAR(100),
    rating float
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    order_status VARCHAR(50),
    
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
);

select * from customers;
select *from restaurants;
select * from orders;

#1
select o.order_id, c.customer_name, r.restaurant_name, o.order_amount
from orders o join customers c 
ON o.customer_id = c.customer_id
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Completed';

use food_delivery;

#2
select r.restaurant_name, sum(o.order_amount) as total_revenue
from orders o join restaurants r
on o.restaurant_id = r.restaurant_id 
group by r.restaurant_name;

#3
select c.customer_name, count(o.order_id) as total_orders 
from orders o left join customers c 
on o.customer_id= c.customer_id 
 group by c.customer_name;
 
 #4
 select r.city, avg(o.order_amount) as avg_amnt
 from orders o join restaurants r 
 on o.restaurant_id=r.restaurant_id
 group by r.city;
 
 
 #5
 select order_id, order_amount ,
 case 
  when order_amount<200 then 'Low'
  when order_amount between 200 and 500 then 'Medium'
  else 'High'
end as category
from orders;
 

use food_delivery;

#6
select r.restaurant_name, avg(o.order_amount) as avg_amount 
from orders o join restaurants r
on o.restaurant_id = r.restaurant_id
group by r.restaurant_name
having avg(o.order_amount) >(select avg(order_amount) from orders);

#7
select c.customer_name 
from customers c left join orders o
on c.customer_id=o.customer_id
where order_id is NULL;

#8
select c.customer_name, sum(order_amount) as total_spending
from orders o join customers c
on o.customer_id=c.customer_id
group by c.customer_name
order by total_spending desc limit 5;

#9
select payment_method, count(*) as usage_count
from orders
group by payment_method
order by usage_count desc limit 1;

#10
select order_date, sum(order_amount) as daily_revenue, 
sum(sum(order_amount)) over (order by order_date) as running_total
from orders
group by order_date;

#11
select r.restaurant_name, sum(o.order_amount) as daily_revenue,
 rank() over( order by SUM(o.order_amount) desc)
as ranking from orders o join restaurants r 
 on o.restaurant_id = r.restaurant_id
group by r.restaurant_name;

#12
select distinct order_amount
from orders
order by order_amount desc
limit 1 offset 1;


#13
select customer_id, count(order_id) as total_orders
from orders group by customer_id
having count(order_id)> (select avg(order_count) from
 ( select count(*) as order_count from orders group by customer_id) avg_table );


#14
with restaurant_orders as
(
    select r.city, r.restaurant_name, count(o.order_id) as total_orders,
        rank() over
        (
            partition by r.city
            order by count(o.order_id) desc
        ) as ranking
    from restaurants r
    join orders o
        on r.restaurant_id = o.restaurant_id
    group by r.city, r.restaurant_name
)
select *
from restaurant_orders
where ranking <= 3;

#15
select
    date_format(order_date, '%Y-%m') as month,
    sum(order_amount) as revenue,

    lag(sum(order_amount))
    over (
        order by date_format(order_date, '%Y-%m')
    ) as previous_month_revenue

from orders
group by date_format(order_date, '%Y-%m');


