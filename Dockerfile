# Watch out for Apple M1 chips
# Have to specify 64 bit version, R7 only works with it:
# --platform=linux/amd64
FROM ubuntu:20.04

# set the user as root
USER root

# Set environment variable, sometimes install scripts
# need $HOME to be defined
ENV HOME /root

# install updates, install dependencies, remove apt cache
RUN apt-get -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true update && \
    apt-get -y upgrade && \
    apt-get update                          && \
    apt-get install -y --no-install-recommends \
    wget sudo libc6 ca-certificates expect && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# update the Certificate Authorities
# wget and other procs check them    
# Download the Rapid7 collector's installer for Linux
# mark it as executable
# --no-check-certificate
RUN update-ca-certificates && \
    wget --progress=dot:giga --output-document="Collector_installer.sh" \
    https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh \
    && chmod u+x Collector_installer.sh

# copy the autoexpect script into the container
# mark it as executable
COPY --chmod=0744 ["script.exp", "/root"]

# run the autoexpect script that will answer the
# interactive questions from the R7 installer
RUN /root/script.exp

# set the working directory for any users that login
WORKDIR /opt/rapid7/collector/

# stop the service and delete all the configuration
# don't want the image to always have the same
# Agent GUID
# service collector stop && 
RUN rm -Rf /opt/rapid7/collector/logs/*.log \
    /opt/rapid7/collector/agent-key/Agent_Key.html \
    /opt/rapid7/collector/felix-cache/*

# define volume mount points
VOLUME ["/opt/rapid7/collector/logs/"]
VOLUME ["/opt/rapid7/collector/felix-cache/"]
VOLUME ["/opt/rapid7/collector/spillover-directory"]

ENTRYPOINT ["/opt/rapid7/collector/collector"]
CMD ["run"]
