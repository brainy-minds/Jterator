#!/usr/bin/env python
import sys
import yaml
import json

# read YAML from standard input
pipe_input = yaml.load(sys.stdin)

# write JSON string to standard output
pipe_output = json.dumps(pipe_input)
print(pipe_output)
