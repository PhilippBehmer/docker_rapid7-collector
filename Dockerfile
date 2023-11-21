# Watch out for Apple M1 chips
# Have to specify 64 bit version, R7 only works with it:
FROM --platform=linux/amd64 ubuntu:20.04

# set the user as root
USER root

# Set environment variables.
ENV HOME /root

RUN apt-get -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true update && \
    apt-get -y upgrade && \
    apt-get update                          && \
    apt-get install -y --no-install-recommends \
    wget sudo libc6 ca-certificates expect && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN sudo update-ca-certificates

# download the discover.sh github repo
RUN wget --no-check-certificate --output-document="Collector_installer.sh" \
    https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh

RUN chmod u+x Collector_installer.sh

COPY --chmod=0744 ["script.exp", "/root"]

# run it
RUN /root/script.exp

# set the working directory for any users that login
WORKDIR /opt/rapid7/collector/

RUN service collector stop && rm -Rf /opt/rapid7/collector/logs/*.log /opt/rapid7/collector/agent-key/Agent_Key.html  /opt/rapid7/collector/felix-cache/*

VOLUME ["/opt/rapid7/collector/logs/"]
VOLUME ["/opt/rapid7/collector/felix-cache/"]
VOLUME ["/opt/rapid7/collector/spillover-directory"]

ENTRYPOINT ["/opt/rapid7/collector/collector"]
CMD ["run"]
