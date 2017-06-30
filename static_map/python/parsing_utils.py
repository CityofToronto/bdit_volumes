#parsing_utils.py
#! python2
"""Parsing utilities for map_metric.py

Public Functions:
    parse_args(args, prog = None, usage = None):
        Parse command line argument
    
    """
import argparse
from parsing_utilities import validate_multiple_yyyymm_range

def _check_hour(parser, hour):
    if hour < 0 or hour > 24:
        raise parser.error('{} must be between 0 and 24'.format(hour))

def _check_hours(parser, hours):
    if len(hours) > 1:
        for hour in hours:
            _check_hour(parser, hour)
        if hours[0] > hours[1]:
            raise parser.error('{} must be before {}'.format(hours[0],hours[1]))
    else:
        _check_hour(parser, hours if type(hours) is int else hours[0])

def parse_args(args, prog = None, usage = None):
    """Parse command line arguments
    
    Args:
        sys.argv[1]: command line arguments
        prog: alternate program name, FOR TESTING
        usage: alternate usage message, to suppress FOR TESTING
        
    Returns:
        dictionary of parsed arguments
    """
    PARSER = argparse.ArgumentParser(description='Produce maps of congestion metrics (tti, bti) for '
                                                 'different aggregation periods, timeperiods, and '
                                                 'aggregation levels', prog=prog, usage=usage)
    
    PARSER.add_argument('Metric', choices=['b', 't'], nargs='+',
                        help="Map either Buffer Time Index, Travel"
                        "Time Index or both e.g. b, t, or 'b t'."
                        "Make sure to space arguments")
    
    PARSER.add_argument("Aggregation", choices=['year', 'quarter', 'month'],
                        help="Aggregation level to be used")
    
    PARSER.add_argument("-r", "--range", nargs=2, action='append',
                        help="Range of months (YYYYMM) to operate over"
                        "from startdate to enddate. Accepts multiple pairs",
                        metavar=('YYYYMM', 'YYYYMM'), required=True)
    
    TIMEPERIOD = PARSER.add_mutually_exclusive_group(required=True)
    TIMEPERIOD.add_argument("-p", "--timeperiod", nargs='+', type=int,
                            help="Timeperiod of aggregation, use 1 arg for 1 hour or 2 args for a range")
    TIMEPERIOD.add_argument("-i","--hours_iterate", nargs=2, type=int,
                            help="Create hourly maps from H1 to H2 with H from 0-24")
    
    PARSER.add_argument("--periodname", nargs=2,
                        help="Custom name for --timeperiod e.g. 'AM Peak'")
    
    PARSER.add_argument("-d", "--dbsetting",
                        default='default.cfg',
                        help="Filename with connection settings to the database"
                        "(default: opens %(default)s)")
    PARSER.add_argument("-t", "--tablename",
                        default='congestion.metrics',
                        help="Table containing metrics %(default)s")
    parsed_args = PARSER.parse_args(args)
    
    if parsed_args.periodname:
        parsed_args.periodname = ' '.join(parsed_args.periodname) + ' '
    if parsed_args.timeperiod and len(parsed_args.timeperiod) > 2:
        PARSER.error('--timeperiod takes one or two arguments')
    if len(parsed_args.Metric) > 2:
        PARSER.error('Extra input of metrics unsupported')
    if parsed_args.periodname and parsed_args.hours_iterate:
        PARSER.error('--periodname should only be used with --timeperiod')
    _check_hours(PARSER, parsed_args.timeperiod if parsed_args.timeperiod else parsed_args.hours_iterate)
    try:
        parsed_args.range = validate_multiple_yyyymm_range(parsed_args.range, parsed_args.Aggregation)
    except ValueError as err:
        PARSER.error(err)
    return parsed_args

