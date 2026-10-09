-- Rendered from production macro and regression test at 2267a2e. Literal-only; no tables.


-- Associate this literal-only regression with the existing CWV test selection.
-- depends_on: snowplow_unified_web_vital_measurements_actual

with input(case_name, value) as (
  select case_name, cast(value as decimal(14,3))
  from values
    ('floating_tail', 53.3), ('floating_tail', 93.2), ('floating_tail', 295),
    ('historical_fixture', 15.2), ('historical_fixture', 278.1),
    ('real_fraction', 1.000), ('real_fraction', 1.001),
    ('below_threshold', 99.999), ('below_threshold', 100.000),
    ('exact_threshold', 99.700), ('exact_threshold', 100.100),
    ('all_null', null), ('all_null', null),
    ('with_null', null), ('with_null', 10), ('with_null', 20),
    ('singleton', 1.001),
    ('duplicates', 1), ('duplicates', 1), ('duplicates', 1), ('duplicates', 2),
    ('large', 9999999999.997), ('large', 9999999999.999),
    ('negative', -1.001), ('negative', -1.000)
  as fixture(case_name, value)
), actual as (
  select case_name,
    
  
  
  
  cast(
    percentile_cont(0.75) within group (order by value)
    as decimal(38, 5)
  )
 as p75,
    
  
  
  
  cast(
    percentile_cont(0.95) within group (order by value)
    as decimal(38, 5)
  )
 as p95
  from input
  group by case_name
), expected(case_name, p75, rounded_p75, p95) as (
  values
    ('floating_tail', 194.10000, 194.100, 274.82000),
    ('historical_fixture', 212.37500, 212.375, 264.95500),
    ('real_fraction', 1.00075, 1.001, 1.00095),
    ('below_threshold', 99.99975, 100.000, 99.99995),
    ('exact_threshold', 100.00000, 100.000, 100.08000),
    ('all_null', null, null, null),
    ('with_null', 17.50000, 17.500, 19.50000),
    ('singleton', 1.00100, 1.001, 1.00100),
    ('duplicates', 1.25000, 1.250, 1.85000),
    ('large', 9999999999.99850, 9999999999.999, 9999999999.99890),
    ('negative', -1.00025, -1.000, -1.00005)
)
select a.case_name
from actual a
full outer join expected e on a.case_name = e.case_name
where a.case_name is null or e.case_name is null
  or not (a.p75 <=> e.p75)
  or not (a.p95 <=> e.p95)
  or not (cast(ceil(a.p75, 3) as decimal(19,3)) <=> e.rounded_p75)
  -- Classification uses the unrounded percentile, not the displayed ceiling.
  or not ((a.p75 < 100) <=> (e.p75 < 100))