#!/bin/bash
LOG=/tmp/xfce-no-lock.log
echo "[$(date)] started" >> "$LOG"

until pgrep -u kali xfce4-session >/dev/null 2>&1; do
  sleep 0.5
done

export DISPLAY=:1
export XAUTHORITY=/home/kali/.Xauthority
set +e

xfconf-query -c xfce4-session -p /general/LockScreen  -t bool -s false --create
xfconf-query -c xfce4-session -p /shutdown/LockScreen -t bool -s false --create

echo "[$(date)] completed" >> "$LOG"