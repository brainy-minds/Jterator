import sys
import json
# from pprint import pprint as pp


def get_handles():
    '''Reading input arguments "handles" from standard input as JSON.'''
    handles = json.loads(sys.stdin.read())
    return handles



