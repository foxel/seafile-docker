#!/usr/bin/env bash

echo "Waiting for MySQL..."
while ! mysqladmin ping -hmysql -useafile -pseafile --silent 2>/dev/null; do
    sleep 1
done
