--1
select count( distinct customer_id) from subscriptions

--2
select count(*), datepart(month, start_date) as month, datename(month, start_date)
from subscriptions
where plan_id=0
group by datepart(month, start_date), datename(month, start_date)
order by datepart(month, start_date)

--3
select a.plan_id, plans.plan_name, count(*) 
from subscriptions a
inner join plans plans on
a.plan_id=plans.plan_id
where start_date>'01-01-2020'
group by a.plan_id, plans.plan_name

--4
select count(*) as total_attrition, cast(100*cast(count(*) as decimal(4,1))/(select count(distinct customer_id) from subscriptions) as decimal(3,1)) as attrition_percent
from subscriptions
where plan_id=4

--5
with cte as(
select *, dense_rank() over (partition by customer_id order by plan_id) as rank
from subscriptions)

select 100*cast( cast(count(*) as decimal(3,1))/(select count(distinct customer_id) from subscriptions) as decimal(3,1)) from cte where rank=2 and plan_id=4

--6
with cte as(
select customer_id, plan_id, lead(plan_id,1) over( partition by customer_id order by plan_id) as next_plan from subscriptions
)
select next_plan, count(next_plan) from cte where next_plan is not null and plan_id=0
group by next_plan

--7
select plan_id, count(distinct customer_id) from subscriptions
where start_date<'2020-12-31'
group by plan_id

--8

select count(distinct customer_id) from subscriptions
where plan_id=3 and start_date<='2020-12-31'

--9
with trial as(
select customer_id, start_date from subscriptions
where plan_id=0),
 annual as(
select customer_id, start_date as next_Date from subscriptions
where plan_id=3)

select avg(datediff(day,  start_date, next_Date)) from trial a inner join annual b
on a.customer_id=b.customer_id

--10
with trial as(
select customer_id, start_date from subscriptions
where plan_id=0),
annual as(
select customer_id, start_date as next_Date from subscriptions
where plan_id=3),

Groupings as(
select 
 case when datediff(day,  start_date, next_Date)>=0 and datediff(day,  start_date, next_Date) <=30
then '0-30'
when datediff(day,  start_date, next_Date)>=31 and datediff(day,  start_date, next_Date)<=60
then '31-60'
else
'60+'
end as group_1
from trial a inner join annual b
on a.customer_id=b.customer_id)
select group_1, count(*) from groupings
group by group_1

--11
with pro_to_basic as(
select customer_id, plan_id, lead(plan_id,1) over (partition by customer_id order by customer_id) as next_plan
from subscriptions
)
select count(distinct customer_id) as 'Pro_to_Basic' from pro_to_basic
where plan_id=2 and next_plan=1
