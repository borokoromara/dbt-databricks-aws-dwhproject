with operational_statuses as (

    select distinct
        status,
        responsible_department
    from {{ ref('wind_power_silver') }}

),

numbered_statuses as (

    select
        row_number() over (
            order by status, responsible_department
        ) as status_id,
        status,
        responsible_department
    from operational_statuses

)

select *
from numbered_statuses