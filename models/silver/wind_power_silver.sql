with source as (

    select *
    from {{ source('wind_power', 'wind_power_bronze') }}

),

transformed as (

    select
        production_id,
        date,
        replace(time, '-', ':') as time,
        try_cast(substring(replace(time, '-', ':'), 1, 2) as int) as hour_of_day,
        try_cast(substring(replace(time, '-', ':'), 4, 2) as int) as minute_of_hour,
        try_cast(substring(replace(time, '-', ':'), 7, 2) as int) as seconde_of_minute,
        dayofmonth(date) as day,
        month(date) as month,
        quarter(date) as quarter,
        year(date) as year,
        case 
           when try_cast(substring(replace(time, '-', ':'), 1, 2) as int) >= 5
             and try_cast(substring(replace(time, '-', ':'), 1, 2) as int) < 12
             then 'Morning'

            when try_cast(substring(replace(time, '-', ':'), 1, 2) as int) >= 12
             and try_cast(substring(replace(time, '-', ':'), 1, 2) as int) < 17
             then 'Afternoon'

            when try_cast(substring(replace(time, '-', ':'), 1, 2) as int) >= 17
             and try_cast(substring(replace(time, '-', ':'), 1, 2) as int) < 21
             then 'Evening'

            else 'Night'
        end as time_period,
        turbine_name,
        capacity,
        location_name,
        latitude,
        longitude,
        region,
        status,
        responsible_department,
        round(wind_speed, 2) as wind_speed,
        wind_direction,
        round(energy_produced, 2) as energy_produced

    from source

)

select *
from transformed

