with turbines as (

    select distinct
        turbine_name,
        capacity,
        location_name,
        latitude,
        longitude,
        region
    from {{ ref('wind_power_silver') }}

),

numbered_turbines as (

    select
        row_number() over (
            order by
                turbine_name,
                capacity,
                location_name,
                latitude,
                longitude,
                region
        ) as turbine_id,
        turbine_name,
        capacity,
        location_name,
        latitude,
        longitude,
        region
    from turbines

)

select *
from numbered_turbines