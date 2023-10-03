# snowplow-unified-integration-tests

Integration test suite for the snowplow-unified dbt package.

The `./scripts` directory contains two scripts:

- `integration_tests.sh`: This tests the standard modules of the snowplow-unified package. It runs the Snowplow web package 4 times to replicate incremental loading of events, then performs an equality test between the actual vs expected output.
- `integration_tests_w_custom_module.sh`: This tests the standard modules of the snowplow-unified package as well as the back-filling of custom modules. In total the package is run 6 times, with run 1-2 being the standard modules, runs 3-4 being the back-filling of the newly introduced custom module, and runs 5-6 being the both the standard and custom module. Once complete, equality checks are performed on the actual vs expected output of the standard modules.

Run the scripts using:

```bash
bash integration_tests.sh -d {warehouse}
```

Supported warehouses:

- redshift
- bigquery
- snowflake
- postgres
- all (iterates through all supported warehouses)

Good-to-knows:

There are certain exceptions to how different warehouses process data and in places we had to adjust the integration test to work around that. Here's a list of things to keep in mind:

- the non-deterministic nature of row_number() function for Redshift/Postgres/Databricks means that we had to hard-code actuals and expected models for cases where we are testing duplicate rows with exact same results / window
- postgres / redshift needing the array format of : (within sessions_expected)
- bigquery handling of snowplow_utils.timestamp_diff()
- rotating domain_userid per session is hard-coded in the integration test expectations, when run in one batch the user_identifier differs: 2e340eb6e94820ea8369c0174c612260d1cfe9d41f0fe46268994e28d9c0bbf17
0e9ab97b5d9d9a174112df13fe9c44788af3ac9088a8b41e0998d92a8b4b5a4fc
- same with the number of quarantined sessions
