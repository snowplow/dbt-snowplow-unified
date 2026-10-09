"""Check the Databricks CWV golden fixture using independent decimal arithmetic.

Run: python -m unittest discover -s integration_tests/python -p 'test_databricks_cwv_fixture.py'
The expected values are calculated from the public source fixture, never copied
from a warehouse result. Other adapters have separate golden fixtures.
"""
import csv
import json
import unittest
from collections import defaultdict
from decimal import Decimal, ROUND_CEILING, ROUND_HALF_UP
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
METRICS = ('lcp', 'fid', 'cls', 'ttfb', 'inp')
DIMENSIONS = {
    'overall': (),
    'by_url_and_device': ('page_url', 'device_class'),
    'by_day_and_device': ('time_period', 'device_class'),
    'by_country_and_device': ('geo_country', 'device_class'),
    'by_country': ('geo_country',),
    'by_device': ('device_class',),
    'by_day': ('time_period',),
}
THRESHOLDS = {'lcp': ('2.5', '4'), 'fid': ('100', '300'), 'cls': ('.1', '.25'),
              'ttfb': ('800', '1800'), 'inp': ('200', '500')}


def percentile(values, fraction=Decimal('.75')):
    values = sorted(v for v in values if v is not None)
    if not values:
        return None
    rank = (len(values) - 1) * fraction
    lower = int(rank)
    weight = rank - lower
    return values[lower] + weight * (values[min(lower + 1, len(values) - 1)] - values[lower])


def source_rows():
    path = ROOT / 'integration_tests/data/source/snowplow_unified_web_vital_events.csv'
    with path.open() as handle:
        source = list(csv.DictReader(handle))
    rows = []
    for row in source:
        if row['event_name'] != 'web_vitals':
            continue
        raw = json.loads(row['unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0'], parse_float=Decimal)[0]
        measurements = {}
        for name in METRICS:
            value = raw.get(name)
            if value is not None:
                value = Decimal(value).quantize(Decimal('.0001'), rounding=ROUND_HALF_UP)
                value = (value.to_integral_value(rounding=ROUND_CEILING) / 1000 if name == 'lcp'
                         else value.quantize(Decimal('.001'), rounding=ROUND_CEILING))
            measurements[name] = value
        rows.append(dict(measurements, page_url=row['page_url'], geo_country=row['geo_country'],
                         device_class=json.loads(row['contexts_nl_basjes_yauaa_context_1_0_0'])[0]['device_class'].lower(),
                         time_period=row['derived_tstamp'][:10] + ' 00:00:00',
                         view_id=json.loads(row['contexts_com_snowplowanalytics_snowplow_web_page_1_0_0'])[0]['id']))
    return rows


class DatabricksCwvFixtureTest(unittest.TestCase):
    def test_all_summary_groups_against_exact_decimal_percentiles(self):
        rows = source_rows()
        self.assertEqual(len(rows), 1000)
        # This fixture has one event per view, so no tie-breaking is needed.
        self.assertEqual(len({row['view_id'] for row in rows}), len(rows))
        groups = {}
        for kind, dimensions in DIMENSIONS.items():
            grouped = defaultdict(list)
            for row in rows:
                grouped[tuple(row[d] for d in dimensions)].append(row)
            groups.update({(kind, key): value for key, value in grouped.items()})
        with (ROOT / 'integration_tests/data/expected/databricks/snowplow_unified_web_vital_measurements_expected.csv').open() as handle:
            expected = list(csv.DictReader(handle))
        self.assertEqual(len(expected), 209)
        self.assertEqual(len(groups), len(expected))
        seen = set()
        for row in expected:
            kind = row['measurement_type']
            key = (kind, tuple(row[d] for d in DIMENSIONS[kind]))
            self.assertNotIn(key, seen)
            seen.add(key)
            values = groups[key]
            self.assertEqual(int(row['view_count']), len(values))
            classes = {}
            for name in METRICS:
                with self.subTest(group=row['compound_key'], metric=name):
                    exact = percentile([value[name] for value in values])
                    rounded = exact.quantize(Decimal('.001'), rounding=ROUND_CEILING)
                    self.assertEqual(Decimal(row[name + '_75p']), rounded)
                    good, poor = map(Decimal, THRESHOLDS[name])
                    classes[name] = 'good' if exact < good else 'needs improvement' if exact < poor else 'poor'
                    self.assertEqual(row[name + '_result'], classes[name])
            self.assertEqual(int(row['passed']), int(all(classes[name] == 'good' for name in ('lcp', 'fid', 'cls'))))
        self.assertEqual(seen, set(groups))

    def test_reference_interpolation_and_ceiling_boundaries(self):
        self.assertEqual(percentile(list(map(Decimal, ['53.3', '93.2', '295']))), Decimal('194.100'))
        self.assertEqual(percentile(list(map(Decimal, ['15.2', '278.1']))), Decimal('212.375'))
        exact = percentile(list(map(Decimal, ['1.000', '1.001'])))
        self.assertEqual(exact, Decimal('1.00075'))
        self.assertEqual(exact.quantize(Decimal('.001'), rounding=ROUND_CEILING), Decimal('1.001'))
        self.assertIsNone(percentile([None, None]))
        self.assertEqual(percentile([None, Decimal('10'), Decimal('20')]), Decimal('17.5'))


if __name__ == '__main__':
    unittest.main()
