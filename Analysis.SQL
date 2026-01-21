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




