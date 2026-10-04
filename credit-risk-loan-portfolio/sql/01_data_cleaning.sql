--------------------------------------------------------------------------------
-- PROJECT: Credit Risk & Loan Portfolio Analytics
-- SCRIPT 1: 01_data_cleaning.sql
-- DESCRIPTION: Creates base tables, defines constraints, handles missing values, 
--              and builds a cleaned staging view for downstream risk modeling.
--------------------------------------------------------------------------------
CREATE DATABASE CreditRiskDB;
GO
USE CreditRiskDB;
GO


-- STEP 1: Drop existing tables if re-running script
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS loans;

-- STEP 2: Create Master Loans Table
CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    loan_amount DECIMAL(12, 2) NOT NULL,
    outstanding_balance DECIMAL(12, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    risk_grade CHAR(1) NOT NULL
);

-- STEP 3: Create Payments Transaction Table
CREATE TABLE payments (
    payment_id VARCHAR(30) PRIMARY KEY,
    loan_id VARCHAR(20) NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    amount_due DECIMAL(10, 2) NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- STEP 4: Data Cleaning & Staging View
-- This view cleans raw anomalies (e.g., negative balances, null risk grades) 
-- and prepares standard data formats for risk modeling.
CREATE VIEW vw_cleaned_loan_portfolio AS
SELECT 
    l.loan_id,
    l.customer_id,
    l.loan_amount,
    -- Ensure balance never drops below zero due to rounding errors
    CASE WHEN l.outstanding_balance < 0 THEN 0 ELSE l.outstanding_balance END AS outstanding_balance,
    l.interest_rate,
    -- Handle any missing risk grades by defaulting to 'C' or 'Unassigned'
    COALESCE(UPPER(l.risk_grade), 'C') AS risk_grade
FROM loans l
WHERE l.loan_amount > 0;

-- Verification Query (Run this to check clean row counts)
SELECT COUNT(*) AS total_clean_loans FROM vw_cleaned_loan_portfolio;