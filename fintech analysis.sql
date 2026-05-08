create database fintech;
use fintech;
select * from customer;
select * from Transaction;
select * from Accounts;
select * from loan;

-- 1.Total Transactions
select count(*) total_transaction from transaction;

-- 2. Total Transaction Amount
select round(sum(amount),2) transaction_amunt from transaction;

-- 3. Transactions by Status
SELECT 
    status, ROUND(SUM(amount), 2) transaction_amunt
FROM
    transaction
GROUP BY status;

-- 4. Customers by City
select city, count(customer_id) total_customer
from customer
group by city;

-- 5. Total Transaction per Customer
select customer_id,round(sum(amount),2) total_transaction
from transaction
group by customer_id;

-- 6. Average Transaction Amount by Payment Method
select method,round(avg(amount),2) avg_transaction
from transaction
group by method;

-- 7. Account Balance by City
select c.city,round(sum(a.balance),2) account_balance
from customer c join accounts a on
c.Customer_ID=a.Customer_ID
group by c.city; 

-- 8. Fraud Rate by Payment Method
select method,
round(count(case when fraud_flag=1 then 1 end)*100/count(*),2) fraud_rate
from transaction
group by method;

-- 9. Top 10 High-Value Customers
select customer_id,round(sum(amount),2) total_transaction
from transaction
group by Customer_ID
order by total_transaction desc
limit 10;

-- 10. Customers with Loans + High Transactions
select t.customer_id,round(sum(l.loan_amount),2) total_loan,round(sum(t.amount),2) total_amount
from transaction t join loan l on
t.Customer_ID=l.customer_id
group by t.customer_id
order by total_loan ,total_amount desc;

-- 11. Fraud Rate Among Loan Defaulters
select l.loan_status,
count(case when t.fraud_flag=1 then 1 end)*100/count(*) fraud_rate
from transaction t join loan l on
t.Customer_ID=l.Customer_ID
where l.Loan_Status="default";

-- 12. Monthly Transaction Trend
select monthname(date) months,round(sum(amount),2) total_amount
from transaction 
group by months;

-- 13. Detect Suspicious Transactions (High Amount + Fraud)
  select * from transaction 
  where amount>8000 and Fraud_Flag=1;
  
-- 14. Customers with High Balance but Low Activity
select c.customer_id,a.balance,count(transaction_id) count_transaction
from customer c join accounts a on
c.Customer_ID=a.customer_id
left join transaction t on
c.Customer_ID=t.Customer_ID
group by c.customer_id,a.balance
having a.balance>300000 and count_transaction<5;

-- 15. Rank Customers by Spending
select customer_id,round(sum(amount),2) total_amount,
rank () over(order by sum(amount) desc) ranking
from transaction
group by Customer_ID; 

-- 16. Running Total of Transactions
select customer_id,date,amount,
sum(amount) over (partition by customer_id order by date) running_total
from transaction;

-- Q4: Detect Peak Fraud Time (Hour-wise)
SELECT 
    HOUR(Date) AS hour,
    COUNT(*) AS fraud_cases
FROM Transaction
WHERE Fraud_Flag = 1
GROUP BY hour
ORDER BY fraud_cases DESC;