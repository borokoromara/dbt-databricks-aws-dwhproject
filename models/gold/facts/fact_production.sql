with production as (

    select *
    from {{ ref('wind_power_silver') }}

),

turbine_dimension as (

    select *
    from {{ ref('dim_turbine') }}

),

status_dimension as (

    select *
    from {{ ref('dim_operational_status') }}

),

fact as (

    select
        p.production_id,
        p.date as date_id,
        p.time as time_id,
        t.turbine_id,
        s.status_id,
        p.wind_speed,
        p.wind_direction,
        p.energy_produced

    from production as p

    left join turbine_dimension as t
        on p.turbine_name = t.turbine_name
        and p.capacity = t.capacity
        and p.location_name = t.location_name
        and p.latitude = t.latitude
        and p.longitude = t.longitude
        and p.region = t.region

    left join status_dimension as s
        on p.status = s.status
        and p.responsible_department = s.responsible_department

)

select *
from fact