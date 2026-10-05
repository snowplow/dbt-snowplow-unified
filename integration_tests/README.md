# snowplow-unified-integration-tests

Integration test suite for the snowplow-unified dbt package.

Snowflake event staging has two additional checks:

- From the package root, run `dbt deps`, install
  `integration_tests/python/requirements.txt`, and run
  `python -m pytest -q integration_tests/python`. These warehouse-free tests
  execute the original Utils query and the staged query on synthetic data in
  DuckDB. They cover full session windows, both timestamp settings, duplicate
  events, late/device-null events, app filters, empty runs and Lake Loader SQL
  projection. They do not validate Snowflake performance.
- After the standard Snowflake integration suite, run
  `bash .scripts/test_staged_events.sh` from this directory. It compares the
  staged base events with the original Utils query on Snowflake for initial and
  incremental runs using each timestamp setting. This is included in warehouse
  CI; it requires a dedicated integration-test profile and resets the test
  manifests. Lake Loader structured-source execution and Iceberg scan pruning
  still need validation on a representative Snowflake Iceberg source.

The `./scripts` directory contains the following:

- `integration_tests.sh`: This tests the standard modules of the snowplow-unified package:

- App error test: runs the app errors optional module without test data to see if it compiles correctly.

- Late enabled contexts test: runs the package first without contexts enabled (excluding cwv due to the separate dummy dataset) then runs them with enabled. It checkes if a new incremental table that is based on events_this_run runs smoothly or not indicating datatype errors.

- All contexts except for cwv test: runs the Snowplow unified package 4 times to replicate incremental loading of events, then performs an equality test between the actual vs expected output.

- Web Vital test: Runs the cwv optional module once and checks the outputs.

- Web (all web contexts except for cwv) test: runs only the web related contexts and checks if it fails by doing so.

- Mobile (all mobile contexts) test: runs only the web related contexts and checks if it fails by doing so.

Run the scripts using:

```bash
bash integration_tests.sh -d {warehouse}
```

Supported warehouses (should be the same as your target in your profile.yml):

- redshift
- bigquery
- snowflake
- databricks
- postgres
- all (iterates through all supported warehouses)

Good-to-knows:

There are certain exceptions to how different warehouses process data and in places we had to adjust the integration test to work around that. Here's a list of things to keep in mind:

- the non-deterministic nature of row_number() function for Redshift/Postgres/Databricks means that we had to hard-code actuals and expected models for cases where we are testing duplicate rows with exact same results / window
- postgres / redshift needing the array format of : (within sessions_expected)
- bigquery handling of snowplow_utils.timestamp_diff() - absolute_time_in_s changes
- rotating domain_userid per session is hard-coded in the integration test expectations, when run in one batch the user_identifier differs: 2e340eb6e94820ea8369c0174c612260d1cfe9d41f0fe46268994e28d9c0bbf17
0e9ab97b5d9d9a174112df13fe9c44788af3ac9088a8b41e0998d92a8b4b5a4fc
- same with the number of quarantined sessions
