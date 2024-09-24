#!/usr/bin/env bash
set -Eeuo pipefail

# Hook for Pomodoro timer to:
# - Continue timew when Pomodoro is started or resumed.
# - Stop timew when Pomodoro is completed, skipped, or paused.

# Inspired by: https://ankursinha.in/2017/12/25/managing-tasks-time-and-making-sure-one-takes-a-break-integrating-taskwarrior-timewarrior-and-gnome-pomodoro.html

echo "$(date) $@" >>/tmp/output.log

if [[ "$1" == "start" || "$1" == "resume" ]]; then
    if ! timew; then
        timew continue
    fi
fi

if [[ "$1" == "complete" || "$1" == "skip" || "$1" == "pause" ]]; then
    if timew; then
        # When stopping, Pomodoro issues a resume followed immediately by a skip.
        # Timewarrior throws a "The end of a date range must be after the start."
        # error, so keep retrying until stopping succeeds. (Up to a maximum of
        # 60 seconds.)
        for i in {1..60}; do
            timew stop && break
            sleep 1
        done
    fi
fi
