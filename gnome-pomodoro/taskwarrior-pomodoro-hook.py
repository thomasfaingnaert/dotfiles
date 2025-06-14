#!/usr/bin/env python3

# Hook for TaskWarrior to:
# - Start Pomodoro timer when starting a task.
# - Stop Pomodoro timer when stopping a task.

# Based on: https://ankursinha.in/2017/12/25/managing-tasks-time-and-making-sure-one-takes-a-break-integrating-taskwarrior-timewarrior-and-gnome-pomodoro.html

# Also see the TaskWarrior hook by Gothenburg Bit Factory, shipped with TimeWarrior.

import json
import sys
import subprocess

try:
    input_stream = sys.stdin.buffer
except AttributeError:
    input_stream = sys.stdin

def main(old, new):
    # Started task.
    if 'start' in new and 'start' not in old:
        subprocess.run(['gnome-pomodoro', '--start'])

    # Stopped task.
    elif ('start' not in new or 'end' in new) and 'start' in old:
        subprocess.run(['gnome-pomodoro', '--pause'])

if __name__ == "__main__":
    old = json.loads(input_stream.readline().decode("utf-8", errors="replace"))
    new = json.loads(input_stream.readline().decode("utf-8", errors="replace"))
    print(json.dumps(new))
    main(old, new)
