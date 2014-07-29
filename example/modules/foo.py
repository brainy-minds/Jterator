import sys
import json
from pprint import pprint as pp


def bar():
    print 'This is a bar function'
    handles = json.loads(sys.stdin.read())
    # pp(handles)
    # print(type(handles))
    baz(handles)


# Parse JSON and pass it as handles input into the function
def baz(handles):
    pp(handles)
    print(type(handles))

