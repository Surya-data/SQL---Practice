CREATE DATABASE projects;


CREATE TABLE sales (
  "customer_id" VARCHAR(10),
  "order_date" DATE,
  "product_id" INTEGER
);



INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('Aarav', '2021-01-01', 1),
  ('Aarav', '2021-01-01', 2),
  ('Aarav', '2021-01-07', 2),
  ('Aarav', '2021-01-10', 3),
  ('Aarav', '2021-01-11', 3),
  ('Aarav', '2021-01-11', 3),
  ('Meera', '2021-01-01', 2),
  ('Meera', '2021-01-02', 2),
  ('Meera', '2021-01-04', 1),
  ('Meera', '2021-01-11', 1),
  ('Meera', '2021-01-16', 3),
  ('Meera', '2021-02-01', 3),
  ('Rohan', '2021-01-01', 3),
  ('Rohan', '2021-01-01', 3),
  ('Rohan', '2021-01-07', 3);

  SELECT * FROM SALES



  CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(50),
  "price" INTEGER
);

Q1 what is the total amount each customer spent at the cafe?

select s.customer_id, sum(m.price)as total_spent
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

Q2 HOW MANY DISTINCT HAS EACH CUSTOMER PLACED AN ORDER?

select customer_id, count(distinct order_date)as days_visited
from sales
group by customer_id;

Q3 What was the fi rst dish ordered by each customer?

with ordered_sales as(
select s.customer_id, m.product_name,
row_number() over(partition by s.customer_id order by s.order_date)as rn
from sales s
join menu m on s.product_id = m.product_id)
select customer_id, product_name
from ordered_sales
where rn =1;

Q4 Which menu item is the most popular overall?

select m.product_name, count(s.product_id)as order_count
from sales s
join menu m on s.product_id = m.product_id
group by m.product_name
order by order_count desc
limit 1;

Q5 What is the most frequently ordered dish for each customer?

with item_counts as (
select s.customer_id, m.product_name, count(s.product_id)as order_count,
DENSE_RANK() over(partition by s.customer_id order by count(s.product_id)desc)as rank
from sales s
JOIN menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name
)
select customer_id, product_name, order_count
from item_counts
where rank =1;

Q6 After joining the loyalty program, what dish did each member fi rst order

SELECT DISTINCT ON (s.customer_id)
       s.customer_id,
       s.order_date,
       m.product_name
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
ORDER BY s.customer_id, s.order_date;

Q7 Before joining the loyalty program, what dish did each customer order last?

SELECT DISTINCT ON (s.customer_id)
       s.customer_id,
       s.order_date,
       m.product_name
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
ORDER BY s.customer_id, s.order_date DESC;

Q8 For each member, how many items and how much did they spend before joining? 

SELECT s.customer_id,
       COUNT(*) AS items_before,
       SUM(m.price) AS amount_before
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

Q9 If each ₹1 = 10 points, and Paneer Butter Masala earns double points, how many 
points does each customer earn?

SELECT s.customer_id,
       SUM(
         CASE 
           WHEN m.product_name = 'Paneer Butter Masala' 
             THEN m.price * 20
           ELSE m.price * 10
         END
       ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

Q10 . In their first loyalty week (starting from join_date), members earn double points on 
all items. How many points do Aarav and Meera have by the end of January? 
DoDS @ND

SELECT s.customer_id,
       SUM(
         CASE 
           WHEN s.order_date BETWEEN mb.join_date AND mb.join_date + INTERVAL '6 day'
             THEN m.price * 20
           WHEN m.product_name = 'Paneer Butter Masala'
             THEN m.price * 20
           ELSE m.price * 10
         END
       ) AS total_points_jan
FROM sales s
JOIN members mb ON s.customer_id = mb.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
