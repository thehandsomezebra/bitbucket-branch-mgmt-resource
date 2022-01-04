FROM ubuntu

ENV COLUMNS=80

# COLUMNS var added to work around certain cli's needing a terminal size specified

# base packages
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -yy wget gnupg \
    && wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update && apt-get install -yy \
      curl \
      git \
      jq \
      file \
      autoconf \
      build-essential \
      bzip2 \
      certstrap \
      concourse-fly \
      hub \
      libreadline8 \
      libreadline-dev \
      libsqlite3-dev \
      libssl-dev \
      libtool \
      libxml2-dev \
      libxslt-dev \
      libyaml-dev \
      lsof \
      om \
      openssl \
      pivnet-cli \
      ruby \
      ruby-dev \
      sipcalc \
      spruce \
      sqlite3 \
      vim-common \
      wget \
      unzip \
      zlib1g-dev \
      zlibc \
    && rm -rf /var/lib/apt/lists/*



# Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install git-lfs && \
    git lfs install

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