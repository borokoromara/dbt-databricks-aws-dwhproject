select
    f.production_id,
    f.status_id
from {{ ref('fact_production') }} as f
left join {{ ref('dim_operational_status') }} as s
    on f.status_id = s.status_id
where f.status_id is null
   or s.status_id is null