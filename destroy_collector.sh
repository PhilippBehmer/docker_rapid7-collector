#!/bin/bash
# Tim H 2023
# Remove R7 collector on Synology via Docker

INSTALL_PATH="/volume1/docker/rapid7_collector"

# destroy any previous version:
sudo docker-compose down

# remove any old files from previous version
cd "$INSTALL_PATH" || exit 1
find . -mindepth 2 -delete
