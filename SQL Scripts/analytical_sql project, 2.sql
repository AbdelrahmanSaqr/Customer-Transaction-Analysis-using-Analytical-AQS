WITH RFM_CTE AS (
    SELECT DISTINCT 
        CUSTOMER_ID,
        TO_DATE('2011-12-10', 'YYYY-MM-DD') - MAX(TO_DATE(INVOICEDATE,'MM/DD/YYYY')) OVER (PARTITION BY CUSTOMER_ID) AS RECENCY,
        COUNT(INVOICE) OVER (PARTITION BY CUSTOMER_ID) AS FREQUENCY,
        SUM(PRICE * QUANTITY) OVER (PARTITION BY CUSTOMER_ID) AS MONETARY
    FROM 
        TABLERETAIL
)

SELECT 
    CUSTOMER_ID, 
    RECENCY, 
    FREQUENCY, 
    MONETARY, 
    R_SCORE,  
    FM_SCORE,
    CASE
        WHEN R_SCORE = 5 AND FM_SCORE = 5 THEN 'Champions'
        WHEN R_SCORE = 5 AND FM_SCORE = 4 THEN 'Champions'
        WHEN R_SCORE = 4 AND FM_SCORE = 5 THEN 'Champions'

        WHEN R_SCORE = 5 AND FM_SCORE = 2 THEN 'Potential Loyalists'
        WHEN R_SCORE = 4 AND FM_SCORE = 2 THEN 'Potential Loyalists'
        WHEN R_SCORE = 3 AND FM_SCORE = 3 THEN 'Potential Loyalists'
        WHEN R_SCORE = 4 AND FM_SCORE = 3 THEN 'Potential Loyalists'
        
        WHEN R_SCORE = 5 AND FM_SCORE = 3 THEN 'Loyal Customers'
        WHEN R_SCORE = 4 AND FM_SCORE = 4 THEN 'Loyal Customers'
        WHEN R_SCORE = 3 AND FM_SCORE = 5 THEN 'Loyal Customers'
        WHEN R_SCORE = 3 AND FM_SCORE = 4 THEN 'Loyal Customers'

        WHEN R_SCORE = 5 AND FM_SCORE = 1 THEN 'Recent Customers'

        WHEN R_SCORE = 4 AND FM_SCORE = 1 THEN 'Promising'
        WHEN R_SCORE = 3 AND FM_SCORE = 1 THEN 'Promising'

        WHEN R_SCORE = 3 AND FM_SCORE = 2 THEN 'Customers Needing Attention'
        WHEN R_SCORE = 2 AND FM_SCORE = 3 THEN 'Customers Needing Attention'
        WHEN R_SCORE = 2 AND FM_SCORE = 2 THEN 'Customers Needing Attention'

        WHEN R_SCORE = 2 AND FM_SCORE = 5 THEN 'At Risk'
        WHEN R_SCORE = 2 AND FM_SCORE = 4 THEN 'At Risk'
        WHEN R_SCORE = 1 AND FM_SCORE = 3 THEN 'At Risk'

        WHEN R_SCORE = 1 AND FM_SCORE = 5 THEN 'Cant Lose Them'
        WHEN R_SCORE = 1 AND FM_SCORE = 4 THEN 'Cant Lose Them'

        WHEN R_SCORE = 1 AND FM_SCORE = 2 THEN 'Hibernating'

        WHEN R_SCORE = 1 AND FM_SCORE = 1 THEN 'Lost'
        
        ELSE 'Unknown'
    END AS CUSTOMER_SEGMENT
            
FROM (
    SELECT 
        CUSTOMER_ID, 
        RECENCY, 
        FREQUENCY, 
        MONETARY, 
        R_SCORE,  
        NTILE(5) OVER (ORDER BY ROUND( (F_SCORE + M_SCORE) / 2)) AS FM_SCORE
    FROM (
        SELECT 
            CUSTOMER_ID,
            RECENCY, 
            FREQUENCY, 
            MONETARY, 
            NTILE(5) OVER (ORDER BY RECENCY DESC) AS R_SCORE,
            NTILE(5) OVER (ORDER BY FREQUENCY) AS F_SCORE,
            NTILE(5) OVER (ORDER BY MONETARY) AS M_SCORE
        FROM 
            RFM_CTE
    ) 
) 
 ORDER BY CUSTOMER_ID
