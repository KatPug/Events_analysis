-- Count of unique users who interacted with product on a daily basis using the engagement_activity table
select 
    event_date, 
    sum(unique_users)
from {{ ref('engagement_activity') }}
group by event_date
order by event_date;

-- Count of unique users interacting with content (e.g., books) on a daily basis using the engagement_activity table
select 
    event_date, 
    sum(content_interaction)
from {{ ref('engagement_activity') }}
group by event_date
order by event_date;

-- Count of content completions on the web using the engagement_activity table
select 
    event_date, 
    sum(content_completions)
from {{ ref('engagement_activity') }}
where channel = 'web'
group by event_date
order by event_date;

-- Count of unique users from the DACH region interacting with Blinkist through the app in the last 30 days
select 
    event_date, 
    sum(dach)
from {{ ref('engagement_activity') }}
where event_date >= current_date - interval '30 days'
group by event_date
order by event_date;
