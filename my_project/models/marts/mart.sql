{{ config(
    materialized='table'
) }}
select
    event_date,
    channel,  -- Channel from which the event originated (e.g., mobile, web)
    count(distinct user_id) as unique_users,  -- DAU: Count of unique users per event_date
    count(distinct case when item_type not null then user_id end) as content_interaction,  -- DAL: Count of unique users interacting with content
    sum(case when event_name = 'item-finished' then 1 else 0 end) as content_completions,  -- Content Completion: Count of 'item-finished' events
    count(distinct case when device_locale_country in ('DE', 'AT', 'CH') then user_id end) as dach -- Count of unique users from DACH region
from {{ ref('all_events_stg') }}
group by
    event_date,
    channel
order by
    event_date
