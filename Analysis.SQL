-- Use schema
use project;

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- Retrieve total number of Orders placed
select count(distinct order_id) as order_count 
from order_details;

-- Calculate total revenue generated from pizza sales
select round(sum(price*quantity),2) as revenue
from pizzas as p
inner join order_details as od
on od.pizza_id = p.pizza_id;

-- Identify the highest priced pizza
select * from (
select p.pizza_id, pt.name, p.price
, dense_rank() over(order by p.price desc) as rn
from pizzas as p
left join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id
) as a
where rn = 1;

--Also
select * from (
select p.pizza_id, pt.name, p.price
, row_number() over (order by p.price desc) as rn
from pizzas as p
left join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id
) as a
where rn = 1;

-- Identify the most common pizza size ordered
select p.size, count(distinct order_id) as orders, sum(od.quantity) as quantity
from pizzas as p
inner join order_details as od
on od.pizza_id = p.pizza_id
group by p.size;

-- List the top 5 most ordered pizza types with along with their quantities
select pt.name as pizza_name, sum(od.quantity) as quantity
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on od.pizza_id = p.pizza_id
group by pt.name
order by od.quantity desc
limit 5;

-- Determine the distribution of orders by the hour of the day
select *,
sum(hr_orders) over() as total_orders,
hr_orders*1.00/sum(hr_orders) over() as order_distribution
from (
select hour(time) as hr, count(distinct order_id) as hr_orders
from orders
group by hour(time)
) as a;

-- Determine the top 3 most ordered pizza types based on revenue
select pt.name as pizza_name, sum(od.quantity * p.price) as rev
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id = p.pizza_type_id
inner join order_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by rev desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue
select pt.category, 
sum(od.quantity * p.price) / (select round(sum(od.quantity*p.price),2) AS total_sales
from order_details od
inner join pizzas p 
on od.pizza_id = p.pizza_id)) * 100 as revenue
from pizza_types pt 
inner join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
inner join order_details od
on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc;

-- Analyze the cumulative revenue generated over time
select order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details
inner join pizzas 
on order_details.pizza_id = pizzas.pizza_id
inner join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue
from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b)
where rn <= 3;

-- Join the necessary tables to find the total quantity of each pizza category ordered
select pizza_types.category, sum(order_details.quantity) as quantity
from pizza_types
inner join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by order_details.quantity desc;


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) 
from pizza_types
group by category;

-- Group the orders by the date and calculate the average number of pizzas ordered per day
select round(avg(quantity),2)
from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders
inner join order_details
on order_details.order_id = orders.order_id
group by orders.order_date) as order_quantity;
