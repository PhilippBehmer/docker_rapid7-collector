# Rapid7 InsightIDR Collector as a Docker Container

**Unofficial** Docker container image for the [Rapid7 InsightIDR Collector](https://docs.rapid7.com/insightidr/collector-overview/).

This Docker container is intended for use in lab environments. It allows for easy deployment and testing of the Rapid7 InsightIDR Collector.

## Warning

This is **NOT** supported by Rapid7! But it works :-)

## Region Tags

Each Insight-Platform region uses its own individual setup file. As such, there is no *latest* image, but different images for each region.  
Please choose the [tag](https://hub.docker.com/r/philippbehmer/docker_rapid7-collector/tags) corresponding to the region where your Insight Platform account was created.

| Region | Image | 
|--|--|
| US | philippbehmer/docker_rapid7-collector:us |
| US2 | philippbehmer/docker_rapid7-collector:us2 |
| US3 | philippbehmer/docker_rapid7-collector:us3 |
| EU | philippbehmer/docker_rapid7-collector:eu |
| AP | philippbehmer/docker_rapid7-collector:ap |
| CA | philippbehmer/docker_rapid7-collector:ca |
| AU | philippbehmer/docker_rapid7-collector:au |

## Running the InsightIDR Collector Container

Ensure you use the correct region tag, replace the volume paths with valid directories on your Docker host, and set an FQDN!

### Network
The following configuration starts the container using the host network. This way, you don't need to forward all ports from the host to the container every time you add a new event source. If you only want other containers to send logs, you can remove the `network_mode` line and use Docker's internal network.  

### Persistant Storage
The volumes mount host directories into the container to preserve logs, configuration, and local cache.

### Hostname
The collector requires an FQDN or it will create warning messages. This FQDN is used by the Insight Agents to connect to the Collector.

### docker-compose.yml

```
---
version: "3.4"
services:
  rapid7-collector:
    image: philippbehmer/docker_rapid7-collector:us
    container_name: rapid7-collector
    hostname: collector.domain.com
    volumes:
      - /path/to/persistent/storage/logs/:/opt/rapid7/collector/logs/
      - /path/to/persistent/storage/felix-cache/:/opt/rapid7/collector/felix-cache/
      - /path/to/persistent/storage/spillover-directory/:/opt/rapid7/collector/spillover-directory
    network_mode: "host"
    restart: unless-stopped
```

### Run command 

```
docker run \
        -d \
        --restart=unless-stopped \
        --network=host \
        --hostname collector.domain.com \
        -v /path/to/persistent/storage/logs:/opt/rapid7/collector/logs/ \
        -v /path/to/persistent/storage/felix-cache/:/opt/rapid7/collector/felix-cache/ \
        -v /path/to/persistent/storage/spillover-directory/:/opt/rapid7/collector/spillover-directory \
        --name rapid7-collector \
        philippbehmer/docker_rapid7-collector:us
```

## First start instructions

After starting the collector for the first time, extract the token (Agent key) with:

`docker logs rapid7-collector`

Then, [activate the collector in InsightIDR](https://docs.rapid7.com/insightidr/collector-installation-and-deployment/).

## Build Your Own Image

You can build your own image on the fly using: 

`docker build -t rapid7-collector --build-arg REGION=<region> .`  
(replace `region` with the region code)

This command creates a fresh image with the latest InsightIDR Collector version.

Since the setup automatically starts the Collector, it generates unique files such as certificates, meaning this image can only be used once. To avoid this limitation, you can [manually create the image](Manual_Image_Creation.md).

## Feedback & Improvements

You can give feedback on the [Rapid7 Discuss Board](https://discuss.rapid7.com/t/insightidr-collector-as-a-docker-container/3483).

For bugs and improvements please [create an issue](https://github.com/PhilippBehmer/docker_rapid7-collector/issues) or send a [pull request](https://github.com/PhilippBehmer/docker_rapid7-collector/pulls).



