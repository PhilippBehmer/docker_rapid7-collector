FROM ubuntu:22.04

LABEL maintainer="Philipp Behmer - https://github.com/PhilippBehmer"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /opt/

# Define region-specific URLs
ARG REGION
ENV REGION_URL=""

# Copy autoexpect script
COPY --chmod=0744 ["script.exp", "/opt"]

# Download the setup script
RUN if [ "$REGION" = "us" ]; then \
        REGION_URL="https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "us2" ]; then \
        REGION_URL="https://s3-us-east-2.amazonaws.com/public.razor-prod-5.us-east-2.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "us3" ]; then \
        REGION_URL="https://s3-us-west-2.amazonaws.com/public.razor-prod-6.us-west-2.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "eu" ]; then \
        REGION_URL="https://s3.eu-central-1.amazonaws.com/public.razor-prod-0.eu-central-1.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "ap" ]; then \
        REGION_URL="https://s3-ap-northeast-1.amazonaws.com/public.razor-prod-2.ap-northeast-1.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "ca" ]; then \
        REGION_URL="https://s3.ca-central-1.amazonaws.com/public.razor-prod-3.ca-central-1.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    elif [ "$REGION" = "au" ]; then \
        REGION_URL="https://s3-ap-southeast-2.amazonaws.com/public.razor-prod-4.ap-southeast-2.insight.rapid7.com/InsightSetup-Linux64.sh"; \
    else \
        echo "Invalid region specified"; exit 1; \
    fi \
    && apt-get update \
    && apt-get install -y wget expect \
    && wget -O InsightSetup-Linux64.sh $REGION_URL \
    && chmod 700 InsightSetup-Linux64.sh \
    && ./script.exp \
    && rm /opt/InsightSetup-Linux64.sh \
          /opt/script.exp \
    && apt-get remove -y wget expect \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory for the collector
WORKDIR /opt/rapid7/collector/

VOLUME ["/opt/rapid7/collector/logs/"]
VOLUME ["/opt/rapid7/collector/felix-cache/"]
VOLUME ["/opt/rapid7/collector/spillover-directory"]

ENTRYPOINT ["/opt/rapid7/collector/collector"]
CMD ["run"]
