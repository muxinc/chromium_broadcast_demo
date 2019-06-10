#!/bin/bash

python3 serve.py &
SERVE_PID=$!

echo "Starting Pulseaudio"
pulseaudio &
PULSE_PID=$!
sleep 1

echo "Starting Xvfb"
Xvfb :1 -screen 0 1280x720x24 &
XVFB_PID=$!
sleep 1

echo "Capturing with FFmpeg"
ffmpeg -y -f x11grab -draw_mouse 0 -s 1280x720 -r 24 -i :1.0+0,0 -f pulse -ac 2 -i default -c:v libx264 -preset veryfast -threads 4 -crf 24 -maxrate 4000k -bufsize 4000k -force_key_frames 'expr:gte(t,n_forced*5)' -c:a aac -b:a 128k -f flv ${2} 2> /dev/null &
FFMPEG_PID=$!

echo "Launching Chromium"
DISPLAY=:1 DISPLAY=:1.0 chromium-browser --autoplay-policy=no-user-gesture-required --enable-logging=stderr --v=1 --no-sandbox --disable-gpu --user-data-dir=/tmp/test --window-position=0,0 --window-size=1280,720 "--app=${1} " 2>&1 | grep -i "INFO:CONSOLE\|peer\|error" &
CHROMIUM_PID=$!

sleep infinity

echo "Stopping"

kill $SERVE_PID
kill $FFMPEG_PID
kill $CHROMIUM_PID
kill $XVFB_PID
kill $PULSE_PID

sleep 1

kill -9 $SERVE_PID
kill -9 $FFMPEG_PID
kill -9 $CHROMIUM_PID
kill -9 $XVFB_PID
kill -9 $PULSE_PID

echo "DONE"
