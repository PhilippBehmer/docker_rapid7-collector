## How to Create a Clean Image on Your Own

**1. (Host) Create new container with Dockerfile**

`docker build -t collector -f Dockerfile_clean_image .`

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

**7. (Container Session 2) Start the Setup**

`./InsightSetup-Linux64.sh`

Install the Collector in the container. Accept all dialogs and install to `/opt/rapid7/collector`.

**8. (Container Session 1) Prevent Collector Autostart**

During the file extraction rename the collector executable.  
This step is important, as it prevents the setup to automatically start the Collector creating unique files like certificates and the agent key.

`mv /opt/rapid7/collector/collector /opt/rapid7/collector/collector.tmp`

After starting the installation you will see an error message: 

>Cannot run program "sudo": error=2, No such file or directory

This can be ignored and it's the right time to execute the `mv` command. Don't wait too long or the collector is automatically started and config files will be created.

If you see the following message you waited too long and you need to start over!

```
Agent key: 8e6cc85b-13bd-4377-b1e3-64a42123618f9d  
Login to https://insight.rapid7.com/ and activate your collector with this
agent key.
```

**9. (Container Session 1) Rename Collector Executable again**

Wait for installation to finish. You will see an error message:

>Rapid7 Insight Platform Collector service could not be started.  The installer will now exit.

This can be ignored and we can now restore the original name of the executable:

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