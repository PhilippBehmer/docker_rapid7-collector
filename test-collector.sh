#!/bin/bash
# Tim H 2023

# Test the new collector

cd "~/source_code/"
git clone --branch tim-dev https://github.com/rapid7/presales-engineering.git
cd ~/source_code/presales-engineering/InsightIDR || exit 1

nmap -Pn -p7000 10.0.1.35
./send_collector_test_data.sh 10.0.1.35 TCP 7000

