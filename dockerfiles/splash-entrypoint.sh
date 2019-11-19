#!/bin/sh

# Exit cleanly on termination
trap 'splash_clean_exit' TERM

splash_clean_exit() {
  kill ${splash_pid}
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

  wait ${splash_pid}
  echo "Attempting to kill Xvfb instances if exist..."
  pkill -9 -e Xvfb 
done
