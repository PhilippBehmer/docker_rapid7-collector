# Rapid7 Collector as a Docker Container (CaaC)

This describes how I created a Docker container for the [Rapid7 Insight-Platform Collector](https://docs.rapid7.com/insightidr/collector-overview/).
You can use it for your personal lab or in case you want to receive logs directly from Docker containers.

## Warning

This is **NOT** supported by Rapid7! But it works :-)

## Region tags

Each Insight-Platform region uses it's own individual setup file. As such, there is no *latest* image, but different images for each region.
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

## Sample

The following configuration starts the container using the host network. This setup is optimal if you want to connect other systems via syslog. This way, you don't need to forward all ports from the host to the container every time you add a new event source. If you only want other containers to send logs, you can remove the network_mode line and use Docker's internal network. The volumes mount host directories into the container to preserve logs, configuration, and local cache.

Ensure you use the correct region tag and replace the volume paths with valid directories on your Docker host!

### docker-compose.yml

```
---
version: "3.4"
services:
  rapid7-collector:
    image: philippbehmer/docker_rapid7-collector:us
    container_name: rapid7-collector
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

## Size

* Image size: 82MB
* RAM (idle): 78MB

## Feedback & Improvments

You can give feedback on the [Rapid7 Discuss Board](https://discuss.rapid7.com/t/insightidr-collector-as-a-docker-container/3483).

For bugs and improvements please [create an issue](https://github.com/PhilippBehmer/docker_rapid7-collector/issues) or send a [pull request](https://github.com/PhilippBehmer/docker_rapid7-collector/pulls).

## How to Create the Image on Your Own

**1. (Host) Create new container with Dockerfile**

`docker build -t collector .`

**2. (Host) Create container and open first container bash session**

`docker run -it --name collector --entrypoint /bin/bash collector`

**3. (Host) Download the latest setup**

|Insight Platform Region| Command |
|--|--|
| US <br> (us-east-1) | `wget https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh` |
| US2 <br> (us-east-2) | `wget https://s3-us-east-2.amazonaws.com/public.razor-prod-5.us-east-2.insight.rapid7.com/InsightSetup-Linux64.sh` |
| US3 <br> (us-west-2) | `wget https://s3-us-west-2.amazonaws.com/public.razor-prod-6.us-west-2.insight.rapid7.com/InsightSetup-Linux64.sh` |
| EU <br> (eu-central-1) | `wget https://s3.eu-central-1.amazonaws.com/public.razor-prod-0.eu-central-1.insight.rapid7.com/InsightSetup-Linux64.sh` |
| AP <br> (ap-northeast-1) | `wget https://s3-ap-northeast-1.amazonaws.com/public.razor-prod-2.ap-northeast-1.insight.rapid7.com/InsightSetup-Linux64.sh` |
| CA <br> (ca-central-1) | `wget https://s3.ca-central-1.amazonaws.com/public.razor-prod-3.ca-central-1.insight.rapid7.com/InsightSetup-Linux64.sh` |
| AU <br> (ap-southeast-2) | `wget https://s3-ap-southeast-2.amazonaws.com/public.razor-prod-4.ap-southeast-2.insight.rapid7.com/InsightSetup-Linux64.sh` |

**4. (Host) Make the setup file executable**

`chmod 700 InsightSetup-Linux64.sh`

**5. (Host) Copy setup into container**

`docker cp InsightSetup-Linux64.sh collector:/opt/`

**6. (Host) Open second bash session in container**

`docker exec -it --workdir /opt/ collector /bin/bash`

**7. (Container Session 2) Start setup in container, accept all dialogs and install to /opt/rapid7/collector**

`./InsightSetup-Linux64.sh`

**8. (Container Session 1) During the file extraction rename the collector executable**

`mv /opt/rapid7/collector/collector /opt/rapid7/collector/collector.tmp`

During the installation you will see an error message which can be ignored: *Cannot run program "sudo": error=2, No such file or directory*  
This is the right time to execute the `mv` command. Don't wait too long or the collector is automatically started and config files will be created.

If you see the following message you waited too long and you need to start over!

```
Agent key: 8e6cc85b-13bd-4377-b1e3-64a42123618f9d  
Login to https://insight.rapid7.com/ and activate your collector with this
agent key.
```

**9. (Container Session 1) Wait for installation to finish and rename the collector executable again**

You will see an error message which can be ignored: *Rapid7 Insight Platform Collector service could not be started.  The installer will now exit.*  
This is the right time to execute the following command.

`mv /opt/rapid7/collector/collector.tmp /opt/rapid7/collector/collector`

**10. (Container Session 2) Remove setup file from the container**

`rm /opt/InsightSetup-Linux64.sh`

**11. Disconnect both container sessions**

Disconnect from both container sessions using `exit`.

**12. (Host) Set ENTRYPOINT, CMD and commit container to new image**

`docker commit --change='WORKDIR /opt/rapid7/collector/' --change='ENTRYPOINT ["/opt/rapid7/collector/collector"]' --change='CMD ["run"]' collector philippbehmer/docker_rapid7-collector:<region>`

Replace `<region>` with region code.

**13. (Host) Delete temporary container and image**

`docker rm collector`

`docker rmi collector`

**14. Test new comtainer image**

`docker run --name collector philippbehmer/docker_rapid7-collector:<region>`

Replace `<region>` with region code. 
You should see an agent key like this:

`INFO: **** Agent key for this Collector is: 74345e2a-d92e-4cf8-bb6e-7cd89c51e127`

