--------------------------------------------------------------------------------
-- PROJECT: Credit Risk & Loan Portfolio Analytics
-- SCRIPT 2: 02_risk_metrics.sql (SQL Server Optimized)
--------------------------------------------------------------------------------

USE CreditRiskDB;
GO

WITH PaymentDelays AS (
    SELECT 
        p.loan_id,
        p.payment_id,
        p.due_date,
        p.payment_date,
        p.amount_due,
        p.amount_paid,
        -- SQL Server native date difference function for Days Past Due (DPD)
        CASE 
            WHEN p.payment_date > p.due_date THEN DATEDIFF(day, p.due_date, p.payment_date)
            ELSE 0 
        END AS days_delayed
    FROM payments p
),

LoanMaxDelinquency AS (
    -- Aggregate maximum historical delinquency per loan
    SELECT 
        loan_id,
        MAX(days_delayed) AS max_days_past_due,
        SUM(CASE WHEN amount_paid < amount_due THEN 1 ELSE 0 END) AS missed_payments_count
    FROM PaymentDelays
    GROUP BY loan_id
),

LoanRiskClassification AS (
    -- Combine master loan data with behavioral risk metrics and assign regulatory DPD buckets
    SELECT 
        l.loan_id,
        l.customer_id,
        l.loan_amount,
        l.outstanding_balance,
        l.interest_rate,
        l.risk_grade,
        COALESCE(m.max_days_past_due, 0) AS max_days_past_due,
        COALESCE(m.missed_payments_count, 0) AS missed_payments_count,
        CASE 
            WHEN COALESCE(m.max_days_past_due, 0) = 0 THEN 'Current (0 Days)'
            WHEN COALESCE(m.max_days_past_due, 0) BETWEEN 1 AND 30 THEN '30 Days DPD'
            WHEN COALESCE(m.max_days_past_due, 0) BETWEEN 31 AND 60 THEN '60 Days DPD'
            WHEN COALESCE(m.max_days_past_due, 0) BETWEEN 61 AND 90 THEN '90 Days DPD'
            ELSE 'Default (90+ Days DPD)'
        END AS delinquency_bucket
    FROM vw_cleaned_loan_portfolio l
    LEFT JOIN LoanMaxDelinquency m ON l.loan_id = m.loan_id
)

-- Final Portfolio Summary for Executive Power BI Reporting
SELECT 
    delinquency_bucket,
    risk_grade,
    COUNT(loan_id) AS total_loans,
    SUM(loan_amount) AS total_disbursed_amount,
    SUM(outstanding_balance) AS total_outstanding_balance,
    ROUND(CAST(AVG(interest_rate) AS FLOAT), 2) AS avg_interest_rate,
    ROUND(SUM(outstanding_balance) * 100.0 / SUM(SUM(outstanding_balance)) OVER(), 2) AS portfolio_exposure_pct
FROM LoanRiskClassification
GROUP BY delinquency_bucket, risk_grade
ORDER BY 
    CASE delinquency_bucket
        WHEN 'Current (0 Days)' THEN 1
        WHEN '30 Days DPD' THEN 2
        WHEN '60 Days DPD' THEN 3
        WHEN '90 Days DPD' THEN 4
        ELSE 5
    END,
    risk_grade;
GO

USE CreditRiskDB;
GO

-- Drop the view if it already exists to avoid creation conflicts
DROP VIEW IF EXISTS vw_portfolio_risk_metrics;
GO

CREATE VIEW vw_portfolio_risk_metrics AS
WITH LoanMaxPayment AS (
    -- Find the latest payment or due date per loan to calculate aging / DPD
    SELECT 
        loan_id,
        MAX(due_date) AS max_due_date,
        MAX(payment_date) AS max_payment_date
    FROM payments
    GROUP BY loan_id
),
LoanDelinquency AS (
    -- Calculate Days Past Due (DPD) and assign delinquency buckets
    SELECT 
        l.loan_id,
        l.customer_id,
        l.loan_amount,
        l.outstanding_balance,
        l.interest_rate,
        l.risk_grade,
        COALESCE(DATEDIFF(day, p.max_due_date, p.max_payment_date), 0) AS days_past_due,
        CASE 
            WHEN DATEDIFF(day, p.max_due_date, p.max_payment_date) <= 0 THEN 'Current (0 Days)'
            WHEN DATEDIFF(day, p.max_due_date, p.max_payment_date) BETWEEN 1 AND 30 THEN '30 Days DPD'
            WHEN DATEDIFF(day, p.max_due_date, p.max_payment_date) BETWEEN 31 AND 60 THEN '60 Days DPD'
            WHEN DATEDIFF(day, p.max_due_date, p.max_payment_date) BETWEEN 61 AND 90 THEN '90 Days DPD'
            ELSE 'Default (90+ Days DPD)'
        END AS delinquency_bucket
    FROM loans l
    LEFT JOIN LoanMaxPayment p ON l.loan_id = p.loan_id
)
-- Aggregate metrics by Delinquency Bucket and Risk Grade
SELECT 
    delinquency_bucket,
    risk_grade,
    COUNT(loan_id) AS total_loans,
    SUM(loan_amount) AS total_disbursed_amount,
    SUM(outstanding_balance) AS total_outstanding_balance,
    CAST(AVG(interest_rate) AS DECIMAL(5,2)) AS avg_interest_rate,
    CAST(
        (SUM(outstanding_balance) * 100.0) / SUM(SUM(outstanding_balance)) OVER() 
        AS DECIMAL(5,2)
    ) AS portfolio_exposure_pct
FROM LoanDelinquency
GROUP BY delinquency_bucket, risk_grade;
GO

SELECT TOP 10 * 
FROM vw_portfolio_risk_metrics;
GO

SELECT * FROM vw_portfolio_risk_metrics;