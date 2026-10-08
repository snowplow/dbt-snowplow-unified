-- Two groups from the public CWV fixture. No dbt, tables, or mutable state.
-- Mirror the fixture's FLOAT -> DECIMAL(14,4) -> CEIL(...,3) input path.
with input(group_name, raw_fid) as (
  values ('march20_desktop', '278.1'), ('march20_desktop', '15.2'),
         ('arm_any_road_mobile', '53.2999999999999'),
         ('arm_any_road_mobile', '93.2'), ('arm_any_road_mobile', '295')
), prepared as (
  select group_name, ceil(cast(cast(raw_fid as float) as decimal(14,4)), 3) as fid
  from input
), percentiles as (
  select group_name, percentile_cont(0.75) within group (order by fid) as p75
  from prepared
  group by group_name
)
select group_name, typeof(p75) as percentile_type,
       format_string('%.17f', p75) as percentile_high_precision,
       ceil(p75, 3) as current_model_result,
       ceil(cast(p75 as decimal(24,5)), 3) as decimal_before_ceiling,
       case group_name when 'march20_desktop' then 212.375 else 194.100 end as exact_decimal_result
from percentiles
order by group_name
