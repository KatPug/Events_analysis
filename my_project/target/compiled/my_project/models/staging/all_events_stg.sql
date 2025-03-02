with mobile_events as (
    select
        event_name,
        CAST(event_timestamp AS DATE) as event_date,
        user_id,
        session_id,
        item_id,
        item_type,
        user_access_type,
        device_locale_country,
        'app' as channel
    from read_parquet('/Users/katlip/Documents/Events_analysis/duckdb/files/mobile_events.parquet')
),
web_events as (
    select
        event_name,
        CAST(event_timestamp AS DATE) as event_date,
        user_id,
        session_id,
        item_id,
        item_type,
        user_access_type,
        country_code as device_locale_country,
        'web' as channel
    from read_parquet('/Users/katlip/Documents/Events_analysis/duckdb/files/web_events.parquet')
)
select *
from mobile_events
union all
select *
from web_events