#!/bin/bash
set -ex

if [ "${RUN_FLUXBOX,,}" != "true" ]; then
  rm -f /app/conf.d/fluxbox.conf
fi

if [ "${RUN_XTERM,,}" != "true" ]; then
  rm -f /app/conf.d/xterm.conf
fi

if [ "${RUN_FIREFOX,,}" != "true" ]; then
  rm -f /app/conf.d/firefox.conf
fi

if [ "${RUN_DOOM,,}" != "true" ]; then
  rm -f /app/conf.d/doom.conf
fi

exec supervisord -c /app/supervisord.conf
