import unittest
import sys
from argparse import ArgumentError
from contextlib import contextmanager
from io import StringIO
from parsing_utils import parse_args
''' Testing file
    Run with `python -m unittest in the root folder'''

@contextmanager
def capture_sys_output():
    capture_out, capture_err = StringIO(), StringIO()
    current_out, current_err = sys.stdout, sys.stderr
    try:
        sys.stdout, sys.stderr = capture_out, capture_err
        yield capture_out, capture_err
    finally:
        sys.stdout, sys.stderr = current_out, current_err

class ArgParseTestCase(unittest.TestCase):
    '''Tests for argument parsing'''

    def __init__(self, *args, **kwargs):
        self.testing_params = {'prog':'TESTING', 'usage':''}
        self.stderr_msg = 'usage: \nTESTING: error: {errmsg}\n'
        super(ArgParseTestCase, self).__init__(*args, **kwargs)
    
    def test_years_y_single(self):
        '''Test if a single pair of years produces the right values'''
        valid_result = {2016:range(4,7)}
        args = parse_args('b month -p 8 -r 201604 201606'.split())
        self.assertEqual(valid_result, args.range)

    def test_metric_both(self):
        '''Test if inputting both metrics produces right metric arguments'''
        valid_result = ['b','t']
        args = parse_args('b t year -p 8 -r 201401 201501'.split())
        self.assertEqual(valid_result, args.Metric)

    def test_metric_three(self):
        '''Test if a too many metrics throws an error'''
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b t t year -p 8 -r 201407 201506'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        errmsg = 'Extra input of metrics unsupported'
        self.assertEqual(self.stderr_msg.format(errmsg=errmsg), stderr.getvalue())

    def test_aggregation_level(self):
        '''Test if aggregation level years produces the right value'''
        valid_result = 'year'
        args = parse_args('b t year -p 8 -r 201401 201501'.split())
        self.assertEqual(valid_result, args.Aggregation)

    def test_years_y_multiple(self):
        '''Test if a multiple pair of years produces the right values'''
        valid_result = {2012:set.union(set(range(3,8)), set(range(9,13))),
                        2013:range(1,4)}
        
        args = parse_args('b month -p 8 -r 201203 201207 -r 201209 201303'.split())
        self.assertEqual(valid_result, args.range)

    def test_range_only_one_exception(self):
        '''Test if a single year produces the right exception'''
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b year -p 8 -r 201201'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        self.assertEqual('usage: \nTESTING: error: argument -r/--range: expected 2 arguments\n', stderr.getvalue())

    def test_custom_period_name_exception(self):
        '''Test if combining custom time period name with -i produces the right exception'''
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b month -i 8 10 --periodname AM Peak -r 201207 201506'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        self.assertEqual('usage: \nTESTING: error: --periodname should only be used with --timeperiod\n', stderr.getvalue())

    def test_timeperiod_too_many_args_exception(self):
        '''Test if a single year produces the right exception'''
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b month -p 8 10 12 -r 201207 201506'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        self.assertEqual('usage: \nTESTING: error: --timeperiod takes one or two arguments\n', stderr.getvalue())

    def test_period_one(self):
        '''Test if a the right value for period is parsed'''
        valid_result = [8]
        args = parse_args('b t month -p 8 -r 201407 201506'.split())
        self.assertEqual(valid_result, args.timeperiod)

    def test_periodname(self):
        '''Test if the right value for a custom timeperiod name is parsed'''
        valid_result = 'AM Peak '
        args = parse_args("b t month -p 8 --periodname AM Peak -r 201407 201506".split())
        self.assertEqual(valid_result, args.periodname)

    def test_iterate_hours(self):
        '''Test if the right value for iteration hours is parsed'''
        valid_result = [8,9]
        args = parse_args('b t month -i 8 9 -r 201407 201506'.split())
        self.assertEqual(valid_result, args.hours_iterate)

    def test_default_tablename(self):
        '''Test if the right default for tablename is returned'''
        valid_result = 'congestion.metrics'
        args = parse_args('b t month -i 8 9 -r 201407 201506'.split())
        self.assertEqual(valid_result, args.tablename)

    def test_hours_check(self):
        '''Test if a too many metrics throws an error'''
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b year -p 8 25 -r 201407 201506'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        errmsg = '25 must be between 0 and 24'
        self.assertEqual(self.stderr_msg.format(errmsg=errmsg), stderr.getvalue())
        with self.assertRaises(SystemExit) as cm, capture_sys_output() as (stdout, stderr):
            args = parse_args('b year -p 24 8 -r 201407 201506'.split(), **self.testing_params)
        self.assertEqual(2, cm.exception.code)
        errmsg = '24 must be before 8'
        self.assertEqual(self.stderr_msg.format(errmsg=errmsg), stderr.getvalue())
                
if __name__ == '__main__':
    unittest.main()