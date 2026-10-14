select
    f.production_id,
    f.turbine_id
from {{ ref('fact_production') }} as f
left join {{ ref('dim_turbine') }} as d
    on f.turbine_id = d.turbine_id
where f.turbine_id is null
   or d.turbine_id is null
