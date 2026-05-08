-- Identify High-Risk Customers
-- A customer is high risk if: Fraud transactions ≥ 2, OR Loan_Status = 'Default'

SELECT 
    t.Customer_ID,
    l.Loan_Status,
    COUNT(CASE WHEN t.Fraud_Flag = 1 THEN 1 END) AS fraud_count
FROM Transaction t
LEFT JOIN Loan l 
    ON t.Customer_ID = l.Customer_ID
GROUP BY t.Customer_ID, l.Loan_Status
HAVING fraud_count >= 2 
   AND l.Loan_Status = 'Default';
   
   SELECT 
    t.Customer_ID,
    l.Loan_Status,
    COUNT(*) AS total_txn,
    COUNT(CASE WHEN t.Fraud_Flag = 1 THEN 1 END) AS fraud_count,
    concat(round(COUNT(CASE WHEN t.Fraud_Flag = 1 THEN 1 END) * 100.0 / COUNT(*),2),"%") AS fraud_rate
FROM Transaction t
LEFT JOIN Loan l 
    ON t.Customer_ID = l.Customer_ID
GROUP BY t.Customer_ID, l.Loan_Status
HAVING fraud_count >= 2 
   AND l.Loan_Status = 'Default';
   
   -- TASK 2: Fraud Pattern Analysis
-- Q1: Which City Has Highest Fraud Rate?
select c.city,
count(case when t.fraud_flag=1 then 1 end) fraud_count,
concat(round(count(case when t.fraud_flag=1 then 1 end)*100/count(Fraud_Flag),2),"%") fraud_rate
from customer c join transaction t on
c.Customer_ID=t.Customer_ID
group by c.city
order by fraud_rate desc;

-- Fraud by Payment Method
select method,
count(case when fraud_flag=1 then 1 end) fraud_count,
concat(round(count(case when fraud_flag=1 then 1 end)*100/count(Fraud_Flag),2),"%") fraud_rate
from transaction 
group by method
order by fraud_rate desc;

-- Customer Segmentation
-- Segments:High Value → Total > 100000,Medium → 50000–100000,Low → < 50000

select customer_id,sum(amount) total_amount,
case when sum(amount)>100000 then " High Value" 
when sum(amount) between 50000 and 100000 then " Medium value" 
else "Low value"
end as segment
from transaction
group by customer_id;

-- Detect Suspicious Behavior
-- Condition:High transaction (>8000),Fraud = 1
SELECT *
FROM Transaction
WHERE Amount > 8000 
AND Fraud_Flag = 1;

-- Time-Based Fraud Detection
 select hour(date) hour, count(*)
 from transaction
 where Fraud_Flag=1
 group by hour
 order by count(*) desc;
 
 select hour(date) hour, count(case when Fraud_Flag=1 then 1 end) fraud_count
 from transaction
 group by hour
 order by fraud_count desc;
 
 -- Customer 360 Analysis
 -- Combine:Transactions,Account Balance,Loan Status
 select l.loan_status,round(sum(t.amount),2) total_trx_amount,round(sum(a.balance),2) account_balance
 from transaction t join accounts a on
 t.Customer_ID=a.Customer_ID 
 join loan l on 
 t.Customer_ID=l.Customer_ID
 group by  l.loan_status;
 
 SELECT 
    c.Customer_ID,
    SUM(t.Amount) AS total_spent,
    a.Balance,
    MAX(l.Loan_Status) AS loan_status
FROM Customer c
LEFT JOIN Transaction t ON c.Customer_ID = t.Customer_ID
LEFT JOIN Accounts a ON c.Customer_ID = a.Customer_ID
LEFT JOIN Loan l ON c.Customer_ID = l.Customer_ID
GROUP BY c.Customer_ID, a.Balance;

-- Rank Customers by Spending
select customer_id,
round(sum(amount),2) total_amount,
dense_rank() over ( order by sum(amount)  desc) ranking
from transaction
group by Customer_ID; 

-- Detect Inactive High-Value Customers
-- High balance (>300K), Low transactions (<5)
select c.customer_id,a.balance,count(t.transaction_id)
from customer c join accounts a on
c.Customer_ID=a.Customer_ID
left join transaction t on 
t.Customer_ID=c.Customer_ID
group by c.customer_id,a.balance
having	a.balance>300000 and count(transaction_id)<5;

-- Monthly Growth Analysis
select monthname(date) monthname,year(date) yearname,round(sum(amount),2) total_amount
from transaction
group by monthname, yearname;

SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS month,
    SUM(Amount) AS total_revenue
FROM Transaction
GROUP BY month
ORDER BY month;