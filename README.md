
# Rapid7 Insight-Platform Collector in a Docker Container

### Warning

This is **NOT** supported by Rapid7! But it works :-)

### Sample run command

```
docker run \
        -d \
        --restart=unless-stopped \
        --network=host \
        -v /path/to/persistent/storage/logs:/opt/rapid7/collector/logs/ \
        -v /path/to/persistent/storage/felix-cache/:/opt/rapid7/collector/felix-cache/ \
        -v /path/to/persistent/storage/spillover-directory/:/opt/rapid7/collector/spillover-directory \
        --name rapid7-collector \
        philippbehmer/docker_rapid7-collector:latest
```

### Sample docker-compose.yml

This compose file starts the container using the host network. This is best if you want to connect other systems via syslog. This way you don't need to manually forward all ports from the host to the container every time you add a new event source. If you just want other containers to send logs you can remove the line "network_mode".

```
---
version: "3.4"
    services:
	    rapid7-collector:
		    image: philippbehmer/docker_rapid7-collector:latest
		    container_name: rapid7-collector
		    volumes:
				- ./data/logs/:/opt/rapid7/collector/logs/
				- ./data/felix-cache/:/opt/rapid7/collector/felix-cache/
		        - ./data/data/spillover-directory/:/opt/rapid7/collector/spillover-directory
			network_mode: "host"
			restart: unless-stopped
```
    
### First start instructions

After staring the collector for the first time you need to extract the token (Agent key) with

`docker logs rapid7-collector`

and activate the collector in InsightIDR or InsightOps.
https://docs.rapid7.com/insightidr/collector-installation-and-deployment/

### Size

* Image Size: 188MB
* RAM (idle): 150MB

### How to create it on your own image

1. Create new container with Dockerfile

`docker build -t collector .`

2. Create container

`docker run -it --name collector collector /bin/bash`

3. Download latest setup

`wget https://s3.eu-central-1.amazonaws.com/public.razor-prod-0.eu-central-1.insight.rapid7.com/InsightSetup-Linux64.sh`

`chmod 700 InsightSetup-Linux64.sh`

4. Copy setup into container

`docker cp InsightSetup-Linux64.sh collector:/opt/`

5. Open second bash session in container

`docker exec -it collector /bin/bash`

6. Start setup in container & accept dialogs and install to /opt/rapid7/collector

`./InsightSetup-Linux64.sh`

7. Directly after the file extraction step rename the collector executable

`mv collector collector.tmp`

8. Wait for installation to finish and then rename the collector executable again

`mv collector.tmp collector`

9. Remove setup file

`rm /opt/InsightSetup-Linux64.sh`

10. Set ENTRYPOINT, CMD and commit container to new image

`docker commit --change='ENTRYPOINT ["/opt/rapid7/collector/collector"]' --change='CMD ["run"]' collector`

11. Tag image

`docker tag <image-id> philippbehmer/docker_rapid7-collector:latest`