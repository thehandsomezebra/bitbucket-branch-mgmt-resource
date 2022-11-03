# FROM ubuntu
FROM ubuntu:kinetic-20220830

ENV COLUMNS=80

# COLUMNS var added to work around certain cli's needing a terminal size specified

# base packages
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update -y \
    && apt-get install -yy \
      curl \
      git \
      jq \
      vim-common \
      wget \
      tree \
    && rm -rf /var/lib/apt/lists/*

# Add a user for running things as non-superuser
RUN useradd -ms /bin/bash worker

# Install yq cli
ADD https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 /tmp/yq_linux_amd64
RUN install /tmp/yq_linux_amd64 /usr/local/bin/yq && \
  yq --version && \
  rm -f /tmp/yq_linux_amd64


ADD resource/ /opt/resource/
RUN chmod +x /opt/resource/*

WORKDIR /
ENTRYPOINT ["/bin/bash"]