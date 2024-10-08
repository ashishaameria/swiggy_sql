# **Swiggy Food Delivery Data Analysis**

This project analyzes my personal Swiggy food delivery data to uncover insights into ordering patterns, delivery performance, spending trends, and customer behavior.

### Project Overview

The analysis focuses on delivery time, order frequency, discounts, and spending habits. SQL queries were used to reveal consumer preferences and potential areas for optimizing food delivery services.

### Dataset

I scraped my **personal Swiggy data** over a **one-year** period across **Pune, Jaipur, and Noida**. The dataset was **cleaned** using **Power Query** in Power BI and **analyzed in MS SQL**.

### Key Insights

1.  **Delivery Speed and Distance Across Cities**  
    **Insight**: **Jaipur** had the **fastest delivery**, with **55%** of orders delivered **faster than average**. In **Pune**, deliveries from restaurants **over 7 km** took **61 minutes**, while in **Jaipur** and **Noida**, deliveries from **beyond 5 km** were **20-30% slower**.
    
2.  **Impact of Discounts on Spending**  
    **Insight**: Discounts were used in **78% of orders**, leading to a **28% total savings**. Discounts successfully incentivized purchases without reducing order value.
    
3.  **Late-Night Ordering Trends**  
    **Insight**: **Pune** had **75%** of orders after **9 PM**, compared to **45%** in **Jaipur** and **83%** evening orders in **Noida**, but only **2%** after midnight.
    
4.  **Delivery Time and Spend by Time of Day**  
    **Insight**: Late-night orders in **Jaipur (0-5 AM)** had the **fastest delivery (24 minutes)** and the **lowest spend (Rs 105)**, while **mid-day orders in Pune (12-5 PM)** took **52 minutes** with the **highest spend (Rs 238)**.
    
5.  **Spending Patterns by Time of Day**  
    **Insight**: **Nighttime orders (6-11 PM)** had the **highest average spend (Rs 205)**, about **12% more than daytime orders**, despite similar delivery times, indicating higher-value orders during dinner hours.
    
6.  **Ordering Concentration by City**  
    **Insight**: In **Noida**, **56%** of orders came from just **5 restaurants**, while **Pune** showed more variety, with **100%** of orders from **different** restaurants. **Jaipur** had **55%** of orders from **3 restaurants**.
    
7.  **Order Frequency and Same-Day Orders**  
    **Insight**: **Noida** saw **frequent ordering**, often on **consecutive days**, while **Pune** had **longer gaps**, averaging **11 days**. In **Noida** and **Jaipur**, **multiple orders** were placed on the **same day** during **April** and **August**.
    
8.  **Preference for Repeat Orders**  
    **Insight**: Across all cities, several instances of **consecutive orders** from the **same restaurant** indicate **strong customer loyalty**.
    
9.  **Seasonal Order Trends**  
    **Insight**: **June** had the **highest number of orders (22)**, likely due to summer vacations, while **October, September, and December** had **fewer orders**, possibly due to festivals and social gatherings.
    



### Tools and Technologies

-   **Web Scraping**: Collected Swiggy data.
-   **Power Query (Power BI)**: Cleaned and prepared the dataset.
-   **MS SQL**: Queried and analyzed the data.
