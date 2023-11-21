#!/bin/bash
# Tim H 2023
# Installing R7 collector on Synology via Docker

INSTALL_PATH="/volume1/docker/rapid7_collector"
mkdir -p "$INSTALL_PATH" \
         "$INSTALL_PATH/logs/" \
         "$INSTALL_PATH/felix-cache" \
         "$INSTALL_PATH/spillover-directory"

cd "$INSTALL_PATH" || exit 1

# start it up
sudo docker-compose up -d

# get the collector pairing key from the logs:
grep "Agent key for this Collector" "$INSTALL_PATH"/logs/*.log | sort --unique
