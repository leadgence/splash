#!/bin/bash
SPLASH_RESTART_SECONDS="${SPLASH_RESTART_SECONDS:-180}"
# Exit cleanly on termination
trap 'splash_clean_exit' TERM

splash_clean_exit() {
  kill -9 ${splash_pid}
  echo "Splash killed, exiting with 0 to prevent container from failing"
  exit 0
}

splash_pid=""
while true; do
  echo "Starting Splash..."

  python3 \
    /app/bin/splash \
    --proxy-profiles-path /etc/splash/proxy-profiles \
    --js-profiles-path /etc/splash/js-profiles \
    --filters-path /etc/splash/filters \
    --lua-package-path /etc/splash/lua_modules/?.lua \
    "$@" &

  splash_pid=$!
  sleep 2
  while true; do
    result=$(curl --max-time 5 -I http://localhost:8050 2>/dev/null)
    if [ -z "$result" ]; then
      pkill -9 python3
      break
    fi
  done
  wait ${splash_pid}
  echo "Attempting to kill Xvfb instances if exist..."
  pkill -9 -e Xvfb 
done
