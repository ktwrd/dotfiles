#!/usr/bin/env bash
/usr/bin/systemctl status $1 | grep 'Active:' | awk '{print $2, $3}'
