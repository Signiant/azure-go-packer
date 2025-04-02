FROM python:3.11-alpine
LABEL maintainer="devops@signiant.com"

# OS packages
COPY apk.packages.list /tmp/apk.packages.list
RUN chmod +r /tmp/apk.packages.list && \
    apk --update add `cat /tmp/apk.packages.list` && \
    rm -rf /var/cache/apk/*

# Azure CLI
COPY pip.packages.list /tmp/pip.packages.list
RUN python3 -m pip install -r /tmp/pip.packages.list && \
    az bicep install

# Gcloud CLI for IAP tunnel
RUN curl -sSL https://sdk.cloud.google.com | bash && \
    mv /root/google-cloud-sdk /usr/local/google-cloud-sdk

# Packer
RUN wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip && \
    mkdir /usr/local/packer && \
    mkdir /root/goworkspace && \
    unzip packer_1.11.2_linux_amd64.zip -d /usr/local/packer && \
    rm packer_1.11.2_linux_amd64.zip && \
    /usr/local/packer/packer plugins install github.com/hashicorp/azure && \
    /usr/local/packer/packer plugins install github.com/hashicorp/googlecompute

ENV GOROOT=/usr/lib/go
ENV GOBIN=/usr/local/packer
ENV GOPATH=/root/goworkspace
ENV PATH $PATH:/usr/local/packer:/usr/local/google-cloud-sdk/bin