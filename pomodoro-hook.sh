#!/usr/bin/env bash
set -Eeuo pipefail

# Hook for Pomodoro timer to:
# - Continue timew when Pomodoro is started or resumed.
# - Stop timew when Pomodoro is completed, skipped, or paused.

# Inspired by: https://ankursinha.in/2017/12/25/managing-tasks-time-and-making-sure-one-takes-a-break-integrating-taskwarrior-timewarrior-and-gnome-pomodoro.html

if [[ "$1" == "start" || "$1" == "resume" ]]; then
    timew || timew continue
fi

if [[ "$1" == "complete" || "$1" == "skip" || "$1" == "pause" ]]; then
    timew && timew stop
fi
