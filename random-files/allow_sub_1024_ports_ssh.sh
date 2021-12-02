#!/bin/bash
set -e
sudo setcap 'CAP_NET_BIND_SERVICE=+ep' /usr/bin/ssh
