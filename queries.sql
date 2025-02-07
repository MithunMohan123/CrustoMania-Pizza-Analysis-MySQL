select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- Retrieve the total number of orders placed

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales

select round(sum(o.quantity*p.price),2) as total_revenue from order_details as o
 join pizzas as p
where o.pizza_id=p.pizza_id;

-- How many orders exist for each quantity.

select quantity,count(order_details_id) as no_of_orders from order_details 
group by quantity;

-- Identify the highest-priced pizza.

select pt.name,p.price from pizzas as p
join pizza_types as pt
where pt.pizza_type_id=p.pizza_type_id
order by p.priDce desc limit 1 ;


-- Identify the most common pizza size ordered.

select p.size,count(o.order_details_id) as ordered from pizzas as p
join order_details as o
where p.pizza_id=o.pizza_id
group by p.size;

-- List the top 5 most ordered pizza types along with their quantities.

select sum(o.quantity) as most_ordered ,pt.name from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
join order_details as o
on o.pizza_id=p.pizza_id
group by pt.name 
order by most_ordered desc limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,sum(o.quantity)as total_orders  from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.category;

-- Determine the distribution of orders by hour of the day.

select hour(time) as hour,count(order_id) as order_count from orders
group by  hour(time) 
order by hour(time) asc;


-- Join relevant tables to find the category-wise distribution of pizzas.

select pt.category as category,count(o.order_id) as total_orders from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as o
on p.pizza_id=o.pizza_id
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT order_date, round(AVG(total_pizzas),2) as avg_num_pizzas
FROM (
    SELECT o.date as order_date, COUNT(od.order_id) as total_pizzas
    FROM order_details od
    JOIN orders o
    ON o.order_id = od.order_id
    GROUP BY o.date
) as order_quantity
GROUP BY order_date 
LIMIT 1000;


-- Determine the top 3 most ordered pizza types based on revenue.

select  pt.name as pizza_type,sum(round((od.quantity*p.price),2))  as revenue from pizzas as p
join order_details as od
on od.pizza_id=p.pizza_id
join  pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by revenue desc limit 3 ;


-- Calculate the percentage contribution of each pizza type to total revenue

select pt.category as category, round(sum(od.quantity*p.price)/(select round(sum(od.quantity*p.price),2) as divisor from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id )*100,2) as percentage_of_revenue
from pizza_types as pt join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by category
order by percentage_of_revenue
limit 1000  ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select pizza_name,revenue from
(select pizza_category,pizza_name,revenue,
rank() over (partition by pizza_category order by revenue desc) as rn from
(
select pt.category as pizza_category ,pt.name as pizza_name, round(sum(od.quantity*p.price),2) as revenue from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pizza_category,pizza_name
) as details) as details_
where rn<=3 ;

-- Analyze the cumulative revenue generated over time.

select order_date,round(sum(revenue) over (order by order_date),2) as cumilitive_revenue from
(select o.date as order_date,round(sum(od.quantity*p.price),2) as revenue from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join orders as o
on o.order_id=od.order_id
group by o.date) as sales;

