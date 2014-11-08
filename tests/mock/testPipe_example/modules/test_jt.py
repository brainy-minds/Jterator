#!/usr/bin/env python
import sys
import json

stream = sys.stdin
data = json.load(stream)

print(type(data))
