# Rapid7 Collector as a Docker Container (CaaC)

[Forked from Philipp Behmer's repo](https://github.com/PhilippBehmer/docker_rapid7-collector)

[Docker Image hosted on DockerHub](https://hub.docker.com/r/themolecularman/rapid7-collector/tags)

[activate the collector in InsightIDR or InsightOps](https://docs.rapid7.com/insightidr/collector-installation-and-deployment/).

This describes how I created a Docker container for the [Rapid7 Insight-Platform Collector](https://docs.rapid7.com/insightidr/collector-overview/). The docker-compose.yml will build a container designed to be run on a Synology.
You can use it for your personal lab or in case you want to receive logs directly from Docker containers.

## Fork Notes:
* Modified Dockerfile to dynamically build the image using automated scripts. Running ./build_docker.sh will create an image that has the latest version of the R7 collector.
* Added script.exp, which is an [expect script](https://linux.die.net/man/1/expect) that automatically answers all the interactive questions for the Bash install script that install the Rapid7 Collector
* Added create_collector.sh, which is designed to deploy a Collector in a docker image on a Synology.
* Added test-collector.sh which points to another repository of mine that will generate fake syslogs and send it to a collector so you can verify everything is working.

## Warning
This Docker image/method is **NOT** officially supported by Rapid7! But it works :-)

## Networking
This starts the container using the host network. This is best if you want to connect other systems via syslog. This way you don't need to forward all ports from the host to the container every time you add a new event source. If you just want other containers to send logs you can remove the line "network_mode" and use the docker internal network.

## Mount points / volumes
The volumes mount host directories into the container to preserve logs, config and local cache.
The default set of mount points are designed for deploying on a Synology.

## Use - deploying the container using my prebuilt Docker Hub image:
1) run the create collector script: ./create_collector.sh
2) It will download the image from Docker Hub, start a new instance locally, and display the pairing key. NOTE: The Docker Hub repository image may not have the latest version of the Rapid7 Collector in it, but the collector will automatically update itself after pairing.

## Use - Building the container to ensure you're using the latest Collector software
1) build the image from scratch: ./build_docker.sh
2) It will build the image, start a new instance, and start a bash terminal session inside the new container

## Size / Stats:
* Image size as of Nov 22, 2023: 190 MB
* RAM utilization with 2 event sources: 291 MB
