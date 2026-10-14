select
    production_id,
    count(*) as number_of_records
from {{ ref('fact_production') }}
group by production_id
having count(*) > 1
