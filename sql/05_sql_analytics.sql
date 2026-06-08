-- =====================================================
-- TELECOM CUSTOMER CHURN & RETENTION ANALYTICS
-- Author: Himit Narayan
-- =====================================================

-- =====================================================
-- DATABASE SETUP
-- =====================================================

CREATE TABLE telecom_customers (

```
customer_id VARCHAR(50),

gender VARCHAR(20),
age INT,
married VARCHAR(10),

tenure_months INT,

phone_service VARCHAR(10),
internet_service VARCHAR(50),

contract VARCHAR(50),
payment_method VARCHAR(100),

monthly_charges NUMERIC(10,2),
total_charges NUMERIC(12,2),

cltv NUMERIC(12,2),

churn_label VARCHAR(10),
churn_score INT,

customer_segment VARCHAR(50)
```

);


-- 1. OVERALL CHURN RATE

SELECT

COUNT(*) AS total_customers,

SUM(
CASE
WHEN churn_label = 'Yes'
THEN 1
ELSE 0
END
) AS churned_customers,
ROUND(
100.0 *
SUM(
CASE
WHEN churn_label = 'Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2) AS churn_rate
FROM telecom_customers;


-- 2. REVENUE AT RISK


SELECT
ROUND(
SUM(monthly_charges),
2) AS monthly_revenue_at_risk,
ROUND(
SUM(total_charges),
2) AS lifetime_revenue_at_risk
FROM telecom_customers
WHERE churn_label='Yes';

-- 3. CHURN BY CONTRACT TYPE


SELECT
contract,
COUNT(*) AS customers,
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
) AS churned_customers,
ROUND(
100.0 *
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2
) AS churn_rate
FROM telecom_customers
GROUP BY contract
ORDER BY churn_rate DESC;


-- 4. CHURN BY INTERNET SERVICE


SELECT
internet_service,
COUNT(*) AS customers,
ROUND(
100.0 *
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2
) AS churn_rate
FROM telecom_customers
GROUP BY internet_service
ORDER BY churn_rate DESC;


-- 5. CHURN BY PAYMENT METHOD


SELECT

payment_method,
COUNT(*) AS customers,
ROUND(
100.0 *
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2
) AS churn_rate
FROM telecom_customers
GROUP BY payment_method
ORDER BY churn_rate DESC;


-- 6. CUSTOMER SEGMENT PERFORMANCE


SELECT
customer_segment,
COUNT(*) AS customers,
ROUND(
AVG(monthly_charges),
2
) AS avg_monthly_charge,
ROUND(
AVG(cltv),
2
) AS avg_cltv,
ROUND(
100.0 *
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2
) AS churn_rate
FROM telecom_customers
GROUP BY customer_segment
ORDER BY avg_cltv DESC;

-- 7. REVENUE CONTRIBUTION BY SEGMENT


SELECT
customer_segment,
ROUND(
SUM(monthly_charges),
2
) AS revenue,
ROUND(
100.0 *
SUM(monthly_charges)
/
(
SELECT SUM(monthly_charges)
FROM telecom_customers
),
2
) AS revenue_share_percent
FROM telecom_customers
GROUP BY customer_segment
ORDER BY revenue DESC;

-- 8. REVENUE LOSS BY SEGMENT


SELECT
customer_segment,
COUNT(*) AS churned_customers,
ROUND(
SUM(monthly_charges),
2
) AS monthly_revenue_loss,
ROUND(
SUM(total_charges),
2
) AS lifetime_revenue_loss
FROM telecom_customers
WHERE churn_label='Yes'
GROUP BY customer_segment
ORDER BY monthly_revenue_loss DESC;

-- 9. CLTV ANALYSIS

SELECT
churn_label,
ROUND(
AVG(cltv),
2
) AS avg_cltv,
ROUND(
MIN(cltv),
2
) AS min_cltv,
ROUND(
MAX(cltv),
2
) AS max_cltv
FROM telecom_customers
GROUP BY churn_label;

-- 10. HIGH RISK CUSTOMERS


SELECT
customer_id,
customer_segment,
contract,
monthly_charges,
cltv,
churn_score
FROM telecom_customers
WHERE churn_score >= 80
ORDER BY churn_score DESC;


-- 11. WINDOW FUNCTION
-- SEGMENT REVENUE RANKING


SELECT

customer_segment,

SUM(monthly_charges) AS revenue,

RANK() OVER(
ORDER BY
SUM(monthly_charges) DESC
) AS revenue_rank
FROM telecom_customers
GROUP BY customer_segment;


-- 12. TOP REVENUE GENERATING CUSTOMERS


SELECT
customer_id,
customer_segment,
monthly_charges,
cltv,

RANK() OVER(
ORDER BY
cltv DESC
) AS cltv_rank
FROM telecom_customers
LIMIT 20;


-- 13. CTE ANALYSIS
-- TOP CHURN SEGMENTS

WITH churn_stats AS (

```
SELECT

customer_segment,

COUNT(*) AS total_customers,

SUM(
    CASE
        WHEN churn_label='Yes'
        THEN 1
        ELSE 0
    END
) AS churned_customers

FROM telecom_customers

GROUP BY customer_segment
```

)

SELECT

customer_segment,
total_customers,
churned_customers,
ROUND(
100.0 *
churned_customers
/
total_customers,
2
) AS churn_rate
FROM churn_stats
ORDER BY churn_rate DESC;


-- 14. TENURE GROUP ANALYSIS

SELECT

CASE

```
WHEN tenure_months <= 12
THEN '0-1 Year'

WHEN tenure_months <= 24
THEN '1-2 Years'

WHEN tenure_months <= 48
THEN '2-4 Years'

ELSE '4+ Years'
```

END AS tenure_group,

COUNT(*) AS customers,

ROUND(
100.0 *
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
)
/
COUNT(*),
2
) AS churn_rate
FROM telecom_customers
GROUP BY tenure_group
ORDER BY churn_rate DESC;

-- 15. EXECUTIVE SUMMARY QUERY


SELECT
COUNT(*) AS total_customers,
SUM(
CASE
WHEN churn_label='Yes'
THEN 1
ELSE 0
END
) AS churned_customers,
ROUND(
AVG(monthly_charges),
2
) AS avg_monthly_charge,
ROUND(
AVG(cltv),
2
) AS avg_cltv,
ROUND(
SUM(monthly_charges),
2
) AS monthly_revenue,
ROUND(
SUM(total_charges),
2
) AS lifetime_revenue
FROM telecom_customers;
