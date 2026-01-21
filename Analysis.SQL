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
select pt.name 

