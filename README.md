# Event Analysis Technical Test

This repository contains a data pipeline built with **dbt** for generating reporting tables (for stakeholders). The pipeline processes raw data from multiple sources, applies transformations, and creates both aggregated and detailed reporting models.

The pipeline starts with raw event data in the **staging layer**, then performs transformations and aggregations in the **core layer**. The final engagement report may be created with **User Queries** directly to a BI tool or just a simple Excel file.

## Data Sources

The raw data resides in **DuckDB** (chosen because it's faster and more suitable for local development, though **Snowflake** would be a better choice for production) under the following tables:

- **web_event**: Contains information about user sessions in the web version of the product.
- **mobile_event**: Contains information about user sessions in the mobile version of the product.

## Models

The data pipeline has been designed with a **modular** approach to enhance readability and code maintainability:

- **Staging Layer**: This layer is responsible for cleaning and preparing the raw data. This layer uses **views** to save space, as it performs minimal transformations.

    **What we do in the Staging Layer**:
    - Clean and standardize the data from both the **mobile_events** and **web_events** tables.
    - Use **UNION ALL** to combine mobile and web events into one table.
    - Convert timestamps to the `date` format for easy aggregation by date.
    - Extract necessary attributes like `user_id`, `item_id`, `event_name`, etc., which will be used later for analysis.
    - Filter only the necessary columns for business needs to make the data easier to work with.
    - Add a new column `channel` to indicate whether the event came from the app or the web.

    **Goal**: 
    - Load the data as-is from the sources (mobile and web).
    - Perform basic cleaning, such as column type conversions and filtering out invalid or missing values.
    - Convert timestamps and other data into usable formats.

- **Mart Layer**: This layer combines and aggregates the data from the staging model to create **data mart** for reporting.

    **What we do in the Mart Layer**:
    - Aggregate data.
    - Apply transformations such as filtering by region and counting unique users.
    - Prepare data for tasks like **DAU**, **DAL**, **content completion**, etc.

    **Goal**:
    - Aggregate data and perform necessary transformations.
    - Calculate unique users and other metrics.
    - Prepare data for reporting, focusing on key business metrics.

    On this level, the following columns are calculated and grouped by date and channel:
    - **event_date**: The date of the event.
    - **unique_users**: Counts all unique users for each date.
    - **content_interaction**: Counts only those unique users who interacted with content (e.g., books).
    - **content_completions**: Counts the number of content completions (e.g., `item-finished` events).
    - **device_locale_country**: Counts unique users from the **DACH** region (Germany, Austria, Switzerland).


event_date	channel	unique_users	content_interaction	content_completions	device_locale_country
2025-01-29	app	3	2	1	1
2025-01-29	web	3	2	1	0

### dbt Tests

dbt will run the following tests after every model run to ensure data integrity:

1. **Not Null**: Ensures that the columns `event_date`, `unique_users`, `content_interaction`, `content_completions`, and `device_locale_country` do not contain null values.
   
2. **Unique**: Ensures that the combination of columns like `event_date`, `channel`, and `device_locale_country` is unique. This is crucial for correct aggregation and data analysis.

3. **Expression Check**: 
   - **unique_users >= content_interaction**: Ensures that the number of unique users (`unique_users`) is always greater or equal or equal to the number of content interactions (`content_interaction`).
   - **device_locale_country <= unique_users**: Ensures that the number of unique users from the **DACH** region (`device_locale_country`) is always less or equal to the total number of unique users (`unique_users`).

## User Queries

This repository also contains **user queries** (stored in `user_queries.sql`) with comments explaining how the queries allow end-users to answer the following business questions:

1. **Daily Active Users (DAU)**: How many users interacted with product on a daily basis? Any interaction is seen as activity.
2. **Daily Active Learners (DAL)**: How many users interacted with product content on a daily basis? Only interactions with Blinkist content items are seen as activity.
3. **Content Completion**: How many content completions did we have on web?
4. **Regional Activity**: How many users from the **DACH** region interacted with product using the app in the last 30 days?

The queries in `user_queries.sql` can be used directly with a BI tool or exported to Excel to explore the data further.

## Directory Structure

- **`duckdb/`**: Contains necessary configurations and scripts for connecting to DuckDB.
- **`my_venv/`**: Python virtual environment for dependency management.
- **`my_project/models/`**: Contains the dbt models for staging and mart layers.
- **`user_queries.sql`**: Contains SQL queries to answer the above business questions.

## Setup Instructions

To set up the environment and dependencies:

 - Install the required dependencies:
    ```bash
    pip install -r requirements.txt
    ```

- Run the dbt models:
    ```bash
    dbt run
    ```

This will execute all models in the dbt project and generate the final engagement tables for reporting.

## Further Exploration

Incorporating additional data points, such as detailed user behavior logs, subscription changes, content categories, and feature usage, can provide deeper insights into user engagement. The following analyses could be explored to gain a better understanding of user behavior:

1. **User Retention and Churn Analysis**:
Metric: Retention Rate (e.g., 1-day, 7-day, 30-day retention).
Reason: Understanding how often users return to the platform after their first interaction. By segmenting retention by user cohorts (e.g., first-time users, subscription type, region), we can identify patterns that help optimize user engagement strategies and reduce churn.

Example: Tracking the percentage of users who return to the platform after one day, one week, and one month. This can be segmented by subscription type (free vs. premium), device platform (iOS vs. Android), and region (DACH vs. others).

2. **Content Engagement Depth**:
Metric: Average Time Spent per Content Item and Completion Rate by Content Type.
Reason: To understand how engaged users are with the content itself, it’s important to look at how much time they spend per content item (e.g., book, article). A high completion rate of content (e.g., finishing books) can indicate strong user engagement, while a low rate may suggest issues with content relevance or user experience.
Example: Measure the average time spent on content by different categories. Compare this with the content completion rate to identify areas where users might be dropping off or not finishing content.

3. **Subscription Behavior and Changes**:
Metric: Subscription Upgrade/Downgrade Rate, Conversion Rate from Free to Paid.
Reason: Tracking changes in user subscriptions (e.g., from free to premium or downgrades) helps to understand how content offerings, marketing, and user experience impact the likelihood of users upgrading or downgrading their plans.
Example: Analyze user behavior leading up to subscription changes—whether users are interacting more with content prior to upgrading or downgrading. Understand the factors behind subscription churn (e.g., content preferences, usage patterns).

4. **User Segmentation Based on Behavior**:
Metric: Behavioral Segmentation (e.g., frequent vs. occasional users, content category preferences).
Reason: By clustering users into segments based on their behavior, such as frequency of content interactions or specific content category preferences, you can develop more targeted engagement strategies and personalize the user experience.
Example: Group users into "frequent", "moderate", and "occasional" users based on interaction frequency. Offer targeted recommendations based on content preferences (e.g., more fiction or non-fiction).

5. **Device and Platform Usage**:
Metric: Device Platform and OS Usage Trends (e.g., iOS vs. Android, mobile vs. desktop).
Reason: Identifying trends in device usage helps optimize content delivery and identify any platform-specific barriers or opportunities. This can lead to better-targeted features or content for different platforms.
Example: Track usage patterns across device platforms to determine if certain features or content types perform better on specific devices or OS versions (e.g., does audio content see higher engagement on mobile devices than on desktop?)
