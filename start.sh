#!/bin/sh
# Bring up a virtual display, a window manager, real DOOM, and a VNC->web bridge.
set -e
export DISPLAY=:0
Xvfb :0 -screen 0 1024x768x24 >/dev/null 2>&1 &
sleep 1
fluxbox >/dev/null 2>&1 &
# the actual game engine + shareware IWAD (installed at /usr/share/games/doom)
chocolate-doom -iwad /usr/share/games/doom/freedoom1.wad -window -geometry 1024x768 >/dev/null 2>&1 &
x11vnc -display :0 -forever -shared -nopw -quiet >/dev/null 2>&1 &
# open http://localhost:8080/vnc.html and play
exec websockify --web /usr/share/novnc 8080 localhost:5900
