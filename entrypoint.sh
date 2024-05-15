#!/bin/bash

set -m

# gracefully shutdown
_term() {
  echo "Caught SIGTERM signal!"
  kill -TERM $(jobs -p)
}
trap _term SIGTERM

# Xvfb for a virtual display
Xvfb :0 -screen 0 1920x1080x24 -listen tcp -ac &
# vnc server
x11vnc -forever -shared &
# window manager
icewm &
# novnc server
/usr/local/bin/websockify-rs localhost:5900 0.0.0.0:80 &

/opt/QQ/qq --no-sandbox &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?