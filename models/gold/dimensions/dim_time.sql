with time_dimension as (

    select distinct
        time as time_id,
        hour_of_day,
        minute_of_hour,
        seconde_of_minute,
        time_period
    from {{ ref('wind_power_silver') }}

)

select *
from time_dimension
