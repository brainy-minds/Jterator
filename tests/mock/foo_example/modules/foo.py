import sys
import json
from pprint import pprint as pp


def get_handles():
    '''Reading input arguments "handles" from standard input as JSON.'''
    json_data = sys.stdin.read()
    handles = json.loads(json_data)
    return handles


def bar(handles):
    print 'Bar has got input: '
    pp(handles)
    print 'Test if bar is happy about the input..'
    assert 'value' in handles['some_arg']
    assert False
    print 'ok'


def baz(handles):
    print 'Baz has also got input: '
    pp(handles)
    print 'Test if baz is happy about the input..'
    assert 'value' in handles['some_other_arg']
    print 'ok'
