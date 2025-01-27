FROM ubuntu:22.04

LABEL maintainer="Philipp Behmer - https://github.com/PhilippBehmer"

VOLUME ["/opt/rapid7/collector/logs/"]
VOLUME ["/opt/rapid7/collector/felix-cache/"]
VOLUME ["/opt/rapid7/collector/spillover-directory"]

WORKDIR /opt/rapid7/collector/

ENTRYPOINT ["/opt/rapid7/collector/collector"]
CMD ["run"]
