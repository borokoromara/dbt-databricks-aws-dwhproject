with date_dimension as (

    select distinct
        date as date_id,
        day,
        month,
        quarter,
        year
    from {{ ref('wind_power_silver') }}

)

select *
from date_dimension