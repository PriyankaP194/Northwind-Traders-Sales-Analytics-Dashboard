-- 1. Average number of orders per customer and high-value repeat customers 
select 
(sum(order_count)/count(distinct CustomerID)) as avg_order_per_customer 
from 
(
select CustomerID, count(*) as order_count 
from capstone.orders
group by CustomerID
order by CustomerID
) as s;


-- Are there high_value repeat customers?
-- high_value repeat customers - >10 and >10000
select CustomerID, count(*) order_count, 
round(sum(UnitPrice*Quantity),2) amount_spend
from orders o
join order_details od 
on o.OrderID=od.OrderID
group by CustomerID
having order_count>=10 
and 
amount_spend>=10000;


-- 2.How do customer order patterns vary by city or country?
select Country, City, count(OrderID)
from customers c
join orders o
on c.customerid=o.customerid
group by Country, City
order by Country, count(orderid) desc;


select Country, count(OrderID)
from customers c
join orders o
on c.customerid=o.customerid
group by country
order by count(orderid) desc;


-- 3.Cluster customers based on total spend, order count, and preferred categories
with category_spend as (
select o.CustomerID, CategoryName, count(distinct o.OrderID) order_count, sum(od.UnitPrice*Quantity) as Total_Spend
from orders o 
join order_details od
on o.OrderID=od.OrderID
join products p 
on od.ProductID=p.ProductID
join categories c 
on p.CategoryID=c.CategoryID
group by o.CustomerID, CategoryName
),
ranked_category as(
select *,
dense_rank() over(
partition by  CustomerID
order by total_spend desc
) as rn
from category_spend
)
select
CustomerID,
round(sum(total_spend),2) as total_spend,
sum(order_count) as order_count,
max(case when rn = 1 then CategoryName end) as preferred_category
from ranked_category
group by CustomerID;

-- 4. Products contribution to order revenue
select 
ProductName,
sum(od.UnitPrice*Quantity) as Total_Spend
from products p 
join order_details od 
on od.ProductID=p.ProductID
group by ProductName
order by Total_Spend desc;


-- 5. Correlations between orders and product category
select 
distinct CategoryName,
count(distinct OrderID) as Total_Orders,
round(sum(od.UnitPrice*Quantity),2) as Total_Spend
from categories c 
join products p 
on c.CategoryID=p.CategoryID
join order_details od 
on od.ProductID=p.ProductID
group by CategoryName
order by Total_Spend desc;


-- 6. How frequently do different customer segments place orders?
with customer_orders as (
select
c.CustomerID,
count(o.OrderID) as total_orders
from customers c
left join orders o
on c.CustomerID = o.CustomerID
group by c.CustomerID
),
customer_segments as (
select
CustomerID,
total_orders,
case
when total_orders between 1 and 3 then 'Low Frequency'
when total_orders between 4 and 10 then 'Medium Frequency'
else 'High Frequency'
end as customer_segment
from customer_orders
)
select
customer_segment,
count(CustomerID) as number_of_customers,
round(avg(total_orders), 2) as avg_orders_per_customer
from customer_segments
group by customer_segment
order by avg_orders_per_customer desc;


-- 7. Geographic and title-wise distribution of employees
select 
City, 
count(Title) as Title_Count
from employee
group by City
order by City;

-- 8. Trends we observe in hire dates across employee titles
select
year(HireDate) as HireDate,
Title,
Count(ID)
from employee
group by year(HireDate), Title;


-- 9. Patterns exist in employee title and courtesy title distributions
select 
Title,
TitleOfCourtesy,
count(ID) as EmployeeCount
from employee
group by Title, TitleOfCourtesy
order by Title;


-- 10. Changes in product demand over months
select 
month(o.OrderDate) as order_month,
p.ProductName,
sum(od.Quantity) as total_units_sold
from Orders o
join Order_Details od 
on o.OrderID = od.OrderID
join Products p 
on od.ProductID = p.ProductID
group by 
month(o.OrderDate),
p.ProductName
order by 
p.ProductName,
order_month;


-- 11. Regional trends in supplier distribution and pricing
select 
s.Country,
count(distinct s.SupplierID) as supplier_count,
round(avg(p.UnitPrice), 2) as avg_unit_price
from Suppliers s
join Products p
on s.SupplierID = p.SupplierID
group by s.Country
order by supplier_count desc;


-- 12. Suppliers distribution across different product categories
select  
c.CategoryName,
count(distinct p.SupplierID) as Supplier_Count
from Products p
join Categories c 
on p.CategoryID = c.CategoryID
group by c.CategoryName
order by Supplier_Count desc;


-- 13. Supplier pricing and categories across different regions
select 
s.Country as Supplier_Country,
c.CategoryName,
sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Revenue
from Suppliers s
join Products p 
on s.SupplierID = p.SupplierID
join Categories c 
on p.CategoryID = c.CategoryID
join Order_Details od 
on p.ProductID = od.ProductID
group by s.Country, c.CategoryName
order by s.Country, Total_Revenue desc;

